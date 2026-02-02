import Foundation
import Observation

@Observable
final class PresetsViewModel {
    private let getPresetsUseCase: GetPresetsUseCase
    private let savePresetUseCase: SavePresetUseCase
    private let deletePresetUseCase: DeletePresetUseCase
    private let applyPresetUseCase: ApplyPresetUseCase
    private let upsertPresetUseCase: UpsertPresetUseCase
    private let getActiveBudgetUseCase: GetActiveBudgetUseCase

    var presets: [MacroPreset] = []
    var baseTotals: MacroTotals = MacroTotals(calories: 2000, protein: 150, fat: 60, carbs: 220)
    var errorMessage: String?

    init(
        getPresetsUseCase: GetPresetsUseCase,
        savePresetUseCase: SavePresetUseCase,
        deletePresetUseCase: DeletePresetUseCase,
        applyPresetUseCase: ApplyPresetUseCase,
        upsertPresetUseCase: UpsertPresetUseCase,
        getActiveBudgetUseCase: GetActiveBudgetUseCase
    ) {
        self.getPresetsUseCase = getPresetsUseCase
        self.savePresetUseCase = savePresetUseCase
        self.deletePresetUseCase = deletePresetUseCase
        self.applyPresetUseCase = applyPresetUseCase
        self.upsertPresetUseCase = upsertPresetUseCase
        self.getActiveBudgetUseCase = getActiveBudgetUseCase
    }

    func load() {
        presets = (try? getPresetsUseCase.execute()) ?? []
        if let budget = try? getActiveBudgetUseCase.execute() {
            baseTotals = MacroTotals(
                calories: budget.caloriesLimit,
                protein: budget.proteinLimit,
                fat: budget.fatLimit,
                carbs: budget.carbsLimit
            )
        }
    }

    func applyPreset(_ preset: MacroPreset) {
        do {
            _ = try applyPresetUseCase.execute(preset: preset)
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
        } catch {
            errorMessage = "Unable to apply preset."
        }
    }

    func deletePreset(id: UUID) {
        do {
            try deletePresetUseCase.execute(id: id)
            presets = (try? getPresetsUseCase.execute()) ?? []
        } catch {
            errorMessage = "Unable to delete preset."
        }
    }

    func savePreset(name: String, calories: Int, protein: Int, fat: Int, carbs: Int, iconName: String, colorName: String) {
        do {
            _ = try savePresetUseCase.execute(
                name: name,
                calories: calories,
                protein: protein,
                fat: fat,
                carbs: carbs,
                iconName: iconName,
                colorName: colorName
            )
            presets = (try? getPresetsUseCase.execute()) ?? []
        } catch {
            errorMessage = "Unable to save preset."
        }
    }

    func updatePreset(
        preset: MacroPreset,
        name: String,
        calories: Int,
        protein: Int,
        fat: Int,
        carbs: Int,
        iconName: String,
        colorName: String
    ) -> Bool {
        errorMessage = nil
        do {
            if preset.name != name {
                try deletePresetUseCase.execute(id: preset.id)
            }
            try upsertPresetUseCase.execute(
                name: name,
                calories: calories,
                protein: protein,
                fat: fat,
                carbs: carbs,
                iconName: iconName,
                colorName: colorName
            )
            presets = (try? getPresetsUseCase.execute()) ?? []
            return true
        } catch {
            errorMessage = "Unable to update preset."
            return false
        }
    }
}
