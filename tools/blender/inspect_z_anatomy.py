"""Create a deterministic inventory of the Z-Anatomy Blender source.

This script is intentionally read-only: it does not change or save the source
file. Run it through bootstrap_z_anatomy.sh rather than directly.
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from pathlib import Path

import bpy


LAYER_KEYWORDS = {
    "body": ("surface", "integument", "skin"),
    "muscles": ("muscle",),
    "skeleton": ("bone", "skeleton"),
    "joints": ("joint",),
    "connective": ("tendon", "ligament", "fascia", "cartilage"),
}


def parse_arguments() -> argparse.Namespace:
    arguments = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True)
    return parser.parse_args(arguments)


def collection_names(obj: bpy.types.Object) -> list[str]:
    return sorted(collection.name for collection in obj.users_collection)


def inferred_layers(obj: bpy.types.Object) -> list[str]:
    searchable = " ".join([obj.name, *collection_names(obj)]).lower()
    return [
        layer
        for layer, keywords in LAYER_KEYWORDS.items()
        if any(keyword in searchable for keyword in keywords)
    ]


def main() -> None:
    args = parse_arguments()
    output_path = Path(args.output).expanduser().resolve()
    output_path.parent.mkdir(parents=True, exist_ok=True)

    objects = []
    layer_counts: Counter[str] = Counter()
    total_vertices = 0
    total_polygons = 0

    for obj in sorted(bpy.data.objects, key=lambda item: item.name.casefold()):
        if obj.type != "MESH":
            continue

        vertices = len(obj.data.vertices)
        polygons = len(obj.data.polygons)
        layers = inferred_layers(obj)
        total_vertices += vertices
        total_polygons += polygons
        layer_counts.update(layers)
        objects.append(
            {
                "name": obj.name,
                "collections": collection_names(obj),
                "vertices": vertices,
                "polygons": polygons,
                "visible": not obj.hide_get(),
                "candidateLayers": layers,
            }
        )

    report = {
        "source": bpy.data.filepath,
        "blenderVersion": bpy.app.version_string,
        "summary": {
            "meshObjects": len(objects),
            "vertices": total_vertices,
            "polygons": total_polygons,
            "candidateObjectsByLayer": dict(sorted(layer_counts.items())),
        },
        "collections": sorted(collection.name for collection in bpy.data.collections),
        "objects": objects,
    }

    output_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps(report["summary"], indent=2))


if __name__ == "__main__":
    main()

