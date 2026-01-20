import Foundation

struct StreakCalculator {
    func isDayCompleted(_ date: Date, transactions: [MacroTransaction], calendar: Calendar = .current) -> Bool {
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else {
            return false
        }
        return transactions.contains { $0.dateTime >= start && $0.dateTime < end }
    }

    func currentStreak(asOf date: Date, transactions: [MacroTransaction], calendar: Calendar = .current) -> Int {
        let todayStart = calendar.startOfDay(for: date)
        var streak = 0
        var cursor = todayStart

        while true {
            if isDayCompleted(cursor, transactions: transactions, calendar: calendar) {
                streak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                    break
                }
                cursor = previous
            } else {
                break
            }
        }

        return streak
    }

    func lastDaysStatus(count: Int, endingAt date: Date, transactions: [MacroTransaction], calendar: Calendar = .current) -> [DayLogStatus] {
        guard count > 0 else { return [] }
        let end = calendar.startOfDay(for: date)
        return (0..<count).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: end) else {
                return nil
            }
            return DayLogStatus(date: day, isCompleted: isDayCompleted(day, transactions: transactions, calendar: calendar))
        }.reversed()
    }
}
