import Foundation
import Observation

@Observable
final class SettingsViewModel {
    private let getActiveBudgetUseCase: GetActiveBudgetUseCase
    private let saveBudgetUseCase: SaveBudgetUseCase
    private let resetDataUseCase: ResetDataUseCase
    private let getPresetsUseCase: GetPresetsUseCase
    private let deletePresetUseCase: DeletePresetUseCase
    private let applyPresetUseCase: ApplyPresetUseCase
    private let exportTransactionsCSVUseCase: ExportTransactionsCSVUseCase
    private let backupJSONUseCase: BackupJSONUseCase
    private let restoreBackupUseCase: RestoreBackupUseCase

    var calories = ""
    var protein = ""
    var fat = ""
    var carbs = ""
    var errorMessage: String?
    var presets: [MacroPreset] = []
    var exportFromDate: Date
    var exportToDate: Date
    var exportCSVURL: URL?
    var backupURL: URL?

    init(
        getActiveBudgetUseCase: GetActiveBudgetUseCase,
        saveBudgetUseCase: SaveBudgetUseCase,
        resetDataUseCase: ResetDataUseCase,
        getPresetsUseCase: GetPresetsUseCase,
        deletePresetUseCase: DeletePresetUseCase,
        applyPresetUseCase: ApplyPresetUseCase,
        exportTransactionsCSVUseCase: ExportTransactionsCSVUseCase,
        backupJSONUseCase: BackupJSONUseCase,
        restoreBackupUseCase: RestoreBackupUseCase
    ) {
        self.getActiveBudgetUseCase = getActiveBudgetUseCase
        self.saveBudgetUseCase = saveBudgetUseCase
        self.resetDataUseCase = resetDataUseCase
        self.getPresetsUseCase = getPresetsUseCase
        self.deletePresetUseCase = deletePresetUseCase
        self.applyPresetUseCase = applyPresetUseCase
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
        }
        presets = (try? getPresetsUseCase.execute()) ?? []
    }

    func save() -> Bool {
        errorMessage = nil
        guard let caloriesValue = Int(calories),
              let proteinValue = Int(protein),
              let fatValue = Int(fat),
              let carbsValue = Int(carbs) else {
            errorMessage = "Enter valid numbers."
            return false
        }
        do {
            _ = try saveBudgetUseCase.execute(
                calories: caloriesValue,
                protein: proteinValue,
                fat: fatValue,
                carbs: carbsValue
            )
            return true
        } catch {
            errorMessage = "Unable to save budget."
            return false
        }
    }

    func resetAll() -> Bool {
        do {
            try resetDataUseCase.execute()
            return true
        } catch {
            errorMessage = "Unable to reset data."
            return false
        }
    }

    func exportCSV() {
        do {
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
        } catch JSONBackupEncoder.BackupError.unsupportedVersion {
            errorMessage = "This backup version is not supported."
        } catch {
            errorMessage = "Unable to restore backup."
        }
    }

    func deletePreset(id: UUID) {
        do {
            try deletePresetUseCase.execute(id: id)
            presets = (try? getPresetsUseCase.execute()) ?? []
        } catch {
            errorMessage = "Unable to delete preset."
        }
    }

    func applyPreset(_ preset: MacroPreset) {
        do {
            _ = try applyPresetUseCase.execute(preset: preset)
            calories = String(preset.calories)
            protein = String(preset.protein)
            fat = String(preset.fat)
            carbs = String(preset.carbs)
        } catch {
            errorMessage = "Unable to apply preset."
        }
    }
}
