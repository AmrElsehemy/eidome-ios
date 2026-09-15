# App Store Connect setup

Eidome's listing metadata, review notes, and screenshot pipeline live in this repository. Credentials and private contact details stay outside git.

## App record

| Field | Value |
|---|---|
| Platform | iOS |
| Name | Eidome |
| Primary language | English (U.S.) |
| Bundle ID | ai.knowlly.eidome |
| SKU | eidome-ios |
| Primary category | Health & Fitness |
| Made for Kids | No |
| Copyright | 2026 Knowlly DMCC |
| Release | Manual |

Child profiles are adult-managed dependents; do not select the Kids Category.

## Public URLs

- Marketing: https://eidome.com
- Support: https://eidome.com/support
- Privacy: https://eidome.com/privacy

The support and privacy pages must remain publicly reachable over HTTPS.

## Privacy and review

Use **Data Not Collected** only while the shipping binary remains fully local, with no analytics, crash SDK, cloud sync, advertising, telemetry, account, or API data transfer. Revisit the declaration before adding HealthKit, camera/video upload, AI services, authentication, or cloud sync.

Enter a monitored review-contact name, email, and international phone number directly in App Store Connect. Private contact details are intentionally not stored in git. No reviewer login is required.

## API key and automated listing upload

Create an App Store Connect team API key and add these GitHub repository secrets:

- `ASC_KEY_ID`
- `ASC_ISSUER_ID`
- `ASC_KEY_CONTENT_BASE64`

Encode the downloaded key locally:

```bash
base64 < AuthKey_YOUR_KEY_ID.p8 | tr -d '\n' | pbcopy
```

Never commit or share the `.p8` key.

In GitHub, open **Actions → App Store Connect Assets → Run workflow**. Select `upload_metadata`, `upload_screenshots`, or `upload_release_assets`, then type `UPLOAD` exactly.

The workflow cannot upload a binary, submit for review, or release a version.

Local equivalents:

```bash
bundle install
bundle exec fastlane ios upload_metadata

bash scripts/capture-app-store-screenshots.sh
bundle exec fastlane ios upload_screenshots
```

## First signed build

The App Store icon is embedded in the binary and appears in App Store Connect after Apple processes the first signed upload.

1. Open `Eidome.xcodeproj`.
2. Confirm version `0.0.7`, build `7`, bundle ID `ai.knowlly.eidome`, and automatic signing.
3. Run on physical iPhone and supported iPad.
4. Choose **Product → Archive**.
5. In Organizer, choose **Validate App**, then **Distribute App → App Store Connect → Upload**.
6. Wait for processing and select the build in TestFlight/App Store Connect.

Xcode Cloud can automate future signed builds after its one-time Apple-account authorization.
