import Foundation

struct GetActiveBudgetUseCase {
    private let repository: BudgetRepository

    init(repository: BudgetRepository) {
        self.repository = repository
    }

    func execute() throws -> DailyBudget? {
        try repository.fetchActiveBudget()
    }
}
