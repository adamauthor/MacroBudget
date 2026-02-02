import Foundation
import Observation

@Observable
final class AnalyticsViewModel {
    enum Range: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"

        var id: String { rawValue }
    }

    struct ChartPoint: Identifiable {
        let id = UUID()
        let date: Date
        let calories: Int
    }

    private let getDaySummaryUseCase: GetDaySummaryUseCase
    private let getWeekSummaryUseCase: GetWeekSummaryUseCase
    private let getMonthSummaryUseCase: GetMonthSummaryUseCase
    private let dateGrouper = DateGrouper()

    var selectedRange: Range = .day
    var selectedDate: Date = Date()
    var daySummary: DaySummary?
    var previousDaySummary: DaySummary?
    var periodSummary: PeriodSummary?
    var chartPoints: [ChartPoint] = []

    init(
        getDaySummaryUseCase: GetDaySummaryUseCase,
        getWeekSummaryUseCase: GetWeekSummaryUseCase,
        getMonthSummaryUseCase: GetMonthSummaryUseCase
    ) {
        self.getDaySummaryUseCase = getDaySummaryUseCase
        self.getWeekSummaryUseCase = getWeekSummaryUseCase
        self.getMonthSummaryUseCase = getMonthSummaryUseCase
    }

    func refresh() {
        switch selectedRange {
        case .day:
            daySummary = try? getDaySummaryUseCase.execute(date: selectedDate)
            let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            previousDaySummary = try? getDaySummaryUseCase.execute(date: previousDate)
            periodSummary = nil
            chartPoints = []
        case .week:
            periodSummary = try? getWeekSummaryUseCase.execute(weekContaining: selectedDate)
            daySummary = nil
            previousDaySummary = nil
            chartPoints = chartPointsFromPeriod()
        case .month:
            periodSummary = try? getMonthSummaryUseCase.execute(monthContaining: selectedDate)
            daySummary = nil
            previousDaySummary = nil
            chartPoints = chartPointsFromPeriod()
        }
    }

    private func chartPointsFromPeriod() -> [ChartPoint] {
        guard let summary = periodSummary else { return [] }
        var dates: [Date] = []
        var cursor = dateGrouper.startOfDay(summary.startDate)
        let end = dateGrouper.startOfDay(summary.endDate)
        while cursor < end {
            dates.append(cursor)
            cursor = dateGrouper.date(byAdding: .day, value: 1, to: cursor)
        }
        return dates.map { date in
            let totals = summary.totalsByDay[date] ?? .zero
            return ChartPoint(date: date, calories: totals.calories)
        }
    }
}
