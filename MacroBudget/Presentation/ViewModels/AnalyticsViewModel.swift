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

    var selectedRange: Range = .day
    var selectedDate: Date = Date()
    var daySummary: DaySummary?
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
            periodSummary = nil
            chartPoints = []
        case .week:
            periodSummary = try? getWeekSummaryUseCase.execute(weekContaining: selectedDate)
            daySummary = nil
            chartPoints = chartPointsFromPeriod()
        case .month:
            periodSummary = try? getMonthSummaryUseCase.execute(monthContaining: selectedDate)
            daySummary = nil
            chartPoints = chartPointsFromPeriod()
        }
    }

    private func chartPointsFromPeriod() -> [ChartPoint] {
        guard let summary = periodSummary else { return [] }
        return summary.totalsByDay
            .map { ChartPoint(date: $0.key, calories: $0.value.calories) }
            .sorted { $0.date < $1.date }
    }
}
