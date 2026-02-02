import Foundation
import Observation

@Observable
final class EditTransactionViewModel {
    private let updateTransactionUseCase: UpdateTransactionUseCase
    private let deleteTransactionUseCase: DeleteTransactionUseCase

    let id: UUID
    var mealType: MealType
    var title: String
    var protein: String
    var fat: String
    var carbs: String
    var calories: String
    var dateTime: Date
    var note: String
    var errorMessage: String?

    init(transaction: MacroTransaction, updateTransactionUseCase: UpdateTransactionUseCase, deleteTransactionUseCase: DeleteTransactionUseCase) {
        self.updateTransactionUseCase = updateTransactionUseCase
        self.deleteTransactionUseCase = deleteTransactionUseCase
        self.id = transaction.id
        self.mealType = transaction.mealType
        self.title = transaction.title ?? ""
        self.protein = String(transaction.protein)
        self.fat = String(transaction.fat)
        self.carbs = String(transaction.carbs)
        self.calories = String(transaction.calories)
        self.dateTime = transaction.dateTime
        self.note = transaction.note ?? ""
    }

    func recalculateCalories() {
        guard let proteinValue = protein.normalizedDecimalValue(),
              let fatValue = fat.normalizedDecimalValue(),
              let carbsValue = carbs.normalizedDecimalValue() else {
            return
        }
        let total = Int(round(proteinValue * 4 + fatValue * 9 + carbsValue * 4))
        calories = String(total)
    }

    func save() -> Bool {
        errorMessage = nil
        guard let proteinValue = protein.normalizedDecimalValue(),
              let fatValue = fat.normalizedDecimalValue(),
              let carbsValue = carbs.normalizedDecimalValue(),
              let caloriesValue = calories.normalizedDecimalValue() else {
            errorMessage = "Enter valid numbers."
            return false
        }

        let roundedProtein = Int(round(proteinValue))
        let roundedFat = Int(round(fatValue))
        let roundedCarbs = Int(round(carbsValue))
        let roundedCalories = Int(round(caloriesValue))

        let updated = MacroTransaction(
            id: id,
            dateTime: dateTime,
            mealType: mealType,
            title: title.isEmpty ? nil : title,
            calories: roundedCalories,
            protein: roundedProtein,
            fat: roundedFat,
            carbs: roundedCarbs,
            note: note.isEmpty ? nil : note
        )

        do {
            try updateTransactionUseCase.execute(updated)
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
            return true
        } catch let error as UpdateTransactionUseCase.ValidationError {
            errorMessage = error.message
            return false
        } catch {
            errorMessage = "Unable to update transaction."
            return false
        }
    }

    func delete() -> Bool {
        errorMessage = nil
        do {
            try deleteTransactionUseCase.execute(id: id)
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
            return true
        } catch {
            errorMessage = "Unable to delete transaction."
            return false
        }
    }
}
