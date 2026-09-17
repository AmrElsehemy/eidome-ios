# Asset evidence audit — 2026-09-17

Status: source-document audit complete; distribution clearance remains open.
No replacement is justified solely by the evidence collected here. No models were removed.

## Verified evidence

| Component | Evidence | Finding |
| --- | --- | --- |
| MPFB core base mesh and targets | https://static.makehumancommunity.org/mpfb/faq/can_i_sell_models.html | Core assets declared CC0; generator code license is separate. Match exact installed inputs before signing off the bundled binary. |
| toigo_light_skin_male_bronze | https://static.makehumancommunity.org/assets/assetpacks/skins02.html | MargaretToigo; CC0. No replacement indicated. |
| elvs_male_swim_shorts1 | https://static.makehumancommunity.org/assets/assetpacks/pants03.html | Elvaerwyn; CC-BY. License version is not specified in the pack table. Exact asset page https://www.makehumancommunity.org/node/1321 returned 502 during audit. Retain attribution; obtain packaged license/version. |
| high-poly eyes | Recorded generation logs | Exact installed asset metadata and dependent textures not inspected. Do not mark verified solely from its name. |
| Z-Anatomy export | Committed z-anatomy-v0.08.json | 277 skeletal + 120 muscle/fascia source names checked. Names alone do not establish individual geometry provenance. |

## Z-Anatomy scope

Pinned upstream license:
https://github.com/Z-Anatomy/Models-of-human-anatomy/blob/b9c9f98066e1e786814603b047c5bd3638c2a864/License.txt

The repository declares CC BY-SA 4.0 and credits BodyParts3D under CC BY-SA 2.1 Japan.
Its separately named non-commercial contributions are Anatomy of the Inner Ear (University of Dundee School of Medicine, CC BY-NC-SA 4.0) and Kidney (Lissie Cowley, CC BY-NC 4.0).
Cranial Nerves and Foramina is credited to University of Dundee, CAHID, CC BY 4.0.
Brainder and White matter credits University of Washington without an explicit license in that list.

No exported names match kidney, cochlea, vestibular, semicircular, white matter, brain or cranial nerve terms. This is a name-screening result, NOT proof that adapted geometry is absent.
The skeleton does contain left/right incus, malleus, stapes and temporal bones. Do not delete these based only on their proximity to the ear, or presume that their provenance matches a differently named upstream contribution.

No per-object license mapping was found in the pinned repository's text-file inventory. The binary source scene and exact installed avatar asset headers remain necessary evidence.

## Exact closure requirements

1. Inspect the source scene's provenance/custom properties or obtain upstream confirmation that the 397 exported objects exclude the separately credited restricted contributions. If any overlap is confirmed, address only those objects.
2. Capture the installed shorts license/version, high-poly eye mesh and texture notices, and any pose/proxy actually baked into the final avatar. Match them to the bundled USDZ rather than to the latest available generator.
3. Supply full applicable credits, source/license links and modification notices in the distributed acknowledgements. Credits include BodyParts3D — The Database Center for Life Science; Z-Anatomy; Elvaerwyn.
4. Review ShareAlike and downstream distribution terms for the anatomy derivative, including App Store restrictions. Documentation alone does not resolve this. CC BY-SA 4.0 reference: https://creativecommons.org/licenses/by-sa/4.0/
5. Archive the evidence with the release artifact and record its hash. Do not label the release cleared before these items are satisfied.

Known export modifications: selecting the skeletal and superficial-muscle layers, removing guide geometry, decimating meshes, normalizing scale/frame and converting to USDZ. Verify any subsequent modifications against the final export.

## Decision

Keep the current assets in development. Do not commission or buy replacements based on a blanket claim that Z-Anatomy is non-commercial. Do not submit this audit as proof of App Store clearance. The remaining work is narrowly scoped provenance and distribution compliance, not an established need to replace the avatar or entire anatomy atlas.
