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
                        TwinSceneView(profile: profile, layer: .joints)
                            .frame(height: 270)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("How \(profile.name) moves")
                                .font(.title2.bold())
                            Text("Record measured joint ranges in degrees. Leave unknown values empty.")
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
                            .foregroundStyle(asymmetry >= 8 ? .orange : EidomeTheme.cyan)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

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

    private func mobilityCard(
        title: String,
        left: Binding<Double?>,
        right: Binding<Double?>
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
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
