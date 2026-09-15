#!/bin/bash
set -euo pipefail

ICON="Eidome/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
MANIFEST="Eidome/PrivacyInfo.xcprivacy"
PROJECT="Eidome.xcodeproj/project.pbxproj"

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
test "$(grep -c 'MARKETING_VERSION = 0.0.7;' "$PROJECT")" -eq 2
test "$(grep -c 'CURRENT_PROJECT_VERSION = 7;' "$PROJECT")" -eq 2
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
