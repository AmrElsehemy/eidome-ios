import Foundation

enum TwinBodyLayer: String, CaseIterable, Hashable {
    case body = "Body", muscles = "Muscles", skeleton = "Skeleton", joints = "Joints"
}

@main
struct CameraStoreRegression {
    static func main() throws {
        let first = UUID(), second = UUID()
        defer {
            TwinCameraStateStore.removeAll(profileID: first)
            TwinCameraStateStore.removeAll(profileID: second)
        }
        // A valid, deterministic camera independent of renderer/device timing.
        let data = Data("""
        {"transform":[1,0,0,0,0,1,0,0,0,0,1,0,0,0,3,1],"target":[0,0,0],"fieldOfView":31,"orthographicScale":1}
        """.utf8)
        let state = try JSONDecoder().decode(TwinCameraState.self, from: data)
        for layer in TwinBodyLayer.allCases {
            TwinCameraStateStore.save(state, profileID: first, layer: layer, scope: .explorer)
            precondition(TwinCameraStateStore.load(profileID: first, layer: layer, scope: .explorer) == state)
            precondition(TwinCameraStateStore.load(profileID: second, layer: layer, scope: .explorer) == nil)
            precondition(TwinCameraStateStore.load(profileID: first, layer: layer, scope: .refinePreview) == nil)
        }
        let unsafe = try JSONDecoder().decode(TwinCameraState.self, from: Data(String(decoding: data, as: UTF8.self).replacingOccurrences(of: "\"fieldOfView\":31", with: "\"fieldOfView\":200").utf8))
        TwinCameraStateStore.save(unsafe, profileID: second, layer: .body, scope: .explorer)
        precondition(TwinCameraStateStore.load(profileID: second, layer: .body, scope: .explorer) == nil)
        print("PASS: all saved layers, profile/scope isolation and unsafe-camera rejection")

        TwinCameraStateStore.removeAll(profileID: first)
        // Reproduce the delayed save from UIViewRepresentable dismantling/backgrounding.
        TwinCameraStateStore.save(state, profileID: first, layer: .body, scope: .explorer)
        for layer in TwinBodyLayer.allCases {
            precondition(TwinCameraStateStore.load(profileID: first, layer: layer, scope: .explorer) == nil,
                         "Teardown must not resurrect a deleted profile's camera")
        }
        TwinCameraStateStore.save(state, profileID: second, layer: .body, scope: .explorer)
        precondition(TwinCameraStateStore.load(profileID: second, layer: .body, scope: .explorer) == state)
        print("PASS: deleted camera cannot be resurrected by delayed saves; other profiles still save")
    }
}
