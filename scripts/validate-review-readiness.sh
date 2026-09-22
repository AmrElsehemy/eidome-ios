#!/bin/bash
set -euo pipefail

ICON="Eidome/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
MANIFEST="Eidome/PrivacyInfo.xcprivacy"
PROJECT="Eidome.xcodeproj/project.pbxproj"
HUMAN_MODEL="Eidome/Resources/Models/eidome-human.usdz"
ANATOMY_MODEL="Eidome/Resources/Models/eidome-anatomy.usdz"
ANATOMY_MANIFEST="docs/asset-manifests/z-anatomy-v0.08.json"
ANATOMY_CHECKSUM="docs/asset-manifests/eidome-anatomy.sha256"
ACKNOWLEDGEMENTS="Eidome/Views/AppSettingsView.swift"
THIRD_PARTY_NOTICE="THIRD_PARTY_ASSETS.md"

test -s "$ICON"
test -s "$MANIFEST"
test -s "$HUMAN_MODEL"
test -s "$ANATOMY_MODEL"
test -s "$ANATOMY_MANIFEST"
test -s "$ANATOMY_CHECKSUM"
shasum -a 256 -c "$ANATOMY_CHECKSUM"
plutil -lint "$MANIFEST"

WIDTH=$(sips -g pixelWidth "$ICON" | awk '/pixelWidth/ {print $2}')
HEIGHT=$(sips -g pixelHeight "$ICON" | awk '/pixelHeight/ {print $2}')
if [[ "$WIDTH" != "1024" || "$HEIGHT" != "1024" ]]; then
  echo "App Store icon must be exactly 1024x1024; found ${WIDTH}x${HEIGHT}."
  exit 1
fi

grep -Eq '"filename"[[:space:]]*:[[:space:]]*"AppIcon\.png"' Eidome/Assets.xcassets/AppIcon.appiconset/Contents.json
grep -q 'NSPrivacyAccessedAPICategoryUserDefaults' "$MANIFEST"
test "$(grep -Fc 'MARKETING_VERSION = 1.0;' "$PROJECT")" -eq 2
test "$(grep -c 'CURRENT_PROJECT_VERSION = 20;' "$PROJECT")" -eq 2
test "$(grep -c 'eidome-anatomy.usdz in Resources' "$PROJECT")" -eq 2
ruby -rjson -e '
  manifest = JSON.parse(File.read(ARGV.fetch(0)))
  abort "Unexpected Z-Anatomy revision" unless manifest["sourceRevision"] == "b9c9f98066e1e786814603b047c5bd3638c2a864"
  abort "Skeleton manifest is incomplete" unless manifest.dig("layers", "skeleton", "exportedObjects").to_i >= 277
  abort "Muscle manifest is incomplete" unless manifest.dig("layers", "muscles", "exportedObjects").to_i >= 120
  names = manifest.dig("layers", "muscles", "sourceNames") || []
  required_regions = {
    "calf" => ["Lateral head of gastrocnemius.l", "Medial head of gastrocnemius.l", "Tibialis anterior muscle.l"],
    "thigh" => ["Rectus femoris muscle.l", "Vastus lateralis muscle.l", "Semitendinosus muscle.l"],
    "shoulder" => ["Acromial part of deltoid muscle.l", "Descending part of trapezius muscle.l"],
    "forearm" => ["Brachioradialis muscle.l", "Extensor digitorum.l", "Humeral head of flexor carpi ulnaris.l"]
  }
  required_regions.each do |region, structures|
    missing = structures - names
    abort "Missing independently selectable #{region} structures: #{missing.join(", ")}" unless missing.empty?
  end
