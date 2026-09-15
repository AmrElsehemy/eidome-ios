"""Generate Eidome's first realistic exterior-human proof of concept.

Requires the MPFB Blender extension. The script is intended to be run through
build_human_poc.sh, not from Blender's scripting workspace.
"""

from __future__ import annotations

import argparse
import importlib
import re
import sys
from pathlib import Path

import bpy
from mathutils import Vector


def parse_arguments() -> argparse.Namespace:
    arguments = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True)
    parser.add_argument("--name", default="Eidome Human")
    parser.add_argument("--sex", choices=("female", "male"), default="male")
    parser.add_argument("--age", type=float, default=40.0)
    parser.add_argument("--height-cm", type=float, default=175.0)
    parser.add_argument("--weight-kg", type=float, default=75.0)
    parser.add_argument("--muscle", type=float, default=0.55)
    parser.add_argument(
        "--skin-query",
        default=None,
        help="Case-insensitive substring used to choose an installed MPFB skin.",
    )
    parser.add_argument(
        "--clothes-query",
        default=None,
        help="Case-insensitive substring used to choose installed MPFB clothing.",
    )
    return parser.parse_args(arguments)


def clamp(value: float, minimum: float = 0.0, maximum: float = 1.0) -> float:
    return max(minimum, min(maximum, value))


def dynamic_import(package_suffix: str, symbol: str):
    for module_name in tuple(sys.modules):
        if module_name.endswith(package_suffix):
            module = importlib.import_module(module_name)
            return getattr(module, symbol)
    raise RuntimeError(
        "MPFB is not enabled. In Blender open Preferences > Get Extensions, "
        "install MPFB, enable it, close Blender, and run this command again."
    )


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def set_studio_material(human: bpy.types.Object) -> None:
    material = bpy.data.materials.new("Eidome Skin Preview")
    if material.node_tree is None:
        material.use_nodes = True
    principled = material.node_tree.nodes.get("Principled BSDF")
    # Until textured skin and eyes are installed, present the body as an
    # intentional warm anatomical study rather than uncanny synthetic skin.
    principled.inputs["Base Color"].default_value = (0.18, 0.055, 0.025, 1.0)
    principled.inputs["Roughness"].default_value = 0.62
    human.data.materials.clear()
    human.data.materials.append(material)


def has_label(path: str, label: str) -> bool:
    # Asset names use separators such as underscores and slashes. Matching
    # labels as tokens prevents "male" from matching inside "female".
    return re.search(
        rf"(?<![a-z]){re.escape(label.casefold())}(?![a-z])",
        path.casefold(),
    ) is not None


def preferred_skin(
    paths: list[str],
    sex: str,
    age: float,
    skin_query: str | None,
) -> str | None:
    if not paths:
        return None

    opposite_sex = "female" if sex == "male" else "male"
    compatible = [
        path
        for path in paths
        if has_label(path, sex) or not has_label(path, opposite_sex)
    ]
    if not compatible:
        return None

    if skin_query:
        query = skin_query.casefold()
        matches = [path for path in compatible if query in path.casefold()]
        if not matches:
            available = ", ".join(sorted(Path(path).stem for path in compatible))
            raise RuntimeError(
                f"No installed {sex} or neutral skin matches {skin_query!r}. "
                f"Available compatible skins: {available or 'none'}"
            )
        return sorted(matches, key=str.casefold)[0]

    age_term = "young" if age < 35 else "middleage" if age < 60 else "old"
    unsafe_terms = ("genital", "tattoo", "makeup", "eyeliner", "goth", "emo")
    ranked = sorted(
        compatible,
        key=lambda path: (
            sum(term in path.lower() for term in unsafe_terms),
            -sum(term in path.lower() for term in (sex, age_term)),
            path.casefold(),
        ),
    )
    return ranked[0]


def preferred_clothes(
    paths: list[str],
    sex: str,
    clothes_query: str | None,
) -> str | None:
    if not clothes_query:
        return None

    opposite_sex = "female" if sex == "male" else "male"
    compatible = [
        path
        for path in paths
        if has_label(path, sex) or not has_label(path, opposite_sex)
    ]
    query = clothes_query.casefold()
    matches = [path for path in compatible if query in path.casefold()]
    if not matches:
        available = ", ".join(sorted(Path(path).stem for path in compatible))
        raise RuntimeError(
            f"No installed {sex} or neutral clothing matches {clothes_query!r}. "
            f"Available compatible clothes: {available or 'none'}"
        )
    return sorted(matches, key=str.casefold)[0]


