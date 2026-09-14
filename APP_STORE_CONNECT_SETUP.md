# App Store Connect setup

The secure App Store Connect browser handoff is not currently available in this workspace. Complete the one-time app record manually; the repository contains upload-ready metadata and an optional Fastlane metadata lane.

## 1. Create the app record

In App Store Connect, open **Apps**, click **+**, then **New App**:

| Field | Value |
|---|---|
| Platforms | iOS |
| Name | Eidome |
| Primary language | English (U.S.) |
| Bundle ID | ai.knowlly.eidome |
| SKU | eidome-ios |
| User access | Full Access |

The bundle ID must already exist in Certificates, Identifiers & Profiles and must match the Xcode target exactly. The name and SKU cannot be assumed available until App Store Connect accepts them.

## 2. App Information

- Primary category: Health & Fitness
- Secondary category: None
- Content rights: Eidome does not contain, show, or access third-party content
- Made for Kids: No
- Copyright: 2026 Knowlly DMCC
- Regulated medical device: No; Eidome is a fitness-education and personal-tracking product, not a medical device

Do not claim that a child profile makes the app a Kids Category app. Child profiles are controlled by the adult device owner.

## 3. Version metadata

The English (U.S.) source files are in `fastlane/metadata/en-US`.

- Support URL: https://eidome.com/support
- Marketing URL: https://eidome.com
- Privacy Policy URL: https://eidome.com/privacy
- Release: Manually release this version

Both support and privacy URLs must be public, use HTTPS, and return successful pages before submission.

## 4. App Privacy

For the current local-only build:

- Select **No, we do not collect data from this app**
- Publish the privacy response only after verifying that the shipping binary contains no analytics, crash-reporting SDK, accounts, cloud sync, API calls, advertising, or telemetry

Revisit this declaration before adding HealthKit, camera/video upload, analytics, AI services, authentication, or cloud synchronization.

## 5. Age rating and review declarations

Answer according to the shipping binary:

- User-generated content: None
- Messaging or chat: None
- Advertising: None
- Unrestricted web access: No
- Gambling, violence, sexual content, profanity, alcohol/tobacco/drugs: None
- Medical or treatment information: None
- Wellness or fitness information: Present only as basic personal tracking; no diagnosis or treatment

Use the standard Apple EULA unless legal counsel requires a custom agreement.

## 6. Review contact

Enter a monitored Knowlly contact name, email address, and phone number in international format. The app does not require sign-in, so reviewer credentials are not required. Paste `fastlane/metadata/review_information/notes.txt` into Review Notes.

## 7. Screenshots

Because the Xcode target currently supports iPhone and iPad, provide at least one screenshot for each required family. Prefer a full set showing:

1. Welcome and privacy
2. Create a Twin
3. Interactive 3D twin
4. Body layers
5. Measurements and mobility
6. Multiple profiles
7. Privacy and delete-all controls

Apple accepts one to ten screenshots per device family. Screenshots cannot contain transparency.

## 8. Build upload

1. In Xcode, select the Eidome target and your Apple Developer team.
2. Confirm automatic signing resolves `ai.knowlly.eidome`.
3. Set the marketing version and a unique build number.
4. Run on a physical iPhone and a supported iPad.
5. Choose **Product → Archive**.
6. In Organizer, run **Validate App**.
7. Choose **Distribute App → App Store Connect → Upload**.
8. Wait for processing, select the build in the app version, then complete export-compliance questions.

The project declares `ITSAppUsesNonExemptEncryption = NO`; this is correct only while Eidome uses no non-exempt encryption.

## Optional metadata upload with Fastlane

Install dependencies:

```bash
bundle install
```

Create an App Store Connect team API key manually, then store these as local environment variables or GitHub Actions secrets:

- `ASC_KEY_ID`
- `ASC_ISSUER_ID`
- `ASC_KEY_CONTENT_BASE64`

Never commit a `.p8` key. After the app record exists:

```bash
bundle exec fastlane ios metadata
```

The lane uploads text metadata only. It deliberately skips the binary and screenshots and keeps confirmation enabled.
