import Foundation

struct GetDaySummaryUseCase {
    private let budgetRepository: BudgetRepository
    private let transactionRepository: TransactionRepository
    private let dateGrouper: DateGrouper
    private let aggregator: Aggregator
    private let calculator: MacroCalculator

    init(
        budgetRepository: BudgetRepository,
        transactionRepository: TransactionRepository,
        dateGrouper: DateGrouper,
        aggregator: Aggregator,
        calculator: MacroCalculator
    ) {
        self.budgetRepository = budgetRepository
        self.transactionRepository = transactionRepository
        self.dateGrouper = dateGrouper
        self.aggregator = aggregator
        self.calculator = calculator
    }

    func execute(date: Date, mealType: MealType? = nil) throws -> DaySummary? {
        guard let budget = try budgetRepository.fetchActiveBudget() else {
            return nil
        }
        let start = dateGrouper.startOfDay(date)
        let end = dateGrouper.date(byAdding: .day, value: 1, to: start)
        var transactions = try transactionRepository.fetchTransactions(from: start, to: end)
        if let mealType {
            transactions = transactions.filter { $0.mealType == mealType }
        }
        let totals = aggregator.totals(for: transactions)
        let limit = MacroTotals(
            calories: budget.caloriesLimit,
            protein: budget.proteinLimit,
            fat: budget.fatLimit,
            carbs: budget.carbsLimit
        )
        let remaining = calculator.remaining(limit: limit, consumed: totals)
        let overBy = calculator.overBy(limit: limit, consumed: totals)
        let grouped = aggregator.totalsByMealType(for: transactions)
        return DaySummary(
            date: start,
            limit: limit,
            totals: totals,
            remaining: remaining,
            overBy: overBy,
            groupedTransactions: grouped
        )
    }
}
