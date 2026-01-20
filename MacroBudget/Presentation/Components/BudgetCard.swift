import SwiftUI

struct BudgetCard: View {
    let title: String
    let totals: MacroTotals
    let limit: MacroTotals
    let remaining: MacroTotals
    let overBy: MacroTotals

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.headline)
            MacroRow(
                title: "Calories",
                consumed: totals.calories,
                limit: limit.calories,
                remaining: remaining.calories,
                overBy: overBy.calories
            )
            Divider()
                .background(DSColor.divider)
            HStack(spacing: Spacing.md) {
                MacroRow(
                    title: "Protein",
                    consumed: totals.protein,
                    limit: limit.protein,
                    remaining: remaining.protein,
                    overBy: overBy.protein
                )
                MacroRow(
                    title: "Fat",
                    consumed: totals.fat,
                    limit: limit.fat,
                    remaining: remaining.fat,
                    overBy: overBy.fat
                )
                MacroRow(
                    title: "Carbs",
                    consumed: totals.carbs,
                    limit: limit.carbs,
                    remaining: remaining.carbs,
                    overBy: overBy.carbs
                )
            }
        }
        .padding(Spacing.md)
        .background(DSColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }
}
