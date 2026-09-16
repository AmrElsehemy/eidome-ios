import SwiftUI

struct AppSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileStore: ProfileStore
    @State private var isConfirmingDeleteAll = false

    private let privacyURL = URL(string: "https://eidome.com/privacy")!
    private let supportURL = URL(string: "https://eidome.com/support")!

    var body: some View {
        NavigationStack {
            List {
                Section("Eidome") {
                    LabeledContent("Version", value: appVersion)
                    Text("A personal body model that becomes more useful as you add measured information.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    NavigationLink("Privacy notice") {
                        PrivacyNoticeView(privacyURL: privacyURL)
                    }

                    Link(destination: privacyURL) {
                        Label("Privacy policy", systemImage: "hand.raised")
                    }

                    Button("Delete all data", role: .destructive) {
                        isConfirmingDeleteAll = true
                    }
                    .disabled(profileStore.profiles.isEmpty)
                } header: {
                    Text("Privacy and data")
                } footer: {
                    Text("This version stores twin profiles only on this device. It has no account, advertising, analytics, or cloud sync.")
                }

                Section("Support") {
                    Link(destination: supportURL) {
                        Label("Eidome support", systemImage: "questionmark.circle")
                    }
                    Link(destination: URL(string: "mailto:support@eidome.com")!) {
                        Label("Email support", systemImage: "envelope")
                    }
                }

                Section("Acknowledgements") {
                    NavigationLink("Anatomy and avatar assets") {
                        AssetAcknowledgementsView()
                    }
                }

                Section("Model limitations") {
                    Label {
                        Text("Eidome creates estimates for fitness education and personal tracking. It is not a body scan, medical device, diagnosis, or treatment recommendation.")
                    } icon: {
                        Image(systemName: "checkmark.shield")
                            .foregroundStyle(EidomeTheme.cyan)
                    }
                    .font(.footnote)
                }
            }
            .navigationTitle("About Eidome")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Delete all Eidome data?",
                isPresented: $isConfirmingDeleteAll,
                titleVisibility: .visible
            ) {
                Button("Delete all data", role: .destructive) {
                    profileStore.deleteAllData()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All twins, measurements, and mobility data will be permanently removed from this device.")
            }
        }
        .preferredColorScheme(.dark)
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(version) (\(build))"
    }
}

private struct PrivacyNoticeView: View {
    let privacyURL: URL

    var body: some View {
        List {
            Section("Data used") {
                Text("Eidome uses the profile, body measurement, and mobility information you choose to enter to create and refine twin profiles.")
            }

            Section("Storage and sharing") {
                Text("In this version, your data remains in local app storage on this device. Eidome does not send it to Knowlly, advertisers, analytics providers, or other third parties.")
            }

            Section("Children's profiles") {
                Text("A child profile is created and managed by the adult device owner. Eidome does not create child accounts or transmit a child's personal information.")
            }

            Section("Your control") {
                Text("Delete one twin from the profile selector, or use Delete All Data in About Eidome. Deleting the app also removes its local data.")
            }

            Section {
                Link("Read the full privacy policy", destination: privacyURL)
            }
        }
        .navigationTitle("Privacy notice")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AssetAcknowledgementsView: View {
    var body: some View {
        List {
            Section("Z-Anatomy") {
                Text("Eidome’s reference skeleton and superficial-muscle layers are derived from Z-Anatomy / Models of Human Anatomy.")
                Link("View Z-Anatomy source", destination: URL(string: "https://github.com/Z-Anatomy/Models-of-human-anatomy")!)
                Link("CC BY-SA 4.0 licence", destination: URL(string: "https://creativecommons.org/licenses/by-sa/4.0/")!)
            }

            Section("BodyParts3D") {
                Text("Z-Anatomy is based in part on BodyParts3D, distributed under CC BY-SA 2.1 Japan.")
                Link("CC BY-SA 2.1 Japan licence", destination: URL(string: "https://creativecommons.org/licenses/by-sa/2.1/jp/deed.en")!)
            }

            Section("MakeHuman and MPFB") {
                Text("The exterior prototype was generated with MakeHuman and MPFB. Individual source assets retain their respective licences.")
                Text("Prototype clothing: elvs_male_swim_shorts1 by Elvaerwyn, CC BY.")
                Link("View MPFB source", destination: URL(string: "https://github.com/makehumancommunity/mpfb2")!)
            }

            Section("Model scope") {
                Text("These models are simplified references for fitness education and personal tracking. They are not medical scans or diagnostic anatomy.")
            }
        }
        .navigationTitle("Asset acknowledgements")
        .navigationBarTitleDisplayMode(.inline)
    }
}
