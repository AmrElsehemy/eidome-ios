import SwiftUI

struct MobilityEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileStore: ProfileStore
    let profile: TwinProfile
    @State private var mobility: MobilityProfile

    init(profile: TwinProfile) {
        self.profile = profile
        _mobility = State(initialValue: profile.mobilityProfile ?? MobilityProfile())
    }

    private var invalidValueCount: Int {
        mobility.values.filter { $0 < 0 || $0 > 220 }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                EidomeTheme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 18) {
                        TwinSceneView(
                            profile: profile,
                            layer: .joints,
                            cameraStateScope: .mobilityEditor
                        )
                            .frame(height: 270)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("How \(profile.name) moves")
                                .font(.title2.bold())
                            Text("Record measured joint ranges in degrees. Leave unknown values empty. The model does not measure motion or diagnose restrictions.")
                                .font(.subheadline)
                                .foregroundStyle(EidomeTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        mobilityCard(
                            title: "Ankle dorsiflexion",
                            left: $mobility.leftAnkleDorsiflexion,
                            right: $mobility.rightAnkleDorsiflexion
                        )
                        mobilityCard(
                            title: "Hip internal rotation",
                            left: $mobility.leftHipInternalRotation,
                            right: $mobility.rightHipInternalRotation
                        )
                        mobilityCard(
                            title: "Shoulder flexion",
                            left: $mobility.leftShoulderFlexion,
                            right: $mobility.rightShoulderFlexion
                        )
                        mobilityCard(
                            title: "Thoracic rotation",
                            left: $mobility.leftThoracicRotation,
                            right: $mobility.rightThoracicRotation
                        )

                        if let asymmetry = mobility.largestAsymmetry {
                            Label(
                                "Largest left/right difference: \(asymmetry.formatted(.number.precision(.fractionLength(0...1))))°",
                                systemImage: "arrow.left.and.right"
                            )
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(EidomeTheme.cyan)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Link("Movement reference: OpenStax Anatomy & Physiology 2e, §9.5",
                             destination: URL(string: "https://openstax.org/books/anatomy-and-physiology-2e/pages/9-5-types-of-body-movements")!)
                            .font(.caption)
                        Text("Use the same measurement method and position on both sides. Do not force a movement. Seek professional guidance for pain or medical decisions.")
                            .font(.caption)
                            .foregroundStyle(EidomeTheme.secondaryText)

                        Label("Self-assessment data is informational, not a diagnosis.", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundStyle(EidomeTheme.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                }
            }
            .foregroundStyle(.white)
            .navigationTitle("Mobility")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = profile
                        updated.mobilityProfile = mobility.isEmpty ? nil : mobility
                        profileStore.update(updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(invalidValueCount > 0)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func movementExplanation(_ title: String) -> String {
        switch title {
        case "Ankle dorsiflexion":
            return "The top of the foot moves toward the shin at the ankle."
        case "Hip internal rotation":
            return "The thigh turns inward around its long axis at the hip."
        case "Shoulder flexion":
            return "The arm moves forward and upward at the shoulder."
        default:
            return "The upper trunk turns left or right through several spinal joints, not one joint."
        }
    }

    private func mobilityCard(
        title: String,
        left: Binding<Double?>,
        right: Binding<Double?>
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
            Text(movementExplanation(title))
                .font(.caption)
                .foregroundStyle(EidomeTheme.secondaryText)
            Text("Entered: \([left.wrappedValue, right.wrappedValue].compactMap { $0 }.count) of 2 sides. Differences alone do not indicate injury.")
                .font(.caption2)
                .foregroundStyle(EidomeTheme.secondaryText)
            HStack(spacing: 12) {
                AngleInput(label: "LEFT", value: left)
                AngleInput(label: "RIGHT", value: right)
            }
        }
        .padding(16)
        .glassCard()
    }
}

private struct AngleInput: View {
    let label: String
    @Binding var value: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.caption2.bold())
                .tracking(0.8)
                .foregroundStyle(EidomeTheme.secondaryText)
            HStack {
                TextField("—", value: $value, format: .number.precision(.fractionLength(0...1)))
                    .keyboardType(.decimalPad)
                    .font(.title3.bold().monospacedDigit())
                Text("°")
                    .foregroundStyle(EidomeTheme.secondaryText)
            }
            .padding(12)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity)
    }
}
