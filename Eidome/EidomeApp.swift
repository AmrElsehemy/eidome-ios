import SwiftUI

@main
struct EidomeApp: App {
    @StateObject private var profileStore = ProfileStore()

    init() {
        #if DEBUG
        let invalidSymbols = TwinBodyLayer.invalidSystemSymbols
        assert(invalidSymbols.isEmpty, "Invalid SF Symbols: \(invalidSymbols.joined(separator: ", "))")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(profileStore)
                .preferredColorScheme(.dark)
        }
    }
}

private struct RootView: View {
    @EnvironmentObject private var profileStore: ProfileStore

    var body: some View {
        Group {
            if profileStore.profiles.isEmpty {
                WelcomeView()
            } else {
                TwinHomeView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: profileStore.profiles.isEmpty)
    }
}
