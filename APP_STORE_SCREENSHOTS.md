# Automated App Store screenshots

Open **Actions → App Store Screenshots → Run workflow**, then download the
`eidome-app-store-screenshots` artifact. The workflow captures deterministic
Welcome and populated Twin screens for iPhone 6.9-inch and iPad 13-inch.

Run locally with:

```bash
bash scripts/capture-app-store-screenshots.sh
```

Override `IPHONE_SIMULATOR` and `IPAD_SIMULATOR` when your installed Xcode
uses different simulator names. Screenshot seed data is compiled only in Debug
builds and is activated only by `-eidomeScreenshotTwin`.
