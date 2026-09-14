# Third-party 3D assets

This file records asset provenance from the first prototype. Inclusion here is
not a final commercial-licensing decision.

## MPFB exterior-human prototype

- Project: MPFB / MakeHuman Plugin for Blender
- Source: https://github.com/makehumancommunity/mpfb2
- Prototype use: generate the exterior body mesh from measurements
- Minimum documented Blender version: 4.2
- Local use: private evaluation and mobile-export spike
- Shipping status: no generated asset is included in the Eidome application yet

MPFB code and generated-asset licensing are distinct. Before distributing a
generated model, record the exact MPFB extension version and every asset pack,
skin, body part, texture, and proxy used, then verify each asset's licence.

## Z-Anatomy prototype source

- Project: Z-Anatomy / Models of Human Anatomy
- Source: https://github.com/Z-Anatomy/Models-of-human-anatomy
- Prototype source file: `Z-Anatomy.zip` / `Startup.blend`
- Pinned revision: `b9c9f98066e1e786814603b047c5bd3638c2a864`
- Repository declaration: CC BY-SA 4.0
- Upstream foundation: BodyParts3D, CC BY-SA 2.1 Japan
- Local use: private evaluation, object inventory, mobile optimization spike
- Shipping status: not included in the Eidome application

The upstream attribution file identifies some incorporated structures with
non-commercial licences, including an inner-ear model and a kidney model.
Those structures must not enter a commercial build without explicit review and
replacement or permission.

Before any derived model is distributed, create a structure-level manifest,
retain required attribution, and obtain a legal review of the ShareAlike impact.

## MPFB prototype skin and clothing

- Skin: `toigo_light_skin_male_bronze`
- Skin source pack: MakeHuman Skins 02
- Skin licence: CC0
- Clothing: `elvs_male_swim_shorts1`
- Clothing source pack: MakeHuman Pants 03
- Clothing author: Elvaerwyn
- Clothing licence: CC BY
- Prototype use: validate fitted clothing, rigging, posing, and mobile export
- Shipping status: not included in the Eidome application

If the clothing enters a distributed build, preserve the author attribution and
licence notice in the app's acknowledgements and release documentation.
