import Foundation

struct MacroTransaction: Identifiable, Equatable {
    let id: UUID
    var dateTime: Date
    var mealType: MealType
    var title: String?
    var calories: Int
    var protein: Int
    var fat: Int
    var carbs: Int
    var note: String?
}
