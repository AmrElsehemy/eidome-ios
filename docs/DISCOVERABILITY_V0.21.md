# v0.21 discoverability pass

Audit date: September 26, 2026. Delivery tracker: [#66](https://github.com/AmrElsehemy/eidome-ios/issues/66). Repository metadata is prepared for review; this document does not assert that it has been uploaded or approved.

## Listing decision

| Field | Prepared value | Reason |
| --- | --- | --- |
| Name | Eidome | Preserve the core brand; no evidence yet justifies a rename. |
| Subtitle | 3D Anatomy & Body Explorer | Makes the existing category/use case legible in search. |
| Keywords | muscle,skeleton,bone,joint,mobility,measurements,avatar,human,reference,rotation,proportion | Feature-relevant terms without duplicating name/subtitle. No keyword-volume data is available; these are a first-pass hypothesis. |
| Primary category | Health & Fitness | Fits the personal measurements/mobility product. Do not copy Medical just because the competitor uses it. |
| Secondary category | Education | Reference anatomy is an existing educational use case. |
| Description / promotional text | Anatomy-led opening, personal model explicitly estimated | Improve comprehension while keeping the trust boundary. |

Only en-US metadata is present. Audit actual storefronts/localizations in Connect before assuming this covers all markets. A future descriptive name such as “Eidome: 3D Anatomy” is an experiment only if branded-query evidence warrants it; it is not part of this change.

## Competitor image review

Reviewed the actual attachment from “Improve Eidome Search Visibility,” not only the earlier assistant's interpretation. The user prefers the competitor's clearer anatomy presentation.

The query shown is “Eidome anatomy”. Anatomy 3D Atlas is marked Ad, with Medical/Education categories and three immediately recognizable anatomy images: cutaway head, muscle torso, and skeleton/vascular torso with a structure label. Eidome appears below it with “Your body, made visible”, Health & Fitness, a welcome screenshot and a clothed body model. The image proves Eidome appeared for that query at capture time. It does not establish today's exact-brand ranking, indexing failure or its cause. Paid placement is not an organic-ranking comparison.

Eidome's first images spend scarce search-result space on branding and setup. Show the existing anatomy interaction at useful scale instead. Do not claim the competitor's organs, vascular detail or coverage for Eidome. Keep reference layers distinct from personal measurements and the estimated body model.

## Screenshot handoff

Master currently captures only Welcome and Twin. Open PR #63 adds real Body, Muscles, Skeleton and Joints captures but still puts Welcome first. Integrate its verified captures before uploading the v0.21 set. Do not upload the old two-image set as the completed ASO pass.

Order for each supported device family:

1. Muscles — “Explore muscles in 3D”; large visible anatomy, recognizable region and readable selection if available.
2. Skeleton — “Identify bones and structures”; show the actual browser/selection interaction.
3. Body — “Build your body estimate”; show measurement inputs and retain estimated wording.
4. Joints — “Record your mobility”; demonstrate existing observations without measured-motion or diagnosis claims.
5. Welcome — last or omitted, never the lead image.

These headlines are design briefs, not assertions that exported PNGs already contain them. In v0.21 perform the basic real-capture reorder; v0.22 adds better framing/captions and thumbnail readability. Validate iPhone and supported iPad screenshots, no clipping, correct dimensions, actual UI and reference-vs-personal labels. Review generated images before upload; don't generate anatomy imagery to simulate unshipped functionality.

## App Store Connect / manual steps

- Confirm exact name, primary locale, approved/live version and build, pending submissions, availability/territories, agreements and direct store URL.
- Compare prepared files with the current Connect values. Use the existing text metadata upload lane on the intended editable version; inspect all fields after upload. Name remains Eidome.
- General → App Information → App Store Tags → Edit: review Apple-assigned tags and deselect irrelevant ones. Tags are not free-text keywords. Apple currently documents en-US metadata and US display support; do not promise this fixes other storefronts.
- Generate/review the anatomy captures, set the above order, upload the supported device sets and verify the result in Connect. PR #63 remains a dependency, not proof of completed assets.
- Confirm support/privacy/marketing URLs and monitored support contact. Tool-access errors alone are not proof the website is down.
- Resolve applicable #6/#61/#65 gates, select a tested signed build with the correct marketing version/unique build when required, submit and record review status. No binary version is changed by this metadata PR.
- Verify the public page after approval. Metadata preparation, upload, review and public availability are separate states.

## Search verification and measurement

Before upload and at +24h, +72h and +7d after availability, record: timestamp, country/storefront (not physical location), device/iOS, language, query, organic rank or “not observed within first 50”, paid placements separately, and screenshot evidence. Use the user's actual storefront plus priority available markets; country is not inferred from this image.

Queries: Eidome; Eidome anatomy; 3D anatomy; muscle anatomy; skeleton; body measurements; joint mobility. Check the direct product page too. No numeric baseline was collected in this pass. If exact-brand absence persists after confirming availability, submit an Apple Developer Support report with app ID, storefront, live time, queries and captures; do not attribute it to low downloads without evidence.

Compare equal-window App Store Search impressions, product-page views, downloads and conversion by territory. Record sample size and analytics definitions, avoid mixing all-source downloads with search-only views, and acknowledge low-volume noise. Weekly releases provide a learning rhythm, not a ranking guarantee.

## Primary references checked

- [Apple: App Store search](https://developer.apple.com/app-store/search/) — text relevance and user behavior affect search.
- [Apple: Product page](https://developer.apple.com/app-store/product-page/) — 30-character name/subtitle, 100-character keywords, first screenshots, relevant categories. Promotional text is not a search-ranking field.
- [Apple: Manage app tags](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-tags) — curated tags and available controls.
