# Third-party 3D assets

This notice records the provenance, licence and modifications of the third-party
3D assets distributed by Eidome. It must remain with release records and is
presented inside the app under About Eidome → Asset acknowledgements.

## Z-Anatomy / BodyParts3D anatomy derivative

- Bundled adapted work: `Eidome/Resources/Models/eidome-anatomy.usdz`
- Source: Z-Anatomy / Models of Human Anatomy
- Pinned revision: `b9c9f98066e1e786814603b047c5bd3638c2a864`
- Source and attribution notice: https://github.com/Z-Anatomy/Models-of-human-anatomy/blob/b9c9f98066e1e786814603b047c5bd3638c2a864/License.txt
- Adapted-work licence: Creative Commons Attribution-ShareAlike 4.0 International
- Licence: https://creativecommons.org/licenses/by-sa/4.0/
- Manifest: `docs/asset-manifests/z-anatomy-v0.08.json`
- Bundled USDZ checksum: `docs/asset-manifests/eidome-anatomy.sha256`
- Included export: 277 skeletal objects and 120 superficial muscle/fascia objects

Required attribution:

> Z-Anatomy — The libre 3D atlas of anatomy — CC BY-SA 4.0.

Published authors relevant to the atlas include Gauthier Kervyn (design, 3D and
anatomy), Marcin Zielinski (Blender add-on), and Lluis Vinent (Unity
development).

Z-Anatomy credits its original model as:

> BodyParts3D — The Database Center for Life Science — CC BY-SA 2.1 Japan.

Kousaku Okubo is identified as the original BodyParts3D model author. Original
data: https://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html
Licence: https://creativecommons.org/licenses/by-sa/2.1/jp/deed.en

Eidome modifications: selected the skeletal and superficial-muscle
hierarchies; removed guide geometry; decimated meshes; normalized scale and
coordinate frame; and converted the result to USDZ. No endorsement by the
original authors or licensors is implied.

Eidome v0.19 adds region and tissue filters over this same pinned derivative.
The filters reveal independently named structures already present in the
manifest; they do not add unlicensed geometry or claim that this superficial
export contains every deep anatomical structure.

The app offers the exact bundled USDZ together with a licence-and-attribution
notice through the system share sheet. This preserves a practical,
unrestricted copy path separate from App Store delivery controls. Any
redistribution or further adaptation of the anatomy model must follow CC
BY-SA 4.0. The open-content licence applies to the anatomy model, not to Eidome
application code.

## MPFB / MakeHuman exterior avatar

- Bundled file: `Eidome/Resources/Models/eidome-human.usdz`
- Generator: MPFB / MakeHuman Plugin for Blender
- Source: https://github.com/makehumancommunity/mpfb2
- MakeHuman asset licence statement: https://static.makehumancommunity.org/about/license.html
- Core body and system assets: CC0
- Skin: `toigo_light_skin_male_bronze`
- Skin author: MargaretToigo
- Skin licence: CC0
- Skin evidence: https://static.makehumancommunity.org/assets/assetpacks/skins02.html
- Clothing: `elvs_male_swim_shorts1`
- Clothing author: Elvaerwyn
- Catalogue licence label: CC BY
- Clothing evidence: https://static.makehumancommunity.org/assets/assetpacks/pants03.html
- Eyes: MPFB high-poly system asset; MPFB identifies this as part of its system
  asset pack. The MakeHuman Community states that all core assets are CC0.

The MPFB and MakeHuman program source-code licences are separate from the
generated graphics and are not applied to Eidome merely because the tools
generated the model.

## Scope screen

The committed Z-Anatomy manifest contains no exported structure name matching
kidney, cochlea, vestibular, semicircular, white matter, brain, or cranial
nerve terms. That is evidence about the selected export, not a per-vertex
provenance guarantee. See `docs/ASSET_LICENSE_AUDIT.md` for the conservative
record and remaining upstream ambiguity.
