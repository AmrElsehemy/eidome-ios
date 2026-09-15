# Automated App Store screenshots

The script creates deterministic Welcome and populated Twin screens directly under `fastlane/screenshots/en-US`:

- `iPhone-6.9-01-welcome.png`
- `iPhone-6.9-02-twin.png`
- `iPad-13-01-welcome.png`
- `iPad-13-02-twin.png`

Flat files allow Fastlane to classify screenshots by pixel dimensions.

## Generate only

Open **Actions → App Store Screenshots → Run workflow**, then download the `eidome-app-store-screenshots` artifact, or run:

```bash
bash scripts/capture-app-store-screenshots.sh
```

Override `IPHONE_SIMULATOR` or `IPAD_SIMULATOR` if local simulator names differ. Seed data exists only in Debug builds and requires `-eidomeScreenshotTwin`.

## Generate and upload

Open **Actions → App Store Connect Assets → Run workflow**, choose `upload_screenshots` or `upload_release_assets`, and type `UPLOAD`. The required secrets are documented in `APP_STORE_CONNECT_SETUP.md`.

Screenshots are replaced only by an explicitly authorized run. No workflow submits the app for review.
