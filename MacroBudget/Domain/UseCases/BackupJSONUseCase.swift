import Foundation

struct BackupJSONUseCase {
    private let budgetRepository: BudgetRepository
    private let transactionRepository: TransactionRepository
    private let encoder: JSONBackupEncoding
    private let exporter: FileExporting

    init(
        budgetRepository: BudgetRepository,
        transactionRepository: TransactionRepository,
        encoder: JSONBackupEncoding,
        exporter: FileExporting
    ) {
        self.budgetRepository = budgetRepository
        self.transactionRepository = transactionRepository
        self.encoder = encoder
        self.exporter = exporter
    }

    func execute() throws -> URL {
        let budgets = try budgetRepository.fetchAllBudgets()
        let transactions = try transactionRepository.fetchAllTransactions()
        let data = try encoder.encode(budgets: budgets, transactions: transactions)
        let fileName = "macrobudget-backup-\(formattedTimestamp()).json"
        return try exporter.write(data, fileName: fileName)
    }

    private func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter.string(from: Date())
    }
}
