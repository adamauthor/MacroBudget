import Foundation

struct DeleteTransactionUseCase {
    private let repository: TransactionRepository

    init(repository: TransactionRepository) {
        self.repository = repository
    }

    func execute(id: UUID) throws {
        try repository.deleteTransaction(id: id)
    }
}
