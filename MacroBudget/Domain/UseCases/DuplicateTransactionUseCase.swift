import Foundation

struct DuplicateTransactionUseCase {
    private let repository: TransactionRepository

    init(repository: TransactionRepository) {
        self.repository = repository
    }

    func execute(source: MacroTransaction, dateTime: Date = Date()) throws {
        let duplicated = MacroTransaction(
            id: UUID(),
            dateTime: dateTime,
            mealType: source.mealType,
            title: source.title,
            calories: source.calories,
            protein: source.protein,
            fat: source.fat,
            carbs: source.carbs,
            note: source.note
        )
        try repository.addTransaction(duplicated)
    }
}
