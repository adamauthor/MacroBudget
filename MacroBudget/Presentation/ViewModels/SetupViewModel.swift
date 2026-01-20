import Foundation
import Observation

@Observable
final class SetupViewModel {
    private let saveBudgetUseCase: SaveBudgetUseCase

    var calories = ""
    var protein = ""
    var fat = ""
    var carbs = ""
    var errorMessage: String?

    init(saveBudgetUseCase: SaveBudgetUseCase) {
        self.saveBudgetUseCase = saveBudgetUseCase
    }

    func save() -> Bool {
        errorMessage = nil
        guard let caloriesValue = Int(calories),
              let proteinValue = Int(protein),
              let fatValue = Int(fat),
              let carbsValue = Int(carbs) else {
            errorMessage = "Enter valid numbers."
            return false
        }
        guard [caloriesValue, proteinValue, fatValue, carbsValue].allSatisfy({ $0 >= 0 }) else {
            errorMessage = "Values must be non-negative."
            return false
        }
        do {
            _ = try saveBudgetUseCase.execute(
                calories: caloriesValue,
                protein: proteinValue,
                fat: fatValue,
                carbs: carbsValue
            )
            return true
        } catch {
            errorMessage = "Unable to save budget."
            return false
        }
    }
}
