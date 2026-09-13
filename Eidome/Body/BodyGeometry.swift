import Foundation

struct BodyGeometry: Equatable {
    let totalHeight: Float
    let headRadius: Float
    let shoulderWidth: Float
    let torsoHeight: Float
    let torsoDepth: Float
    let waistWidth: Float
    let hipWidth: Float
    let armLength: Float
    let armRadius: Float
    let legLength: Float
    let legRadius: Float

    init(profile: TwinProfile) {
        let normalizedHeight = Float(profile.heightCentimeters / 175)
        totalHeight = 1.72 * normalizedHeight

        let age = max(2, profile.age)
        let headRatio: Float = age < 7 ? 0.078 : age < 13 ? 0.071 : 0.064
        headRadius = totalHeight * headRatio

        let bmiFactor = Float(min(max((profile.bmi - 21) / 22, -0.18), 0.48))
        let sexShoulderFactor: Float = profile.biologicalSex == .male ? 1.04 : 0.94
        let sexHipFactor: Float = profile.biologicalSex == .female ? 1.07 : 0.98
        let youthScale: Float = age < 13 ? 0.88 : 1

        shoulderWidth = totalHeight * 0.235 * sexShoulderFactor * youthScale * (1 + bmiFactor * 0.32)
        torsoHeight = totalHeight * (age < 13 ? 0.27 : 0.30)
        torsoDepth = totalHeight * 0.105 * (1 + bmiFactor * 0.8)
        waistWidth = totalHeight * 0.155 * (1 + bmiFactor * 0.75)
        hipWidth = totalHeight * 0.19 * sexHipFactor * youthScale * (1 + bmiFactor * 0.45)
        armLength = totalHeight * (age < 13 ? 0.31 : 0.34)
        armRadius = totalHeight * 0.034 * (1 + bmiFactor * 0.55)
        legLength = totalHeight * (age < 13 ? 0.43 : 0.47)
        legRadius = totalHeight * 0.047 * (1 + bmiFactor * 0.6)
    }
}