def apply_installed_assets(
    human: bpy.types.Object,
    sex: str,
    age: float,
    skin_query: str | None,
    clothes_query: str | None,
    AssetService,
    HumanService,
) -> dict[str, str]:
    """Add optional MPFB system assets when they are installed locally."""
    applied: dict[str, str] = {}
    skins = [str(path) for path in AssetService.list_mhmat_assets("skins")]
    skin = preferred_skin(skins, sex, age, skin_query)
    if skin:
        HumanService.set_character_skin(
            skin,
            human,
            bodyproxy=None,
            skin_type="GAMEENGINE",
            material_instances=False,
        )
        applied["skin"] = skin
    else:
        set_studio_material(human)

    eyes = AssetService.find_asset_absolute_path(
        "high-poly/high-poly.mhclo",
        "eyes",
    )
    if eyes:
        HumanService.add_mhclo_asset(
            eyes,
            human,
            asset_type="eyes",
            subdiv_levels=0,
            material_type="GAMEENGINE",
        )
        applied["eyes"] = str(eyes)

    clothes = preferred_clothes(
        [str(path) for path in AssetService.list_mhclo_assets("clothes")],
        sex,
        clothes_query,
    )
    if clothes:
        HumanService.add_mhclo_asset(
            clothes,
            human,
            asset_type="Clothes",
            subdiv_levels=0,
            material_type="GAMEENGINE",
        )
        applied["clothes"] = clothes

    return applied



def make_usdz_material(
    name: str,
    color: tuple[float, float, float, float],
    roughness: float,
) -> bpy.types.Material:
    """Create a deliberately simple Apple-compatible PBR material."""
    material = bpy.data.materials.new(name)
    material.diffuse_color = color
    if material.node_tree is None:
        material.use_nodes = True
    node_tree = material.node_tree
    node_tree.nodes.clear()
    output = node_tree.nodes.new("ShaderNodeOutputMaterial")
    principled = node_tree.nodes.new("ShaderNodeBsdfPrincipled")
    principled.inputs["Base Color"].default_value = color
    principled.inputs["Roughness"].default_value = roughness
    principled.inputs["Metallic"].default_value = 0.0
    node_tree.links.new(principled.outputs["BSDF"], output.inputs["Surface"])
    return material


def export_static_usdz(
    output_path: Path,
    human: bpy.types.Object,
) -> None:
    """Bake evaluated meshes before USDZ export.

    SceneKit interpreted MPFB's armature/skinning transforms differently from
    Blender, producing severe stretching even though the Blender scene was
    healthy. v0.05 does not animate the exterior avatar, so export only the
    evaluated static geometry and simple PBR materials. The rig remains in the
    .blend and GLB for future animation work.
    """
    depsgraph = bpy.context.evaluated_depsgraph_get()
    sources = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    if len(sources) < 3:
        raise RuntimeError("Static USDZ export requires body, eyes, and clothing meshes.")

    skin = make_usdz_material("Eidome_USDZ_Skin", (0.43, 0.20, 0.11, 1.0), 0.58)
    eyes = make_usdz_material("Eidome_USDZ_Eyes", (0.72, 0.76, 0.78, 1.0), 0.34)
    clothes = make_usdz_material("Eidome_USDZ_Shorts", (0.018, 0.045, 0.075, 1.0), 0.72)

    baked: list[tuple[bpy.types.Object, bpy.types.Mesh]] = []
    try:
        for source in sources:
            evaluated = source.evaluated_get(depsgraph)
            mesh = bpy.data.meshes.new_from_object(
                evaluated,
                preserve_all_data_layers=True,
                depsgraph=depsgraph,
            )
            mesh.name = f"{source.name}_USDZ_Mesh"
            mesh.materials.clear()

            source_name = source.name.casefold()
            if source == human:
                material = skin
            elif "eye" in source_name or "high-poly" in source_name:
                material = eyes
            else:
                material = clothes
            mesh.materials.append(material)
            for polygon in mesh.polygons:
                polygon.material_index = 0

            baked_object = bpy.data.objects.new(f"{source.name}_USDZ", mesh)
            bpy.context.collection.objects.link(baked_object)
            baked_object.matrix_world = source.matrix_world.copy()
            baked.append((baked_object, mesh))

        bpy.ops.object.select_all(action="DESELECT")
        for baked_object, _ in baked:
            baked_object.select_set(True)
        bpy.context.view_layer.objects.active = baked[0][0]
        bpy.ops.wm.usd_export(
            filepath=str(output_path),
            selected_objects_only=True,
            export_animation=False,
        )
    finally:
        for baked_object, mesh in baked:
            bpy.data.objects.remove(baked_object, do_unlink=True)
            if mesh.users == 0:
                bpy.data.meshes.remove(mesh)

def evaluated_bounds(obj: bpy.types.Object) -> tuple[Vector, Vector]:
    evaluated = obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
    corners = [evaluated.matrix_world @ Vector(corner) for corner in evaluated.bound_box]
    minimum = Vector(tuple(min(point[index] for point in corners) for index in range(3)))
    maximum = Vector(tuple(max(point[index] for point in corners) for index in range(3)))
    return minimum, maximum


def point_at(obj: bpy.types.Object, target: Vector) -> None:
    obj.rotation_euler = (target - obj.location).to_track_quat("-Z", "Y").to_euler()


def add_area_light(name: str, location: tuple[float, float, float], energy: float, size: float, target: Vector) -> None:
    data = bpy.data.lights.new(name, type="AREA")
    data.energy = energy
    data.shape = "DISK"
    data.size = size
    light = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(light)
    light.location = location
    point_at(light, target)


