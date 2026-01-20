import Foundation

struct BackupSnapshot: Equatable {
    let version: Int
    let budgets: [BackupBudget]
    let transactions: [BackupTransaction]
}

struct BackupBudget: Equatable {
    let id: UUID
    let caloriesLimit: Int
    let proteinLimit: Int
    let fatLimit: Int
    let carbsLimit: Int
    let effectiveFrom: Date
    let isActive: Bool
    let budgetProfile: String?
}

struct BackupTransaction: Equatable {
    let id: UUID
    let dateTime: Date
    let mealType: String
    let title: String?
    let calories: Int
    let protein: Int
    let fat: Int
    let carbs: Int
    let note: String?
}

extension BackupBudget {
    init(domain: DailyBudget) {
        self.id = domain.id
        self.caloriesLimit = domain.caloriesLimit
        self.proteinLimit = domain.proteinLimit
        self.fatLimit = domain.fatLimit
        self.carbsLimit = domain.carbsLimit
        self.effectiveFrom = domain.effectiveFrom
        self.isActive = domain.isActive
        self.budgetProfile = domain.budgetProfile
    }

    func toDomain() -> DailyBudget {
        DailyBudget(
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

extension BackupTransaction {
    init(domain: MacroTransaction) {
        self.id = domain.id
        self.dateTime = domain.dateTime
        self.mealType = domain.mealType.rawValue
        self.title = domain.title
        self.calories = domain.calories
        self.protein = domain.protein
        self.fat = domain.fat
        self.carbs = domain.carbs
        self.note = domain.note
    }

    func toDomain() -> MacroTransaction {
        MacroTransaction(
            id: id,
            dateTime: dateTime,
            mealType: MealType(rawValue: mealType) ?? .breakfast,
            title: title,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            note: note
        )
    }
}
