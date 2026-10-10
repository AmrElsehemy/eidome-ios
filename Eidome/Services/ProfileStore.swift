import Foundation
import Combine

@MainActor
final class ProfileStore: ObservableObject {
    @Published private(set) var profiles: [TwinProfile] = []
    @Published private(set) var selectedProfileID: UUID?
    @Published private(set) var explorerLayers: [UUID: TwinBodyLayer] = [:]

    private let defaults: UserDefaults

    private let profilesKey = "eidome.twin-profiles.v1"
    private let selectedProfileKey = "eidome.selected-profile.v1"
    private let legacyProfilesKey = "soma.twin-profiles.v1"
    private let legacySelectedProfileKey = "soma.selected-profile.v1"

    private let explorerLayersKey = "eidome.explorer-layers.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
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

    var selectedExplorerLayer: TwinBodyLayer {
        guard let id = selectedProfile?.id else { return .body }
        return explorerLayers[id] ?? .body
    }

    func selectExplorerLayer(_ layer: TwinBodyLayer) {
        guard let id = selectedProfile?.id else { return }
        explorerLayers[id] = layer
        save()
    }

    func add(_ profile: TwinProfile) {
        profiles.append(profile)
        selectedProfileID = profile.id
        save()
    }

    func select(_ profile: TwinProfile) {
        guard profiles.contains(where: { $0.id == profile.id }) else { return }
        selectedProfileID = profile.id
        save()
    }

    func update(_ profile: TwinProfile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index] = profile
        save()
    }

    func delete(_ profile: TwinProfile) {
        TwinCameraStateStore.removeAll(profileID: profile.id)
        profiles.removeAll { $0.id == profile.id }
        explorerLayers.removeValue(forKey: profile.id)

        if selectedProfileID == profile.id || selectedProfile == nil {
            selectedProfileID = profiles.first?.id
        }

        save()
    }

    func deleteAllData() {
        profiles.forEach { TwinCameraStateStore.removeAll(profileID: $0.id) }
        TwinCameraStateStore.removeAll()
        profiles = []
        selectedProfileID = nil
        explorerLayers = [:]

        [profilesKey, selectedProfileKey, legacyProfilesKey, legacySelectedProfileKey, explorerLayersKey]
            .forEach { defaults.removeObject(forKey: $0) }
    }

    private func load() {
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
        if !profiles.contains(where: { $0.id == selectedProfileID }) {
            selectedProfileID = profiles.first?.id
        }
        if let savedLayers = defaults.dictionary(forKey: explorerLayersKey) as? [String: String] {
            for (rawID, rawLayer) in savedLayers {
                guard let id = UUID(uuidString: rawID),
                      profiles.contains(where: { $0.id == id }),
                      let layer = TwinBodyLayer(rawValue: rawLayer) else { continue }
                explorerLayers[id] = layer
            }
        }
        save()
    }

    private func save() {
        let layers = Dictionary(uniqueKeysWithValues: explorerLayers.map { ($0.key.uuidString, $0.value.rawValue) })
        defaults.set(layers, forKey: explorerLayersKey)
        if let data = try? JSONEncoder().encode(profiles) {
            defaults.set(data, forKey: profilesKey)
        }

        if let selectedProfileID {
            defaults.set(selectedProfileID.uuidString, forKey: selectedProfileKey)
        } else {
            defaults.removeObject(forKey: selectedProfileKey)
        }
    }

    #if DEBUG
    private static var screenshotProfile: TwinProfile {
        let birthDate = Calendar(identifier: .gregorian)
            .date(from: DateComponents(year: 1986, month: 1, day: 1)) ?? Date(timeIntervalSince1970: 0)
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
