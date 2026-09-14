#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$ROOT_DIR/fastlane/screenshots/en-US"
DERIVED_DATA="${RUNNER_TEMP:-$ROOT_DIR/.derived-data}/eidome-screenshots"
BUNDLE_ID="ai.knowlly.eidome"

device_udid() {
  xcrun simctl list devices available | awk -v target="$1" 'index($0,target " ("){match($0,/[0-9A-F-]{36}/);if(RSTART){print substr($0,RSTART,RLENGTH);exit}}'
}

capture() {
  local name="$1" family="$2" udid
  udid="$(device_udid "$name")"
  test -n "$udid" || { echo "Simulator not found: $name"; exit 1; }
  xcrun simctl boot "$udid" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "$udid" -b
  xcrun simctl status_bar "$udid" override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4
  xcodebuild -project "$ROOT_DIR/Eidome.xcodeproj" -scheme Eidome -configuration Debug -destination "platform=iOS Simulator,id=$udid" -derivedDataPath "$DERIVED_DATA/$family" CODE_SIGNING_ALLOWED=NO clean build
  local app="$DERIVED_DATA/$family/Build/Products/Debug-iphonesimulator/Eidome.app"
  xcrun simctl uninstall "$udid" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl install "$udid" "$app"
  mkdir -p "$OUTPUT_DIR/$family"
  xcrun simctl launch "$udid" "$BUNDLE_ID"; sleep 3
  xcrun simctl io "$udid" screenshot "$OUTPUT_DIR/$family/01-welcome.png"
  xcrun simctl terminate "$udid" "$BUNDLE_ID"
  xcrun simctl launch "$udid" "$BUNDLE_ID" -eidomeScreenshotTwin; sleep 4
  xcrun simctl io "$udid" screenshot "$OUTPUT_DIR/$family/02-twin.png"
  xcrun simctl terminate "$udid" "$BUNDLE_ID"
  xcrun simctl status_bar "$udid" clear
  xcrun simctl shutdown "$udid"
}

rm -rf "$OUTPUT_DIR"
capture "${IPHONE_SIMULATOR:-iPhone 16 Pro Max}" iPhone-6.9
capture "${IPAD_SIMULATOR:-iPad Pro 13-inch (M4)}" iPad-13