def create_studio(human: bpy.types.Object) -> None:
    minimum, maximum = evaluated_bounds(human)
    center = (minimum + maximum) * 0.5
    height = maximum.z - minimum.z

    world = bpy.context.scene.world or bpy.data.worlds.new("Eidome World")
    bpy.context.scene.world = world
    if world.node_tree is None:
        world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.003, 0.012, 0.016, 1.0)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.18

    camera_data = bpy.data.cameras.new("Eidome Camera")
    camera = bpy.data.objects.new("Eidome Camera", camera_data)
    bpy.context.collection.objects.link(camera)
    # The rest pose is wider than it is tall in portrait framing. Pulling back
    # prevents hands and feet from being clipped in the checkpoint render.
    camera.location = (center.x, minimum.y - height * 2.15, center.z)
    camera_data.lens = 62
    point_at(camera, center)
    bpy.context.scene.camera = camera

    add_area_light("Key", (-height * 0.65, -height * 0.75, maximum.z), 280, height * 0.55, center)
    add_area_light("Fill", (height * 0.65, -height * 0.25, center.z), 110, height * 0.45, center)
    add_area_light("Rim", (0, height * 0.5, maximum.z * 0.9), 360, height * 0.35, center)


def select_render_engine(scene: bpy.types.Scene) -> str:
    """Use the Eevee identifier exposed by the installed Blender build."""
    for engine in ("BLENDER_EEVEE_NEXT", "BLENDER_EEVEE"):
        try:
            scene.render.engine = engine
            return engine
        except TypeError:
            continue
    raise RuntimeError("This Blender build does not expose a supported Eevee engine.")


def main() -> None:
    args = parse_arguments()
    output = Path(args.output).expanduser().resolve()
    output.mkdir(parents=True, exist_ok=True)

    HumanService = dynamic_import("mpfb.services.humanservice", "HumanService")
    TargetService = dynamic_import("mpfb.services.targetservice", "TargetService")
    HumanObjectProperties = dynamic_import("mpfb.entities.objectproperties", "HumanObjectProperties")
    AssetService = dynamic_import("mpfb.services.assetservice", "AssetService")

    clear_scene()
    human = HumanService.create_human(
        mask_helpers=True,
        detailed_helpers=False,
        extra_vertex_groups=False,
        feet_on_ground=True,
        scale=0.1,
    )
    human.name = args.name

    height_m = args.height_cm / 100.0
    bmi = args.weight_kg / (height_m * height_m)
    macro_values = {
        "gender": 1.0 if args.sex == "male" else 0.0,
        "age": clamp((args.age - 10.0) / 70.0),
        "height": clamp((args.height_cm - 150.0) / 50.0),
        "weight": clamp((bmi - 16.0) / 14.0),
        "muscle": clamp(args.muscle),
    }
    for property_name, value in macro_values.items():
        HumanObjectProperties.set_value(property_name, value, entity_reference=human)
    TargetService.reapply_macro_details(human)
    bpy.context.view_layer.update()

    # Add the mobile-oriented skeleton before body parts and clothes. MPFB then
    # binds each subsequently attached mesh to the same armature.
    rig = HumanService.add_builtin_rig(human, "game_engine", import_weights=True)

    applied_assets = apply_installed_assets(
        human,
        args.sex,
        args.age,
        args.skin_query,
        args.clothes_query,
        AssetService,
        HumanService,
    )
    create_studio(human)

    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.context.scene.objects:
        if obj.type in {"MESH", "ARMATURE"}:
            obj.select_set(True)
    bpy.context.view_layer.objects.active = human
    bpy.ops.wm.save_as_mainfile(filepath=str(output / "eidome-human-poc.blend"))
    bpy.ops.export_scene.gltf(
        filepath=str(output / "eidome-human-poc.glb"),
        export_format="GLB",
        use_selection=True,
    )
    export_static_usdz(output / "eidome-human-poc.usdz", human)

    scene = bpy.context.scene
    render_engine = select_render_engine(scene)
    scene.render.resolution_x = 900
    scene.render.resolution_y = 1400
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.filepath = str(output / "eidome-human-poc.png")
    scene.render.film_transparent = False
    scene.view_settings.exposure = -0.7
    bpy.ops.render.render(write_still=True)

    print("Generated Eidome human:")
    print(f"  Render engine: {render_engine}")
    print(f"  Installed skin: {applied_assets.get('skin', 'not found; using study material')}")
    print(f"  Installed eyes: {applied_assets.get('eyes', 'not found')}")
    print(f"  Installed clothes: {applied_assets.get('clothes', 'not requested')}")
    print(f"  Mobile rig: {rig.name}")
    print("  Pose: MPFB rest A-pose")
    print(f"  BMI-derived shape input: {bmi:.2f}")
    print(f"  Blender: {output / 'eidome-human-poc.blend'}")
    print(f"  Mobile GLB: {output / 'eidome-human-poc.glb'}")
    print(f"  Apple USDZ: {output / 'eidome-human-poc.usdz'}")
    print(f"  Preview: {output / 'eidome-human-poc.png'}")


if __name__ == "__main__":
    main()
