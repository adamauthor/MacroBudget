import SwiftUI

enum PresetColorOption: String, CaseIterable, Identifiable {
    case blue
    case green
    case orange
    case red
    case gray

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: return Color(.systemBlue)
        case .green: return Color(.systemGreen)
        case .orange: return Color(.systemOrange)
        case .red: return Color(.systemRed)
        case .gray: return Color(.systemGray)
        }
    }
}

enum PresetIconOption: String, CaseIterable, Identifiable {
    case bolt
    case flame
    case dumbbell
    case moon
    case sun

    var id: String { rawValue }

    var systemName: String {
        switch self {
        case .bolt: return "bolt.fill"
        case .flame: return "flame.fill"
        case .dumbbell: return "dumbbell.fill"
        case .moon: return "moon.fill"
        case .sun: return "sun.max.fill"
        }
    }
}
