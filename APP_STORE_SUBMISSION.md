# Eidome App Store submission checklist

## Automated in CI

- Profile persistence/return-state regression checks
- Debug build, static analysis, and unsigned Release archive
- Version/build check for 1.0.3 (23)
- 1024×1024 icon and privacy-manifest validation
- Required listing metadata and URL validation
- Deterministic iPhone/iPad screenshots covering onboarding, Body, Muscles, Skeleton, and Joints
- Explicitly guarded metadata/screenshot uploads
- No binary upload, review submission, or automatic release

## Complete manually

- Add the three App Store Connect API values as GitHub repository secrets
- Enter review contact details in App Store Connect
- Confirm privacy/support URLs and monitored support email
- Test create, edit, switch, individual-delete, and delete-all on physical iPhone
- Test supported iPad layout or explicitly switch to iPhone-only
- Verify VoiceOver, Dynamic Type, contrast, and reduced motion
- Confirm candidate build 23 is greater than every build already uploaded; choose a higher build if needed
- Archive with automatic signing and upload the signed build
- Attach a fresh physical-device recording showing the shipping Rotate 3D interaction to the Resolution Center reply
- Complete age rating, privacy, and export-compliance answers from the shipping binary

## Review smoke test

1. Launch onboarding and open **Privacy & About**.
2. Create a twin and confirm the 3D model appears.
3. Confirm the page scrolls over the model before camera control is enabled.
4. Tap Rotate 3D, rotate/zoom, Reset, then tap Done and immediately scroll the page.
5. Switch Body, Muscles, Skeleton, and Joints; browse and select named structures.
6. Add body/mobility measurements and verify persistence.
7. Add and switch to a second profile.
8. Delete one profile and confirm the warning.
9. Delete all data in **About Eidome**.
10. Confirm the app returns to onboarding.
11. Confirm no missing-symbol or application Auto Layout errors.

SceneKit's `focusItemsInRect` simulator notice is framework noise, not an app failure.

## 1.0.3 return-experience acceptance

- Clean install: Privacy & About and support before entry; creation with a blank name explains the missing input; Cancel returns to Welcome; valid creation opens Body.
- Upgrade from 1.0.2: profile IDs, measurements, mobility values and saved camera views survive. Until a layer is chosen, the profile opens Body.
- Choose a different layer for two profiles, rotate/zoom each, background/relaunch, switch between them and confirm the selected profile, last layer and each saved camera view.
- Select/focus/hide anatomy, open filters and enable Rotate 3D, then switch profiles: transient anatomy state clears and page scrolling works immediately.
- Delete the selected profile: the remaining profile opens its own layer. Delete all: Welcome returns; relaunch remains empty.
- Verify small iPhone and iPad, largest accessibility text, VoiceOver focus order/labels, and Reduce Motion.
- Review updated iPhone/iPad screenshots and available retention/feedback evidence. Record missing metrics rather than inventing results.
