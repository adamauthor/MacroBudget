import Foundation

struct UpsertPresetUseCase {
    private let repository: PresetRepository

    init(repository: PresetRepository) {
        self.repository = repository
    }

    func execute(name: String, calories: Int, protein: Int, fat: Int, carbs: Int, iconName: String, colorName: String) throws {
        try repository.upsertPreset(
            name: name,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            iconName: iconName,
            colorName: colorName
        )
    }
}
