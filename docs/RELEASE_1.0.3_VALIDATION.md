# 1.0.3 candidate validation

Date: October 10, 2026 (Africa/Cairo). Candidate: version 1.0.3, build 23. Source branch: `release/1.0.3`, based on public-release source `release/1.0.2`; PR #78 remains open. PR #79 is a draft. Confirm build uniqueness in App Store Connect before upload.

## Implemented

- Earlier creation/privacy actions in Welcome and generation before the longer explanation in creation; missing-name guidance and accessible field/measurement labels.
- Each profile remembers its last explorer layer. Profile switches clear temporary anatomy focus, selections, hidden structures, filters and active camera control.
- Invalid saved profile selection is normalized; invalid/orphan layer preferences are discarded. Existing profile schema, measurements and camera format remain compatible.
- Deleted profiles cannot have saved camera data recreated by a delayed scene teardown/background save. Delete-all invalidates all current profiles before removing stored camera data.

## Automated evidence

- `scripts/test-profile-store.sh`: clean install, independent layers/profiles, relaunch, public-version upgrade without a layer preference, preserved measurements/mobility, stale profile IDs, invalid layer preferences, legacy migration, individual deletion and delete-all pass. Compiles production ProfileStore and TwinProfile; substitutes only the renderer layer enum and camera-cleanup boundary on the host.
- `scripts/test-camera-store.sh`: all four layers, profile/scope isolation, safe-camera validation and a simulated late write after deletion pass. Compiles production stored properties, safety validation and storage methods verbatim; excludes platform-specific SceneKit renderer adapters. This is persistence coverage, not an interactive camera-gesture test.
- Debug simulator build, unsigned Release device archive, static analysis and review-readiness validator pass with Xcode 27.0. Build/analysis use warnings as errors.
- Ten deterministic PNGs generated: Welcome, Body, Muscles, Skeleton and Joints on isolated iPhone 18 Pro Max and iPad Pro 13-inch (M5), iOS 27.0. All ten inspected visually; dimensions are 1320×2868 and 2064×2752 respectively. UI source hashes and image hashes are recorded in `asset-manifests/1.0.3-screenshots.json`. Capture predates only the invisible camera cleanup fix and final validation documents; UI source hashes still match.
- CI now runs persistence regressions for release branch pushes and release pull requests.

## Outstanding before submission

Device Hub repeatedly returned timeout/no-window errors; computer-use discovery also reported its app server exited. Interactive creation/cancel, profile switch, anatomy controls, largest Dynamic Type, VoiceOver, reduced motion and physical-device upgrade/rotation checks could not be completed through that interface. Do not treat screenshots or host persistence tests as proof of these checks. Follow the 1.0.3 acceptance steps in `APP_STORE_SUBMISSION.md`.

No new user-observation or App Store retention metrics were available in this session; first-use speed and retention improvement are not measured claims. Keep #70 open for its remaining evidence.

A signed upload, fresh screenshot upload, App Store Connect version/build verification and review submission remain outstanding. No submission or public release is claimed for 1.0.3.
