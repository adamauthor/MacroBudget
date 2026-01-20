import Foundation
import SwiftData

final class SwiftDataTransactionRepository: TransactionRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func addTransaction(_ transaction: MacroTransaction) throws {
        context.insert(MacroTransactionModel.fromDomain(transaction))
        try context.save()
    }

    func deleteTransaction(id: UUID) throws {
        if let model = try fetchModel(id: id) {
            context.delete(model)
            try context.save()
        }
    }

    func deleteAllTransactions() throws {
        let descriptor = FetchDescriptor<MacroTransactionModel>()
        let transactions = try context.fetch(descriptor)
        transactions.forEach { context.delete($0) }
        try context.save()
    }

    func fetchTransaction(id: UUID) throws -> MacroTransaction? {
        try fetchModel(id: id)?.toDomain()
    }

    func fetchTransactions(from startDate: Date, to endDate: Date) throws -> [MacroTransaction] {
        let descriptor = FetchDescriptor<MacroTransactionModel>(
            predicate: #Predicate { $0.dateTime >= startDate && $0.dateTime < endDate },
            sortBy: [SortDescriptor(\.dateTime, order: .reverse)]
        )
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func fetchAllTransactions() throws -> [MacroTransaction] {
        let descriptor = FetchDescriptor<MacroTransactionModel>(sortBy: [SortDescriptor(\.dateTime, order: .reverse)])
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    private func fetchModel(id: UUID) throws -> MacroTransactionModel? {
        let descriptor = FetchDescriptor<MacroTransactionModel>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor).first
    }
}
