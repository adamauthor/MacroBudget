import Foundation

enum BiologicalSex: String, CaseIterable, Identifiable {
    case male
    case female

    var id: String { rawValue }

    var title: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}

enum ActivityLevel: String, CaseIterable, Identifiable {
    case sedentary
    case light
    case moderate
    case high
    case veryHigh

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .veryHigh: return "Very High"
        }
    }

    var coefficient: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .high: return 1.725
        case .veryHigh: return 1.9
        }
    }
}

enum GoalType: String, CaseIterable, Identifiable {
    case cut
    case maintain
    case gain

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cut: return "Fat Loss"
        case .maintain: return "Maintain"
        case .gain: return "Gain"
        }
    }
}

enum PaceType: String, CaseIterable, Identifiable {
    case gentle
    case standard
    case aggressive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gentle: return "Gentle"
        case .standard: return "Standard"
        case .aggressive: return "Aggressive"
        }
    }
}
