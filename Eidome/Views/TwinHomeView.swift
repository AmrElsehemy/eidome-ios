import SwiftUI

struct TwinHomeView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @State private var isShowingProfiles = false
    @State private var isShowingDetails = false

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
                        improveCard
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
        ZStack(alignment: .bottom) {
            TwinSceneView(profile: profile)
                .frame(height: 470)
                .id(profile.id)

            VStack(spacing: 7) {
                Text("Drag to rotate · Pinch to zoom")
                    .font(.caption)
                    .foregroundStyle(EidomeTheme.secondaryText)
                Label("Estimated model", systemImage: "circle.dashed")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(EidomeTheme.cyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(.bottom, 8)
        }
    }

    private func identityCard(_ profile: TwinProfile) -> some View {
        VStack(spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TWIN v0.01")
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

    private var improveCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(EidomeTheme.violet)
                .frame(width: 44, height: 44)
                .background(EidomeTheme.violet.opacity(0.14), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text("Improve this twin")
                    .font(.headline)
                Text("Waist, chest and limb measurements unlock in v0.02")
                    .font(.caption)
                    .foregroundStyle(EidomeTheme.secondaryText)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: "lock.fill")
                .foregroundStyle(EidomeTheme.secondaryText)
        }
        .padding(18)
        .glassCard()
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Improve this twin. More measurements unlock in version 0.02.")
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
}
