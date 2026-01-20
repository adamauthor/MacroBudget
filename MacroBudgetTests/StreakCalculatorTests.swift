import XCTest
@testable import MacroBudget

final class StreakCalculatorTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    func testDayWithoutTransactionsIsNotCompleted() {
        let calculator = StreakCalculator()
        let date = makeDate("2026-01-10")
        let result = calculator.isDayCompleted(date, transactions: [], calendar: calendar)
        XCTAssertFalse(result)
    }

    func testDayWithTransactionIsCompleted() {
        let calculator = StreakCalculator()
        let date = makeDate("2026-01-10")
        let transaction = MacroTransaction(
            id: UUID(),
            dateTime: makeDateTime("2026-01-10", hour: 12),
            mealType: .lunch,
            title: nil,
            calories: 100,
            protein: 10,
            fat: 5,
            carbs: 10,
            note: nil
        )
        let result = calculator.isDayCompleted(date, transactions: [transaction], calendar: calendar)
        XCTAssertTrue(result)
    }

    func testStreakCountsConsecutiveDays() {
        let calculator = StreakCalculator()
        let today = makeDate("2026-01-07")
        let transactions = makeTransactions(dates: ["2026-01-07"])
        XCTAssertEqual(calculator.currentStreak(asOf: today, transactions: transactions, calendar: calendar), 1)

        let threeDayTransactions = makeTransactions(dates: ["2026-01-07", "2026-01-06", "2026-01-05"])
        XCTAssertEqual(calculator.currentStreak(asOf: today, transactions: threeDayTransactions, calendar: calendar), 3)

        let sevenDayTransactions = makeTransactions(dates: [
            "2026-01-07", "2026-01-06", "2026-01-05", "2026-01-04", "2026-01-03", "2026-01-02", "2026-01-01"
        ])
        XCTAssertEqual(calculator.currentStreak(asOf: today, transactions: sevenDayTransactions, calendar: calendar), 7)
    }

    func testMissedDayStopsStreakButKeepsPastDaysCompleted() {
        let calculator = StreakCalculator()
        let today = makeDate("2026-01-07")
        let transactions = makeTransactions(dates: ["2026-01-07", "2026-01-05"])

        let streak = calculator.currentStreak(asOf: today, transactions: transactions, calendar: calendar)
        XCTAssertEqual(streak, 1)

        let statuses = calculator.lastDaysStatus(count: 3, endingAt: today, transactions: transactions, calendar: calendar)
        XCTAssertEqual(statuses.count, 3)
        XCTAssertTrue(statuses[0].isCompleted) // 2026-01-05
        XCTAssertFalse(statuses[1].isCompleted) // 2026-01-06
        XCTAssertTrue(statuses[2].isCompleted) // 2026-01-07
    }

    private func makeTransactions(dates: [String]) -> [MacroTransaction] {
        dates.map { value in
            MacroTransaction(
                id: UUID(),
                dateTime: makeDateTime(value, hour: 12),
                mealType: .lunch,
                title: nil,
                calories: 100,
                protein: 10,
                fat: 5,
                carbs: 10,
                note: nil
            )
        }
    }

    private func makeDate(_ value: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = calendar.timeZone
        return formatter.date(from: value) ?? Date()
    }

    private func makeDateTime(_ value: String, hour: Int) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: makeDate(value))
        components.hour = hour
        return calendar.date(from: components) ?? Date()
    }
}
