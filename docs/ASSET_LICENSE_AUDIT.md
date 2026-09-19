# Asset evidence audit — 2026-09-19

Status: attribution, modification notice, ShareAlike labelling, and an
unrestricted export path are implemented. Source-provenance uncertainty is
narrowed and recorded below; this document is not legal advice.

## Implemented distribution controls

1. In-app acknowledgements now contain the requested Z-Anatomy and BodyParts3D
   credits, exact licence links, source revision, and Eidome modification notice.
2. Eidome explicitly offers the bundled anatomy derivative under CC BY-SA 4.0.
3. The acknowledgements screen exports the exact bundled USDZ plus a plain-text
   licence and attribution notice using the iOS share sheet. This provides a
   copy path independent of App Store delivery controls.
4. Avatar credits identify the MakeHuman/MPFB core asset licence, MargaretToigo
   skin, and Elvaerwyn clothing.
5. CI validates that the acknowledgement and export language remain present.

## Evidence

| Component | Evidence | Finding |
| --- | --- | --- |
| MPFB core body/system assets | https://static.makehumancommunity.org/about/license.html | MakeHuman Community states all core assets are CC0. |
| MPFB high-poly eyes | MPFB source labels high-poly eyes as coming from the system asset pack | Treated as a core/system asset under the published CC0 statement. |
| `toigo_light_skin_male_bronze` | https://static.makehumancommunity.org/assets/assetpacks/skins02.html | MargaretToigo; CC0. |
| `elvs_male_swim_shorts1` | https://static.makehumancommunity.org/assets/assetpacks/pants03.html | Elvaerwyn; catalogue label “CC-BY”. The catalogue does not identify a version. |
| Z-Anatomy export | `docs/asset-manifests/z-anatomy-v0.08.json` | 277 skeletal and 120 muscle/fascia source names recorded. |
| Z-Anatomy licence | pinned `License.txt` below | Project declaration and required attribution are CC BY-SA 4.0; BodyParts3D is credited CC BY-SA 2.1 Japan. |

Pinned Z-Anatomy notice:
https://github.com/Z-Anatomy/Models-of-human-anatomy/blob/b9c9f98066e1e786814603b047c5bd3638c2a864/License.txt

Known Eidome modifications: selecting the skeletal and superficial-muscle
layers, removing guide geometry, decimating meshes, normalizing scale/frame,
and converting to USDZ.

## Restricted upstream contributions screen

The pinned Z-Anatomy notice separately identifies:

- Anatomy of the Inner Ear — University of Dundee School of Medicine —
  CC BY-NC-SA 4.0.
- Kidney — Lissie Cowley — CC BY-NC 4.0.
- Cranial Nerves and Foramina — University of Dundee, CAHID — CC BY 4.0.
- Brainder and White matter — University of Washington — no explicit licence
  stated in that notice.

No exported manifest name matches kidney, cochlea, vestibular, semicircular,
white matter, brain, or cranial nerve terms. The skeleton contains incus,
malleus, stapes, and temporal-bone entries; those are not proof of provenance
from the separately named inner-ear contribution. The upstream repository
does not provide a per-object licence map in its text inventory.

## Honest residual risk

- The name screen is not a per-vertex provenance proof. Upstream confirmation
  or inspection of the source scene's provenance metadata would strengthen it.
- The clothing catalogue says “CC-BY” without a version. Attribution is
  preserved, but the publisher should retain any licence file packaged with the
  installed asset if one is available.
- A lawyer should review the final App Store contractual setup if commercial
  risk tolerance requires an opinion. The implemented export path, attribution,
  same-licence declaration, and modification notice address the concrete
  technical distribution duties identified in the source licences.

## Decision

The repository now contains and ships the compliance material that can be
implemented in software: credits, source and licence links, modification
notice, ShareAlike declaration, and exportable model-plus-notice package. No
blanket claim that all Z-Anatomy content is non-commercial is supported. The
remaining issue is upstream provenance certainty, not missing in-app
attribution work.
