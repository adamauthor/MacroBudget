import Foundation

protocol JSONBackupEncoding {
    func encode(budgets: [DailyBudget], transactions: [MacroTransaction]) throws -> Data
    func decode(from data: Data) throws -> BackupSnapshot
}
