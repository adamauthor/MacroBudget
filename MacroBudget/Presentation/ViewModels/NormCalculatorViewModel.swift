import Foundation
import Observation

@Observable
final class NormCalculatorViewModel {
    private let calculator: NormCalculator
    private let saveBudgetUseCase: SaveBudgetUseCase
    private let upsertPresetUseCase: UpsertPresetUseCase

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

    init(calculator: NormCalculator, saveBudgetUseCase: SaveBudgetUseCase, upsertPresetUseCase: UpsertPresetUseCase) {
        self.calculator = calculator
        self.saveBudgetUseCase = saveBudgetUseCase
        self.upsertPresetUseCase = upsertPresetUseCase
    }

    func calculate() -> Bool {
        errorMessage = nil
        guard let ageValue = Int(age),
              let heightValue = Int(height),
              let weightValue = weight.normalizedDecimalValue(),
              ageValue > 0, heightValue > 0, weightValue > 0 else {
            errorMessage = "Enter valid age, height, and weight."
            return false
        }

        if goal == .maintain {
            pace = .standard
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

    func setDefaultPaceForMaintain() {
        pace = .standard
    }

    func handleInputChange() {
        persistInputs()
        if isInputComplete() {
            _ = calculate()
        } else {
            clearRecommendation()
        }
    }

    func loadPersistedInputs() {
        let defaults = UserDefaults.standard
        age = defaults.string(forKey: "norm.age") ?? age
        height = defaults.string(forKey: "norm.height") ?? height
        weight = defaults.string(forKey: "norm.weight") ?? weight
        if let raw = defaults.string(forKey: "norm.sex"), let value = BiologicalSex(rawValue: raw) {
            sex = value
        }
        if let raw = defaults.string(forKey: "norm.activity"), let value = ActivityLevel(rawValue: raw) {
            activity = value
        }
        if let raw = defaults.string(forKey: "norm.goal"), let value = GoalType(rawValue: raw) {
            goal = value
        }
        if let raw = defaults.string(forKey: "norm.pace"), let value = PaceType(rawValue: raw) {
            pace = value
        }
        handleInputChange()
    }

    private func persistInputs() {
        let defaults = UserDefaults.standard
        defaults.set(age, forKey: "norm.age")
        defaults.set(height, forKey: "norm.height")
        defaults.set(weight, forKey: "norm.weight")
        defaults.set(sex.rawValue, forKey: "norm.sex")
        defaults.set(activity.rawValue, forKey: "norm.activity")
        defaults.set(goal.rawValue, forKey: "norm.goal")
        defaults.set(pace.rawValue, forKey: "norm.pace")
    }

    private func clearRecommendation() {
        calories = ""
        protein = ""
        fat = ""
        carbs = ""
        warnings = []
    }

    private func isInputComplete() -> Bool {
        guard let ageValue = Int(age),
              let heightValue = Int(height),
              let weightValue = weight.normalizedDecimalValue() else {
            return false
        }
        return ageValue > 0 && heightValue > 0 && weightValue > 0
    }

    func recalculateCaloriesFromMacros() {
        guard let proteinValue = protein.normalizedDecimalValue(),
              let fatValue = fat.normalizedDecimalValue(),
              let carbsValue = carbs.normalizedDecimalValue() else {
            return
        }
        let totalCalories = Int(round(proteinValue * 4 + fatValue * 9 + carbsValue * 4))
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
            try upsertPresetUseCase.execute(
                name: "Regular Day",
                calories: totals.calories,
                protein: totals.protein,
                fat: totals.fat,
                carbs: totals.carbs,
                iconName: "bolt.fill",
                colorName: "blue"
            )
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
            return true
        } catch {
            errorMessage = "Unable to apply budget."
            return false
        }
    }

    private func currentTotals() -> MacroTotals? {
        guard let caloriesValue = calories.normalizedDecimalValue(),
              let proteinValue = protein.normalizedDecimalValue(),
              let fatValue = fat.normalizedDecimalValue(),
              let carbsValue = carbs.normalizedDecimalValue() else {
            errorMessage = "Enter valid macro values."
            return nil
        }
        let roundedCalories = Int(round(caloriesValue))
        let roundedProtein = Int(round(proteinValue))
        let roundedFat = Int(round(fatValue))
        let roundedCarbs = Int(round(carbsValue))

        guard roundedCalories >= 0, roundedProtein >= 0, roundedFat >= 0, roundedCarbs >= 0 else {
            errorMessage = "Values must be non-negative."
            return nil
        }
        guard roundedCalories <= 20000, roundedProtein <= 1000, roundedFat <= 1000, roundedCarbs <= 1000 else {
            errorMessage = "Values exceed safe limits."
            return nil
        }
        return MacroTotals(calories: roundedCalories, protein: roundedProtein, fat: roundedFat, carbs: roundedCarbs)
    }
}
