import Foundation

struct GetWeekSummaryUseCase {
    private let budgetRepository: BudgetRepository
    private let transactionRepository: TransactionRepository
    private let dateGrouper: DateGrouper
    private let aggregator: Aggregator

    init(
        budgetRepository: BudgetRepository,
        transactionRepository: TransactionRepository,
        dateGrouper: DateGrouper,
        aggregator: Aggregator
    ) {
        self.budgetRepository = budgetRepository
        self.transactionRepository = transactionRepository
        self.dateGrouper = dateGrouper
        self.aggregator = aggregator
    }

    func execute(weekContaining date: Date) throws -> PeriodSummary? {
        guard let budget = try budgetRepository.fetchActiveBudget() else {
            return nil
        }
        let start = dateGrouper.startOfWeek(containing: date)
        let end = dateGrouper.date(byAdding: .day, value: 7, to: start)
        let transactions = try transactionRepository.fetchTransactions(from: start, to: end)
        let totalsByDay = aggregator.totalsByDay(for: transactions, dateGrouper: dateGrouper)
        let days = daysBetween(start: start, end: end)
        let averages = averageTotals(days: days, totalsByDay: totalsByDay)
        let percent = withinLimitPercent(days: days, totalsByDay: totalsByDay, budget: budget)
        return PeriodSummary(startDate: start, endDate: end, totalsByDay: totalsByDay, averageTotals: averages, withinLimitPercent: percent)
    }

    private func daysBetween(start: Date, end: Date) -> [Date] {
        var dates: [Date] = []
        var cursor = start
        while cursor < end {
            dates.append(cursor)
            cursor = dateGrouper.date(byAdding: .day, value: 1, to: cursor)
        }
        return dates
    }

    private func averageTotals(days: [Date], totalsByDay: [Date: MacroTotals]) -> MacroTotals {
        guard !days.isEmpty else { return .zero }
        let total = days.reduce(MacroTotals.zero) { partial, day in
            partial.adding(totalsByDay[day] ?? .zero)
        }
        return MacroTotals(
            calories: total.calories / days.count,
            protein: total.protein / days.count,
            fat: total.fat / days.count,
            carbs: total.carbs / days.count
        )
    }

    private func withinLimitPercent(days: [Date], totalsByDay: [Date: MacroTotals], budget: DailyBudget) -> Double {
        guard !days.isEmpty else { return 0 }
        let limitCalories = budget.caloriesLimit
        let within = days.filter { (totalsByDay[$0]?.calories ?? 0) <= limitCalories }.count
        return (Double(within) / Double(days.count)) * 100.0
    }
}
