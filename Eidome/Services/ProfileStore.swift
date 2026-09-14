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
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-eidomeScreenshotTwin") {
            let profile = Self.screenshotProfile
            profiles = [profile]
            selectedProfileID = profile.id
            return
        }
        #endif
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

    func delete(_ profile: TwinProfile) {
        profiles.removeAll { $0.id == profile.id }

        if selectedProfileID == profile.id || selectedProfile == nil {
            selectedProfileID = profiles.first?.id
        }

        save()
    }

    func deleteAllData() {
        profiles = []
        selectedProfileID = nil

        let defaults = UserDefaults.standard
        [profilesKey, selectedProfileKey, legacyProfilesKey, legacySelectedProfileKey]
            .forEach { defaults.removeObject(forKey: $0) }
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

        if let selectedProfileID {
            UserDefaults.standard.set(selectedProfileID.uuidString, forKey: selectedProfileKey)
        } else {
            UserDefaults.standard.removeObject(forKey: selectedProfileKey)
        }
    }

    #if DEBUG
    private static var screenshotProfile: TwinProfile {
        let birthDate = Calendar(identifier: .gregorian)
            .date(from: DateComponents(year: 1986, month: 1, day: 1)) ?? .now
        return TwinProfile(
            name: "Amr", relationship: .me, biologicalSex: .male,
            birthDate: birthDate, heightCentimeters: 180, weightKilograms: 84.7,
            bodyMeasurements: BodyMeasurements(
                shoulderWidthCentimeters: 48, chestCircumferenceCentimeters: 104,
                waistCircumferenceCentimeters: 86, hipCircumferenceCentimeters: 98,
                inseamCentimeters: 82, thighCircumferenceCentimeters: 58,
                calfCircumferenceCentimeters: 39
            ),
            mobilityProfile: MobilityProfile(
                leftAnkleDorsiflexion: 36, rightAnkleDorsiflexion: 39,
                leftHipInternalRotation: 34, rightHipInternalRotation: 36,
                leftShoulderFlexion: 168, rightShoulderFlexion: 171,
                leftThoracicRotation: 47, rightThoracicRotation: 49
            )
        )
    }
    #endif
}
