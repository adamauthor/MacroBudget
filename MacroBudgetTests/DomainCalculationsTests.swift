import XCTest
@testable import MacroBudget

final class DomainCalculationsTests: XCTestCase {
    func testRemainingAndOverBy() {
        let calculator = MacroCalculator()
        let limit = MacroTotals(calories: 2000, protein: 150, fat: 60, carbs: 220)
        let consumed = MacroTotals(calories: 2300, protein: 120, fat: 80, carbs: 200)

        let remaining = calculator.remaining(limit: limit, consumed: consumed)
        let overBy = calculator.overBy(limit: limit, consumed: consumed)

        XCTAssertEqual(remaining.calories, 0)
        XCTAssertEqual(remaining.protein, 30)
        XCTAssertEqual(remaining.fat, 0)
        XCTAssertEqual(remaining.carbs, 20)

        XCTAssertEqual(overBy.calories, 300)
        XCTAssertEqual(overBy.protein, 0)
        XCTAssertEqual(overBy.fat, 20)
        XCTAssertEqual(overBy.carbs, 0)
    }

    func testWeeklyAggregation() throws {
        let calendar = Calendar(identifier: .gregorian)
        let dateGrouper = DateGrouper(calendar: calendar)
        let aggregator = Aggregator()
        let budgetRepo = InMemoryBudgetRepository(budget: DailyBudget(
            id: UUID(),
            caloriesLimit: 2000,
            proteinLimit: 150,
            fatLimit: 60,
            carbsLimit: 220,
            effectiveFrom: Date(),
            isActive: true,
            budgetProfile: nil
        ))
        let transactions = [
            MacroTransaction(id: UUID(), dateTime: makeDate("2026-01-20"), mealType: .breakfast, title: nil, calories: 500, protein: 30, fat: 10, carbs: 60, note: nil),
            MacroTransaction(id: UUID(), dateTime: makeDate("2026-01-21"), mealType: .lunch, title: nil, calories: 700, protein: 40, fat: 20, carbs: 80, note: nil),
            MacroTransaction(id: UUID(), dateTime: makeDate("2026-01-21"), mealType: .dinner, title: nil, calories: 400, protein: 25, fat: 15, carbs: 40, note: nil)
        ]
        let transactionRepo = InMemoryTransactionRepository(transactions: transactions)

        let useCase = GetWeekSummaryUseCase(
            budgetRepository: budgetRepo,
            transactionRepository: transactionRepo,
            dateGrouper: dateGrouper,
            aggregator: aggregator
        )

        let summary = try useCase.execute(weekContaining: makeDate("2026-01-21"))
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.totalsByDay[dateGrouper.startOfDay(makeDate("2026-01-21"))]?.calories, 1100)
    }

    func testMonthlyAggregation() throws {
        let calendar = Calendar(identifier: .gregorian)
        let dateGrouper = DateGrouper(calendar: calendar)
        let aggregator = Aggregator()
        let budgetRepo = InMemoryBudgetRepository(budget: DailyBudget(
            id: UUID(),
            caloriesLimit: 2000,
            proteinLimit: 150,
            fatLimit: 60,
            carbsLimit: 220,
            effectiveFrom: Date(),
            isActive: true,
            budgetProfile: nil
        ))
        let transactions = [
            MacroTransaction(id: UUID(), dateTime: makeDate("2026-01-03"), mealType: .breakfast, title: nil, calories: 800, protein: 35, fat: 20, carbs: 90, note: nil),
            MacroTransaction(id: UUID(), dateTime: makeDate("2026-01-10"), mealType: .lunch, title: nil, calories: 600, protein: 45, fat: 15, carbs: 70, note: nil)
        ]
        let transactionRepo = InMemoryTransactionRepository(transactions: transactions)

        let useCase = GetMonthSummaryUseCase(
            budgetRepository: budgetRepo,
            transactionRepository: transactionRepo,
            dateGrouper: dateGrouper,
            aggregator: aggregator
        )

        let summary = try useCase.execute(monthContaining: makeDate("2026-01-15"))
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.totalsByDay[dateGrouper.startOfDay(makeDate("2026-01-10"))]?.calories, 600)
    }

    private func makeDate(_ value: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: value) ?? Date()
    }
}

private final class InMemoryBudgetRepository: BudgetRepository {
    private var budget: DailyBudget?

    init(budget: DailyBudget?) {
        self.budget = budget
    }

    func fetchActiveBudget() throws -> DailyBudget? { budget }
    func fetchAllBudgets() throws -> [DailyBudget] { budget.map { [$0] } ?? [] }
    func saveBudget(_ budget: DailyBudget) throws { self.budget = budget }
    func deactivateAllBudgets() throws { self.budget?.isActive = false }
    func deleteAllBudgets() throws { self.budget = nil }
}

private final class InMemoryTransactionRepository: TransactionRepository {
    private var transactions: [MacroTransaction]

    init(transactions: [MacroTransaction]) {
        self.transactions = transactions
    }

    func addTransaction(_ transaction: MacroTransaction) throws { transactions.append(transaction) }
    func deleteTransaction(id: UUID) throws { transactions.removeAll { $0.id == id } }
    func deleteAllTransactions() throws { transactions.removeAll() }
    func fetchTransaction(id: UUID) throws -> MacroTransaction? { transactions.first { $0.id == id } }

    func fetchTransactions(from startDate: Date, to endDate: Date) throws -> [MacroTransaction] {
        transactions.filter { $0.dateTime >= startDate && $0.dateTime < endDate }
    }

    func fetchAllTransactions() throws -> [MacroTransaction] {
        transactions
    }
}
