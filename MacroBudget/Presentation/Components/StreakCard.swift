import SwiftUI

struct StreakCard: View {
    let streakCount: Int
    let lastDays: [DayLogStatus]

    private var titleText: String {
        if streakCount >= 7 {
            return "7-day logging streak"
        }
        if streakCount >= 3 {
            return "\(streakCount)-day logging streak"
        }
        return "Keep going"
    }

    private var subtitleText: String {
        if streakCount >= 3 {
            return "You've logged food \(streakCount) days in a row"
        }
        return "Log food today to build your streak"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: streakCount >= 3 ? "flame.fill" : "checkmark.circle")
                    .foregroundStyle(DSColor.accent)
                Text(titleText)
                    .font(.subheadline.weight(.semibold))
            }
            Text(subtitleText)
                .font(.caption)
                .foregroundStyle(DSColor.mutedText)

            if !lastDays.isEmpty {
                HStack(spacing: Spacing.xs) {
                    ForEach(lastDays.indices, id: \.self) { index in
                        let status = lastDays[index]
                        Circle()
                            .strokeBorder(DSColor.divider, lineWidth: 1)
                            .background(
                                Circle()
                                    .fill(status.isCompleted ? DSColor.accent : Color.clear)
                            )
                            .frame(width: 8, height: 8)
                            .accessibilityLabel(status.isCompleted ? "Completed" : "Not completed")
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(DSColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }
}
