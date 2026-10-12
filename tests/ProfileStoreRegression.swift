import Foundation

// Host-only substitutes for the SceneKit layer and camera-store boundary.
// The production model and ProfileStore are compiled unchanged by the runner.
enum TwinBodyLayer: String {
    case body = "Body", muscles = "Muscles", skeleton = "Skeleton", joints = "Joints"
}
enum TwinCameraStateStore {
    static var removedProfiles: [UUID] = []
    static var removedAll = false
    static func removeAll(profileID: UUID) { removedProfiles.append(profileID) }
    static func removeAll() { removedAll = true }
}

@main
struct ProfileStoreRegression {
    @MainActor
    static func main() throws {
        let suite = "eidome.regression.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let first = profile("First")
        let second = profile("Second")
        let store = ProfileStore(defaults: defaults)
        precondition(store.profiles.isEmpty && store.selectedExplorerLayer == .body)
        store.add(first)
        store.selectExplorerLayer(.skeleton)
        store.add(second)
        precondition(store.selectedExplorerLayer == .body, "New profiles start in Body")
        store.selectExplorerLayer(.joints)
        store.select(first)
        precondition(store.selectedExplorerLayer == .skeleton, "Layers must be independent")
        let reopened = ProfileStore(defaults: defaults)
        precondition(reopened.selectedProfile?.id == first.id)
        precondition(reopened.selectedExplorerLayer == .skeleton, "Restore selected layer after relaunch")
        reopened.select(second)
        precondition(reopened.selectedExplorerLayer == .joints)
        reopened.delete(second)
        precondition(reopened.selectedProfile?.id == first.id && reopened.selectedExplorerLayer == .skeleton)
        precondition(reopened.explorerLayers[second.id] == nil)
        precondition(TwinCameraStateStore.removedProfiles == [second.id])
        precondition(ProfileStore(defaults: defaults).profiles.map(withoutHistory) == [first], "Deleted profile must stay deleted")
        print("PASS: clean install, independent profiles, relaunch and selected-profile deletion")

        // Model an upgrade from the public version, which has no layer preference.
        defaults.removeObject(forKey: "eidome.explorer-layers.v1")
        defaults.set(UUID().uuidString, forKey: "eidome.selected-profile.v1")
        let upgraded = ProfileStore(defaults: defaults)
        precondition(upgraded.profiles.map(withoutHistory) == [first], "Upgrade must preserve profile data")
        precondition(upgraded.selectedProfileID == first.id && upgraded.selectedExplorerLayer == .body)
        precondition(defaults.string(forKey: "eidome.selected-profile.v1") == first.id.uuidString)
        upgraded.select(second)
        precondition(upgraded.selectedProfileID == first.id, "Reject a removed profile")
        defaults.set([first.id.uuidString: "Unknown layer", UUID().uuidString: "Skeleton", "bad-id": "Body"], forKey: "eidome.explorer-layers.v1")
        let repaired = ProfileStore(defaults: defaults)
        precondition(repaired.explorerLayers.isEmpty && repaired.selectedExplorerLayer == .body)
        print("PASS: public-version upgrade, stale selection and invalid saved layers")

        defaults.removePersistentDomain(forName: suite)
        defaults.set(try JSONEncoder().encode([first, second]), forKey: "soma.twin-profiles.v1")
        defaults.set(second.id.uuidString, forKey: "soma.selected-profile.v1")
        let legacy = ProfileStore(defaults: defaults)
        precondition(legacy.profiles.map(withoutHistory) == [first, second] && legacy.selectedProfileID == second.id)
        precondition(legacy.profiles.allSatisfy { $0.measurementHistory?.count == 1 && $0.measurementHistory?.first?.isStartingRecord == true })
        let original = legacy.selectedProfile!
        var changed = original
        changed.weightKilograms = 66
        legacy.update(changed)
        precondition(legacy.selectedProfile?.measurementHistory?.count == 2)
        precondition(legacy.selectedProfile?.measurementHistory?.first?.weight == 65)
        legacy.update(changed) // stale form history must not replace the stored history
        precondition(legacy.selectedProfile?.measurementHistory?.count == 2, "No-op save must not duplicate history")
        changed.mobilityProfile?.leftAnkleDorsiflexion = nil
        legacy.update(changed)
        let restored = ProfileStore(defaults: defaults)
        precondition(restored.selectedProfile?.measurementHistory?.count == 3)
        precondition(restored.selectedProfile?.measurementHistory?[1].mobility?.leftAnkleDorsiflexion == 0)
        precondition(restored.selectedProfile?.measurementHistory?.last?.mobility?.leftAnkleDorsiflexion == nil)
        precondition(restored.profiles.first?.measurementHistory?.count == 1, "History is profile scoped")
        for record in restored.selectedProfile!.measurementHistory! {
            restored.deleteSnapshot(record.id, profileID: original.id)
        }
        precondition(ProfileStore(defaults: defaults).selectedProfile?.measurementHistory?.isEmpty == true,
                     "Deleted history must not be recreated on relaunch")
        precondition(restored.selectedProfile?.weightKilograms == 66, "Deleting history leaves current readings intact")
        print("PASS: history migration, changed/no-op saves, zero versus unknown, relaunch, isolation and deletion")
        legacy.selectExplorerLayer(.muscles)
        legacy.deleteAllData()
        precondition(TwinCameraStateStore.removedAll && legacy.explorerLayers.isEmpty)
        precondition(ProfileStore(defaults: defaults).profiles.isEmpty)
        for key in ["eidome.twin-profiles.v1", "eidome.selected-profile.v1", "eidome.explorer-layers.v1", "soma.twin-profiles.v1", "soma.selected-profile.v1"] {
            precondition(defaults.object(forKey: key) == nil, "Delete all must remove \(key)")
        }
        print("PASS: legacy migration and delete-all without resurrection")
    }

    static func withoutHistory(_ profile: TwinProfile) -> TwinProfile {
        var result = profile
        result.measurementHistory = nil
        return result
    }

    static func profile(_ name: String) -> TwinProfile {
        TwinProfile(name: name, relationship: .me, biologicalSex: .female,
                    birthDate: Date(timeIntervalSince1970: 500_000_000),
                    heightCentimeters: 170, weightKilograms: 65,
                    bodyMeasurements: BodyMeasurements(waistCircumferenceCentimeters: 75),
                    mobilityProfile: MobilityProfile(leftAnkleDorsiflexion: 0, rightAnkleDorsiflexion: 30))
    }
}
