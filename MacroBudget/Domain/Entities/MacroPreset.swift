import Foundation

struct MacroPreset: Identifiable, Equatable {
    let id: UUID
    var name: String
    var calories: Int
    var protein: Int
    var fat: Int
    var carbs: Int
    var iconName: String
    var colorName: String
    var createdAt: Date
}
