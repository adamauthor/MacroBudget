import Foundation

final class TransactionCSVEncoder: CSVEncoding {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func encode(transactions: [MacroTransaction]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = calendar.timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let timeFormatter = DateFormatter()
        timeFormatter.calendar = calendar
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.timeZone = calendar.timeZone
        timeFormatter.dateFormat = "HH:mm"

        let rows = transactions.map { transaction -> String in
            let date = dateFormatter.string(from: transaction.dateTime)
            let time = timeFormatter.string(from: transaction.dateTime)
            let fields: [String] = [
                date,
                time,
                transaction.mealType.rawValue,
                transaction.title ?? "",
                String(transaction.calories),
                String(transaction.protein),
                String(transaction.fat),
                String(transaction.carbs),
                transaction.note ?? ""
            ]
            return fields.map { escape($0) }.joined(separator: ",")
        }

        return rows.joined(separator: "\n")
    }

    private func escape(_ value: String) -> String {
        let needsEscaping = value.contains(",") || value.contains("\"") || value.contains("\n") || value.contains("\r")
        if needsEscaping {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }
}
