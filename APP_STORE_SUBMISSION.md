# Eidome App Store submission checklist

This document separates automated repository checks from work that must be
completed in Apple Developer and App Store Connect.

## Automated in CI

- Debug build for the generic iOS Simulator
- Unsigned Release archive for a generic iOS device
- Xcode static analysis with Swift warnings treated as errors
- 1024×1024 RGB App Store icon exists and is referenced by the asset catalog
- `PrivacyInfo.xcprivacy` is valid and declares Eidome's `UserDefaults` use
- Customer-facing Swift files contain no `beta`, `demo`, or milestone-version labels
- Every body-layer SF Symbol is asserted in Debug builds and has a Release fallback
- App declares that it does not use non-exempt encryption
- macOS `.DS_Store` files are ignored and never shipped

## Complete before TestFlight upload

- Archive once in Xcode with the Eidome distribution team and automatic signing
- Confirm bundle identifier `ai.knowlly.eidome`
- Confirm version/build numbers are unique in App Store Connect
- Run the complete create, edit, switch, delete-one and delete-all flows on a physical iPhone
- Test the supported iPad layouts, or change Targeted Device Family to iPhone only
- Verify VoiceOver, Dynamic Type, contrast, and reduced-motion behavior
- Publish `docs/privacy.html` at `https://eidome.com/privacy`
- Publish `docs/support.html` at `https://eidome.com/support`
- Configure and test `support@eidome.com`

## App Store Connect

- Primary category: Health & Fitness
- Do not select the Kids Category; child profiles are adult-managed dependents
- Complete the age-rating questionnaire accurately
- Supply iPhone and iPad screenshots for every supported display family
- Supply description, keywords, promotional text, copyright, support URL and privacy-policy URL
- Set App Privacy to **Data Not Collected** only while all entered data stays on-device and no SDK or service receives it
- Revisit App Privacy before adding analytics, accounts, cloud sync, HealthKit, camera/video, crash reporting, or AI services

## Suggested review notes

Eidome creates an estimated visual body model for fitness education and personal
tracking. It is not a medical device and does not diagnose or recommend
treatment. This version has no account, advertising, analytics or cloud sync;
profile data remains on-device. A device owner may create adult-managed dependent
profiles. Reviewers can create a twin without credentials, refine measurements,
record mobility, switch profiles, swipe to delete one profile, and use About
Eidome to delete all local data.

## Review smoke test

1. Launch into onboarding and open **Privacy & About**.
2. Create a twin and verify the 3D model appears.
3. Rotate and zoom the model; switch Body, Muscles, Skeleton and Joints.
4. Add body and mobility measurements and confirm they persist after relaunch.
5. Add a second profile and switch between profiles.
6. Swipe-delete one profile and confirm the warning.
7. Open **About Eidome**, inspect the privacy notice, and delete all data.
8. Confirm the app returns to onboarding with no retained profiles.
9. Confirm the Xcode console contains no missing-symbol messages. The SceneKit
   `focusItemsInRect` caching notice is simulator framework noise and is not an
   application Auto Layout or runtime failure.
