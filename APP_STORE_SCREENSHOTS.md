# Automated App Store screenshots

The script creates deterministic Welcome, Body, Muscles, Skeleton, and Joints screens directly under `fastlane/screenshots/en-US` for each supported device family:

- `iPhone-6.9-05-welcome.png`
- `iPhone-6.9-03-body.png`
- `iPhone-6.9-01-muscles.png`
- `iPhone-6.9-02-skeleton.png`
- `iPhone-6.9-04-joints.png`
- `iPad-13-05-welcome.png`
- `iPad-13-03-body.png`
- `iPad-13-01-muscles.png`
- `iPad-13-02-skeleton.png`
- `iPad-13-04-joints.png`

Flat files allow Fastlane to classify screenshots by pixel dimensions.

## Generate only

Open **Actions → App Store Screenshots → Run workflow**, then download the `eidome-app-store-screenshots` artifact, or run:

```bash
bash scripts/capture-app-store-screenshots.sh
```

Override `IPHONE_SIMULATOR` or `IPAD_SIMULATOR` with a device name or exact UUID if local simulators differ. Use a 6.9-inch iPhone and 13-inch iPad; UUIDs avoid selecting an older runtime with the same device name. Seed data exists only in Debug builds and requires `-eidomeScreenshotTwin`. The layer flags choose Body, Muscles, Skeleton, or Joints without changing production behavior.

The workflow runs automatically for release branch pull requests and remains available through manual dispatch.

## Generate and upload

Open **Actions → App Store Connect Assets → Run workflow**, choose `upload_screenshots` or `upload_release_assets`, and type `UPLOAD`. The required secrets are documented in `APP_STORE_CONNECT_SETUP.md`.

Screenshots are replaced only by an explicitly authorized run. No workflow submits the app for review.
