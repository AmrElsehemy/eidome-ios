# Eidome v0.08

Eidome is a body-centric digital twin prototype for iPhone and iPad.

Official domain: [eidome.com](https://eidome.com)

## Open and run

1. Open `Eidome.xcodeproj` in Xcode 16 or later.
2. Select the `Eidome` target and choose your Apple Development Team under Signing & Capabilities.
3. Select an iPhone simulator or connected device.
4. Run the `Eidome` scheme.

Bundle identifier: `ai.knowlly.eidome`

## v0.08 scope

- Create a twin from name, relationship, biological sex, date of birth, height and weight
- Render a validated, bundled USDZ human avatar using native SceneKit, with the parametric body retained as a safe fallback
- Render validated Z-Anatomy skeleton and superficial-muscle USDZ layers, with procedural anatomy retained as a safe fallback
- Preserve structure-level anatomy provenance in a committed export manifest
- Deform the imported human at runtime from weight and regional body measurements
- Reopen generated USDZ assets with Apple SceneKit in CI before promotion
- Support independent Me / Child / Other profiles
- Persist profiles locally
- Show twin completeness and distinguish measured, derived and estimated data
- Add optional shoulder, chest, waist, hip, inseam, thigh and calf measurements
- Reshape the imported human live while weight and measurements are entered
- Preserve profiles created with v0.01
- Switch interactively between Body, Muscles, Skeleton and Joints
- Keep the selected anatomical layer aligned to the personalized body geometry
- Label internal anatomy as reference/estimated rather than measured
- Record left/right ankle, hip, shoulder and thoracic mobility measurements
- Delete individual profiles or all locally stored Eidome data
- Explain local data handling, child-profile handling and model limitations in-app
- Include an Apple privacy manifest for local preferences storage
- Include a production 1024×1024 App Store icon
- Validate review assets and an unsigned Release archive in CI
- Generate deterministic App Store screenshots for iPhone and iPad
- Upload App Store metadata and screenshots through explicitly confirmed Fastlane workflows
- Keep binary upload and App Review submission as separate, deliberate release actions

## Review preparation

The files in `docs/` are the source for `https://eidome.com/privacy` and
`https://eidome.com/support`. Publish both URLs and configure
`support@eidome.com` before an App Store submission.

See `APP_STORE_SUBMISSION.md` for the remaining App Store Connect work.

The avatar is a parametric estimate, not a scan or medically accurate anatomical model.
