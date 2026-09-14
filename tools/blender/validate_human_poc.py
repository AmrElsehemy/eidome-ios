"""Validate generated Eidome avatar geometry and export artifacts.

Run inside Blender after opening the generated .blend file.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import bpy
from mathutils import Vector


def parse_arguments() -> argparse.Namespace:
    arguments = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--human-name", required=True)
    parser.add_argument("--glb", required=True)
    parser.add_argument("--preview", required=True)
    parser.add_argument("--report", required=True)
    return parser.parse_args(arguments)


def world_bounds(obj: bpy.types.Object) -> tuple[Vector, Vector]:
    evaluated = obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
    corners = [evaluated.matrix_world @ Vector(corner) for corner in evaluated.bound_box]
    minimum = Vector(tuple(min(point[index] for point in corners) for index in range(3)))
    maximum = Vector(tuple(max(point[index] for point in corners) for index in range(3)))
    return minimum, maximum


def evaluated_geometry(
    obj: bpy.types.Object,
) -> tuple[list[Vector], list[tuple[int, int]]]:
    """Return a stable snapshot of evaluated local-space mesh geometry."""
    depsgraph = bpy.context.evaluated_depsgraph_get()
    evaluated = obj.evaluated_get(depsgraph)
    mesh = evaluated.to_mesh()
    try:
        vertices = [vertex.co.copy() for vertex in mesh.vertices]
        edges = [tuple(edge.vertices) for edge in mesh.edges]
        return vertices, edges
    finally:
        evaluated.to_mesh_clear()


def deformation_metrics(obj: bpy.types.Object) -> dict[str, float]:
    """Measure armature deformation without assuming raw/evaluated topology matches.

    MPFB's body contains topology-changing helper/mask modifiers. Comparing its raw
    mesh directly with Blender's fully evaluated mesh therefore rejects healthy
    avatars. Instead, evaluate the same modifier stack twice—with armature
    modifiers disabled and enabled—and compare those two compatible meshes.
    """
    armature_modifiers = [modifier for modifier in obj.modifiers if modifier.type == "ARMATURE"]
    if not armature_modifiers:
        raise RuntimeError("Human mesh has no armature modifier to validate.")

    original_states = [modifier.show_viewport for modifier in armature_modifiers]
    try:
        for modifier in armature_modifiers:
            modifier.show_viewport = False
        bpy.context.view_layer.update()
        rest_vertices, rest_edges = evaluated_geometry(obj)

        for modifier, state in zip(armature_modifiers, original_states, strict=True):
            modifier.show_viewport = state
        bpy.context.view_layer.update()
        posed_vertices, posed_edges = evaluated_geometry(obj)
    finally:
        for modifier, state in zip(armature_modifiers, original_states, strict=True):
            modifier.show_viewport = state
        bpy.context.view_layer.update()

    if len(rest_vertices) != len(posed_vertices) or rest_edges != posed_edges:
        raise RuntimeError(
            "Body topology changed when armature evaluation was toggled; "
            "deformation cannot be compared safely."
        )

    ratios: list[float] = []
    for first, second in rest_edges:
        rest_length = (rest_vertices[first] - rest_vertices[second]).length
        if rest_length <= 1e-8:
            continue
        posed_length = (posed_vertices[first] - posed_vertices[second]).length
        ratios.append(posed_length / rest_length)

    if not ratios:
        raise RuntimeError("No body edges were available for deformation validation.")

    ratios.sort()
    percentile_index = min(len(ratios) - 1, int(len(ratios) * 0.999))
    return {
        "maximum_edge_stretch": ratios[-1],
        "p99_9_edge_stretch": ratios[percentile_index],
    }


def main() -> None:
    args = parse_arguments()
    glb = Path(args.glb).expanduser().resolve()
    preview = Path(args.preview).expanduser().resolve()
    report_path = Path(args.report).expanduser().resolve()

    body = bpy.data.objects.get(args.human_name)
    if body is None or body.type != "MESH":
        raise RuntimeError(f"Human mesh {args.human_name!r} was not found.")

    meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    armatures = [obj for obj in bpy.context.scene.objects if obj.type == "ARMATURE"]
    if len(meshes) < 3:
        raise RuntimeError(f"Expected body, eyes, and clothing meshes; found {len(meshes)}.")
    if len(armatures) != 1:
        raise RuntimeError(f"Expected exactly one armature; found {len(armatures)}.")

    minimum, maximum = world_bounds(body)
    dimensions = maximum - minimum
    height = dimensions.z
    width_to_height = dimensions.x / height if height else 0.0
    deformation = deformation_metrics(body)

    if not 0.15 <= width_to_height <= 1.10:
        raise RuntimeError(f"Implausible body width/height ratio: {width_to_height:.3f}.")
    if deformation["p99_9_edge_stretch"] > 2.0:
        raise RuntimeError(
            "Pathological mesh deformation detected: "
            f"99.9th-percentile edge stretch is {deformation['p99_9_edge_stretch']:.3f}x."
        )
    if deformation["maximum_edge_stretch"] > 8.0:
        raise RuntimeError(
            "Pathological mesh deformation detected: "
            f"maximum edge stretch is {deformation['maximum_edge_stretch']:.3f}x."
        )

    if not glb.is_file() or glb.stat().st_size < 100_000:
        raise RuntimeError("GLB output is missing or unexpectedly small.")
    if not preview.is_file() or preview.stat().st_size < 10_000:
        raise RuntimeError("Preview output is missing or unexpectedly small.")

    image = bpy.data.images.load(str(preview), check_existing=False)
    try:
        preview_size = list(image.size)
    finally:
        bpy.data.images.remove(image)
    if preview_size != [900, 1400]:
        raise RuntimeError(f"Unexpected preview dimensions: {preview_size}.")

    report = {
        "status": "passed",
        "human": args.human_name,
        "mesh_count": len(meshes),
        "armature_count": len(armatures),
        "body_height": height,
        "body_width_to_height": width_to_height,
        "glb_bytes": glb.stat().st_size,
        "preview_bytes": preview.stat().st_size,
        "preview_size": preview_size,
        **deformation,
    }
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("Eidome avatar validation passed")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
