import Foundation
import SceneKit
import SwiftUI
import UIKit

enum TwinBodyLayer: String, CaseIterable, Identifiable {
    case body = "Body"
    case muscles = "Muscles"
    case skeleton = "Skeleton"
    case joints = "Joints"

    var id: String { rawValue }

    private var preferredSymbol: String {
        switch self {
        case .body: "figure.stand"
        case .muscles: "figure.strengthtraining.traditional"
        case .skeleton: "viewfinder"
        case .joints: "circle.grid.cross"
        }
    }

    var symbol: String {
        UIImage(systemName: preferredSymbol) == nil ? "circle.dashed" : preferredSymbol
    }

    static var invalidSystemSymbols: [String] {
        allCases
            .map(\.preferredSymbol)
            .filter { UIImage(systemName: $0) == nil }
    }

    var modelNote: String {
        switch self {
        case .body: "Personalized estimate"
        case .muscles: "Reference muscles · personalized shape"
        case .skeleton: "Reference skeleton · estimated proportions"
        case .joints: "Reference joint map · estimated positions"
        }
    }
}

struct TwinSceneView: UIViewRepresentable {
    let profile: TwinProfile
    var layer: TwinBodyLayer = .body

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.allowsCameraControl = true
        view.defaultCameraController.interactionMode = .orbitTurntable
        view.defaultCameraController.inertiaEnabled = true
        view.autoenablesDefaultLighting = false
        configureScene(in: view, profile: profile, layer: layer)
        context.coordinator.lastProfile = profile
        context.coordinator.lastLayer = layer
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        guard context.coordinator.lastProfile != profile || context.coordinator.lastLayer != layer else { return }
        configureScene(in: view, profile: profile, layer: layer)
        context.coordinator.lastProfile = profile
        context.coordinator.lastLayer = layer
    }

    final class Coordinator {
        var lastProfile: TwinProfile?
        var lastLayer: TwinBodyLayer?
    }

    private func configureScene(in view: SCNView, profile: TwinProfile, layer: TwinBodyLayer) {
        let previousCameraTransform = view.pointOfView?.presentation.transform
        let scene = SCNScene()
        scene.rootNode.addChildNode(makeBody(for: profile, layer: layer))
        scene.rootNode.addChildNode(makeGroundRing(for: profile, layer: layer))

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.fieldOfView = 31
        if let previousCameraTransform {
            camera.transform = previousCameraTransform
        } else {
            camera.position = SCNVector3(0, 0.08, 3.45)
            camera.look(at: SCNVector3(0, 0.02, 0))
        }
        scene.rootNode.addChildNode(camera)

        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light?.type = .directional
        keyLight.light?.intensity = layer == .skeleton ? 920 : 760
        keyLight.light?.color = UIColor(red: 1.0, green: 0.94, blue: 0.88, alpha: 1)
        keyLight.position = SCNVector3(-2.2, 2.4, 2.8)
        keyLight.look(at: SCNVector3(0, 0.08, 0))
        scene.rootNode.addChildNode(keyLight)

        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .omni
        fillLight.light?.intensity = 140
        fillLight.light?.color = UIColor(red: 0.82, green: 0.88, blue: 1.0, alpha: 1)
        fillLight.position = SCNVector3(1.8, 0.9, 2.3)
        scene.rootNode.addChildNode(fillLight)

        let rimLight = SCNNode()
        rimLight.light = SCNLight()
        rimLight.light?.type = .omni
        rimLight.light?.intensity = 110
        rimLight.light?.color = UIColor(red: 0.70, green: 1.0, blue: 0.88, alpha: 1)
        rimLight.position = SCNVector3(1.8, 1.1, -1.8)
        scene.rootNode.addChildNode(rimLight)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = layer == .skeleton ? 150 : 70
        ambient.light?.color = UIColor(white: 0.62, alpha: 1)
        scene.rootNode.addChildNode(ambient)

        view.scene = scene
        view.pointOfView = camera
    }

    private func makeBody(for profile: TwinProfile, layer: TwinBodyLayer) -> SCNNode {
        switch layer {
        case .body:
            makeBundledExteriorBody(for: profile) ?? makeExteriorBody(for: profile)
        case .muscles:
            makeMuscleBody(for: profile)
        case .skeleton:
            makeSkeletonBody(for: profile)
        case .joints:
            makeJointBody(for: profile)
        }
    }

    private func makeBundledExteriorBody(for profile: TwinProfile) -> SCNNode? {
        guard
            let url = Bundle.main.url(
                forResource: "eidome-human",
                withExtension: "usdz"
            ),
            let sourceScene = try? SCNScene(url: url, options: [
                SCNSceneSource.LoadingOption.checkConsistency: true
            ])
        else {
            return nil
        }

        let model = SCNNode()
        for child in sourceScene.rootNode.childNodes where child.camera == nil && child.light == nil {
            model.addChildNode(child.clone())
        }
        guard !model.childNodes.isEmpty else { return nil }

        let (minimum, maximum) = model.boundingBox
        let sourceHeight = maximum.y - minimum.y
        guard sourceHeight.isFinite, sourceHeight > 0 else { return nil }

        applyPersonalization(to: model, for: profile)

        let geometry = BodyGeometry(profile: profile)
        let scale = geometry.totalHeight / sourceHeight
        model.pivot = SCNMatrix4MakeTranslation(
            (minimum.x + maximum.x) / 2,
            minimum.y,
            (minimum.z + maximum.z) / 2
        )
        model.scale = SCNVector3(scale, scale, scale)
        model.position = SCNVector3(0, -geometry.totalHeight / 2, 0)
        model.eulerAngles.y = -.pi / 12
        model.name = "EidomeBundledHuman"
        return model
    }

    private func applyPersonalization(to model: SCNNode, for profile: TwinProfile) {
        let deformation = AvatarDeformation(profile: profile)
        guard !deformation.isIdentity else { return }

        model.enumerateChildNodes { node, _ in
            guard let geometry = node.geometry else { return }
            let label = [node.name, geometry.name]
                .compactMap { $0?.lowercased() }
                .joined(separator: " ")

            if label.contains("eye") || label.contains("high-poly") {
                return
            }

            let (minimum, maximum) = node.boundingBox
            let isBody = label.contains("base") || label.contains("body")
            geometry.shaderModifiers = [
                .geometry: isBody
                    ? deformation.bodyShader(minimumY: minimum.y, maximumY: maximum.y)
                    : deformation.clothingShader(minimumY: minimum.y, maximumY: maximum.y)
            ]
        }
    }

    private func makeExteriorBody(
        for profile: TwinProfile,
        material: SCNMaterial? = nil,
        jointMaterial: SCNMaterial? = nil
    ) -> SCNNode {
        let g = BodyGeometry(profile: profile)
        let root = SCNNode()
        let surface = material ?? bodyMaterial()
        let joints = jointMaterial ?? glowMaterial()
        let p = bodyPositions(g)

        addEllipsoid(to: root, radii: SCNVector3(g.headRadius * 0.82, g.headRadius, g.headRadius * 0.83), at: SCNVector3(0, p.headY, 0), material: surface)
        addCapsule(to: root, radius: g.headRadius * 0.34, height: g.headRadius * 0.75, at: SCNVector3(0, p.neckY, 0), material: surface)
        addEllipsoid(to: root, radii: SCNVector3(g.chestWidth / 2, g.torsoHeight * 0.32, g.chestDepth / 2), at: SCNVector3(0, p.hipY + g.torsoHeight * 0.68, 0), material: surface)
        addEllipsoid(to: root, radii: SCNVector3(g.waistWidth / 2, g.torsoHeight * 0.27, g.waistDepth / 2), at: SCNVector3(0, p.hipY + g.torsoHeight * 0.35, 0), material: surface)
        addEllipsoid(to: root, radii: SCNVector3(g.hipWidth / 2, g.torsoHeight * 0.18, g.hipDepth / 2), at: SCNVector3(0, p.hipY + g.torsoHeight * 0.08, 0), material: surface)
        addEllipsoid(to: root, radii: SCNVector3(g.shoulderWidth / 2, g.totalHeight * 0.045, g.chestDepth * 0.50), at: SCNVector3(0, p.shoulderY, 0), material: surface)

        for side: Float in [-1, 1] {
            addCapsule(to: root, radius: g.armRadius, height: g.armLength, at: SCNVector3(side * p.armX, p.armY, 0), material: surface)
            addSphere(to: root, radius: g.armRadius * 1.10, at: SCNVector3(side * p.armX, p.shoulderY, 0), material: joints)
            addEllipsoid(to: root, radii: SCNVector3(g.armRadius * 0.92, g.armRadius * 1.55, g.armRadius * 0.72), at: SCNVector3(side * p.armX, p.armY - g.armLength * 0.55, 0), material: surface)
        }

        let thighLength = g.legLength * 0.52
        let calfLength = g.legLength * 0.48
        let kneeY = p.floorY + calfLength
        for side: Float in [-1, 1] {
            addCapsule(to: root, radius: g.thighRadius, height: thighLength, at: SCNVector3(side * p.legX, kneeY + thighLength / 2, 0), material: surface)
            addCapsule(to: root, radius: g.calfRadius, height: calfLength, at: SCNVector3(side * p.legX, p.floorY + calfLength / 2, 0), material: surface)
            addSphere(to: root, radius: g.calfRadius * 0.90, at: SCNVector3(side * p.legX, kneeY, 0), material: joints)
            addSphere(to: root, radius: g.thighRadius, at: SCNVector3(side * p.legX, p.hipY, 0), material: joints)
            addEllipsoid(to: root, radii: SCNVector3(g.calfRadius * 0.95, g.calfRadius * 0.55, g.calfRadius * 1.65), at: SCNVector3(side * p.legX, p.floorY - g.calfRadius * 0.05, g.calfRadius * 0.62), material: surface)
        }

        root.eulerAngles.y = -.pi / 12
        return root
    }

    private func makeMuscleBody(for profile: TwinProfile) -> SCNNode {
        let g = BodyGeometry(profile: profile)
        let p = bodyPositions(g)
        let root = SCNNode()
        let muscle = muscleMaterial()
        let muscleLight = muscleMaterial(light: true)
        let tendon = tendonMaterial()

        addEllipsoid(to: root, radii: SCNVector3(g.headRadius * 0.78, g.headRadius * 0.96, g.headRadius * 0.79), at: SCNVector3(0, p.headY, 0), material: tendon)
        addCapsule(to: root, radius: g.headRadius * 0.30, height: g.headRadius * 0.70, at: SCNVector3(0, p.neckY, 0), material: muscle)

        let chestY = p.hipY + g.torsoHeight * 0.68
        for side: Float in [-1, 1] {
            addEllipsoid(to: root, radii: SCNVector3(g.chestWidth * 0.245, g.torsoHeight * 0.17, g.chestDepth * 0.53), at: SCNVector3(side * g.chestWidth * 0.245, chestY, g.chestDepth * 0.035), material: muscle)
            addSphere(to: root, radius: g.armRadius * 1.34, at: SCNVector3(side * p.armX, p.shoulderY, 0), material: muscleLight)

            let upperArmY = p.shoulderY - g.armLength * 0.23
            let forearmY = p.shoulderY - g.armLength * 0.70
            addCapsule(to: root, radius: g.armRadius * 1.08, height: g.armLength * 0.43, at: SCNVector3(side * p.armX, upperArmY, 0), material: muscle)
            addCapsule(to: root, radius: g.armRadius * 0.82, height: g.armLength * 0.40, at: SCNVector3(side * p.armX, forearmY, 0), material: muscleLight)
            addCapsule(to: root, radius: g.armRadius * 0.42, height: g.armLength * 0.12, at: SCNVector3(side * p.armX, p.shoulderY - g.armLength * 0.49, 0), material: tendon)
        }

        for row in 0..<3 {
            let y = p.hipY + g.torsoHeight * (0.48 - Float(row) * 0.14)
            for side: Float in [-1, 1] {
                addEllipsoid(to: root, radii: SCNVector3(g.waistWidth * 0.105, g.torsoHeight * 0.075, g.waistDepth * 0.54), at: SCNVector3(side * g.waistWidth * 0.12, y, g.waistDepth * 0.04), material: row.isMultiple(of: 2) ? muscleLight : muscle)
            }
        }

        addEllipsoid(to: root, radii: SCNVector3(g.hipWidth * 0.48, g.torsoHeight * 0.17, g.hipDepth * 0.52), at: SCNVector3(0, p.hipY + g.torsoHeight * 0.08, -g.hipDepth * 0.04), material: muscle)

        let thighLength = g.legLength * 0.52
        let calfLength = g.legLength * 0.48
        let kneeY = p.floorY + calfLength
        for side: Float in [-1, 1] {
            addCapsule(to: root, radius: g.thighRadius * 0.96, height: thighLength * 0.92, at: SCNVector3(side * p.legX, kneeY + thighLength * 0.53, 0), material: muscle)
            addCapsule(to: root, radius: g.calfRadius * 0.96, height: calfLength * 0.78, at: SCNVector3(side * p.legX, p.floorY + calfLength * 0.48, -g.calfRadius * 0.12), material: muscleLight)
            addCapsule(to: root, radius: g.calfRadius * 0.36, height: g.legLength * 0.10, at: SCNVector3(side * p.legX, p.floorY + g.legLength * 0.05, 0), material: tendon)
        }

        root.eulerAngles.y = -.pi / 12
        return root
    }

    private func makeSkeletonBody(for profile: TwinProfile) -> SCNNode {
        let g = BodyGeometry(profile: profile)
        let p = bodyPositions(g)
        let root = SCNNode()
        let bone = boneMaterial()
        let cartilage = cartilageMaterial()

        addEllipsoid(to: root, radii: SCNVector3(g.headRadius * 0.72, g.headRadius * 0.88, g.headRadius * 0.72), at: SCNVector3(0, p.headY, 0), material: bone)
        addCapsule(to: root, radius: g.totalHeight * 0.012, height: g.torsoHeight * 0.86, at: SCNVector3(0, p.hipY + g.torsoHeight * 0.48, -g.chestDepth * 0.22), material: bone)

        for rib in 0..<6 {
            let progress = Float(rib) / 5
            let ribRadius = (g.chestWidth * (0.42 - progress * 0.08))
            let torus = SCNTorus(ringRadius: CGFloat(ribRadius), pipeRadius: CGFloat(g.totalHeight * 0.006))
            torus.ringSegmentCount = 48
            torus.pipeSegmentCount = 10
            torus.firstMaterial = bone
            let node = SCNNode(geometry: torus)
            node.scale.z = 0.46
            node.position = SCNVector3(0, p.hipY + g.torsoHeight * (0.78 - progress * 0.10), 0)
            root.addChildNode(node)
        }

        addCapsule(to: root, radius: g.totalHeight * 0.009, height: g.shoulderWidth * 0.82, at: SCNVector3(0, p.shoulderY, 0), material: bone, rotation: SCNVector4(0, 0, 1, Float.pi / 2))
        addEllipsoid(to: root, radii: SCNVector3(g.hipWidth * 0.42, g.totalHeight * 0.055, g.hipDepth * 0.38), at: SCNVector3(0, p.hipY, 0), material: bone)

        let elbowY = p.shoulderY - g.armLength * 0.48
        let wristY = p.shoulderY - g.armLength * 0.94
        let kneeY = p.floorY + g.legLength * 0.48
        for side: Float in [-1, 1] {
            addCapsule(to: root, radius: g.totalHeight * 0.012, height: g.armLength * 0.46, at: SCNVector3(side * p.armX, (p.shoulderY + elbowY) / 2, 0), material: bone)
            addCapsule(to: root, radius: g.totalHeight * 0.009, height: g.armLength * 0.42, at: SCNVector3(side * p.armX, (elbowY + wristY) / 2, 0), material: bone)
            addCapsule(to: root, radius: g.totalHeight * 0.018, height: g.legLength * 0.47, at: SCNVector3(side * p.legX, (p.hipY + kneeY) / 2, 0), material: bone)
            addCapsule(to: root, radius: g.totalHeight * 0.013, height: g.legLength * 0.44, at: SCNVector3(side * p.legX, (kneeY + p.floorY) / 2, 0), material: bone)

            for point in [
                SCNVector3(side * p.armX, p.shoulderY, 0),
                SCNVector3(side * p.armX, elbowY, 0),
                SCNVector3(side * p.armX, wristY, 0),
                SCNVector3(side * p.legX, p.hipY, 0),
                SCNVector3(side * p.legX, kneeY, 0),
                SCNVector3(side * p.legX, p.floorY, 0)
            ] {
                addSphere(to: root, radius: g.totalHeight * 0.018, at: point, material: cartilage)
            }
        }

        root.eulerAngles.y = -.pi / 12
        return root
    }

    private func makeJointBody(for profile: TwinProfile) -> SCNNode {
        let g = BodyGeometry(profile: profile)
        let p = bodyPositions(g)
        let root = makeExteriorBody(for: profile, material: translucentMaterial(), jointMaterial: translucentMaterial())
        let joint = jointHighlightMaterial()
        let elbowY = p.shoulderY - g.armLength * 0.48
        let wristY = p.shoulderY - g.armLength * 0.94
        let kneeY = p.floorY + g.legLength * 0.48

        addSphere(to: root, radius: g.totalHeight * 0.020, at: SCNVector3(0, p.neckY, 0), material: joint)
        addSphere(to: root, radius: g.totalHeight * 0.022, at: SCNVector3(0, p.hipY + g.torsoHeight * 0.38, 0), material: joint)
        for side: Float in [-1, 1] {
            for point in [
                SCNVector3(side * p.armX, p.shoulderY, 0),
                SCNVector3(side * p.armX, elbowY, 0),
                SCNVector3(side * p.armX, wristY, 0),
                SCNVector3(side * p.legX, p.hipY, 0),
                SCNVector3(side * p.legX, kneeY, 0),
                SCNVector3(side * p.legX, p.floorY, 0)
            ] {
                addSphere(to: root, radius: g.totalHeight * 0.026, at: point, material: joint)
            }
        }
        return root
    }

    private func bodyPositions(_ g: BodyGeometry) -> (
        floorY: Float,
        hipY: Float,
        shoulderY: Float,
        neckY: Float,
        headY: Float,
        armX: Float,
        armY: Float,
        legX: Float
    ) {
        let floorY = -g.totalHeight / 2
        let hipY = floorY + g.legLength
        let shoulderY = hipY + g.torsoHeight * 0.88
        let neckY = hipY + g.torsoHeight + g.headRadius * 0.28
        return (
            floorY,
            hipY,
            shoulderY,
            neckY,
            neckY + g.headRadius * 1.18,
            g.shoulderWidth * 0.57,
            shoulderY - g.armLength * 0.48,
            g.hipWidth * 0.28
        )
    }

    private func makeGroundRing(for profile: TwinProfile, layer: TwinBodyLayer) -> SCNNode {
        let geometry = BodyGeometry(profile: profile)
        let torus = SCNTorus(ringRadius: CGFloat(geometry.shoulderWidth * 0.92), pipeRadius: 0.004)
        torus.ringSegmentCount = 96
        torus.pipeSegmentCount = 12

        let material = SCNMaterial()
        let color: UIColor = layer == .muscles
            ? UIColor(red: 0.95, green: 0.30, blue: 0.25, alpha: 0.40)
            : UIColor(red: 0.35, green: 0.94, blue: 0.72, alpha: 0.36)
        material.diffuse.contents = color
        material.emission.contents = color
        torus.firstMaterial = material

        let node = SCNNode(geometry: torus)
        node.position = SCNVector3(0, -geometry.totalHeight / 2 - geometry.calfRadius * 0.12, 0)
        return node
    }

    private func addCapsule(
        to root: SCNNode,
        radius: Float,
        height: Float,
        at position: SCNVector3,
        material: SCNMaterial,
        rotation: SCNVector4? = nil
    ) {
        let geometry = SCNCapsule(capRadius: CGFloat(radius), height: CGFloat(height))
        geometry.radialSegmentCount = 32
        geometry.firstMaterial = material
        let node = SCNNode(geometry: geometry)
        node.position = position
        if let rotation {
            node.rotation = rotation
        }
        root.addChildNode(node)
    }

    private func addSphere(to root: SCNNode, radius: Float, at position: SCNVector3, material: SCNMaterial) {
        addEllipsoid(to: root, radii: SCNVector3(radius, radius, radius), at: position, material: material)
    }

    private func addEllipsoid(to root: SCNNode, radii: SCNVector3, at position: SCNVector3, material: SCNMaterial) {
        let sphere = SCNSphere(radius: 1)
        sphere.segmentCount = 48
        sphere.firstMaterial = material
        let node = SCNNode(geometry: sphere)
        node.scale = radii
        node.position = position
        root.addChildNode(node)
    }

    private func bodyMaterial() -> SCNMaterial {
        material(
            diffuse: UIColor(red: 0.18, green: 0.24, blue: 0.25, alpha: 1),
            emission: nil,
            metalness: 0.16,
            roughness: 0.48
        )
    }

    private func glowMaterial() -> SCNMaterial {
        material(
            diffuse: UIColor(red: 0.18, green: 0.24, blue: 0.25, alpha: 1),
            emission: UIColor(red: 0.25, green: 0.72, blue: 0.58, alpha: 0.30),
            metalness: 0.12,
            roughness: 0.45
        )
    }

    private func muscleMaterial(light: Bool = false) -> SCNMaterial {
        material(
            diffuse: light
                ? UIColor(red: 0.90, green: 0.22, blue: 0.20, alpha: 1)
                : UIColor(red: 0.62, green: 0.08, blue: 0.10, alpha: 1),
            emission: UIColor(red: 0.22, green: 0.015, blue: 0.02, alpha: 0.22),
            metalness: 0.02,
            roughness: 0.62
        )
    }

    private func tendonMaterial() -> SCNMaterial {
        material(diffuse: UIColor(red: 0.76, green: 0.65, blue: 0.49, alpha: 1), emission: nil, metalness: 0, roughness: 0.72)
    }

    private func boneMaterial() -> SCNMaterial {
        material(diffuse: UIColor(red: 0.88, green: 0.85, blue: 0.70, alpha: 1), emission: nil, metalness: 0, roughness: 0.68)
    }

    private func cartilageMaterial() -> SCNMaterial {
        material(
            diffuse: UIColor(red: 0.40, green: 0.85, blue: 0.74, alpha: 1),
            emission: UIColor(red: 0.18, green: 0.52, blue: 0.45, alpha: 0.32),
            metalness: 0,
            roughness: 0.48
        )
    }

    private func translucentMaterial() -> SCNMaterial {
        let value = material(
            diffuse: UIColor(red: 0.18, green: 0.30, blue: 0.31, alpha: 0.24),
            emission: UIColor(red: 0.12, green: 0.28, blue: 0.27, alpha: 0.12),
            metalness: 0.05,
            roughness: 0.42
        )
        value.transparency = 0.32
        value.isDoubleSided = true
        return value
    }

    private func jointHighlightMaterial() -> SCNMaterial {
        material(
            diffuse: UIColor(red: 0.35, green: 0.94, blue: 0.72, alpha: 1),
            emission: UIColor(red: 0.25, green: 0.86, blue: 0.64, alpha: 0.72),
            metalness: 0.08,
            roughness: 0.28
        )
    }

    private func material(
        diffuse: UIColor,
        emission: UIColor?,
        metalness: CGFloat,
        roughness: CGFloat
    ) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = diffuse
        material.emission.contents = emission
        material.metalness.contents = metalness
        material.roughness.contents = roughness
        return material
    }
}


