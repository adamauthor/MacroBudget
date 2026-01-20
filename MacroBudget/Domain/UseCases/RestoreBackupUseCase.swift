import Foundation

struct RestoreBackupUseCase {
    enum RestoreError: Error {
        case invalidData
    }

    private let budgetRepository: BudgetRepository
    private let transactionRepository: TransactionRepository
    private let encoder: JSONBackupEncoding

    init(
        budgetRepository: BudgetRepository,
        transactionRepository: TransactionRepository,
        encoder: JSONBackupEncoding
    ) {
        self.budgetRepository = budgetRepository
        self.transactionRepository = transactionRepository
        self.encoder = encoder
    }

    func execute(from data: Data) throws {
        let snapshot = try encoder.decode(from: data)
        try transactionRepository.deleteAllTransactions()
        try budgetRepository.deleteAllBudgets()

        for budget in snapshot.budgets {
            try budgetRepository.saveBudget(budget.toDomain())
        }
        for transaction in snapshot.transactions {
            try transactionRepository.addTransaction(transaction.toDomain())
        }
    }
}
