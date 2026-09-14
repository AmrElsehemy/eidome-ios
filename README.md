# Eidome v0.03

Eidome is a body-centric digital twin prototype for iPhone and iPad.

Official domain: [eidome.com](https://eidome.com)

## Open and run

1. Open `Eidome.xcodeproj` in Xcode 16 or later.
2. Select the `Eidome` target and choose your Apple Development Team under Signing & Capabilities.
3. Select an iPhone simulator or connected device.
4. Run the `Eidome` scheme.

Bundle identifier: `ai.knowlly.eidome`

## v0.03 scope

- Create a twin from name, relationship, biological sex, date of birth, height and weight
- Render an estimated, rotatable 3D body using native SceneKit
- Support independent Me / Child / Other profiles
- Persist profiles locally
- Show twin completeness and distinguish measured, derived and estimated data
- Add optional shoulder, chest, waist, hip, inseam, thigh and calf measurements
- Reshape the twin live while measurements are entered
- Preserve profiles created with v0.01
- Switch interactively between Body, Muscles, Skeleton and Joints
- Keep the selected anatomical layer aligned to the personalized body geometry
- Label internal anatomy as reference/estimated rather than measured

The mannequin is a parametric estimate, not a scan or medically accurate anatomical model.
