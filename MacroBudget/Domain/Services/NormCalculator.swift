import Foundation

struct NormCalculator {
    func calculate(
        sex: BiologicalSex,
        age: Int,
        heightCm: Int,
        weightKg: Double,
        activity: ActivityLevel,
        goal: GoalType,
        pace: PaceType
    ) -> MacroRecommendation {
        let bmr: Double
        switch sex {
        case .male:
            bmr = 10 * weightKg + 6.25 * Double(heightCm) - 5 * Double(age) + 5
        case .female:
            bmr = 10 * weightKg + 6.25 * Double(heightCm) - 5 * Double(age) - 161
        }

        let tdee = bmr * activity.coefficient
        let targetCalories = adjustedCalories(from: tdee, goal: goal, pace: pace)

        let proteinPerKg: Double
        let fatPerKg: Double
        switch goal {
        case .cut:
            proteinPerKg = 2.0
            fatPerKg = 0.8
        case .maintain:
            proteinPerKg = 1.8
            fatPerKg = 0.9
        case .gain:
            proteinPerKg = 1.6
            fatPerKg = 1.0
        }

        let protein = Int(round(weightKg * proteinPerKg))
        let fat = Int(round(weightKg * fatPerKg))
        let carbCalories = Double(targetCalories) - Double(protein * 4) - Double(fat * 9)
        let carbs = max(0, Int(round(carbCalories / 4)))

        var warnings: [String] = []
        if pace == .aggressive {
            warnings.append("Aggressive pace can be hard to sustain.")
        }
        if carbs < 50 {
            warnings.append("Carbs are below 50g. Consider lowering protein/fat or a gentler pace.")
        }

        return MacroRecommendation(
            calories: targetCalories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            warnings: warnings
        )
    }

    private func adjustedCalories(from tdee: Double, goal: GoalType, pace: PaceType) -> Int {
        let multiplier: Double
        switch goal {
        case .maintain:
            multiplier = 1.0
        case .cut:
            switch pace {
            case .gentle: multiplier = 0.9
            case .standard: multiplier = 0.85
            case .aggressive: multiplier = 0.8
            }
        case .gain:
            switch pace {
            case .gentle: multiplier = 1.05
            case .standard: multiplier = 1.1
            case .aggressive: multiplier = 1.15
            }
        }

        let raw = tdee * multiplier
        let rounded = (raw / 10).rounded() * 10
        return max(0, Int(rounded))
    }
}
