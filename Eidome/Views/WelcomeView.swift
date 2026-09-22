import SwiftUI

struct WelcomeView: View {
    @State private var isCreatingTwin = false
    @State private var isShowingSettings = false

    var body: some View {
        ZStack {
            EidomeTheme.backgroundGradient.ignoresSafeArea()

            Circle()
                .fill(EidomeTheme.violet.opacity(0.16))
                .frame(width: 320, height: 320)
                .blur(radius: 45)
                .offset(y: -180)

            ScrollView {
                VStack(spacing: 22) {
                    OrbitalTwinMark()
                        .frame(width: 148, height: 148)
                        .padding(.top, 28)

                    VStack(spacing: 8) {
                        EidomeWordmark()

                        Text("Understand your body in one visual place")
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)

                        Text("Create an estimated body model, connect your measurements to it, and explore the reference anatomy and mobility behind movement.")
                            .font(.subheadline)
                            .foregroundStyle(EidomeTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)

                    VStack(spacing: 10) {
                        onboardingStep(
                            icon: "figure.stand",
                            title: "1. Build your body estimate",
                            detail: "Start with height and weight. Add measurements later to refine the exterior shape."
                        )
                        onboardingStep(
                            icon: "square.grid.2x2",
                            title: "2. Explore reference anatomy",
                            detail: "Browse muscles, bones, and joints to understand where structures are and what they do."
                        )
                        onboardingStep(
                            icon: "ruler",
                            title: "3. Record mobility",
                            detail: "Save your own joint movement observations and keep them with this twin."
                        )
                    }
                    .padding(.horizontal, 20)

                    VStack(spacing: 14) {
                        Text("Your measurements describe you. The anatomy layers are educational references, not a scan.")
                            .font(.footnote)
                            .foregroundStyle(EidomeTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)

                        Button("Create My Twin") {
                            isCreatingTwin = true
                        }
                        .buttonStyle(EidomePrimaryButtonStyle())

                        Button("Privacy & About") {
                            isShowingSettings = true
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(EidomeTheme.secondaryText)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
                .frame(maxWidth: 620)
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(.white)
        .sheet(isPresented: $isCreatingTwin) {
            NavigationStack {
                CreateTwinView(defaultRelationship: .me)
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $isShowingSettings) {
            AppSettingsView()
        }
    }

    private func onboardingStep(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(EidomeTheme.cyan)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(EidomeTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .glassCard()
        .accessibilityElement(children: .combine)
    }
}
