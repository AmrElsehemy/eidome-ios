# Weekly releases after v0.20

Decision: September 26, 2026. Ship one bounded improvement each week. This plan and [release operations #71](https://github.com/AmrElsehemy/eidome-ios/issues/71) supersede the former v0.21–v0.25 feature assignments. Release owner: Amr Elsehemy.

| Internal release | Submit by | Target public date | Outcome / tracker |
| --- | --- | --- | --- |
| v0.21 | 2026-09-30 | 2026-10-02 | Discoverability, ASO and launch polish — [#66](https://github.com/AmrElsehemy/eidome-ios/issues/66) |
| v0.22 | 2026-10-07 | 2026-10-09 | Screenshots and first impressions — [#67](https://github.com/AmrElsehemy/eidome-ios/issues/67) |
| v0.23 | 2026-10-14 | 2026-10-16 | Anatomy UX clarity — [#68](https://github.com/AmrElsehemy/eidome-ios/issues/68) |
| v0.24 | 2026-10-21 | 2026-10-23 | Joints/body usefulness — [#69](https://github.com/AmrElsehemy/eidome-ios/issues/69) |
| v0.25 | 2026-10-28 | 2026-10-30 | Onboarding and return experience — [#70](https://github.com/AmrElsehemy/eidome-ios/issues/70) |

Times use Europe/Rome. Public dates depend on Apple review and existing release gates. Prepare v0.21 immediately; do not wait for the first Monday to fix metadata. Confirm the live version first: the user screenshot shows availability, while #6 remains open and #63 is unmerged. Internal version labels do not prescribe App Store marketing numbers. If 1.0 is already live, use the next valid marketing version and a unique build when required; do not upload another 1.0 update blindly.

## Weekly operating rhythm

- Monday: review search evidence, App Store analytics, feedback and crashes; select one bounded outcome.
- Tuesday: freeze scope. Defer unfinished noncritical work instead of expanding the release.
- Wednesday: exact-commit checks, device smoke test, final metadata and submission.
- Thursday: handle review feedback and prepare verification.
- Friday: publish if approved, check the public listing, record the version/build, submission/approval/live times and results.

If review or a quality gate blocks release, record the blocker and next date in the milestone tracker; keep the next week's preparation moving without overlapping incompatible submissions. Never bypass asset rights, privacy, data persistence or crash gates for cadence. No empty binary releases just to increment a number.

## Backlog and dependencies

#30 guided mobility, #31 timeline, #32 Health import, #33 physiology, #34 check-in map and #62 stable anatomy IDs are unscheduled backlog. Their original feature acceptance criteria remain intact. #69 may choose a small existing-workflow improvement without committing to all of #30. Existing v0.26–v0.39 ideas are provisional candidates, not calendar commitments. Reassess after v0.25; preserve actual feature dependencies rather than inferring them from obsolete version labels.

## Definition of shipped

Record the exact commit, marketing version/build, supported territories, CI/asset/device checks, metadata and screenshot revision, public URL and live time. Keep #6/#61/#65 checks open until evidenced. Validate support/privacy URLs and clean install/upgrade/profile deletion. App Store submission is not public release, and merging listing copy does not prove indexing improved.

Measure App Store Search impressions, product-page views, downloads and conversion using comparable territory/date windows and documented denominators. Use existing App Store analytics; do not add tracking SDKs for this pass. Flag insufficient samples and unavailable metrics. Follow the search checks in [DISCOVERABILITY_V0.21.md](DISCOVERABILITY_V0.21.md).
