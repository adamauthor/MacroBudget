import SwiftUI

enum AccentColorOption: String, CaseIterable, Identifiable {
    case blue
    case teal
    case green
    case orange
    case pink

    var id: String { rawValue }

    var title: String {
        switch self {
        case .blue: return "Blue"
        case .teal: return "Teal"
        case .green: return "Green"
        case .orange: return "Orange"
        case .pink: return "Pink"
        }
    }

    var color: Color {
        switch self {
        case .blue: return Color(.systemBlue)
        case .teal: return Color(.systemTeal)
        case .green: return Color(.systemGreen)
        case .orange: return Color(.systemOrange)
        case .pink: return Color(.systemPink)
        }
    }

    static let `default` = AccentColorOption.blue
}
