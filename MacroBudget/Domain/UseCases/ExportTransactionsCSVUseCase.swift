import Foundation

struct ExportTransactionsCSVUseCase {
    enum ExportError: Error {
        case noData
    }

    private let repository: TransactionRepository
    private let encoder: CSVEncoding
    private let exporter: FileExporting
    private let calendar: Calendar

    init(repository: TransactionRepository, encoder: CSVEncoding, exporter: FileExporting, calendar: Calendar = .current) {
        self.repository = repository
        self.encoder = encoder
        self.exporter = exporter
        self.calendar = calendar
    }

    func execute(from startDate: Date, to endDate: Date) throws -> URL {
        let start = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.startOfDay(for: endDate)
        guard let end = calendar.date(byAdding: .day, value: 1, to: endOfDay) else {
            throw ExportError.noData
        }
        let transactions = try repository.fetchTransactions(from: start, to: end)
        guard !transactions.isEmpty else {
            throw ExportError.noData
        }
        let csv = encoder.encode(transactions: transactions)
        guard let data = csv.data(using: .utf8) else {
            throw ExportError.noData
        }
        let fileName = "macrobudget-transactions-\(formatDate(start))_\(formatDate(endOfDay)).csv"
        return try exporter.write(data, fileName: fileName)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
}
