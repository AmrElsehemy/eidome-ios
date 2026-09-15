#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ASSET_ROOT="${REPOSITORY_ROOT}/.eidome-assets"
SOURCE_ROOT="${ASSET_ROOT}/source"
REPORT_ROOT="${ASSET_ROOT}/reports"
ARCHIVE_PATH="${SOURCE_ROOT}/z-anatomy.zip"
BLEND_PATH="${SOURCE_ROOT}/Z-Anatomy/Startup.blend"
SOURCE_REVISION="b9c9f98066e1e786814603b047c5bd3638c2a864"
SOURCE_URL="https://raw.githubusercontent.com/Z-Anatomy/Models-of-human-anatomy/${SOURCE_REVISION}/Z-Anatomy.zip"
DEFAULT_BLENDER_BIN="/Applications/Blender.app/Contents/MacOS/Blender"
BLENDER_EXECUTABLE="${BLENDER_BIN:-${DEFAULT_BLENDER_BIN}}"

if [[ ! -x "${BLENDER_EXECUTABLE}" ]]; then
  echo "Blender was not found at ${BLENDER_EXECUTABLE}."
  echo "Set BLENDER_BIN to the Blender executable and retry."
  exit 1
fi

mkdir -p "${SOURCE_ROOT}" "${REPORT_ROOT}"

if [[ ! -f "${BLEND_PATH}" ]]; then
  if [[ ! -f "${ARCHIVE_PATH}" ]]; then
    echo "Downloading the Z-Anatomy prototype source..."
    curl --fail --location --progress-bar "${SOURCE_URL}" --output "${ARCHIVE_PATH}"
  fi

  echo "Extracting the Blender source..."
  unzip -o "${ARCHIVE_PATH}" -d "${SOURCE_ROOT}" >/dev/null
fi

echo "Inspecting Z-Anatomy with Blender..."
"${BLENDER_EXECUTABLE}" \
  --background "${BLEND_PATH}" \
  --python "${SCRIPT_DIR}/inspect_z_anatomy.py" \
  -- \
  --output "${REPORT_ROOT}/z-anatomy-inventory.json"

echo
echo "Inventory created at:"
echo "${REPORT_ROOT}/z-anatomy-inventory.json"
