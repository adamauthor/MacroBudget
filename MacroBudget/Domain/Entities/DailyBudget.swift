import Foundation

struct DailyBudget: Identifiable, Equatable {
    let id: UUID
    var caloriesLimit: Int
    var proteinLimit: Int
    var fatLimit: Int
    var carbsLimit: Int
    var effectiveFrom: Date
    var isActive: Bool
    var budgetProfile: String?
}
