import Foundation

struct BodyGeometry: Equatable {
    let totalHeight: Float
    let headRadius: Float
    let shoulderWidth: Float
    let torsoHeight: Float
    let chestWidth: Float
    let chestDepth: Float
    let waistWidth: Float
    let waistDepth: Float
    let hipWidth: Float
    let hipDepth: Float
    let armLength: Float
    let armRadius: Float
    let legLength: Float
    let thighRadius: Float
    let calfRadius: Float

    init(profile: TwinProfile) {
        let heightMeters = Float(profile.heightCentimeters / 100)
        let normalizedHeight = Float(profile.heightCentimeters / 175)
        let modelHeight = 1.72 * normalizedHeight
        let sceneScale = modelHeight / max(heightMeters, 0.8)

        let age = max(2, profile.age)
        let headRatio: Float = age < 7 ? 0.078 : age < 13 ? 0.071 : 0.064
        let bmiFactor = Float(min(max((profile.bmi - 21) / 22, -0.18), 0.48))
        let sexShoulderFactor: Float = profile.biologicalSex == .male ? 1.04 : 0.94
        let sexHipFactor: Float = profile.biologicalSex == .female ? 1.07 : 0.98
        let youthScale: Float = age < 13 ? 0.88 : 1
        let measurements = profile.bodyMeasurements

        func sceneLength(_ centimeters: Double) -> Float {
            Float(centimeters / 100) * sceneScale
        }

        func ellipseDiameters(for circumference: Double, widthRatio: Float) -> (width: Float, depth: Float) {
            let averageDiameter = sceneLength(circumference) / Float.pi
            return (averageDiameter * widthRatio, averageDiameter * (2 - widthRatio))
        }

        let resolvedShoulderWidth = measurements?.shoulderWidthCentimeters.map(sceneLength)
            ?? modelHeight * 0.235 * sexShoulderFactor * youthScale * (1 + bmiFactor * 0.32)

        let resolvedChest: (width: Float, depth: Float)
        if let chest = measurements?.chestCircumferenceCentimeters {
            resolvedChest = ellipseDiameters(for: chest, widthRatio: 1.14)
        } else {
            resolvedChest = (
                resolvedShoulderWidth * 0.86,
                modelHeight * 0.108 * (1 + bmiFactor * 0.8)
            )
        }

        let resolvedWaist: (width: Float, depth: Float)
        if let waist = measurements?.waistCircumferenceCentimeters {
            resolvedWaist = ellipseDiameters(for: waist, widthRatio: 1.10)
        } else {
            resolvedWaist = (
                modelHeight * 0.155 * (1 + bmiFactor * 0.75),
                modelHeight * 0.098 * (1 + bmiFactor * 0.82)
            )
        }

        let resolvedHips: (width: Float, depth: Float)
        if let hips = measurements?.hipCircumferenceCentimeters {
            resolvedHips = ellipseDiameters(for: hips, widthRatio: 1.18)
        } else {
            resolvedHips = (
                modelHeight * 0.19 * sexHipFactor * youthScale * (1 + bmiFactor * 0.45),
                modelHeight * 0.105 * (1 + bmiFactor * 0.70)
            )
        }

        let resolvedLegLength: Float
        if let inseam = measurements?.inseamCentimeters {
            resolvedLegLength = min(max(sceneLength(inseam), modelHeight * 0.38), modelHeight * 0.55)
        } else {
            resolvedLegLength = modelHeight * (age < 13 ? 0.43 : 0.47)
        }

        let resolvedThighRadius = measurements?.thighCircumferenceCentimeters.map {
            sceneLength($0) / (2 * Float.pi)
        } ?? modelHeight * 0.049 * (1 + bmiFactor * 0.6)
        let resolvedCalfRadius = measurements?.calfCircumferenceCentimeters.map {
            sceneLength($0) / (2 * Float.pi)
        } ?? resolvedThighRadius * 0.72

        totalHeight = modelHeight
        headRadius = modelHeight * headRatio
        shoulderWidth = resolvedShoulderWidth
        torsoHeight = modelHeight * (age < 13 ? 0.27 : 0.30)
        chestWidth = resolvedChest.width
        chestDepth = resolvedChest.depth
        waistWidth = resolvedWaist.width
        waistDepth = resolvedWaist.depth
        hipWidth = resolvedHips.width
        hipDepth = resolvedHips.depth
        armLength = modelHeight * (age < 13 ? 0.31 : 0.34)
        armRadius = modelHeight * 0.034 * (1 + bmiFactor * 0.55)
        legLength = resolvedLegLength
        thighRadius = resolvedThighRadius
        calfRadius = resolvedCalfRadius
    }
}
