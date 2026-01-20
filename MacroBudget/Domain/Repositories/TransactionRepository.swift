import Foundation

protocol TransactionRepository {
    func addTransaction(_ transaction: MacroTransaction) throws
    func deleteTransaction(id: UUID) throws
    func deleteAllTransactions() throws
    func fetchTransaction(id: UUID) throws -> MacroTransaction?
    func fetchTransactions(from startDate: Date, to endDate: Date) throws -> [MacroTransaction]
    func fetchAllTransactions() throws -> [MacroTransaction]
}
