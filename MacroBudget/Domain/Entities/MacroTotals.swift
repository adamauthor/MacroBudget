import Foundation

struct MacroTotals: Equatable {
    var calories: Int
    var protein: Int
    var fat: Int
    var carbs: Int

    static let zero = MacroTotals(calories: 0, protein: 0, fat: 0, carbs: 0)

    func adding(_ other: MacroTotals) -> MacroTotals {
        MacroTotals(
            calories: calories + other.calories,
            protein: protein + other.protein,
            fat: fat + other.fat,
            carbs: carbs + other.carbs
        )
    }
}
