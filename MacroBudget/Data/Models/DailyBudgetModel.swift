import Foundation
import SwiftData

@Model
final class DailyBudgetModel {
    @Attribute(.unique) var id: UUID
    var caloriesLimit: Int
    var proteinLimit: Int
    var fatLimit: Int
    var carbsLimit: Int
    var effectiveFrom: Date
    var isActive: Bool
    var budgetProfile: String?

    init(
        id: UUID,
        caloriesLimit: Int,
        proteinLimit: Int,
        fatLimit: Int,
        carbsLimit: Int,
        effectiveFrom: Date,
        isActive: Bool,
        budgetProfile: String?
    ) {
        self.id = id
        self.caloriesLimit = caloriesLimit
        self.proteinLimit = proteinLimit
        self.fatLimit = fatLimit
        self.carbsLimit = carbsLimit
        self.effectiveFrom = effectiveFrom
        self.isActive = isActive
        self.budgetProfile = budgetProfile
    }
}

extension DailyBudgetModel {
    func toDomain() -> DailyBudget {
        DailyBudget(
            id: id,
            caloriesLimit: caloriesLimit,
            proteinLimit: proteinLimit,
            fatLimit: fatLimit,
            carbsLimit: carbsLimit,
            effectiveFrom: effectiveFrom,
            isActive: isActive,
            budgetProfile: budgetProfile
        )
    }

    static func fromDomain(_ budget: DailyBudget) -> DailyBudgetModel {
        DailyBudgetModel(
            id: budget.id,
            caloriesLimit: budget.caloriesLimit,
            proteinLimit: budget.proteinLimit,
            fatLimit: budget.fatLimit,
            carbsLimit: budget.carbsLimit,
            effectiveFrom: budget.effectiveFrom,
            isActive: budget.isActive,
            budgetProfile: budget.budgetProfile
        )
    }
}
