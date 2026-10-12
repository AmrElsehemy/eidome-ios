import Foundation

struct BodyMeasurements: Codable, Hashable {
    var shoulderWidthCentimeters: Double? = nil
    var chestCircumferenceCentimeters: Double? = nil
    var waistCircumferenceCentimeters: Double? = nil
    var hipCircumferenceCentimeters: Double? = nil
    var inseamCentimeters: Double? = nil
    var thighCircumferenceCentimeters: Double? = nil
    var calfCircumferenceCentimeters: Double? = nil

    var completedCount: Int {
        [
            shoulderWidthCentimeters,
            chestCircumferenceCentimeters,
            waistCircumferenceCentimeters,
            hipCircumferenceCentimeters,
            inseamCentimeters,
            thighCircumferenceCentimeters,
            calfCircumferenceCentimeters
        ].compactMap { $0 }.count
    }

    var isEmpty: Bool { completedCount == 0 }
}

enum BodyMeasurementKind: String, Codable, CaseIterable, Identifiable {
    case shoulderWidth = "shoulderWidth"
    case chestCircumference = "chestCircumference"
    case waistCircumference = "waistCircumference"
    case hipCircumference = "hipCircumference"
    case inseam = "inseam"
    case thighCircumference = "thighCircumference"
    case calfCircumference = "calfCircumference"

    var id: String { rawValue }
    var storageKey: String { rawValue }
}

enum MeasurementUnit: String, Codable, CaseIterable, Identifiable {
    case centimeters = "cm"
    case inches = "in"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .centimeters: "cm"
        case .inches: "in"
        }
    }
}

enum MeasurementSide: String, Codable, CaseIterable, Identifiable {
    case center = "Centre"
    case left = "Left"
    case right = "Right"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .center: "Centre"
        case .left: "Left"
        case .right: "Right"
        }
    }
}

enum MeasurementMethod: String, Codable, CaseIterable, Identifiable {
    case selfTape = "Self-measured tape"
    case assistedTape = "Assisted tape"
    case other = "Other method"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .selfTape: "Self-measured tape"
        case .assistedTape: "Assisted tape"
        case .other: "Other method"
        }
    }
}

enum MeasurementConfidence: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }
}

struct BodyMeasurementMetadata: Codable, Hashable {
    var recordedAt: Date
    var unit: MeasurementUnit
    var side: MeasurementSide
    var method: MeasurementMethod
    var confidence: MeasurementConfidence
}

struct MobilityProfile: Codable, Hashable {
    var leftAnkleDorsiflexion: Double? = nil
    var rightAnkleDorsiflexion: Double? = nil
    var leftHipInternalRotation: Double? = nil
    var rightHipInternalRotation: Double? = nil
    var leftShoulderFlexion: Double? = nil
    var rightShoulderFlexion: Double? = nil
    var leftThoracicRotation: Double? = nil
    var rightThoracicRotation: Double? = nil

    var values: [Double] {
        [
            leftAnkleDorsiflexion, rightAnkleDorsiflexion,
            leftHipInternalRotation, rightHipInternalRotation,
            leftShoulderFlexion, rightShoulderFlexion,
            leftThoracicRotation, rightThoracicRotation
        ].compactMap { $0 }
    }

    var completedCount: Int { values.count }
    var isEmpty: Bool { completedCount == 0 }

    var largestAsymmetry: Double? {
        let pairs = [
            pairedDifference(leftAnkleDorsiflexion, rightAnkleDorsiflexion),
            pairedDifference(leftHipInternalRotation, rightHipInternalRotation),
            pairedDifference(leftShoulderFlexion, rightShoulderFlexion),
            pairedDifference(leftThoracicRotation, rightThoracicRotation)
        ].compactMap { $0 }
        return pairs.max()
    }

    private func pairedDifference(_ left: Double?, _ right: Double?) -> Double? {
        guard let left, let right else { return nil }
        return abs(left - right)
    }
}

struct TwinProfile: Identifiable, Codable, Hashable {
    enum Relationship: String, Codable, CaseIterable, Identifiable {
        case me = "Me"
        case child = "Child"
        case other = "Other"

        var id: String { rawValue }
    }

    enum BiologicalSex: String, Codable, CaseIterable, Identifiable {
        case male = "Male"
        case female = "Female"

        var id: String { rawValue }
    }

    let id: UUID
    var name: String
    var relationship: Relationship
    var biologicalSex: BiologicalSex
    var birthDate: Date
    var heightCentimeters: Double
    var weightKilograms: Double
    var createdAt: Date
    var bodyMeasurements: BodyMeasurements?
    var measurementsUpdatedAt: Date?
    var measurementMetadata: [String: BodyMeasurementMetadata]?
    var mobilityProfile: MobilityProfile?
    var measurementHistory: [MeasurementSnapshot]? = nil

