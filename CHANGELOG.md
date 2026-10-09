# Changelog

## v0.24 — Mobility entry clarity (in development)

- Explain whose left/right is being entered and distinguish unknown values from a recorded zero.
- Explain invalid values beside their fields and why Save is unavailable; reject non-finite values. The numeric limit is not presented as a normal clinical range.
- Add explicit per-side clear actions and movement/side/unit labels for assistive technology. Existing storage and profile handling are unchanged.

## v0.23 — Anatomy navigation (in development)

- Focus a selected structure, restore surrounding anatomy or clear selection beside the model. Current filters and saved camera views remain intact.
- Explain that left/right refers to the displayed body; action controls stack when horizontal space is limited.

## v0.22 — Anatomy clarity (in development)

- Put the anatomy model ahead of optional filters; expand Filters to choose a region or tissue type. The collapsed summary retains the current filter choices.
- Show selected structure names and side directly beneath the model, before the camera controls.
- Use explicit muscle/bone headings and explain that the anatomy is a reference, not a scan.

Eidome 1.0.1 is live, confirmed by the owner October 7. These changes are for the next update and have not been submitted.

## v0.21 — Discoverability and launch polish (unreleased)

Internal release label; the candidate currently uses App Store version 1.0, build 20. Confirm the next valid version and unique build in App Store Connect before upload. Merging this work is not an App Store submission or public release.

### What’s new

- Clearer, scrollable onboarding explains the body estimate, reference anatomy and mobility recording before creating a twin. Privacy & About remains available before entering personal data.
- Twin creation now explains the next steps, including switching layers and using Rotate 3D / Done to move the model and return to page scrolling.
- The default Body camera scales with profile height and uses an explicit vertical field of view, fixing cropped heads in the initial view while preserving saved camera views and explicit Reset.
- Anatomy-first listing preparation: Muscles, Skeleton, Body, Joints, then Welcome. Automated captures cover iPhone and iPad and accept exact simulator identifiers.
- Discoverability metadata prepared in #72: Eidome keeps its name, with subtitle “3D Anatomy & Body Explorer”, revised keywords and anatomy-led copy, and Education as the secondary category. These repository changes are not evidence of a live listing update.

### Validation and remaining release work

Candidate implementation: [PR #73](https://github.com/AmrElsehemy/eidome-ios/pull/73), incorporating the launch preparation from #63. Both GitHub build/archive and screenshot capture passed on `f7d3268aabacdb65fe414967550b9de69cb82184`. Local Release archive, static analysis, readiness validation and both bundled SceneKit asset-loading checks passed; corrected iPhone Body framing was visually verified. Full screenshot acceptance and physical-device/accessibility checks remain outstanding.

Nothing has been submitted, as confirmed October 5, 2026. Asset provenance/licence clearance remains open in [#61](https://github.com/AmrElsehemy/eidome-ios/issues/61); the source inspection is documented in [the asset audit](docs/ASSET_LICENSE_AUDIT.md). Complete the [submission checklist](APP_STORE_SUBMISSION.md), confirm the Connect version/build, upload a signed build and approved listing assets, and submit for review before claiming readiness or release.

See [release operations #71](https://github.com/AmrElsehemy/eidome-ios/issues/71) and the [weekly plan](docs/WEEKLY_RELEASE_PLAN.md) for scheduling. October 7 submission / October 9 public availability is the recovery target, conditional on release gates and Apple approval.
