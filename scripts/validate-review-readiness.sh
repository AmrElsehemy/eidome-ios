#!/bin/bash
set -euo pipefail

ICON="Eidome/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
MANIFEST="Eidome/PrivacyInfo.xcprivacy"

test -s "$ICON"
test -s "$MANIFEST"
plutil -lint "$MANIFEST"

WIDTH=$(sips -g pixelWidth "$ICON" | awk '/pixelWidth/ {print $2}')
HEIGHT=$(sips -g pixelHeight "$ICON" | awk '/pixelHeight/ {print $2}')

if [[ "$WIDTH" != "1024" || "$HEIGHT" != "1024" ]]; then
  echo "App Store icon must be exactly 1024x1024; found ${WIDTH}x${HEIGHT}."
  exit 1
fi

grep -Eq '"filename"[[:space:]]*:[[:space:]]*"AppIcon\.png"' Eidome/Assets.xcassets/AppIcon.appiconset/Contents.json
grep -q 'NSPrivacyAccessedAPICategoryUserDefaults' "$MANIFEST"

if grep -RniE 'TWIN v0\.|beta|demo' Eidome --include='*.swift'; then
  echo "Customer-facing prototype language found."
  exit 1
fi

echo "Review-readiness assets validated."
