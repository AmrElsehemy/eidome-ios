"""Validate the reproducible anatomy export before it can enter the app."""

from __future__ import annotations

import argparse
import json
import zipfile
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--usdz", required=True)
    parser.add_argument("--manifest", required=True)
    args = parser.parse_args()
    usdz = Path(args.usdz)
    manifest_path = Path(args.manifest)

    if not usdz.is_file() or usdz.stat().st_size < 100_000:
        raise SystemExit("Anatomy USDZ is missing or implausibly small.")
    if usdz.stat().st_size > 35_000_000:
        raise SystemExit("Anatomy USDZ exceeds the 35 MB v0.08 mobile budget.")
    if not zipfile.is_zipfile(usdz):
        raise SystemExit("Anatomy export is not a valid USDZ zip package.")

    try:
        manifest_text = manifest_path.read_text()
    except OSError as exc:
        raise SystemExit(f"Cannot read manifest file: {exc}") from exc
    try:
        manifest = json.loads(manifest_text)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Manifest contains invalid JSON: {exc}") from exc
    required_keys = {"layers"}
    missing = required_keys - manifest.keys()
    if missing:
        raise SystemExit(f"Manifest is missing required keys: {missing}")
    layers = manifest["layers"]
    forbidden_guides = {"skeletal system.g"}
    selected_names = {
        name.strip().casefold()
        for layer in layers.values()
        for name in layer.get("sourceNames", [])
    }
    if selected_names & forbidden_guides:
        raise SystemExit("Non-anatomical guide geometry entered the export.")
    requirements = {
        "skeleton": {"minimumObjects": 200, "maximumPolygons": 170_000},
        "muscles": {"minimumObjects": 100, "maximumPolygons": 220_000},
    }
    for name, requirement in requirements.items():
        if name not in layers:
            raise SystemExit(f"Manifest is missing required layer: {name}")
        layer = layers[name]
        if layer["exportedObjects"] < requirement["minimumObjects"]:
            raise SystemExit(f"{name} contains too few objects.")
        if layer["exportedPolygons"] <= 0:
            raise SystemExit(f"{name} contains no polygons.")
        if layer["exportedPolygons"] > requirement["maximumPolygons"]:
            raise SystemExit(f"{name} exceeds its mobile polygon budget.")

    skeleton_height = layers["skeleton"]["boundsMeters"]["size"][2]
    if not 1.70 <= skeleton_height <= 1.74:
        raise SystemExit(
            f"Skeleton normalization is invalid ({skeleton_height:.3f} m high)."
        )

    skeleton_bounds = layers["skeleton"]["boundsMeters"]
    muscle_bounds = layers["muscles"]["boundsMeters"]
    lateral_axis = max(range(2), key=lambda index: skeleton_bounds["size"][index])
    skeleton_center = (
        skeleton_bounds["minimum"][lateral_axis]
        + skeleton_bounds["maximum"][lateral_axis]
    ) / 2
    skeleton_half_width = skeleton_bounds["size"][lateral_axis] / 2
    negative_coverage = (
        skeleton_center - muscle_bounds["minimum"][lateral_axis]
    ) / skeleton_half_width
    positive_coverage = (
        muscle_bounds["maximum"][lateral_axis] - skeleton_center
    ) / skeleton_half_width
    muscle_center = (
        muscle_bounds["minimum"][lateral_axis]
        + muscle_bounds["maximum"][lateral_axis]
    ) / 2
    center_offset = abs(muscle_center - skeleton_center) / skeleton_half_width
    if center_offset > 0.15:
        raise SystemExit(
            f"Muscle and skeleton centers are misaligned ({center_offset:.2f})."
        )
    if min(negative_coverage, positive_coverage) < 0.35:
        raise SystemExit(
            "Muscle layer does not cover both lateral halves "
            f"({negative_coverage:.2f}, {positive_coverage:.2f})."
        )

    print(
        json.dumps(
            {
                "sizeBytes": usdz.stat().st_size,
                "skeletonObjects": layers["skeleton"]["exportedObjects"],
                "skeletonPolygons": layers["skeleton"]["exportedPolygons"],
                "muscleObjects": layers["muscles"]["exportedObjects"],
                "musclePolygons": layers["muscles"]["exportedPolygons"],
                "muscleLateralCoverage": [negative_coverage, positive_coverage],
                "muscleCenterOffset": center_offset,
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
