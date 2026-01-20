import Foundation

struct ApplyPresetUseCase {
    private let repository: BudgetRepository

    init(repository: BudgetRepository) {
        self.repository = repository
    }

    func execute(preset: MacroPreset, effectiveFrom: Date = Date()) throws -> DailyBudget {
        let newBudget = DailyBudget(
            id: UUID(),
            caloriesLimit: preset.calories,
            proteinLimit: preset.protein,
            fatLimit: preset.fat,
            carbsLimit: preset.carbs,
            effectiveFrom: effectiveFrom,
            isActive: true,
            budgetProfile: preset.name
        )
        try repository.deactivateAllBudgets()
        try repository.saveBudget(newBudget)
        return newBudget
    }
}
