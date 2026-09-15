#!/usr/bin/env swift

import Foundation
import SceneKit

enum ValidationFailure: Error, CustomStringConvertible {
    case invalid(String)

    var description: String {
        switch self {
        case .invalid(let message): return message
        }
    }
}

func fail(_ message: String) throws -> Never {
    throw ValidationFailure.invalid(message)
}

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: validate_usdz_scene.swift <avatar.usdz> <report.json>\n", stderr)
    exit(2)
}

let assetURL = URL(fileURLWithPath: CommandLine.arguments[1])
let reportURL = URL(fileURLWithPath: CommandLine.arguments[2])

do {
    let scene = try SCNScene(
        url: assetURL,
        options: [SCNSceneSource.LoadingOption.checkConsistency: true]
    )

    var geometryCount = 0
    var materialCount = 0
    var skinnerCount = 0
    var minimum = SCNVector3(
        Float.greatestFiniteMagnitude,
        Float.greatestFiniteMagnitude,
        Float.greatestFiniteMagnitude
    )
    var maximum = SCNVector3(
        -Float.greatestFiniteMagnitude,
        -Float.greatestFiniteMagnitude,
        -Float.greatestFiniteMagnitude
    )

    func include(_ point: SCNVector3) throws {
        guard point.x.isFinite, point.y.isFinite, point.z.isFinite else {
            try fail("USDZ contains non-finite geometry coordinates.")
        }
        minimum.x = min(minimum.x, point.x)
        minimum.y = min(minimum.y, point.y)
        minimum.z = min(minimum.z, point.z)
        maximum.x = max(maximum.x, point.x)
        maximum.y = max(maximum.y, point.y)
        maximum.z = max(maximum.z, point.z)
    }

    scene.rootNode.enumerateChildNodes { node, _ in
        guard let geometry = node.geometry else { return }
        geometryCount += 1
        materialCount += geometry.materials.count
        if node.skinner != nil {
            skinnerCount += 1
        }

        let (localMinimum, localMaximum) = node.boundingBox
        let corners = [
            SCNVector3(localMinimum.x, localMinimum.y, localMinimum.z),
            SCNVector3(localMinimum.x, localMinimum.y, localMaximum.z),
            SCNVector3(localMinimum.x, localMaximum.y, localMinimum.z),
            SCNVector3(localMinimum.x, localMaximum.y, localMaximum.z),
            SCNVector3(localMaximum.x, localMinimum.y, localMinimum.z),
            SCNVector3(localMaximum.x, localMinimum.y, localMaximum.z),
            SCNVector3(localMaximum.x, localMaximum.y, localMinimum.z),
            SCNVector3(localMaximum.x, localMaximum.y, localMaximum.z),
        ]
        for corner in corners {
            try? include(node.convertPosition(corner, to: scene.rootNode))
        }
    }

    guard geometryCount >= 3 else {
        try fail("Expected at least body, eyes, and clothing geometry; found \(geometryCount).")
    }
    guard materialCount >= 3 else {
        try fail("Expected Apple-renderable materials on every avatar mesh.")
    }
    guard skinnerCount == 0 else {
        try fail("Static iOS avatar unexpectedly contains \(skinnerCount) skinned nodes.")
    }

    let width = maximum.x - minimum.x
    let height = maximum.y - minimum.y
    let depth = maximum.z - minimum.z
    guard width.isFinite, height.isFinite, depth.isFinite, height > 0 else {
        try fail("USDZ produced invalid aggregate bounds.")
    }

    let widthToHeight = width / height
    let depthToHeight = depth / height
    guard (1.40...2.20).contains(height) else {
        try fail("USDZ height \(height)m is outside the expected human range.")
    }
    guard (0.35...1.00).contains(widthToHeight) else {
        try fail("USDZ width/height ratio \(widthToHeight) is implausible.")
    }
    guard (0.08...0.60).contains(depthToHeight) else {
        try fail("USDZ depth/height ratio \(depthToHeight) is implausible.")
    }

    let report: [String: Any] = [
        "status": "passed",
        "geometry_count": geometryCount,
        "material_count": materialCount,
        "skinner_count": skinnerCount,
        "height": height,
        "width_to_height": widthToHeight,
        "depth_to_height": depthToHeight,
    ]
    let data = try JSONSerialization.data(
        withJSONObject: report,
        options: [.prettyPrinted, .sortedKeys]
    )
    try data.write(to: reportURL)
    print("Apple SceneKit USDZ validation passed")
    print(String(decoding: data, as: UTF8.self))
} catch {
    fputs("Apple SceneKit USDZ validation failed: \(error)\n", stderr)
    exit(1)
}
