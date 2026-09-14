# Eidome Blender pipeline

This directory contains the reproducible source-asset pipeline for Eidome's
human avatar. The large third-party Blender sources and generated reports stay
outside Git and are stored under `.eidome-assets/`.

## First inspection

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

If Blender is installed elsewhere:

```bash
BLENDER_BIN="/path/to/blender" bash tools/blender/bootstrap_z_anatomy.sh
```

Do not commit the downloaded source, reports, or generated intermediate assets.

