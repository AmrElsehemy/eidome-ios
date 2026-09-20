# Eidome engineering guidance

Eidome is a body-centric athletic digital-twin app. The body is the interface; the product beneath it is a progressively personalized model of structure, mobility, physiology, movement and performance.

## Product rule

Eidome helps a person understand their body, why it moves the way it does, and what to improve next. The intended path is: personal data → body model → movement meaning → useful action.

Every feature must contribute at least one of these: a measurable metric, a model input, an interpretable insight or a coaching action. Do not add generic fitness-dashboard features, decorative anatomy, or technical model controls without a clear user purpose.

## Trust rule

All twin data must remain distinguishable as measured, derived or estimated. Never imply medical accuracy from a parametric body model.

## v0.15 boundary

Keep v0.15 focused on a dependable persistent 3D workspace. Each profile must remember a safe rotation, target and zoom independently for Body, Muscles, Skeleton and Joints across layer changes, navigation, backgrounding and relaunch.

Reset view must remain explicit, accessible and deterministic. Reject corrupt or unsafe saved camera values. Deleting a profile or all local data must also remove its saved 3D views. Do not add new anatomy assets or imply greater model accuracy in this release.

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
