import SwiftUI

struct TwinHomeView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @State private var isShowingProfiles = false
    @State private var isShowingDetails = false
    @State private var isRefiningTwin = false
    @State private var selectedLayer: TwinBodyLayer = .body
    @State private var isEditingMobility = false
    @State private var isShowingSettings = false
    @State private var selectedStructure: AnatomySelection?
    @State private var focusedStructure: AnatomySelection?

    var body: some View {
        ZStack {
            EidomeTheme.backgroundGradient.ignoresSafeArea()
            ambientGlow

            if let profile = profileStore.selectedProfile {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        topBar(profile)
                        twinStage(profile)
                        identityCard(profile)
                        improveCard(profile)
                        mobilityCard(profile)
                    }
                    .padding(.bottom, 28)
                }
            }
        }
        .foregroundStyle(.white)
        .sheet(isPresented: $isShowingProfiles) {
            ProfileSwitcherSheet()
        }
        .sheet(isPresented: $isShowingDetails) {
            if let profile = profileStore.selectedProfile {
                TwinDetailsView(profile: profile)
            }
        }
        .sheet(isPresented: $isRefiningTwin) {
            if let profile = profileStore.selectedProfile {
                RefineTwinView(profile: profile)
            }
        }
        .sheet(isPresented: $isEditingMobility) {
            if let profile = profileStore.selectedProfile {
                MobilityEditorView(profile: profile)
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            AppSettingsView()
        }
    }

    private var ambientGlow: some View {
        RadialGradient(
            colors: [EidomeTheme.violet.opacity(0.19), .clear],
            center: .top,
            startRadius: 20,
            endRadius: 330
        )
        .ignoresSafeArea()
    }

    private func topBar(_ profile: TwinProfile) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                EidomeWordmark(compact: true)
                    .foregroundStyle(EidomeTheme.cyan)
                Text(profile.name)
                    .font(.title2.bold())
            }
            Spacer()
            Button {
                isShowingSettings = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(EidomeTheme.panel, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("About, privacy, and support")

            Button {
                isShowingProfiles = true
            } label: {
                HStack(spacing: 8) {
                    Text(profile.name.prefix(1).uppercased())
                        .font(.subheadline.bold())
                        .frame(width: 34, height: 34)
                        .background(EidomeTheme.violet.opacity(0.32), in: Circle())
                    Image(systemName: "chevron.down")
                        .font(.caption.bold())
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(EidomeTheme.panel, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
    }

    private func twinStage(_ profile: TwinProfile) -> some View {
        VStack(spacing: 12) {
            TwinSceneView(
                profile: profile,
                layer: selectedLayer,
                focusedStructure: focusedStructure,
                onStructureSelected: { selection in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if focusedStructure != selection {
                            focusedStructure = nil
                        }
                        selectedStructure = selection
                    }
                }
            )
                .frame(height: 420)
                .id(profile.id)

            Text(selectedLayer == .muscles || selectedLayer == .skeleton
                 ? "Tap a structure · Drag to rotate · Pinch to zoom"
                 : "Drag to rotate · Pinch to zoom")
                .font(.caption)
                .foregroundStyle(EidomeTheme.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(EidomeTheme.panel.opacity(0.84), in: Capsule())

            layerPicker

            Label(selectedLayer.modelNote, systemImage: "circle.dashed")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(EidomeTheme.cyan)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())

            if let selectedStructure {
                anatomySelectionCard(selectedStructure)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var layerPicker: some View {
        HStack(spacing: 6) {
            ForEach(TwinBodyLayer.allCases) { layer in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedLayer = layer
                        selectedStructure = nil
                        focusedStructure = nil
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: layer.symbol)
                            .font(.body)
                        Text(layer.rawValue)
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(selectedLayer == layer ? Color.white : EidomeTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selectedLayer == layer ? EidomeTheme.violet.opacity(0.32) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 13, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedLayer == layer ? .isSelected : [])
            }
        }
        .padding(5)
        .background(EidomeTheme.panel, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(EidomeTheme.line, lineWidth: 1)
        }
        .padding(.horizontal, 20)
    }

    private func anatomySelectionCard(_ selection: AnatomySelection) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: selection.layer == .muscles ? "figure.strengthtraining.traditional" : "viewfinder")
                    .font(.title3)
                    .foregroundStyle(selection.layer == .muscles ? Color.red.opacity(0.85) : EidomeTheme.cyan)
                    .frame(width: 40, height: 40)
                    .background(EidomeTheme.panel, in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(selection.name)
                        .font(.subheadline.bold())
                        .lineLimit(2)
                    Text([selection.side?.rawValue, selection.category]
                        .compactMap { $0 }
                        .joined(separator: " · "))
                        .font(.caption2)
                        .foregroundStyle(EidomeTheme.secondaryText)
                    Text("Reference anatomy · not measured")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(EidomeTheme.cyan)
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedStructure = nil
                        focusedStructure = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .frame(width: 30, height: 30)
                        .background(EidomeTheme.panel, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear selected structure")
            }

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    focusedStructure = focusedStructure == selection ? nil : selection
                }
            } label: {
                Label(
                    focusedStructure == selection ? "Show full layer" : "Focus structure",
                    systemImage: focusedStructure == selection ? "rectangle.expand.vertical" : "scope"
                )
                .font(.caption.bold())
                .foregroundStyle(EidomeTheme.cyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(EidomeTheme.cyan.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .accessibilityHint(
                focusedStructure == selection
                    ? "Restores all structures in this anatomy layer."
                    : "Dims surrounding anatomy to make this structure easier to inspect."
            )
        }
        .padding(14)
        .glassCard()
        .padding(.horizontal, 20)
    }

    private func identityCard(_ profile: TwinProfile) -> some View {
        VStack(spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DIGITAL TWIN")
                        .font(.caption.bold())
                        .tracking(1.2)
                        .foregroundStyle(EidomeTheme.secondaryText)
                    Text("\(profile.completeness)% complete")
                        .font(.title2.bold())
                }
                Spacer()
                completenessRing(profile.completeness)
            }

            ProgressView(value: Double(profile.completeness), total: 100)
                .tint(EidomeTheme.cyan)

            HStack {
                stat("HEIGHT", "\(Int(profile.heightCentimeters)) cm")
                divider
                stat("WEIGHT", "\(Int(profile.weightKilograms)) kg")
                divider
                stat("AGE", "\(profile.age)")
            }

            Button("View model details") { isShowingDetails = true }
                .font(.subheadline.bold())
                .foregroundStyle(EidomeTheme.cyan)
        }
        .padding(20)
        .glassCard()
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    private func improveCard(_ profile: TwinProfile) -> some View {
        Button {
            isRefiningTwin = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "ruler")
                    .font(.title2)
                    .foregroundStyle(EidomeTheme.violet)
                    .frame(width: 44, height: 44)
                    .background(EidomeTheme.violet.opacity(0.14), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.bodyMeasurements?.isEmpty == false ? "Refine body shape" : "Shape this twin")
                        .font(.headline)
                    Text("\(profile.bodyMeasurements?.completedCount ?? 0) of 7 body measurements added")
                        .font(.caption)
                        .foregroundStyle(EidomeTheme.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(EidomeTheme.secondaryText)
            }
            .padding(18)
            .glassCard()
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Shape this twin with body measurements.")
    }

    private func mobilityCard(_ profile: TwinProfile) -> some View {
        Button {
            isEditingMobility = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "figure.flexibility")
                    .font(.title2)
                    .foregroundStyle(EidomeTheme.cyan)
                    .frame(width: 44, height: 44)
                    .background(EidomeTheme.cyan.opacity(0.12), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Map mobility")
                        .font(.headline)
                    Text("\(profile.mobilityProfile?.completedCount ?? 0) of 8 joint ranges measured")
                        .font(.caption)
                        .foregroundStyle(EidomeTheme.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(EidomeTheme.secondaryText)
            }
            .padding(18)
            .glassCard()
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 14)
    }

    private func completenessRing(_ value: Int) -> some View {
        ZStack {
            Circle().stroke(EidomeTheme.line, lineWidth: 6)
            Circle()
                .trim(from: 0, to: Double(value) / 100)
                .stroke(EidomeTheme.cyan, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(value)%")
                .font(.caption.bold().monospacedDigit())
        }
        .frame(width: 58, height: 58)
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.caption2.bold())
                .tracking(0.8)
                .foregroundStyle(EidomeTheme.secondaryText)
            Text(value)
                .font(.subheadline.bold().monospacedDigit())
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle().fill(EidomeTheme.line).frame(width: 1, height: 34)
    }
}

private struct TwinDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    let profile: TwinProfile

    var body: some View {
        NavigationStack {
            ZStack {
                EidomeTheme.backgroundGradient.ignoresSafeArea()
                List {
                    Section("Identity") {
                        detail("Name", profile.name)
                        detail("Relationship", profile.relationship.rawValue)
                        detail("Age", "\(profile.age) years")
                        detail("Biological sex", profile.biologicalSex.rawValue)
                    }
                    Section("Measured") {
                        detail("Height", "\(Int(profile.heightCentimeters)) cm")
                        detail("Weight", "\(Int(profile.weightKilograms)) kg")
                        if let measurements = profile.bodyMeasurements {
                            measurementDetails(measurements)
                        }
                    }
                    Section("Derived") {
                        detail("BMI", String(format: "%.1f", profile.bmi))
                    }
                    Section("Model confidence") {
                        Label("Body geometry is estimated from five profile parameters.", systemImage: "info.circle")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Twin details")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func detail(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func measurementDetails(_ values: BodyMeasurements) -> some View {
        optionalDetail("Shoulders", values.shoulderWidthCentimeters)
        optionalDetail("Chest", values.chestCircumferenceCentimeters)
        optionalDetail("Waist", values.waistCircumferenceCentimeters)
        optionalDetail("Hips", values.hipCircumferenceCentimeters)
        optionalDetail("Inseam", values.inseamCentimeters)
        optionalDetail("Thigh", values.thighCircumferenceCentimeters)
        optionalDetail("Calf", values.calfCircumferenceCentimeters)
    }

    @ViewBuilder
    private func optionalDetail(_ label: String, _ value: Double?) -> some View {
        if let value {
            detail(label, value.formatted(.number.precision(.fractionLength(0...1))) + " cm")
        }
    }
}

private struct RefineTwinView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileStore: ProfileStore
    let profile: TwinProfile
    @State private var measurements: BodyMeasurements
    @State private var heightCentimeters: Double
    @State private var weightKilograms: Double

    init(profile: TwinProfile) {
        self.profile = profile
        _measurements = State(initialValue: profile.bodyMeasurements ?? BodyMeasurements())
        _heightCentimeters = State(initialValue: profile.heightCentimeters)
        _weightKilograms = State(initialValue: profile.weightKilograms)
    }

    private var previewProfile: TwinProfile {
        var copy = profile
        copy.heightCentimeters = heightCentimeters
        copy.weightKilograms = weightKilograms
        copy.bodyMeasurements = measurements.isEmpty ? nil : measurements
        return copy
    }

    private var invalidFieldCount: Int {
        let optionalMeasurementErrors = [
            (measurements.shoulderWidthCentimeters, 20.0...70.0),
            (measurements.chestCircumferenceCentimeters, 40.0...180.0),
            (measurements.waistCircumferenceCentimeters, 35.0...180.0),
            (measurements.hipCircumferenceCentimeters, 40.0...180.0),
            (measurements.inseamCentimeters, 35.0...130.0),
            (measurements.thighCircumferenceCentimeters, 20.0...100.0),
            (measurements.calfCircumferenceCentimeters, 15.0...70.0)
        ].filter { entry in
            guard let value = entry.0 else { return false }
            return !entry.1.contains(value)
        }.count

        let requiredMetricErrors = [
            (80.0...230.0).contains(heightCentimeters),
            (15.0...250.0).contains(weightKilograms)
        ].filter { !$0 }.count

        return optionalMeasurementErrors + requiredMetricErrors
    }

    var body: some View {
        NavigationStack {
            ZStack {
                EidomeTheme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 18) {
                        TwinSceneView(profile: previewProfile)
                            .frame(height: 300)
                            .accessibilityLabel("Live preview of \(profile.name)'s body model")

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Shape \(profile.name)'s twin")
                                .font(.title2.bold())
                            Text("Add only what you have measured. Each value updates the model above and can be changed later.")
                                .font(.subheadline)
                                .foregroundStyle(EidomeTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 0) {
                            RequiredMetricInputRow(
                                title: "Height",
                                value: $heightCentimeters,
                                unit: "cm"
                            )
                            Rectangle()
                                .fill(EidomeTheme.line)
                                .frame(height: 1)
                                .padding(.leading, 16)
                            RequiredMetricInputRow(
                                title: "Weight",
                                value: $weightKilograms,
                                unit: "kg"
                            )
                        }
                        .glassCard()

                        Text("Height sets overall scale. Weight drives an estimated shape; circumferences replace regional estimates with measured inputs.")
                            .font(.caption)
                            .foregroundStyle(EidomeTheme.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 0) {
                            MeasurementInputRow(title: "Shoulder width", value: $measurements.shoulderWidthCentimeters)
                            MeasurementInputRow(title: "Chest circumference", value: $measurements.chestCircumferenceCentimeters)
                            MeasurementInputRow(title: "Waist circumference", value: $measurements.waistCircumferenceCentimeters)
                            MeasurementInputRow(title: "Hip circumference", value: $measurements.hipCircumferenceCentimeters)
                            MeasurementInputRow(title: "Inseam", value: $measurements.inseamCentimeters)
                            MeasurementInputRow(title: "Thigh circumference", value: $measurements.thighCircumferenceCentimeters)
                            MeasurementInputRow(title: "Calf circumference", value: $measurements.calfCircumferenceCentimeters, showsDivider: false)
                        }
                        .glassCard()

                        HStack(spacing: 12) {
                            provenanceLabel("Measured", color: EidomeTheme.cyan)
                            provenanceLabel("Derived", color: EidomeTheme.violet)
                            provenanceLabel("Estimated", color: EidomeTheme.secondaryText)
                        }

                        if invalidFieldCount > 0 {
                            Label("Check \(invalidFieldCount) measurement\(invalidFieldCount == 1 ? "" : "s").", systemImage: "exclamationmark.triangle.fill")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.orange)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(20)
                }
            }
            .foregroundStyle(.white)
            .navigationTitle("Body measurements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = profile
                        updated.heightCentimeters = heightCentimeters
                        updated.weightKilograms = weightKilograms
                        updated.bodyMeasurements = measurements.isEmpty ? nil : measurements
                        profileStore.update(updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(invalidFieldCount > 0)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func provenanceLabel(_ title: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(title).font(.caption2.weight(.semibold))
        }
        .foregroundStyle(EidomeTheme.secondaryText)
    }
}

private struct MeasurementInputRow: View {
    let title: String
    @Binding var value: Double?
    var showsDivider = true

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.subheadline)
                Spacer()
                TextField("—", value: $value, format: .number.precision(.fractionLength(0...1)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.body.monospacedDigit())
                    .frame(width: 76)
                    .padding(.vertical, 9)
                    .padding(.horizontal, 10)
                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
                Text("cm")
                    .font(.caption)
                    .foregroundStyle(EidomeTheme.secondaryText)
                    .frame(width: 22, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 7)

            if showsDivider {
                Rectangle()
                    .fill(EidomeTheme.line)
                    .frame(height: 1)
                    .padding(.leading, 16)
            }
        }
    }
}


private struct RequiredMetricInputRow: View {
    let title: String
    @Binding var value: Double
    let unit: String

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
            Spacer()
            TextField(
                "—",
                value: $value,
                format: .number.precision(.fractionLength(0...1))
            )
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .font(.body.monospacedDigit())
            .frame(width: 76)
            .padding(.vertical, 9)
            .padding(.horizontal, 10)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
            Text(unit)
                .font(.caption)
                .foregroundStyle(EidomeTheme.secondaryText)
                .frame(width: 22, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
    }
}
