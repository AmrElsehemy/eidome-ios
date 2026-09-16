# Third-party 3D assets

This file records the provenance of third-party assets used by Eidome. It is
not legal advice or a substitute for a distribution-licensing review.

## MPFB / MakeHuman exterior human

- Project: MPFB / MakeHuman Plugin for Blender
- Source: https://github.com/makehumancommunity/mpfb2
- Current use: generate the bundled exterior prototype
- Bundled file: `Eidome/Resources/Models/eidome-human.usdz`
- Minimum documented Blender version: 4.2
- Prototype skin: `toigo_light_skin_male_bronze`
- Skin source pack: MakeHuman Skins 02
- Skin licence: CC0
- Prototype clothing: `elvs_male_swim_shorts1`
- Clothing source pack: MakeHuman Pants 03
- Clothing author: Elvaerwyn
- Clothing licence: CC BY

MPFB code and generated-asset licensing are distinct. Preserve the clothing
author attribution and verify the exact extension, eyes, body assets, textures,
and proxy licences before public or commercial distribution.

## Z-Anatomy skeletal and muscular layers

- Project: Z-Anatomy / Models of Human Anatomy
- Source: https://github.com/Z-Anatomy/Models-of-human-anatomy
- Prototype source file: `Z-Anatomy.zip` / `Startup.blend`
- Pinned revision: `b9c9f98066e1e786814603b047c5bd3638c2a864`
- Repository declaration: CC BY-SA 4.0
- Upstream foundation: BodyParts3D, CC BY-SA 2.1 Japan
- Bundled derived file: `Eidome/Resources/Models/eidome-anatomy.usdz`
- Structure manifest: `docs/asset-manifests/z-anatomy-v0.08.json`
- Included layers: 277 skeletal objects and 120 superficial muscle/fascia objects
- Shipping status: included in the v0.08 prototype

The export pipeline selects only the skeletal and superficial-muscle
hierarchies, removes guide geometry, normalizes both layers to the same frame,
and records every included source object in the manifest.

The upstream attribution file identifies some incorporated models with
non-commercial terms. The committed structure manifest is the review source of
truth; its contents and ShareAlike obligations must receive legal review before
public or commercial distribution. Retain the required attribution and licence
texts with any distributed derivative.
