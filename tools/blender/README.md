# Eidome Blender pipeline

This directory contains the reproducible source-asset pipeline for Eidome's
human avatar. The large third-party Blender sources and generated reports stay
outside Git and are stored under `.eidome-assets/`.

## 1. Inspect the anatomy source

Requirements:

- macOS
- Blender installed in `/Applications/Blender.app`
- `curl` and `unzip` (included with macOS)

From the repository root, run:

```bash
bash tools/blender/bootstrap_z_anatomy.sh
```

The command downloads the pinned prototype source when it is missing, opens it
headlessly in Blender, and writes:

```text
.eidome-assets/reports/z-anatomy-inventory.json
```

The first run downloads approximately 87 MB and extracts a Blender source file
of approximately 307 MB. The inspection is read-only and never saves over the
source file.

## 2. Generate the realistic exterior POC

Install the free MPFB extension once:

1. Open Blender.
2. Choose **Edit > Preferences > Get Extensions**.
3. Search for **MPFB**, install it, and make sure it is enabled.
4. Download the **makehuman system assets** pack from the official MPFB asset packs page.
5. In Blender's MPFB panel, open **Apply Assets > Library Settings**, choose
   **Load pack from zip file**, and select the downloaded pack without
   extracting it.
6. Restart Blender so the extension and asset index are fully loaded.

Then pull this branch and run:

```bash
bash tools/blender/build_human_poc.sh \
  --name "Amr" \
  --sex male \
  --age 40 \
  --height-cm 175 \
  --weight-kg 75
```

This creates:

```text
.eidome-assets/generated/human-poc/eidome-human-poc.blend
.eidome-assets/generated/human-poc/eidome-human-poc.glb
.eidome-assets/generated/human-poc/eidome-human-poc.png
```

The generator automatically uses a suitable installed skin and the system
high-poly eyes. If the asset pack is missing, its console summary explicitly
reports that it fell back to the study material and could not find eyes.

The `.blend` file is the editable source, the `.glb` is the mobile interchange
asset, and the `.png` is a quick visual checkpoint. These outputs are local and
must not be committed.

The current measurement mapping is intentionally marked as **estimated**. It
uses height directly and derives a normalized body-shape input from BMI. Later
versions will add waist, chest, hip, limb, and scan-driven controls.

If Blender is installed elsewhere, prefix either command with:

```bash
BLENDER_BIN="/path/to/blender"
```

Do not commit downloaded sources, reports, or generated intermediate assets.
