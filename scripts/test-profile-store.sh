#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/eidome-profile-tests.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT
xcrun swiftc -parse-as-library -swift-version 5 \
  "$ROOT_DIR/Eidome/Models/TwinProfile.swift" \
  "$ROOT_DIR/Eidome/Services/ProfileStore.swift" \
  "$ROOT_DIR/tests/ProfileStoreRegression.swift" \
  -o "$TEST_DIR/profile-tests"
"$TEST_DIR/profile-tests"