private struct AvatarDeformation {
    private static let referenceGeometry: BodyGeometry = {
        let birthDate = Calendar(identifier: .gregorian)
            .date(from: DateComponents(year: 1986, month: 1, day: 1))
            ?? Date(timeIntervalSince1970: 0)
        let profile = TwinProfile(
            name: "Reference",
            relationship: .me,
            biologicalSex: .male,
            birthDate: birthDate,
            heightCentimeters: 180,
            weightKilograms: 85
        )
        return BodyGeometry(profile: profile)
    }()

    let shoulderX: Float
    let chestX: Float
    let chestZ: Float
    let waistX: Float
    let waistZ: Float
    let hipX: Float
    let hipZ: Float
    let thigh: Float
    let calf: Float

    init(profile: TwinProfile) {
        let target = BodyGeometry(profile: profile)
        let reference = Self.referenceGeometry

        shoulderX = Self.ratio(
            target.shoulderWidth, target.totalHeight,
            reference.shoulderWidth, reference.totalHeight
        )
        chestX = Self.ratio(
            target.chestWidth, target.totalHeight,
            reference.chestWidth, reference.totalHeight
        )
        chestZ = Self.ratio(
            target.chestDepth, target.totalHeight,
            reference.chestDepth, reference.totalHeight
        )
        waistX = Self.ratio(
            target.waistWidth, target.totalHeight,
            reference.waistWidth, reference.totalHeight
        )
        waistZ = Self.ratio(
            target.waistDepth, target.totalHeight,
            reference.waistDepth, reference.totalHeight
        )
        hipX = Self.ratio(
            target.hipWidth, target.totalHeight,
            reference.hipWidth, reference.totalHeight
        )
        hipZ = Self.ratio(
            target.hipDepth, target.totalHeight,
            reference.hipDepth, reference.totalHeight
        )
        thigh = Self.ratio(
            target.thighRadius, target.totalHeight,
            reference.thighRadius, reference.totalHeight
        )
        calf = Self.ratio(
            target.calfRadius, target.totalHeight,
            reference.calfRadius, reference.totalHeight
        )
    }

