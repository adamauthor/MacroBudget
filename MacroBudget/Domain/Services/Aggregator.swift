import Foundation

struct Aggregator {
    func totals(for transactions: [MacroTransaction]) -> MacroTotals {
        transactions.reduce(.zero) { partial, transaction in
            partial.adding(MacroTotals(
                calories: transaction.calories,
                protein: transaction.protein,
                fat: transaction.fat,
                carbs: transaction.carbs
            ))
        }
    }

    func totalsByMealType(for transactions: [MacroTransaction]) -> [MealType: [MacroTransaction]] {
        var grouped: [MealType: [MacroTransaction]] = [:]
        for meal in MealType.allCases {
            grouped[meal] = []
        }
        transactions.forEach { transaction in
            grouped[transaction.mealType, default: []].append(transaction)
        }
        for meal in MealType.allCases {
            grouped[meal] = grouped[meal]?.sorted { $0.dateTime > $1.dateTime }
        }
        return grouped
    }

    func totalsByDay(for transactions: [MacroTransaction], dateGrouper: DateGrouper) -> [Date: MacroTotals] {
        var result: [Date: MacroTotals] = [:]
        for transaction in transactions {
            let day = dateGrouper.startOfDay(transaction.dateTime)
            let totals = result[day] ?? .zero
            result[day] = totals.adding(MacroTotals(
                calories: transaction.calories,
                protein: transaction.protein,
                fat: transaction.fat,
                carbs: transaction.carbs
            ))
        }
        return result
    }
}
