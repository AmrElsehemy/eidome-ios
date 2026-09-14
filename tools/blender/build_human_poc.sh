#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
OUTPUT_ROOT="${REPOSITORY_ROOT}/.eidome-assets/generated/human-poc"
DEFAULT_BLENDER_BIN="/Applications/Blender.app/Contents/MacOS/Blender"
BLENDER_EXECUTABLE="${BLENDER_BIN:-${DEFAULT_BLENDER_BIN}}"

if [[ ! -x "${BLENDER_EXECUTABLE}" ]]; then
  echo "Blender was not found at ${BLENDER_EXECUTABLE}."
  echo "Set BLENDER_BIN to the Blender executable and retry."
  exit 1
fi

mkdir -p "${OUTPUT_ROOT}"

"${BLENDER_EXECUTABLE}" \
  --background \
  --python "${SCRIPT_DIR}/create_human_poc.py" \
  -- \
  --output "${OUTPUT_ROOT}" \
  "$@"

echo
echo "Open the generated preview:"
echo "open \"${OUTPUT_ROOT}/eidome-human-poc.png\""
