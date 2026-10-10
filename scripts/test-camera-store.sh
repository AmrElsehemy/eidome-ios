#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/eidome-camera-tests.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT
# Compile production camera data validation/storage without platform-specific renderer adapters.
python3 - "$ROOT_DIR" "$TEST_DIR" <<'PY'
from pathlib import Path
import sys
source = (Path(sys.argv[1]) / 'Eidome/Body/TwinSceneView.swift').read_text()
start = source.index('struct TwinCameraState:')
properties_end = source.index('    init?(view: SCNView)', start)
validation_start = source.index('    var isSafe: Bool', properties_end)
validation_end = source.index('    var sceneTransform:', validation_start)
store_start = source.index('enum TwinCameraStateScope:')
store_end = source.index('struct AnatomySelection:')
# Renderer adapters are excluded because SceneKit matrix components differ on macOS/iOS.
# Stored properties, isSafe and all storage methods are taken verbatim from production.
core = source[start:properties_end] + source[validation_start:validation_end] + '}\n' + source[store_start:store_end]
(Path(sys.argv[2]) / 'CameraPersistence.swift').write_text('import Foundation\n' + core)
PY
xcrun swiftc -parse-as-library -swift-version 5 \
  "$TEST_DIR/CameraPersistence.swift" "$ROOT_DIR/tests/CameraStoreRegression.swift" \
  -o "$TEST_DIR/camera-tests"
"$TEST_DIR/camera-tests"
