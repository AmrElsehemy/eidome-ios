# Eidome engineering guidance

Eidome is a body-centric athletic digital-twin app. The body is the interface; the product beneath it is a progressively personalized model of structure, mobility, physiology, movement and performance.

## Product rule

Every feature must contribute at least one of these: a measurable metric, a model input, an interpretable insight or a coaching action. Do not add generic fitness-dashboard features.

## Trust rule

All twin data must remain distinguishable as measured, derived or estimated. Never imply medical accuracy from a parametric body model.

## v0.04 boundary

Keep v0.04 focused on interactive anatomical layers, measured mobility and a reusable review-ready foundation. Anatomy is a visual reference with estimated proportions, not a scan of the user's internal structures. HealthKit, accounts, video analysis and cloud infrastructure belong to later versions.

## Release rule

- Privacy and support must be reachable before personal data entry.
- Every profile and all local data must be deletable in-app.
- Customer-facing UI must not contain beta/demo or internal milestone labels.
- Any new protected data source must add its permission purpose, privacy declaration and denial path in the same change.

## Technical direction

- Native SwiftUI app with SceneKit for the initial parametric model
- iOS 17 minimum
- Bundle identifier `ai.knowlly.eidome`
- Keep `TwinProfile` independent from account/user concepts
- Preserve local profile data across refactors
- Prefer semantic SwiftUI controls and accessible Dynamic Type
- Use the Eidome design tokens rather than introducing ad hoc colors
