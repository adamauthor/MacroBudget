import Foundation
import Observation

@Observable
final class SettingsViewModel {
    private let getActiveBudgetUseCase: GetActiveBudgetUseCase
    private let saveBudgetUseCase: SaveBudgetUseCase
    private let resetDataUseCase: ResetDataUseCase
    private let exportTransactionsCSVUseCase: ExportTransactionsCSVUseCase
    private let backupJSONUseCase: BackupJSONUseCase
    private let restoreBackupUseCase: RestoreBackupUseCase

    var calories = ""
    var protein = ""
    var fat = ""
    var carbs = ""
    var errorMessage: String?
    var exportFromDate: Date
    var exportToDate: Date
    var exportCSVURL: URL?
    var backupURL: URL?

    init(
        getActiveBudgetUseCase: GetActiveBudgetUseCase,
        saveBudgetUseCase: SaveBudgetUseCase,
        resetDataUseCase: ResetDataUseCase,
        exportTransactionsCSVUseCase: ExportTransactionsCSVUseCase,
        backupJSONUseCase: BackupJSONUseCase,
        restoreBackupUseCase: RestoreBackupUseCase
    ) {
        self.getActiveBudgetUseCase = getActiveBudgetUseCase
        self.saveBudgetUseCase = saveBudgetUseCase
        self.resetDataUseCase = resetDataUseCase
        self.exportTransactionsCSVUseCase = exportTransactionsCSVUseCase
        self.backupJSONUseCase = backupJSONUseCase
        self.restoreBackupUseCase = restoreBackupUseCase

        let today = Date()
        self.exportToDate = today
        self.exportFromDate = Calendar.current.date(byAdding: .day, value: -6, to: today) ?? today
    }

    func load() {
        if let budget = try? getActiveBudgetUseCase.execute() {
            calories = String(budget.caloriesLimit)
            protein = String(budget.proteinLimit)
            fat = String(budget.fatLimit)
            carbs = String(budget.carbsLimit)
            recalculateCalories()
        }
    }

    func save() -> Bool {
        errorMessage = nil
        guard let proteinValue = protein.normalizedDecimalValue(),
              let fatValue = fat.normalizedDecimalValue(),
              let carbsValue = carbs.normalizedDecimalValue() else {
            errorMessage = "Enter valid numbers."
            return false
        }
        let roundedProtein = Int(round(proteinValue))
        let roundedFat = Int(round(fatValue))
        let roundedCarbs = Int(round(carbsValue))
        let roundedCalories = roundedProtein * 4 + roundedFat * 9 + roundedCarbs * 4
        calories = String(roundedCalories)
        do {
            _ = try saveBudgetUseCase.execute(
                calories: roundedCalories,
                protein: roundedProtein,
                fat: roundedFat,
                carbs: roundedCarbs
            )
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
            return true
        } catch {
            errorMessage = "Unable to save budget."
            return false
        }
    }

    func recalculateCalories() {
        guard let proteinValue = protein.normalizedDecimalValue(),
              let fatValue = fat.normalizedDecimalValue(),
              let carbsValue = carbs.normalizedDecimalValue() else {
            calories = "0"
            return
        }
        let roundedProtein = Int(round(proteinValue))
        let roundedFat = Int(round(fatValue))
        let roundedCarbs = Int(round(carbsValue))
        let roundedCalories = roundedProtein * 4 + roundedFat * 9 + roundedCarbs * 4
        calories = String(roundedCalories)
    }

    func resetAll() -> Bool {
        do {
            try resetDataUseCase.execute()
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
            return true
        } catch {
            errorMessage = "Unable to reset data."
            return false
        }
    }

    func exportCSV() {
        do {
            if exportFromDate > exportToDate {
                errorMessage = "Select a valid date range."
                exportCSVURL = nil
                return
            }
            exportCSVURL = try exportTransactionsCSVUseCase.execute(from: exportFromDate, to: exportToDate)
        } catch ExportTransactionsCSVUseCase.ExportError.noData {
            errorMessage = "No data to export for the selected period."
            exportCSVURL = nil
        } catch {
            errorMessage = "Unable to export CSV."
            exportCSVURL = nil
        }
    }

    func backupData() {
        do {
            backupURL = try backupJSONUseCase.execute()
        } catch {
            errorMessage = "Unable to create backup."
            backupURL = nil
        }
    }

    func restoreBackup(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            try restoreBackupUseCase.execute(from: data)
            load()
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
        } catch JSONBackupEncoder.BackupError.unsupportedVersion {
            errorMessage = "This backup version is not supported."
        } catch {
            errorMessage = "Unable to restore backup."
        }
    }

}
