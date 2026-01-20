import Foundation

protocol BudgetRepository {
    func fetchActiveBudget() throws -> DailyBudget?
    func fetchAllBudgets() throws -> [DailyBudget]
    func saveBudget(_ budget: DailyBudget) throws
    func deactivateAllBudgets() throws
    func deleteAllBudgets() throws
}
