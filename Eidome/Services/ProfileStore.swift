import Foundation

@MainActor
final class ProfileStore: ObservableObject {
    @Published private(set) var profiles: [TwinProfile] = []
    @Published var selectedProfileID: UUID?

    private let profilesKey = "eidome.twin-profiles.v1"
    private let selectedProfileKey = "eidome.selected-profile.v1"
    private let legacyProfilesKey = "soma.twin-profiles.v1"
    private let legacySelectedProfileKey = "soma.selected-profile.v1"

    init() {
        load()
    }

    var selectedProfile: TwinProfile? {
        profiles.first(where: { $0.id == selectedProfileID }) ?? profiles.first
    }

    func add(_ profile: TwinProfile) {
        profiles.append(profile)
        selectedProfileID = profile.id
        save()
    }

    func select(_ profile: TwinProfile) {
        selectedProfileID = profile.id
        save()
    }

    func update(_ profile: TwinProfile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index] = profile
        save()
    }

    private func load() {
        let defaults = UserDefaults.standard
        let data = defaults.data(forKey: profilesKey) ?? defaults.data(forKey: legacyProfilesKey)
        guard
            let data,
            let savedProfiles = try? JSONDecoder().decode([TwinProfile].self, from: data)
        else { return }

        profiles = savedProfiles
        let rawID = defaults.string(forKey: selectedProfileKey)
            ?? defaults.string(forKey: legacySelectedProfileKey)
        if let rawID {
            selectedProfileID = UUID(uuidString: rawID)
        }
        if selectedProfile == nil {
            selectedProfileID = profiles.first?.id
        }
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: profilesKey)
        }
        UserDefaults.standard.set(selectedProfileID?.uuidString, forKey: selectedProfileKey)
    }
}
