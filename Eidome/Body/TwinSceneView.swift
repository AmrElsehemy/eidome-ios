import SceneKit
import SwiftUI
import UIKit

struct TwinSceneView: UIViewRepresentable {
    let profile: TwinProfile

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.allowsCameraControl = true
        view.defaultCameraController.interactionMode = .orbitTurntable
        view.defaultCameraController.inertiaEnabled = true
        view.autoenablesDefaultLighting = false
        configureScene(in: view, profile: profile)
        context.coordinator.lastProfile = profile
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        guard context.coordinator.lastProfile != profile else { return }
        configureScene(in: view, profile: profile)
        context.coordinator.lastProfile = profile
    }

    final class Coordinator {
        var lastProfile: TwinProfile?
    }

    private func configureScene(in view: SCNView, profile: TwinProfile) {
        let scene = SCNScene()
        let body = makeBody(for: profile)
        scene.rootNode.addChildNode(body)
        scene.rootNode.addChildNode(makeGroundRing(for: profile))

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.fieldOfView = 31
        camera.position = SCNVector3(0, 0.08, 3.45)
        camera.look(at: SCNVector3(0, 0.02, 0))
        scene.rootNode.addChildNode(camera)

        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light?.type = .omni
        keyLight.light?.intensity = 1050
        keyLight.light?.color = UIColor(red: 0.36, green: 0.52, blue: 1, alpha: 1)
        keyLight.position = SCNVector3(-2.2, 2.2, 2.4)
        scene.rootNode.addChildNode(keyLight)

        let rimLight = SCNNode()
        rimLight.light = SCNLight()
        rimLight.light?.type = .omni
        rimLight.light?.intensity = 900
        rimLight.light?.color = UIColor(red: 0.35, green: 0.94, blue: 0.72, alpha: 1)
        rimLight.position = SCNVector3(2.0, 0.7, -1.5)
        scene.rootNode.addChildNode(rimLight)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 260
        ambient.light?.color = UIColor(white: 0.48, alpha: 1)
        scene.rootNode.addChildNode(ambient)

        view.scene = scene
        view.pointOfView = camera
    }

    private func makeBody(for profile: TwinProfile) -> SCNNode {
        let g = BodyGeometry(profile: profile)
        let root = SCNNode()
        let material = bodyMaterial()
        let jointMaterial = glowMaterial()

        let floorY = -g.totalHeight / 2
        let legCenterY = floorY + g.legLength / 2
        let hipY = floorY + g.legLength
        let torsoCenterY = hipY + g.torsoHeight / 2
        let shoulderY = hipY + g.torsoHeight * 0.88
        let neckY = hipY + g.torsoHeight + g.headRadius * 0.28
        let headY = neckY + g.headRadius * 1.18

        addEllipsoid(to: root, radii: SCNVector3(g.headRadius * 0.82, g.headRadius, g.headRadius * 0.83), at: SCNVector3(0, headY, 0), material: material)
        addCapsule(to: root, radius: g.headRadius * 0.34, height: g.headRadius * 0.75, at: SCNVector3(0, neckY, 0), material: material)

        let torsoWidth = (g.shoulderWidth + g.waistWidth) / 2
        let torso = SCNBox(
            width: CGFloat(torsoWidth),
            height: CGFloat(g.torsoHeight),
            length: CGFloat(g.torsoDepth),
            chamferRadius: CGFloat(torsoWidth * 0.18)
        )
        torso.widthSegmentCount = 8
        torso.heightSegmentCount = 8
        torso.lengthSegmentCount = 8
        let torsoNode = SCNNode(geometry: torso)
        torsoNode.geometry?.firstMaterial = material
        torsoNode.position = SCNVector3(0, torsoCenterY, 0)
        torsoNode.scale = SCNVector3(1, 1, 1)
        root.addChildNode(torsoNode)

        addEllipsoid(
            to: root,
            radii: SCNVector3(g.shoulderWidth / 2, g.totalHeight * 0.065, g.torsoDepth * 0.52),
            at: SCNVector3(0, shoulderY, 0),
            material: material
        )

        addEllipsoid(to: root, radii: SCNVector3(g.hipWidth / 2, g.totalHeight * 0.075, g.torsoDepth * 0.56), at: SCNVector3(0, hipY, 0), material: material)

        let armX = g.shoulderWidth * 0.57
        let armY = shoulderY - g.armLength * 0.48
        for side: Float in [-1, 1] {
            addCapsule(to: root, radius: g.armRadius, height: g.armLength, at: SCNVector3(side * armX, armY, 0), material: material)
            addSphere(to: root, radius: g.armRadius * 1.10, at: SCNVector3(side * armX, shoulderY, 0), material: jointMaterial)
            addEllipsoid(to: root, radii: SCNVector3(g.armRadius * 0.92, g.armRadius * 1.55, g.armRadius * 0.72), at: SCNVector3(side * armX, armY - g.armLength * 0.55, 0), material: material)
        }

        let legX = g.hipWidth * 0.28
        for side: Float in [-1, 1] {
            addCapsule(to: root, radius: g.legRadius, height: g.legLength, at: SCNVector3(side * legX, legCenterY, 0), material: material)
            addSphere(to: root, radius: g.legRadius * 1.02, at: SCNVector3(side * legX, hipY, 0), material: jointMaterial)
            addEllipsoid(to: root, radii: SCNVector3(g.legRadius * 0.95, g.legRadius * 0.55, g.legRadius * 1.65), at: SCNVector3(side * legX, floorY - g.legRadius * 0.05, g.legRadius * 0.62), material: material)
        }

        root.eulerAngles.y = -.pi / 12
        return root
    }

    private func makeGroundRing(for profile: TwinProfile) -> SCNNode {
        let geometry = BodyGeometry(profile: profile)
        let torus = SCNTorus(
            ringRadius: CGFloat(geometry.shoulderWidth * 0.92),
            pipeRadius: 0.004
        )
        torus.ringSegmentCount = 96
        torus.pipeSegmentCount = 12

        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.35, green: 0.94, blue: 0.72, alpha: 0.36)
        material.emission.contents = UIColor(red: 0.18, green: 0.62, blue: 0.49, alpha: 0.32)
        torus.firstMaterial = material

        let node = SCNNode(geometry: torus)
        node.position = SCNVector3(0, -geometry.totalHeight / 2 - geometry.legRadius * 0.12, 0)
        return node
    }

    private func addCapsule(to root: SCNNode, radius: Float, height: Float, at position: SCNVector3, material: SCNMaterial) {
        let geometry = SCNCapsule(capRadius: CGFloat(radius), height: CGFloat(height))
        geometry.radialSegmentCount = 32
        geometry.firstMaterial = material
        let node = SCNNode(geometry: geometry)
        node.position = position
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
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(red: 0.18, green: 0.24, blue: 0.25, alpha: 1)
        material.metalness.contents = 0.16
        material.roughness.contents = 0.48
        return material
    }

    private func glowMaterial() -> SCNMaterial {
        let material = bodyMaterial()
        material.emission.contents = UIColor(red: 0.25, green: 0.72, blue: 0.58, alpha: 0.30)
        return material
    }
}
