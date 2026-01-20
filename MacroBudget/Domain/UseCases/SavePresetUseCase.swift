import Foundation

struct SavePresetUseCase {
    private let repository: PresetRepository

    init(repository: PresetRepository) {
        self.repository = repository
    }

    func execute(name: String, calories: Int, protein: Int, fat: Int, carbs: Int, iconName: String, colorName: String) throws -> MacroPreset {
        let preset = MacroPreset(
            id: UUID(),
            name: name,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            iconName: iconName,
            colorName: colorName,
            createdAt: Date()
        )
        try repository.savePreset(preset)
        return preset
    }
}
