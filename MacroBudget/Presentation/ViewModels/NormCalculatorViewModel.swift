import Foundation
import Observation

@Observable
final class NormCalculatorViewModel {
    private let calculator: NormCalculator
    private let saveBudgetUseCase: SaveBudgetUseCase
    private let savePresetUseCase: SavePresetUseCase

    var sex: BiologicalSex = .male
    var age = ""
    var height = ""
    var weight = ""
    var activity: ActivityLevel = .sedentary
    var goal: GoalType = .maintain
    var pace: PaceType = .standard

    var calories = ""
    var protein = ""
    var fat = ""
    var carbs = ""
    var warnings: [String] = []
    var errorMessage: String?
    var isManualMacros = false

    init(calculator: NormCalculator, saveBudgetUseCase: SaveBudgetUseCase, savePresetUseCase: SavePresetUseCase) {
        self.calculator = calculator
        self.saveBudgetUseCase = saveBudgetUseCase
        self.savePresetUseCase = savePresetUseCase
    }

    func calculate() -> Bool {
        errorMessage = nil
        guard let ageValue = Int(age),
              let heightValue = Int(height),
              let weightValue = parseDouble(weight),
              ageValue > 0, heightValue > 0, weightValue > 0 else {
            errorMessage = "Enter valid age, height, and weight."
            return false
        }

        let recommendation = calculator.calculate(
            sex: sex,
            age: ageValue,
            heightCm: heightValue,
            weightKg: weightValue,
            activity: activity,
            goal: goal,
            pace: pace
        )

        calories = String(recommendation.calories)
        protein = String(recommendation.protein)
        fat = String(recommendation.fat)
        carbs = String(recommendation.carbs)
        warnings = recommendation.warnings
        isManualMacros = false
        return true
    }

    func recalculateCaloriesFromMacros() {
        guard let proteinValue = Int(protein),
              let fatValue = Int(fat),
              let carbsValue = Int(carbs) else {
            return
        }
        let totalCalories = proteinValue * 4 + fatValue * 9 + carbsValue * 4
        calories = String(totalCalories)
    }

    func applyAsBudget() -> Bool {
        guard let totals = currentTotals() else { return false }
        do {
            _ = try saveBudgetUseCase.execute(
                calories: totals.calories,
                protein: totals.protein,
                fat: totals.fat,
                carbs: totals.carbs
            )
            return true
        } catch {
            errorMessage = "Unable to apply budget."
            return false
        }
    }

    func savePreset(name: String, iconName: String, colorName: String) -> Bool {
        guard let totals = currentTotals() else { return false }
        do {
            _ = try savePresetUseCase.execute(
                name: name,
                calories: totals.calories,
                protein: totals.protein,
                fat: totals.fat,
                carbs: totals.carbs,
                iconName: iconName,
                colorName: colorName
            )
            return true
        } catch {
            errorMessage = "Unable to save preset."
            return false
        }
    }

    private func currentTotals() -> MacroTotals? {
        guard let caloriesValue = Int(calories),
              let proteinValue = Int(protein),
              let fatValue = Int(fat),
              let carbsValue = Int(carbs) else {
            errorMessage = "Enter valid macro values."
            return nil
        }
        guard caloriesValue >= 0, proteinValue >= 0, fatValue >= 0, carbsValue >= 0 else {
            errorMessage = "Values must be non-negative."
            return nil
        }
        guard caloriesValue <= 20000, proteinValue <= 1000, fatValue <= 1000, carbsValue <= 1000 else {
            errorMessage = "Values exceed safe limits."
            return nil
        }
        return MacroTotals(calories: caloriesValue, protein: proteinValue, fat: fatValue, carbs: carbsValue)
    }

    private func parseDouble(_ value: String) -> Double? {
        let normalized = value.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
}
