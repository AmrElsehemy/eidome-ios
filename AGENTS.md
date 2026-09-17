# Eidome engineering guidance

Eidome is a body-centric athletic digital-twin app. The body is the interface; the product beneath it is a progressively personalized model of structure, mobility, physiology, movement and performance.

## Product rule

Eidome helps a person understand their body, why it moves the way it does, and what to improve next. The intended path is: personal data → body model → movement meaning → useful action.

Every feature must contribute at least one of these: a measurable metric, a model input, an interpretable insight or a coaching action. Do not add generic fitness-dashboard features, decorative anatomy, or technical model controls without a clear user purpose.

## Trust rule

All twin data must remain distinguishable as measured, derived or estimated. Never imply medical accuracy from a parametric body model.

## v0.11 boundary

Keep v0.11 focused on making the existing explorer understandable and purposeful. Body leads to measurements, Anatomy leads to structure inspection, and Joints leads to mobility. Do not add new anatomy assets or imply deeper anatomical precision in this version.

Anatomy remains a visual reference with estimated proportions, not a scan of the user's internal structures. HealthKit, accounts, video analysis and cloud infrastructure belong to later versions.

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
