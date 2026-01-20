import Foundation
import Observation

@Observable
final class AddTransactionViewModel {
    private let addTransactionUseCase: AddTransactionUseCase

    var mealType: MealType = .breakfast
    var title = ""
    var calories = ""
    var protein = ""
    var fat = ""
    var carbs = ""
    var dateTime = Date()
    var note = ""
    var errorMessage: String?

    init(addTransactionUseCase: AddTransactionUseCase) {
        self.addTransactionUseCase = addTransactionUseCase
    }

    func add() -> Bool {
        errorMessage = nil
        guard let caloriesValue = Int(calories),
              let proteinValue = Int(protein),
              let fatValue = Int(fat),
              let carbsValue = Int(carbs) else {
            errorMessage = "Enter valid numbers."
            return false
        }

        let transaction = MacroTransaction(
            id: UUID(),
            dateTime: dateTime,
            mealType: mealType,
            title: title.isEmpty ? nil : title,
            calories: caloriesValue,
            protein: proteinValue,
            fat: fatValue,
            carbs: carbsValue,
            note: note.isEmpty ? nil : note
        )

        do {
            try addTransactionUseCase.execute(transaction)
            return true
        } catch let error as AddTransactionUseCase.ValidationError {
            errorMessage = error.message
            return false
        } catch {
            errorMessage = "Unable to add transaction."
            return false
        }
    }
}
