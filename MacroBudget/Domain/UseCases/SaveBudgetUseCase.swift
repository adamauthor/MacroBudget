import Foundation

struct SaveBudgetUseCase {
    private let repository: BudgetRepository

    init(repository: BudgetRepository) {
        self.repository = repository
    }

    func execute(calories: Int, protein: Int, fat: Int, carbs: Int, effectiveFrom: Date = Date()) throws -> DailyBudget {
        let newBudget = DailyBudget(
            id: UUID(),
            caloriesLimit: calories,
            proteinLimit: protein,
            fatLimit: fat,
            carbsLimit: carbs,
            effectiveFrom: effectiveFrom,
            isActive: true,
            budgetProfile: nil
        )
        try repository.deactivateAllBudgets()
        try repository.saveBudget(newBudget)
        return newBudget
    }
}
