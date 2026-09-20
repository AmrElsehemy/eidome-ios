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
    @State private var anatomyExportItems: [URL] = []

    var body: some View {
        List {
            Section("Z-Anatomy derivative") {
                Text("“Z-Anatomy — The libre 3D atlas of anatomy — CC BY-SA 4.0.” Authors include Gauthier Kervyn (design, 3D and anatomy), Marcin Zielinski (Blender add-on) and Lluis Vinent (Unity development).")
                Text("Eidome’s bundled anatomy model is an adapted work licensed under Creative Commons Attribution-ShareAlike 4.0. Eidome selected the skeletal and superficial-muscle layers, removed guide geometry, decimated meshes, normalized scale and frame, and converted the result to USDZ.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Link("Pinned Z-Anatomy source and attribution", destination: URL(string: "https://github.com/Z-Anatomy/Models-of-human-anatomy/blob/b9c9f98066e1e786814603b047c5bd3638c2a864/License.txt")!)
                Link("CC BY-SA 4.0 licence", destination: URL(string: "https://creativecommons.org/licenses/by-sa/4.0/")!)

                if anatomyExportItems.isEmpty {
                    Label("Licensed model export unavailable", systemImage: "exclamationmark.triangle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ShareLink(items: anatomyExportItems) {
                        Label("Export model and licence notice", systemImage: "square.and.arrow.up")
                    }
                }
            }

            Section("BodyParts3D") {
                Text("“BodyParts3D — The Database Center for Life Science — CC BY-SA 2.1 Japan.” Original model by Kousaku Okubo.")
                Link("Download original BodyParts3D data", destination: URL(string: "https://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html")!)
                Link("CC BY-SA 2.1 Japan licence", destination: URL(string: "https://creativecommons.org/licenses/by-sa/2.1/jp/deed.en")!)
            }

            Section("MakeHuman and MPFB avatar") {
                Text("The exterior avatar uses MakeHuman/MPFB core assets made available under CC0.")
                Text("Skin: toigo_light_skin_male_bronze by MargaretToigo, CC0.")
                Text("Clothing: elvs_male_swim_shorts1 by Elvaerwyn, published as CC BY by the MakeHuman Community asset catalogue.")
                Link("MakeHuman asset licence", destination: URL(string: "https://static.makehumancommunity.org/about/license.html")!)
                Link("Skin catalogue entry", destination: URL(string: "https://static.makehumancommunity.org/assets/assetpacks/skins02.html")!)
                Link("Clothing catalogue entry", destination: URL(string: "https://static.makehumancommunity.org/assets/assetpacks/pants03.html")!)
                Link("MPFB source", destination: URL(string: "https://github.com/makehumancommunity/mpfb2")!)
            }

            Section("Model scope") {
                Text("These models are simplified references for fitness education and personal tracking. They are not medical scans or diagnostic anatomy.")
            }
        }
        .navigationTitle("Asset acknowledgements")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            anatomyExportItems = Self.makeAnatomyExportItems()
        }
    }

    private static func makeAnatomyExportItems() -> [URL] {
        guard let modelURL = Bundle.main.url(forResource: "eidome-anatomy", withExtension: "usdz") else {
            return []
        }

        let noticeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("EIDOME-ANATOMY-LICENCE.txt")
        do {
            try anatomyNotice.write(to: noticeURL, atomically: true, encoding: .utf8)
            return [modelURL, noticeURL]
        } catch {
            return [modelURL]
        }
    }

    private static let anatomyNotice = """
    EIDOME ANATOMY MODEL — LICENCE AND ATTRIBUTION

    This eidome-anatomy.usdz file is an adapted work licensed under the
    Creative Commons Attribution-ShareAlike 4.0 International licence:
    https://creativecommons.org/licenses/by-sa/4.0/

    Source revision:
    https://github.com/Z-Anatomy/Models-of-human-anatomy/tree/b9c9f98066e1e786814603b047c5bd3638c2a864

    Required model credits:
    “Z-Anatomy — The libre 3D atlas of anatomy — CC BY-SA 4.0.”
    Gauthier Kervyn — design, 3D and anatomy
    Marcin Zielinski — Blender add-on
    Lluis Vinent — Unity development

    “BodyParts3D — The Database Center for Life Science — CC BY-SA 2.1 Japan.”
    Kousaku Okubo — original BodyParts3D model
    https://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html
    https://creativecommons.org/licenses/by-sa/2.1/jp/deed.en

    Eidome modifications:
    Selected skeletal and superficial-muscle layers; removed guide geometry;
    decimated meshes; normalized scale and coordinate frame; converted to USDZ.

    No endorsement by the original authors or licensors is implied.
    This notice applies to the anatomy model, not to Eidome application code.
    """
}
