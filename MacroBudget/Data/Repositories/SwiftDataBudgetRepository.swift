import Foundation
import SwiftData

final class SwiftDataBudgetRepository: BudgetRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchActiveBudget() throws -> DailyBudget? {
        let descriptor = FetchDescriptor<DailyBudgetModel>(
            predicate: #Predicate { $0.isActive == true },
            sortBy: [SortDescriptor(\.effectiveFrom, order: .reverse)]
        )
        return try context.fetch(descriptor).first?.toDomain()
    }

    func fetchAllBudgets() throws -> [DailyBudget] {
        let descriptor = FetchDescriptor<DailyBudgetModel>(sortBy: [SortDescriptor(\.effectiveFrom, order: .reverse)])
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func saveBudget(_ budget: DailyBudget) throws {
        context.insert(DailyBudgetModel.fromDomain(budget))
        try context.save()
    }

    func deactivateAllBudgets() throws {
        let descriptor = FetchDescriptor<DailyBudgetModel>()
        let budgets = try context.fetch(descriptor)
        budgets.forEach { $0.isActive = false }
        try context.save()
    }

    func deleteAllBudgets() throws {
        let descriptor = FetchDescriptor<DailyBudgetModel>()
        let budgets = try context.fetch(descriptor)
        budgets.forEach { context.delete($0) }
        try context.save()
    }
}