    var isIdentity: Bool {
        [
            shoulderX, chestX, chestZ, waistX, waistZ,
            hipX, hipZ, thigh, calf
        ].allSatisfy { abs($0 - 1) < 0.001 }
    }

    func bodyShader(minimumY: Float, maximumY: Float) -> String {
        let height = max(maximumY - minimumY, 0.001)

        return """
        #pragma body
        float eidomeY = clamp(
            (_geometry.position.y - \(Self.format(minimumY))) / \(Self.format(height)),
            0.0,
            1.0
        );
        float eidomeCentral = 1.0 - smoothstep(
            \(Self.format(height * 0.15)),
            \(Self.format(height * 0.31)),
            abs(_geometry.position.x)
        );

        float eidomeCalf = smoothstep(0.04, 0.15, eidomeY)
            * (1.0 - smoothstep(0.27, 0.35, eidomeY));
        float eidomeThigh = smoothstep(0.24, 0.34, eidomeY)
            * (1.0 - smoothstep(0.47, 0.53, eidomeY));
        float eidomeHip = smoothstep(0.43, 0.49, eidomeY)
            * (1.0 - smoothstep(0.56, 0.62, eidomeY));
        float eidomeWaist = smoothstep(0.51, 0.58, eidomeY)
            * (1.0 - smoothstep(0.65, 0.71, eidomeY));
        float eidomeChest = smoothstep(0.60, 0.68, eidomeY)
            * (1.0 - smoothstep(0.76, 0.82, eidomeY));
        float eidomeShoulder = smoothstep(0.70, 0.76, eidomeY)
            * (1.0 - smoothstep(0.83, 0.88, eidomeY));

        float eidomeXScale = 1.0;
        eidomeXScale = mix(eidomeXScale, \(Self.format(calf)), eidomeCalf * eidomeCentral);
        eidomeXScale = mix(eidomeXScale, \(Self.format(thigh)), eidomeThigh * eidomeCentral);
        eidomeXScale = mix(eidomeXScale, \(Self.format(hipX)), eidomeHip * eidomeCentral);
        eidomeXScale = mix(eidomeXScale, \(Self.format(waistX)), eidomeWaist * eidomeCentral);
        eidomeXScale = mix(eidomeXScale, \(Self.format(chestX)), eidomeChest * eidomeCentral);
        eidomeXScale = mix(eidomeXScale, \(Self.format(shoulderX)), eidomeShoulder);

        float eidomeZScale = 1.0;
        eidomeZScale = mix(eidomeZScale, \(Self.format(calf)), eidomeCalf);
        eidomeZScale = mix(eidomeZScale, \(Self.format(thigh)), eidomeThigh);
        eidomeZScale = mix(eidomeZScale, \(Self.format(hipZ)), eidomeHip);
        eidomeZScale = mix(eidomeZScale, \(Self.format(waistZ)), eidomeWaist);
        eidomeZScale = mix(eidomeZScale, \(Self.format(chestZ)), eidomeChest);

        _geometry.position.x *= eidomeXScale;
        _geometry.position.z *= eidomeZScale;
        _geometry.normal.x /= max(eidomeXScale, 0.01);
        _geometry.normal.z /= max(eidomeZScale, 0.01);
        _geometry.normal = normalize(_geometry.normal);
        """
    }

