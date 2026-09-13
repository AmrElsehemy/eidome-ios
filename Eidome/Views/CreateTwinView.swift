import SwiftUI

struct CreateTwinView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileStore: ProfileStore
    @State private var draft: TwinDraft
    @State private var isGenerating = false

    init(defaultRelationship: TwinProfile.Relationship) {
        _draft = State(initialValue: TwinDraft(relationship: defaultRelationship))
    }

    var body: some View {
        ZStack {
            EidomeTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    identitySection
                    bodySection
                    trustNote

                    Button(draft.relationship == .me ? "Generate My Twin" : "Generate Twin") {
                        generateTwin()
                    }
                    .buttonStyle(EidomePrimaryButtonStyle())
                    .disabled(!draft.isValid)
                    .opacity(draft.isValid ? 1 : 0.45)
                }
                .padding(24)
                .padding(.bottom, 18)
            }

            if isGenerating {
                generationOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .foregroundStyle(.white)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(EidomeTheme.cyan)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .interactiveDismissDisabled(isGenerating)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Create your twin")
                .font(.largeTitle.bold())
            Text("A few details are enough to create your first body estimate.")
                .foregroundStyle(EidomeTheme.secondaryText)
        }
    }

    private var identitySection: some View {
        VStack(spacing: 18) {
            fieldLabel("PROFILE")

            TextField("Name", text: $draft.name)
                .textContentType(.name)
                .font(.title3.weight(.semibold))
                .padding(16)
                .background(EidomeTheme.panelStrong, in: RoundedRectangle(cornerRadius: 16))

            Picker("Relationship", selection: $draft.relationship) {
                ForEach(TwinProfile.Relationship.allCases) { relationship in
                    Text(relationship.rawValue).tag(relationship)
                }
            }
            .pickerStyle(.segmented)

            Picker("Biological sex", selection: $draft.biologicalSex) {
                ForEach(TwinProfile.BiologicalSex.allCases) { sex in
                    Text(sex.rawValue).tag(sex)
                }
            }
            .pickerStyle(.segmented)

            DatePicker("Date of birth", selection: $draft.birthDate, in: ...Date.now, displayedComponents: .date)
                .tint(EidomeTheme.cyan)
        }
        .padding(20)
        .glassCard()
    }

    private var bodySection: some View {
        VStack(spacing: 22) {
            fieldLabel("STARTING GEOMETRY")
            measurementRow(
                icon: "ruler",
                label: "Height",
                value: "\(Int(draft.heightCentimeters)) cm",
                valueBinding: $draft.heightCentimeters,
                range: 80...230
            )
            Divider().overlay(EidomeTheme.line)
            measurementRow(
                icon: "scalemass",
                label: "Weight",
                value: "\(Int(draft.weightKilograms)) kg",
                valueBinding: $draft.weightKilograms,
                range: 15...250
            )
        }
        .padding(20)
        .glassCard()
    }

    private var trustNote: some View {
        Label {
            Text("The first body is an **estimate**. Future measurements will refine its shape and confidence.")
        } icon: {
            Image(systemName: "checkmark.shield")
                .foregroundStyle(EidomeTheme.cyan)
        }
        .font(.footnote)
        .foregroundStyle(EidomeTheme.secondaryText)
    }

    private var generationOverlay: some View {
        ZStack {
            EidomeTheme.background.opacity(0.96).ignoresSafeArea()

            VStack(spacing: 24) {
                OrbitalTwinMark(animated: true)
                    .frame(width: 220, height: 220)

                VStack(spacing: 8) {
                    Text("Creating \(draft.name.trimmingCharacters(in: .whitespacesAndNewlines))'s twin")
                        .font(.title2.bold())
                    Text("Building the first estimate from your profile")
                        .font(.subheadline)
                        .foregroundStyle(EidomeTheme.secondaryText)
                }

                ProgressView()
                    .tint(EidomeTheme.cyan)
            }
            .multilineTextAlignment(.center)
            .padding(28)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Creating digital twin")
    }

    private func generateTwin() {
        guard draft.isValid, !isGenerating else { return }
        let profile = draft.makeProfile()

        withAnimation(.easeInOut(duration: 0.25)) {
            isGenerating = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
            profileStore.add(profile)
            dismiss()
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.bold())
            .tracking(1.3)
            .foregroundStyle(EidomeTheme.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func measurementRow(icon: String, label: String, value: String, valueBinding: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(spacing: 12) {
            HStack {
                Label(label, systemImage: icon)
                Spacer()
                Text(value)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(EidomeTheme.cyan)
            }
            Slider(value: valueBinding, in: range, step: 1)
                .tint(EidomeTheme.violet)
        }
    }
}

private extension TwinDraft {
    init(relationship: TwinProfile.Relationship) {
        self.init()
        self.relationship = relationship
    }
}
