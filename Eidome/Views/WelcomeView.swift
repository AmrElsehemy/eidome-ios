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

            VStack(spacing: 0) {
                Spacer()

                OrbitalTwinMark()
                    .frame(width: 230, height: 230)

                EidomeWordmark()
                    .padding(.top, 34)

                Text("Your body, understood.")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(EidomeTheme.secondaryText)
                    .padding(.top, 8)

                Spacer()

                VStack(spacing: 16) {
                    Text("Build your estimated body model. Explore reference anatomy. Record your mobility. Your entries stay on this device.")
                        .font(.subheadline)
                        .foregroundStyle(EidomeTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 22)

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
}
