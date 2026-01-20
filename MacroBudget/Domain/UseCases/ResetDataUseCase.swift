import Foundation

struct ResetDataUseCase {
    private let budgetRepository: BudgetRepository
    private let transactionRepository: TransactionRepository
    private let presetRepository: PresetRepository

    init(budgetRepository: BudgetRepository, transactionRepository: TransactionRepository, presetRepository: PresetRepository) {
        self.budgetRepository = budgetRepository
        self.transactionRepository = transactionRepository
        self.presetRepository = presetRepository
    }

    func execute() throws {
        try transactionRepository.deleteAllTransactions()
        try budgetRepository.deleteAllBudgets()
        try presetRepository.deleteAllPresets()
    }
}
