import Foundation

final class JSONBackupEncoder: JSONBackupEncoding {
    enum BackupError: Error {
        case unsupportedVersion
    }

    private let version: Int

    init(version: Int = 1) {
        self.version = version
    }

    func encode(budgets: [DailyBudget], transactions: [MacroTransaction]) throws -> Data {
        let snapshot = BackupSnapshot(
            version: version,
            budgets: budgets.map { BackupBudget(domain: $0) },
            transactions: transactions.map { BackupTransaction(domain: $0) }
        )

        let encodable = CodableBackupSnapshot(snapshot: snapshot)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(encodable)
    }

    func decode(from data: Data) throws -> BackupSnapshot {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(CodableBackupSnapshot.self, from: data)
        guard decoded.version == version else {
            throw BackupError.unsupportedVersion
        }
        return decoded.toSnapshot()
    }
}

private struct CodableBackupSnapshot: Codable {
    let version: Int
    let budgets: [CodableBackupBudget]
    let transactions: [CodableBackupTransaction]

    init(snapshot: BackupSnapshot) {
        self.version = snapshot.version
        self.budgets = snapshot.budgets.map { CodableBackupBudget(from: $0) }
        self.transactions = snapshot.transactions.map { CodableBackupTransaction(from: $0) }
    }

    func toSnapshot() -> BackupSnapshot {
        BackupSnapshot(
            version: version,
            budgets: budgets.map { $0.toModel() },
            transactions: transactions.map { $0.toModel() }
        )
    }
}

private struct CodableBackupBudget: Codable {
    let id: UUID
    let caloriesLimit: Int
    let proteinLimit: Int
    let fatLimit: Int
    let carbsLimit: Int
    let effectiveFrom: Date
    let isActive: Bool
    let budgetProfile: String?

    init(from budget: BackupBudget) {
        self.id = budget.id
        self.caloriesLimit = budget.caloriesLimit
        self.proteinLimit = budget.proteinLimit
        self.fatLimit = budget.fatLimit
        self.carbsLimit = budget.carbsLimit
        self.effectiveFrom = budget.effectiveFrom
        self.isActive = budget.isActive
        self.budgetProfile = budget.budgetProfile
    }

    func toModel() -> BackupBudget {
        BackupBudget(
            id: id,
            caloriesLimit: caloriesLimit,
            proteinLimit: proteinLimit,
            fatLimit: fatLimit,
            carbsLimit: carbsLimit,
            effectiveFrom: effectiveFrom,
            isActive: isActive,
            budgetProfile: budgetProfile
        )
    }
}

private struct CodableBackupTransaction: Codable {
    let id: UUID
    let dateTime: Date
    let mealType: String
    let title: String?
    let calories: Int
    let protein: Int
    let fat: Int
    let carbs: Int
    let note: String?

    init(from transaction: BackupTransaction) {
        self.id = transaction.id
        self.dateTime = transaction.dateTime
        self.mealType = transaction.mealType
        self.title = transaction.title
        self.calories = transaction.calories
        self.protein = transaction.protein
        self.fat = transaction.fat
        self.carbs = transaction.carbs
        self.note = transaction.note
    }

    func toModel() -> BackupTransaction {
        BackupTransaction(
            id: id,
            dateTime: dateTime,
            mealType: mealType,
            title: title,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            note: note
        )
    }
}
