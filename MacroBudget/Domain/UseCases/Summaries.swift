import Foundation

struct DaySummary {
    let date: Date
    let limit: MacroTotals
    let totals: MacroTotals
    let remaining: MacroTotals
    let overBy: MacroTotals
    let groupedTransactions: [MealType: [MacroTransaction]]
}

struct PeriodSummary {
    let startDate: Date
    let endDate: Date
    let totalsByDay: [Date: MacroTotals]
    let averageTotals: MacroTotals
    let withinLimitPercent: Double
}
