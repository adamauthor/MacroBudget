import Foundation

struct MacroCalculator {
    func remaining(limit: MacroTotals, consumed: MacroTotals) -> MacroTotals {
        MacroTotals(
            calories: max(limit.calories - consumed.calories, 0),
            protein: max(limit.protein - consumed.protein, 0),
            fat: max(limit.fat - consumed.fat, 0),
            carbs: max(limit.carbs - consumed.carbs, 0)
        )
    }

    func overBy(limit: MacroTotals, consumed: MacroTotals) -> MacroTotals {
        MacroTotals(
            calories: max(consumed.calories - limit.calories, 0),
            protein: max(consumed.protein - limit.protein, 0),
            fat: max(consumed.fat - limit.fat, 0),
            carbs: max(consumed.carbs - limit.carbs, 0)
        )
    }
}