    init(
        id: UUID = UUID(),
        name: String,
        relationship: Relationship,
        biologicalSex: BiologicalSex,
        birthDate: Date,
        heightCentimeters: Double,
        weightKilograms: Double,
        createdAt: Date = .now,
        bodyMeasurements: BodyMeasurements? = nil,
        measurementsUpdatedAt: Date? = nil,
        measurementMetadata: [String: BodyMeasurementMetadata]? = nil,
        mobilityProfile: MobilityProfile? = nil
    ) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.biologicalSex = biologicalSex
        self.birthDate = birthDate
        self.heightCentimeters = heightCentimeters
        self.weightKilograms = weightKilograms
        self.createdAt = createdAt
        self.bodyMeasurements = bodyMeasurements
        self.measurementsUpdatedAt = measurementsUpdatedAt
        self.measurementMetadata = measurementMetadata
        self.mobilityProfile = mobilityProfile
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: .now).year ?? 0
    }

    var bmi: Double {
        let meters = heightCentimeters / 100
        guard meters > 0 else { return 0 }
        return weightKilograms / (meters * meters)
    }

    var completeness: Int {
        let measuredShapeInputs = bodyMeasurements?.completedCount ?? 0
        let shapeScore = Int((Double(measuredShapeInputs) / 7.0 * 16.0).rounded())
        let mobilityInputs = mobilityProfile?.completedCount ?? 0
        let mobilityScore = Int((Double(mobilityInputs) / 8.0 * 14.0).rounded())
        return min(38, 8 + shapeScore + mobilityScore)
    }
}

struct TwinDraft {
    var name = ""
    var relationship: TwinProfile.Relationship = .me
    var biologicalSex: TwinProfile.BiologicalSex = .male
    var birthDate = Calendar.current.date(byAdding: .year, value: -30, to: .now) ?? .now
    var heightCentimeters = 175.0
    var weightKilograms = 75.0

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        heightCentimeters >= 80 && heightCentimeters <= 230 &&
        weightKilograms >= 15 && weightKilograms <= 250
    }

    func makeProfile() -> TwinProfile {
        TwinProfile(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            relationship: relationship,
            biologicalSex: biologicalSex,
            birthDate: birthDate,
            heightCentimeters: heightCentimeters,
            weightKilograms: weightKilograms
        )
    }
}


/// A saved set of entered values, not a measured avatar or a clinical observation.
struct MeasurementSnapshot: Identifiable, Codable, Hashable {
    let id: UUID
    let savedAt: Date
    let isStartingRecord: Bool
    let height: Double
    let weight: Double
    let body: BodyMeasurements?
    let metadata: [String: BodyMeasurementMetadata]?
    let mobility: MobilityProfile?

    init(profile: TwinProfile, starting: Bool = false, date: Date = .now) {
        id = UUID()
        savedAt = date
        isStartingRecord = starting
        height = profile.heightCentimeters
        weight = profile.weightKilograms
        body = profile.bodyMeasurements
        metadata = profile.measurementMetadata
        mobility = profile.mobilityProfile
    }

    func matches(_ profile: TwinProfile) -> Bool {
        height == profile.heightCentimeters && weight == profile.weightKilograms
            && body == profile.bodyMeasurements && metadata == profile.measurementMetadata
            && mobility == profile.mobilityProfile
    }

    var readings: [(name: String, value: Double?, unit: String)] {
        [
            ("Height", height, "cm"), ("Weight", weight, "kg"),
            ("Shoulder width", body?.shoulderWidthCentimeters, "cm"),
            ("Chest", body?.chestCircumferenceCentimeters, "cm"),
            ("Waist", body?.waistCircumferenceCentimeters, "cm"),
            ("Hip", body?.hipCircumferenceCentimeters, "cm"),
            ("Inseam", body?.inseamCentimeters, "cm"),
            ("Thigh", body?.thighCircumferenceCentimeters, "cm"),
            ("Calf", body?.calfCircumferenceCentimeters, "cm"),
            ("Left ankle dorsiflexion", mobility?.leftAnkleDorsiflexion, "°"),
            ("Right ankle dorsiflexion", mobility?.rightAnkleDorsiflexion, "°"),
            ("Left hip internal rotation", mobility?.leftHipInternalRotation, "°"),
            ("Right hip internal rotation", mobility?.rightHipInternalRotation, "°"),
            ("Left shoulder flexion", mobility?.leftShoulderFlexion, "°"),
            ("Right shoulder flexion", mobility?.rightShoulderFlexion, "°"),
            ("Left thoracic rotation", mobility?.leftThoracicRotation, "°"),
            ("Right thoracic rotation", mobility?.rightThoracicRotation, "°")
        ]
    }
}
