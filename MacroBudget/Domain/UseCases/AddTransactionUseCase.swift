import Foundation

struct AddTransactionUseCase {
    struct ValidationError: Error {
        let message: String
    }

    private let repository: TransactionRepository

    init(repository: TransactionRepository) {
        self.repository = repository
    }

    func execute(_ transaction: MacroTransaction) throws {
        try validate(transaction)
        try repository.addTransaction(transaction)
    }

    private func validate(_ transaction: MacroTransaction) throws {
        let values = [transaction.calories, transaction.protein, transaction.fat, transaction.carbs]
        guard values.allSatisfy({ $0 >= 0 }) else {
            throw ValidationError(message: "Values must be non-negative.")
        }
        guard transaction.calories <= 20000 else {
            throw ValidationError(message: "Calories must be <= 20000.")
        }
        guard transaction.protein <= 1000, transaction.fat <= 1000, transaction.carbs <= 1000 else {
            throw ValidationError(message: "Macros must be <= 1000.")
        }
    }
}
