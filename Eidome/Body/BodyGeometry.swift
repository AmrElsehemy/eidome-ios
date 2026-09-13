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
        totalHeight = 1.72 * normalizedHeight
        let sceneScale = totalHeight / max(heightMeters, 0.8)

        let age = max(2, profile.age)
        let headRatio: Float = age < 7 ? 0.078 : age < 13 ? 0.071 : 0.064
        headRadius = totalHeight * headRatio

        let bmiFactor = Float(min(max((profile.bmi - 21) / 22, -0.18), 0.48))
        let sexShoulderFactor: Float = profile.biologicalSex == .male ? 1.04 : 0.94
        let sexHipFactor: Float = profile.biologicalSex == .female ? 1.07 : 0.98
        let youthScale: Float = age < 13 ? 0.88 : 1
        let measurements = profile.bodyMeasurements

        func sceneLength(_ centimeters: Double) -> Float {
            Float(centimeters / 100) * sceneScale
        }

        func ellipseDiameters(for circumference: Double, widthRatio: Float) -> (width: Float, depth: Float) {
            let averageDiameter = sceneLength(circumference) / .pi
            return (averageDiameter * widthRatio, averageDiameter * (2 - widthRatio))
        }

        shoulderWidth = measurements?.shoulderWidthCentimeters.map(sceneLength)
            ?? totalHeight * 0.235 * sexShoulderFactor * youthScale * (1 + bmiFactor * 0.32)
        torsoHeight = totalHeight * (age < 13 ? 0.27 : 0.30)

        if let chest = measurements?.chestCircumferenceCentimeters {
            let diameters = ellipseDiameters(for: chest, widthRatio: 1.14)
            chestWidth = diameters.width
            chestDepth = diameters.depth
        } else {
            chestWidth = shoulderWidth * 0.86
            chestDepth = totalHeight * 0.108 * (1 + bmiFactor * 0.8)
        }

        if let waist = measurements?.waistCircumferenceCentimeters {
            let diameters = ellipseDiameters(for: waist, widthRatio: 1.10)
            waistWidth = diameters.width
            waistDepth = diameters.depth
        } else {
            waistWidth = totalHeight * 0.155 * (1 + bmiFactor * 0.75)
            waistDepth = totalHeight * 0.098 * (1 + bmiFactor * 0.82)
        }

        if let hips = measurements?.hipCircumferenceCentimeters {
            let diameters = ellipseDiameters(for: hips, widthRatio: 1.18)
            hipWidth = diameters.width
            hipDepth = diameters.depth
        } else {
            hipWidth = totalHeight * 0.19 * sexHipFactor * youthScale * (1 + bmiFactor * 0.45)
            hipDepth = totalHeight * 0.105 * (1 + bmiFactor * 0.70)
        }

        armLength = totalHeight * (age < 13 ? 0.31 : 0.34)
        armRadius = totalHeight * 0.034 * (1 + bmiFactor * 0.55)
        legLength = measurements?.inseamCentimeters.map {
            min(max(sceneLength($0), totalHeight * 0.38), totalHeight * 0.55)
        } ?? totalHeight * (age < 13 ? 0.43 : 0.47)
        thighRadius = measurements?.thighCircumferenceCentimeters.map {
            sceneLength($0) / (2 * .pi)
        } ?? totalHeight * 0.049 * (1 + bmiFactor * 0.6)
        calfRadius = measurements?.calfCircumferenceCentimeters.map {
            sceneLength($0) / (2 * .pi)
        } ?? thighRadius * 0.72
    }
}
