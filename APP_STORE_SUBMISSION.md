# Eidome App Store submission checklist

## Automated in CI

- Debug build, static analysis, and unsigned Release archive
- Version/build check for 0.0.7 (7)
- 1024×1024 icon and privacy-manifest validation
- Required listing metadata and URL validation
- Deterministic iPhone/iPad screenshots
- Explicitly guarded metadata/screenshot uploads
- No binary upload, review submission, or automatic release

## Complete manually

- Add the three App Store Connect API values as GitHub repository secrets
- Enter review contact details in App Store Connect
- Confirm privacy/support URLs and monitored support email
- Test create, edit, switch, individual-delete, and delete-all on physical iPhone
- Test supported iPad layout or explicitly switch to iPhone-only
- Verify VoiceOver, Dynamic Type, contrast, and reduced motion
- Archive with automatic signing and upload the signed build
- Complete age rating, privacy, and export-compliance answers from the shipping binary

## Review smoke test

1. Launch onboarding and open **Privacy & About**.
2. Create a twin and confirm the 3D model appears.
3. Rotate/zoom and switch Body, Muscles, Skeleton, and Joints.
4. Add body/mobility measurements and verify persistence.
5. Add and switch to a second profile.
6. Delete one profile and confirm the warning.
7. Delete all data in **About Eidome**.
8. Confirm the app returns to onboarding.
9. Confirm no missing-symbol or application Auto Layout errors.

SceneKit's `focusItemsInRect` simulator notice is framework noise, not an app failure.