' "$ANATOMY_MANIFEST"
grep -q 'CC BY-SA 4.0' "$ACKNOWLEDGEMENTS"
grep -q 'Export model and licence notice' "$ACKNOWLEDGEMENTS"
grep -q 'makeAnatomyExportItems' "$ACKNOWLEDGEMENTS"
grep -q 'Eidome modifications' "$THIRD_PARTY_NOTICE"
grep -q 'unrestricted copy path' "$THIRD_PARTY_NOTICE"
grep -q 'TwinCameraStateStore' Eidome/Body/TwinSceneView.swift
grep -q 'eidome.camera-state.v2' Eidome/Body/TwinSceneView.swift
grep -q 'case refinePreview = "refine-preview"' Eidome/Body/TwinSceneView.swift
grep -q 'case mobilityEditor = "mobility-editor"' Eidome/Body/TwinSceneView.swift
grep -q 'cameraStateScope: .explorer' Eidome/Views/TwinHomeView.swift
grep -q 'cameraStateScope: .refinePreview' Eidome/Views/TwinHomeView.swift
grep -q 'cameraStateScope: .mobilityEditor' Eidome/Views/MobilityEditorView.swift
grep -q 'guard selectedMode == .anatomy else { return availableStructures }' Eidome/Views/TwinHomeView.swift
grep -q 'hidesSelectableStructures: selectedMode == .body' Eidome/Views/TwinHomeView.swift
grep -q 'node.isHidden = hidesSelectableStructures' Eidome/Body/TwinSceneView.swift
grep -q 'normalizeSelectableNodeNames' Eidome/Body/TwinSceneView.swift
grep -q 'DispatchQueue.main.async { \[weak coordinator\]' Eidome/Body/TwinSceneView.swift
grep -q 'Structure list unavailable' Eidome/Views/TwinHomeView.swift
grep -q 'accessibilityLabel("Why this view matters")' Eidome/Views/TwinHomeView.swift
grep -q 'presentationDetents(\[.medium, .large\])' Eidome/Views/TwinHomeView.swift
grep -q 'sheet(item: \$explorerHelpProfile)' Eidome/Views/TwinHomeView.swift
test "$(grep -c 'allowsCameraControl: isSceneCameraControlEnabled' Eidome/Views/TwinHomeView.swift)" -eq 2
grep -q 'allowsCameraControl: isSceneCameraControlEnabled' Eidome/Views/MobilityEditorView.swift
test "$(grep -c 'TwinSceneControlBar(' Eidome/Views/TwinHomeView.swift)" -eq 2
grep -q 'TwinSceneControlBar(' Eidome/Views/MobilityEditorView.swift
grep -q 'Label("Rotate 3D", systemImage: "view.3d")' Eidome/Body/TwinSceneView.swift
grep -q 'Measurements shaping this estimate' Eidome/Views/TwinHomeView.swift
grep -q 'initialGuide: requestedMeasurementGuide' Eidome/Views/TwinHomeView.swift
grep -q 'BodyMeasurementKind.allCases.filter' Eidome/Views/TwinHomeView.swift
grep -q 'didEnterBackgroundNotification' Eidome/Body/TwinSceneView.swift
grep -q 'BodyMeasurementMetadata' Eidome/Models/TwinProfile.swift
grep -q 'case shoulderWidth = "shoulderWidth"' Eidome/Models/TwinProfile.swift
grep -q 'case selfTape = "Self-measured tape"' Eidome/Models/TwinProfile.swift
grep -q 'measurementMetadata\[kind.storageKey\]' Eidome/Views/TwinHomeView.swift
grep -q 'arrow.up.and.down' Eidome/Views/TwinHomeView.swift
grep -q 'GuidedMeasurementSheet' Eidome/Views/TwinHomeView.swift
grep -q 'Guideline 2.1' fastlane/metadata/review_information/notes.txt
grep -q 'Physical-device recording' fastlane/metadata/review_information/notes.txt
grep -q 'Tap Rotate 3D' fastlane/metadata/review_information/notes.txt
grep -q -- '-eidomeScreenshotMuscles' Eidome/Views/TwinHomeView.swift
grep -q -- '-eidomeScreenshotSkeleton' Eidome/Views/TwinHomeView.swift
grep -q -- '-eidomeScreenshotJoints' Eidome/Views/TwinHomeView.swift
test "$(grep -c 'simctl io.*screenshot' scripts/capture-app-store-screenshots.sh)" -eq 5
KNOWLEDGE_COUNT=$(grep -c '^[[:space:]]*\.init(pattern:' Eidome/Views/TwinHomeView.swift)
if (( KNOWLEDGE_COUNT < 50 )); then
  echo "Anatomy knowledge catalog must contain at least 50 curated entries; found ${KNOWLEDGE_COUNT}."
  exit 1
fi
ruby -c fastlane/Fastfile

required_metadata=(
  fastlane/metadata/en-US/name.txt
  fastlane/metadata/en-US/subtitle.txt
  fastlane/metadata/en-US/description.txt
  fastlane/metadata/en-US/keywords.txt
  fastlane/metadata/en-US/support_url.txt
  fastlane/metadata/en-US/marketing_url.txt
  fastlane/metadata/en-US/privacy_url.txt
  fastlane/metadata/review_information/notes.txt
)
for file in "${required_metadata[@]}"; do
  test -s "$file" || { echo "Missing App Store metadata: $file"; exit 1; }
done

grep -qx 'https://eidome.com/support' fastlane/metadata/en-US/support_url.txt
grep -qx 'https://eidome.com' fastlane/metadata/en-US/marketing_url.txt
grep -qx 'https://eidome.com/privacy' fastlane/metadata/en-US/privacy_url.txt

if grep -RniE 'TWIN v0\.|beta|demo' Eidome --include='*.swift'; then
  echo "Customer-facing prototype language found."
  exit 1
fi

echo "Review-readiness assets validated."
