import Foundation
import Observation

@Observable
final class TodayViewModel {
    private let getDaySummaryUseCase: GetDaySummaryUseCase
    private let getActiveBudgetUseCase: GetActiveBudgetUseCase
    private let deleteTransactionUseCase: DeleteTransactionUseCase
    private let duplicateTransactionUseCase: DuplicateTransactionUseCase
    private let getPresetsUseCase: GetPresetsUseCase
    private let applyPresetUseCase: ApplyPresetUseCase
    private let streakCalculator: StreakCalculator

    var date: Date = Date()
    var budget: DailyBudget?
    var summary: DaySummary?
    var errorMessage: String?
    var presets: [MacroPreset] = []
    var streakCount: Int = 0
    var lastDaysStatus: [DayLogStatus] = []

    init(
        getDaySummaryUseCase: GetDaySummaryUseCase,
        getActiveBudgetUseCase: GetActiveBudgetUseCase,
        deleteTransactionUseCase: DeleteTransactionUseCase,
        duplicateTransactionUseCase: DuplicateTransactionUseCase,
        getPresetsUseCase: GetPresetsUseCase,
        applyPresetUseCase: ApplyPresetUseCase,
        streakCalculator: StreakCalculator
    ) {
        self.getDaySummaryUseCase = getDaySummaryUseCase
        self.getActiveBudgetUseCase = getActiveBudgetUseCase
        self.deleteTransactionUseCase = deleteTransactionUseCase
        self.duplicateTransactionUseCase = duplicateTransactionUseCase
        self.getPresetsUseCase = getPresetsUseCase
        self.applyPresetUseCase = applyPresetUseCase
        self.streakCalculator = streakCalculator
    }

    func refresh() {
        date = Date()
        budget = try? getActiveBudgetUseCase.execute()
        summary = try? getDaySummaryUseCase.execute(date: date)
        presets = (try? getPresetsUseCase.execute()) ?? []
    }

    func deleteTransaction(id: UUID) {
        do {
            try deleteTransactionUseCase.execute(id: id)
            refresh()
        } catch {
            errorMessage = "Unable to delete."
        }
    }

    func duplicate(transaction: MacroTransaction) {
        do {
            try duplicateTransactionUseCase.execute(source: transaction)
            refresh()
        } catch {
            errorMessage = "Unable to duplicate."
        }
    }

    func applyPreset(_ preset: MacroPreset) {
        do {
            _ = try applyPresetUseCase.execute(preset: preset)
            refresh()
        } catch {
            errorMessage = "Unable to apply preset."
        }
    }

    func updateStreak(transactions: [MacroTransaction], calendar: Calendar = .current) {
        date = Date()
        streakCount = streakCalculator.currentStreak(asOf: date, transactions: transactions, calendar: calendar)
        lastDaysStatus = streakCalculator.lastDaysStatus(count: 7, endingAt: date, transactions: transactions, calendar: calendar)
    }
}
