"""Export a mobile, aligned skeletal/muscle reference from Z-Anatomy.

Run through build_anatomy_mobile.sh. The source Blender file is never saved.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import bpy
from mathutils import Matrix, Vector


SOURCE_REVISION = "b9c9f98066e1e786814603b047c5bd3638c2a864"
REFERENCE_HEIGHT_METERS = 1.72
SKELETON_COLLECTION = "1: Skeletal system"
MUSCLE_COLLECTION = "Superficial muscles"


def arguments() -> argparse.Namespace:
    values = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True)
    parser.add_argument("--skeleton-polygons", type=int, default=140_000)
    parser.add_argument("--muscle-polygons", type=int, default=180_000)
    return parser.parse_args(values)


def descendant_collections(root_name: str) -> set[bpy.types.Collection]:
    root = bpy.data.collections.get(root_name)
    if root is None:
        raise RuntimeError(f"Required Z-Anatomy collection is missing: {root_name}")

    result = {root}
    pending = list(root.children)
    while pending:
        collection = pending.pop()
        if collection in result:
            continue
        result.add(collection)
        pending.extend(collection.children)
    return result


def source_objects(layer: str) -> list[bpy.types.Object]:
    collection_name = SKELETON_COLLECTION if layer == "skeleton" else MUSCLE_COLLECTION
    allowed_collections = descendant_collections(collection_name)
    result = []
    for obj in bpy.data.objects:
        if obj.type != "MESH" or len(obj.data.polygons) == 0:
            continue
        if layer == "skeleton" and obj.name.strip().casefold() == "skeletal system.g":
            continue
        if any(collection in allowed_collections for collection in obj.users_collection):
            result.append(obj)
    return sorted(result, key=lambda item: item.name.casefold())


def world_bounds(objects: list[bpy.types.Object]) -> tuple[Vector, Vector]:
    points = []
    for obj in objects:
        points.extend(obj.matrix_world @ Vector(corner) for corner in obj.bound_box)
    if not points:
        raise RuntimeError("No geometry was selected for anatomy export.")
    minimum = Vector(tuple(min(point[index] for point in points) for index in range(3)))
    maximum = Vector(tuple(max(point[index] for point in points) for index in range(3)))
    return minimum, maximum


def prune_unrelated_objects(keep: list[bpy.types.Object]) -> None:
    retained = set(keep)
    world_matrices = {obj: obj.matrix_world.copy() for obj in keep}
    for obj in list(bpy.data.objects):
        if obj not in retained:
            bpy.data.objects.remove(obj, do_unlink=True)
    for obj, matrix in world_matrices.items():
        obj.matrix_world = matrix


def material(name: str, color: tuple[float, float, float, float], roughness: float):
    value = bpy.data.materials.new(name)
    value.diffuse_color = color
    value.use_nodes = True
    principled = value.node_tree.nodes.get("Principled BSDF")
    principled.inputs["Base Color"].default_value = color
    principled.inputs["Roughness"].default_value = roughness
    principled.inputs["Metallic"].default_value = 0.0
    return value


def copy_layer(
    name: str,
    sources: list[bpy.types.Object],
    normalization: Matrix,
    target_polygons: int,
    layer_material: bpy.types.Material,
    export_collection: bpy.types.Collection,
) -> tuple[bpy.types.Object, list[bpy.types.Object], dict]:
    root = bpy.data.objects.new(name, None)
    export_collection.objects.link(root)
    source_polygons = sum(len(obj.data.polygons) for obj in sources)
    ratio = min(1.0, target_polygons / max(source_polygons, 1))
    copies = []

    for index, source in enumerate(sources):
        mesh = source.data.copy()
        mesh.name = f"{name}_{index:04d}_{source.name}_Mesh"
        mesh.materials.clear()
        mesh.materials.append(layer_material)
        for polygon in mesh.polygons:
            polygon.material_index = 0

        copied = bpy.data.objects.new(f"{name}_{index:04d}_{source.name}", mesh)
        export_collection.objects.link(copied)
        copied.matrix_world = normalization @ source.matrix_world
        copied.parent = root
        copied.matrix_parent_inverse = root.matrix_world.inverted()
        copies.append(copied)

        if ratio < 0.995 and len(mesh.polygons) >= 120:
            modifier = copied.modifiers.new("Eidome Mobile Decimation", "DECIMATE")
            modifier.ratio = max(ratio, 0.04)
            modifier.use_collapse_triangulate = True
            bpy.ops.object.select_all(action="DESELECT")
            bpy.context.view_layer.objects.active = copied
            copied.select_set(True)
            bpy.ops.object.modifier_apply(modifier=modifier.name)
            copied.select_set(False)

    exported_polygons = sum(len(obj.data.polygons) for obj in copies)
    exported_minimum, exported_maximum = world_bounds(copies)
    return root, copies, {
        "sourceObjects": len(sources),
        "exportedObjects": len(copies),
        "sourcePolygons": source_polygons,
        "exportedPolygons": exported_polygons,
        "decimationRatio": ratio,
        "boundsMeters": {
            "minimum": list(exported_minimum),
            "maximum": list(exported_maximum),
            "size": list(exported_maximum - exported_minimum),
        },
        "sourceNames": [obj.name for obj in sources],
    }


def export_usdz(path: Path, objects: list[bpy.types.Object]) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.wm.usd_export(
        filepath=str(path),
        selected_objects_only=True,
        export_animation=False,
        export_materials=True,
        convert_orientation=True,
        export_global_forward_selection="NEGATIVE_Z",
        export_global_up_selection="Y",
    )


def main() -> None:
    args = arguments()
    output = Path(args.output).expanduser().resolve()
    output.mkdir(parents=True, exist_ok=True)

    skeleton_sources = source_objects("skeleton")
    muscle_sources = source_objects("muscles")
    if len(skeleton_sources) < 100 or len(muscle_sources) < 50:
        raise RuntimeError(
            f"Unexpected Z-Anatomy selection: {len(skeleton_sources)} skeleton, "
            f"{len(muscle_sources)} muscle objects."
        )

    # Z-Anatomy's full scene contains unrelated curve dependencies. Retaining
    # only the two requested mesh hierarchies prevents those dependencies from
    # entering Blender's graph during the mobile decimation pass.
    prune_unrelated_objects([*skeleton_sources, *muscle_sources])

    minimum, maximum = world_bounds(skeleton_sources)
    source_height = maximum.z - minimum.z
    if source_height <= 0:
        raise RuntimeError("Z-Anatomy skeleton has an invalid height.")
    scale = REFERENCE_HEIGHT_METERS / source_height
    center = Vector(((minimum.x + maximum.x) / 2, (minimum.y + maximum.y) / 2, minimum.z))
    normalization = Matrix.Scale(scale, 4) @ Matrix.Translation(-center)

    export_collection = bpy.data.collections.new("Eidome Anatomy Export")
    bpy.context.scene.collection.children.link(export_collection)
    bone = material("Eidome Bone", (0.82, 0.78, 0.64, 1.0), 0.66)
    muscle = material("Eidome Muscle", (0.56, 0.055, 0.045, 1.0), 0.58)

    skeleton_root, skeleton, skeleton_report = copy_layer(
        "EidomeSkeleton", skeleton_sources, normalization,
        args.skeleton_polygons, bone, export_collection,
    )
    muscle_root, muscles, muscle_report = copy_layer(
        "EidomeMuscles", muscle_sources, normalization,
        args.muscle_polygons, muscle, export_collection,
    )

    export_objects = [skeleton_root, muscle_root, *skeleton, *muscles]
    export_usdz(output / "eidome-anatomy.usdz", export_objects)

    report = {
        "source": ".eidome-assets/source/Z-Anatomy/Startup.blend",
        "sourceRevision": SOURCE_REVISION,
        "blenderVersion": bpy.app.version_string,
        "referenceHeightMeters": REFERENCE_HEIGHT_METERS,
        "normalizationScale": scale,
        "layers": {"skeleton": skeleton_report, "muscles": muscle_report},
    }
    (output / "eidome-anatomy-manifest.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n"
    )
    bpy.ops.wm.save_as_mainfile(filepath=str(output / "eidome-anatomy-export.blend"))
    print(json.dumps({key: {k: v for k, v in value.items() if k != "sourceNames"}
                      for key, value in report["layers"].items()}, indent=2))


if __name__ == "__main__":
    main()
