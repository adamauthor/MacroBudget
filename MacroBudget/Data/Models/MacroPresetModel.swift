import Foundation
import SwiftData

@Model
final class MacroPresetModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var calories: Int
    var protein: Int
    var fat: Int
    var carbs: Int
    var iconName: String
    var colorName: String
    var createdAt: Date

    init(
        id: UUID,
        name: String,
        calories: Int,
        protein: Int,
        fat: Int,
        carbs: Int,
        iconName: String,
        colorName: String,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.iconName = iconName
        self.colorName = colorName
        self.createdAt = createdAt
    }
}

extension MacroPresetModel {
    func toDomain() -> MacroPreset {
        MacroPreset(
            id: id,
            name: name,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            iconName: iconName,
            colorName: colorName,
            createdAt: createdAt
        )
    }

    static func fromDomain(_ preset: MacroPreset) -> MacroPresetModel {
        MacroPresetModel(
            id: preset.id,
            name: preset.name,
            calories: preset.calories,
            protein: preset.protein,
            fat: preset.fat,
            carbs: preset.carbs,
            iconName: preset.iconName,
            colorName: preset.colorName,
            createdAt: preset.createdAt
        )
    }
}
