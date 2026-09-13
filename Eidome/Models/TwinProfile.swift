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

    init(
        id: UUID = UUID(),
        name: String,
        relationship: Relationship,
        biologicalSex: BiologicalSex,
        birthDate: Date,
        heightCentimeters: Double,
        weightKilograms: Double,
        createdAt: Date = .now,
        bodyMeasurements: BodyMeasurements? = nil
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
        return min(24, 8 + Int((Double(measuredShapeInputs) / 7.0 * 16.0).rounded()))
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
