import Foundation
import Observation

@Observable
final class AddTransactionViewModel {
    private let addTransactionUseCase: AddTransactionUseCase

    var mealType: MealType = .breakfast
    var title = ""
    var calories = ""
    var proteinPer100 = ""
    var fatPer100 = ""
    var carbsPer100 = ""
    var weightGrams = ""
    var totalProtein = "0"
    var totalFat = "0"
    var totalCarbs = "0"
    var dateTime = Date()
    var note = ""
    var errorMessage: String?

    init(addTransactionUseCase: AddTransactionUseCase) {
        self.addTransactionUseCase = addTransactionUseCase
    }

    func add() -> Bool {
        errorMessage = nil
        guard let totals = computedTotals() else {
            errorMessage = "Enter valid numbers."
            return false
        }
        calories = String(totals.calories)

        let transaction = MacroTransaction(
            id: UUID(),
            dateTime: dateTime,
            mealType: mealType,
            title: title.isEmpty ? nil : title,
            calories: totals.calories,
            protein: totals.protein,
            fat: totals.fat,
            carbs: totals.carbs,
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

    func recalculateCaloriesFromMacros() {
        guard let totals = computedTotals() else {
            calories = ""
            totalProtein = "0"
            totalFat = "0"
            totalCarbs = "0"
            return
        }
        calories = String(totals.calories)
        totalProtein = String(totals.protein)
        totalFat = String(totals.fat)
        totalCarbs = String(totals.carbs)
    }

    private func computedTotals() -> MacroTotals? {
        guard let gramsValue = weightGrams.normalizedDecimalValue(),
              let proteinPer100Value = proteinPer100.normalizedDecimalValue(),
              let fatPer100Value = fatPer100.normalizedDecimalValue(),
              let carbsPer100Value = carbsPer100.normalizedDecimalValue(),
              gramsValue > 0 else {
            return nil
        }

        let factor = gramsValue / 100.0
        let proteinTotal = Int(round(proteinPer100Value * factor))
        let fatTotal = Int(round(fatPer100Value * factor))
        let carbsTotal = Int(round(carbsPer100Value * factor))
        let caloriesTotal = proteinTotal * 4 + fatTotal * 9 + carbsTotal * 4
        return MacroTotals(calories: caloriesTotal, protein: proteinTotal, fat: fatTotal, carbs: carbsTotal)
    }
}
