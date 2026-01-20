import XCTest
@testable import MacroBudget

final class ExportBackupTests: XCTestCase {
    func testCSVEncodingEscapesCommas() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        let encoder = TransactionCSVEncoder(calendar: calendar)
        let transaction = MacroTransaction(
            id: UUID(),
            dateTime: makeDateTime("2026-01-10", hour: 9, calendar: calendar),
            mealType: .breakfast,
            title: "Eggs, toast",
            calories: 300,
            protein: 20,
            fat: 10,
            carbs: 25,
            note: "note,with,comma"
        )

        let csv = encoder.encode(transactions: [transaction])
        XCTAssertEqual(csv, "2026-01-10,09:00,breakfast,\"Eggs, toast\",300,20,10,25,\"note,with,comma\"")
    }

    func testJSONEncodeDecodeRoundTrip() throws {
        let encoder = JSONBackupEncoder(version: 1)
        let budget = DailyBudget(
            id: UUID(),
            caloriesLimit: 2000,
            proteinLimit: 150,
            fatLimit: 60,
            carbsLimit: 220,
            effectiveFrom: Date(timeIntervalSince1970: 1_700_000_000),
            isActive: true,
            budgetProfile: "Regular"
        )
        let transaction = MacroTransaction(
            id: UUID(),
            dateTime: Date(timeIntervalSince1970: 1_700_000_100),
            mealType: .lunch,
            title: nil,
            calories: 500,
            protein: 40,
            fat: 15,
            carbs: 60,
            note: nil
        )

        let data = try encoder.encode(budgets: [budget], transactions: [transaction])
        let decoded = try encoder.decode(from: data)

        let expected = BackupSnapshot(
            version: 1,
            budgets: [BackupBudget(domain: budget)],
            transactions: [BackupTransaction(domain: transaction)]
        )

        XCTAssertEqual(decoded, expected)
    }

    func testJSONVersionMismatch() throws {
        let encoderV2 = JSONBackupEncoder(version: 2)
        let encoderV1 = JSONBackupEncoder(version: 1)

        let budget = DailyBudget(
            id: UUID(),
            caloriesLimit: 2000,
            proteinLimit: 150,
            fatLimit: 60,
            carbsLimit: 220,
            effectiveFrom: Date(timeIntervalSince1970: 1_700_000_000),
            isActive: true,
            budgetProfile: nil
        )

        let data = try encoderV2.encode(budgets: [budget], transactions: [])
        XCTAssertThrowsError(try encoderV1.decode(from: data))
    }

    func testRestoreReplacesExistingData() throws {
        let budgetRepo = InMemoryBudgetRepository()
        let transactionRepo = InMemoryTransactionRepository()
        let encoder = JSONBackupEncoder(version: 1)

        try budgetRepo.saveBudget(DailyBudget(
            id: UUID(),
            caloriesLimit: 1800,
            proteinLimit: 120,
            fatLimit: 50,
            carbsLimit: 200,
            effectiveFrom: Date(timeIntervalSince1970: 1_600_000_000),
            isActive: true,
            budgetProfile: nil
        ))
        try transactionRepo.addTransaction(MacroTransaction(
            id: UUID(),
            dateTime: Date(timeIntervalSince1970: 1_600_000_200),
            mealType: .snack,
            title: nil,
            calories: 150,
            protein: 5,
            fat: 5,
            carbs: 20,
            note: nil
        ))

        let newBudget = DailyBudget(
            id: UUID(),
            caloriesLimit: 2100,
            proteinLimit: 160,
            fatLimit: 70,
            carbsLimit: 230,
            effectiveFrom: Date(timeIntervalSince1970: 1_700_000_000),
            isActive: true,
            budgetProfile: "New"
        )
        let newTransaction = MacroTransaction(
            id: UUID(),
            dateTime: Date(timeIntervalSince1970: 1_700_000_300),
            mealType: .dinner,
            title: nil,
            calories: 600,
            protein: 45,
            fat: 20,
            carbs: 70,
            note: nil
        )
        let backupData = try encoder.encode(budgets: [newBudget], transactions: [newTransaction])

        let useCase = RestoreBackupUseCase(
            budgetRepository: budgetRepo,
            transactionRepository: transactionRepo,
            encoder: encoder
        )

        try useCase.execute(from: backupData)

        let budgets = try budgetRepo.fetchAllBudgets()
        let transactions = try transactionRepo.fetchAllTransactions()
        XCTAssertEqual(budgets, [newBudget])
        XCTAssertEqual(transactions, [newTransaction])
    }

    private func makeDateTime(_ value: String, hour: Int, calendar: Calendar) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = calendar.timeZone
        let base = formatter.date(from: value) ?? Date()
        var components = calendar.dateComponents([.year, .month, .day], from: base)
        components.hour = hour
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }
}

private final class InMemoryBudgetRepository: BudgetRepository {
    private var budgets: [DailyBudget] = []

    func fetchActiveBudget() throws -> DailyBudget? {
        budgets.first { $0.isActive }
    }

    func fetchAllBudgets() throws -> [DailyBudget] {
        budgets
    }

    func saveBudget(_ budget: DailyBudget) throws {
        budgets.append(budget)
    }

    func deactivateAllBudgets() throws {
        budgets = budgets.map { budget in
            var updated = budget
            updated.isActive = false
            return updated
        }
    }

    func deleteAllBudgets() throws {
        budgets.removeAll()
    }
}

private final class InMemoryTransactionRepository: TransactionRepository {
    private var transactions: [MacroTransaction] = []

    func addTransaction(_ transaction: MacroTransaction) throws {
        transactions.append(transaction)
    }

    func deleteTransaction(id: UUID) throws {
        transactions.removeAll { $0.id == id }
    }

    func deleteAllTransactions() throws {
        transactions.removeAll()
    }

    func fetchTransaction(id: UUID) throws -> MacroTransaction? {
        transactions.first { $0.id == id }
    }

    func fetchTransactions(from startDate: Date, to endDate: Date) throws -> [MacroTransaction] {
        transactions.filter { $0.dateTime >= startDate && $0.dateTime < endDate }
    }

    func fetchAllTransactions() throws -> [MacroTransaction] {
        transactions
    }
}
