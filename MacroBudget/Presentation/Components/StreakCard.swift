import SwiftUI

struct StreakCard: View {
    let streakCount: Int
    let lastDays: [DayLogStatus]
    @AppStorage("accentColor") private var accentColorName = AccentColorOption.default.rawValue

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
        let accent = AccentColorOption(rawValue: accentColorName)?.color ?? AccentColorOption.default.color
        HStack(alignment: .center, spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.12))
                Image(systemName: streakCount >= 3 ? "flame.fill" : "checkmark.circle.fill")
                    .foregroundStyle(accent)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(titleText)
                    .font(.subheadline.weight(.semibold))
                Text(subtitleText)
                    .font(.caption)
                    .foregroundStyle(DSColor.mutedText)
            }

            Spacer()

            if !lastDays.isEmpty {
                HStack(spacing: 4) {
                    ForEach(lastDays.indices, id: \.self) { index in
                        let status = lastDays[index]
                        Circle()
                            .fill(status.isCompleted ? accent : DSColor.divider.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .accessibilityLabel(status.isCompleted ? "Completed" : "Not completed")
                    }
                }
            }
        }
        .cardStyle()
    }
}
