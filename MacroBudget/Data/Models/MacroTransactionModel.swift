import Foundation
import SwiftData

@Model
final class MacroTransactionModel {
    @Attribute(.unique) var id: UUID
    var dateTime: Date
    var mealTypeRaw: String
    var title: String?
    var calories: Int
    var protein: Int
    var fat: Int
    var carbs: Int
    var note: String?

    init(
        id: UUID,
        dateTime: Date,
        mealTypeRaw: String,
        title: String?,
        calories: Int,
        protein: Int,
        fat: Int,
        carbs: Int,
        note: String?
    ) {
        self.id = id
        self.dateTime = dateTime
        self.mealTypeRaw = mealTypeRaw
        self.title = title
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.note = note
    }
}

extension MacroTransactionModel {
    func toDomain() -> MacroTransaction {
        MacroTransaction(
            id: id,
            dateTime: dateTime,
            mealType: MealType(rawValue: mealTypeRaw) ?? .breakfast,
            title: title,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            note: note
        )
    }

    static func fromDomain(_ transaction: MacroTransaction) -> MacroTransactionModel {
        MacroTransactionModel(
            id: transaction.id,
            dateTime: transaction.dateTime,
            mealTypeRaw: transaction.mealType.rawValue,
            title: transaction.title,
            calories: transaction.calories,
            protein: transaction.protein,
            fat: transaction.fat,
            carbs: transaction.carbs,
            note: transaction.note
        )
    }
}
