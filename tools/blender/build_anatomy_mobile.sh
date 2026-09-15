#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SOURCE="${REPOSITORY_ROOT}/.eidome-assets/source/Z-Anatomy/Startup.blend"
OUTPUT="${REPOSITORY_ROOT}/.eidome-assets/generated/anatomy-mobile"
BLENDER="${BLENDER_BIN:-/Applications/Blender.app/Contents/MacOS/Blender}"

if [[ ! -x "${BLENDER}" ]]; then
  echo "Blender was not found at ${BLENDER}. Set BLENDER_BIN and retry."
  exit 1
fi

if [[ ! -f "${SOURCE}" ]]; then
  bash "${SCRIPT_DIR}/bootstrap_z_anatomy.sh"
fi

mkdir -p "${OUTPUT}"
"${BLENDER}" --background "${SOURCE}" --python-exit-code 1 \
  --python "${SCRIPT_DIR}/export_anatomy_mobile.py" -- \
  --output "${OUTPUT}" "$@"

python3 "${SCRIPT_DIR}/validate_anatomy_mobile.py" \
  --usdz "${OUTPUT}/eidome-anatomy.usdz" \
  --manifest "${OUTPUT}/eidome-anatomy-manifest.json"

echo
echo "Generated anatomy proof of concept:"
echo "  ${OUTPUT}/eidome-anatomy.usdz"
echo "  ${OUTPUT}/eidome-anatomy-export.blend"
echo "  ${OUTPUT}/eidome-anatomy-manifest.json"
echo
echo "Open in Quick Look:"
echo "open \"${OUTPUT}/eidome-anatomy.usdz\""