    func clothingShader(minimumY: Float, maximumY: Float) -> String {
        let height = max(maximumY - minimumY, 0.001)
        let clothingX = max(thigh, max(hipX, waistX)) * 1.03
        let clothingZ = max(thigh, max(hipZ, waistZ)) * 1.03

        return """
        #pragma body
        float eidomeY = clamp(
            (_geometry.position.y - \(Self.format(minimumY))) / \(Self.format(height)),
            0.0,
            1.0
        );
        float eidomeHemEase = smoothstep(0.0, 0.18, eidomeY);
        float eidomeXScale = mix(
            \(Self.format(clothingX * 1.02)),
            \(Self.format(clothingX)),
            eidomeHemEase
        );
        float eidomeZScale = mix(
            \(Self.format(clothingZ * 1.02)),
            \(Self.format(clothingZ)),
            eidomeHemEase
        );

        _geometry.position.x *= eidomeXScale;
        _geometry.position.z *= eidomeZScale;
        _geometry.normal.x /= max(eidomeXScale, 0.01);
        _geometry.normal.z /= max(eidomeZScale, 0.01);
        _geometry.normal = normalize(_geometry.normal);
        """
    }

    private static func ratio(
        _ targetValue: Float,
        _ targetHeight: Float,
        _ referenceValue: Float,
        _ referenceHeight: Float
    ) -> Float {
        let targetProportion = targetValue / max(targetHeight, 0.001)
        let referenceProportion = referenceValue / max(referenceHeight, 0.001)
        return min(max(targetProportion / max(referenceProportion, 0.001), 0.78), 1.28)
    }

    private static func format(_ value: Float) -> String {
        String(
            format: "%.6f",
            locale: Locale(identifier: "en_US_POSIX"),
            Double(value)
        )
    }
}
