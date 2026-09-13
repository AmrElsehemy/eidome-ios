# Eidome engineering guidance

Eidome is a body-centric athletic digital-twin app. The body is the interface; the product beneath it is a progressively personalized model of structure, mobility, physiology, movement and performance.

## Product rule

Every feature must contribute at least one of these: a measurable metric, a model input, an interpretable insight or a coaching action. Do not add generic fitness-dashboard features.

## Trust rule

All twin data must remain distinguishable as measured, derived or estimated. Never imply medical accuracy from a parametric body model.

## v0.02 boundary

Keep v0.02 focused on optional body measurements, live visible reshaping, editing existing profiles, provenance and backward-compatible local persistence. HealthKit, accounts, video analysis, anatomical layers and cloud infrastructure belong to later versions.

## Technical direction

- Native SwiftUI app with SceneKit for the initial parametric model
- iOS 17 minimum
- Bundle identifier `ai.knowlly.eidome`
- Keep `TwinProfile` independent from account/user concepts
- Preserve local profile data across refactors
- Prefer semantic SwiftUI controls and accessible Dynamic Type
- Use the Eidome design tokens rather than introducing ad hoc colors
