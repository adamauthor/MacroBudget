import Foundation
import SwiftData

final class AppContainer {
    static let shared = AppContainer()

    let modelContainer: ModelContainer
    let budgetRepository: BudgetRepository
    let transactionRepository: TransactionRepository
    let presetRepository: PresetRepository

    let macroCalculator: MacroCalculator
    let normCalculator: NormCalculator
    let streakCalculator: StreakCalculator
    let dateGrouper: DateGrouper
    let aggregator: Aggregator

    let getActiveBudgetUseCase: GetActiveBudgetUseCase
    let saveBudgetUseCase: SaveBudgetUseCase
    let addTransactionUseCase: AddTransactionUseCase
    let deleteTransactionUseCase: DeleteTransactionUseCase
    let duplicateTransactionUseCase: DuplicateTransactionUseCase
    let getDaySummaryUseCase: GetDaySummaryUseCase
    let getWeekSummaryUseCase: GetWeekSummaryUseCase
    let getMonthSummaryUseCase: GetMonthSummaryUseCase
    let resetDataUseCase: ResetDataUseCase
    let getPresetsUseCase: GetPresetsUseCase
    let savePresetUseCase: SavePresetUseCase
    let deletePresetUseCase: DeletePresetUseCase
    let applyPresetUseCase: ApplyPresetUseCase
    let exportTransactionsCSVUseCase: ExportTransactionsCSVUseCase
    let backupJSONUseCase: BackupJSONUseCase
    let restoreBackupUseCase: RestoreBackupUseCase

    let csvEncoder: CSVEncoding
    let jsonBackupEncoder: JSONBackupEncoding
    let fileExporter: FileExporting

    private init() {
        let schema = Schema([DailyBudgetModel.self, MacroTransactionModel.self, MacroPresetModel.self])
        let configuration = ModelConfiguration(schema: schema)
        modelContainer = try! ModelContainer(for: schema, configurations: configuration)
        let context = ModelContext(modelContainer)

        budgetRepository = SwiftDataBudgetRepository(context: context)
        transactionRepository = SwiftDataTransactionRepository(context: context)
        presetRepository = SwiftDataPresetRepository(context: context)

        macroCalculator = MacroCalculator()
        normCalculator = NormCalculator()
        streakCalculator = StreakCalculator()
        dateGrouper = DateGrouper()
        aggregator = Aggregator()
        csvEncoder = TransactionCSVEncoder()
        jsonBackupEncoder = JSONBackupEncoder()
        fileExporter = LocalFileExporter()

        getActiveBudgetUseCase = GetActiveBudgetUseCase(repository: budgetRepository)
        saveBudgetUseCase = SaveBudgetUseCase(repository: budgetRepository)
        addTransactionUseCase = AddTransactionUseCase(repository: transactionRepository)
        deleteTransactionUseCase = DeleteTransactionUseCase(repository: transactionRepository)
        duplicateTransactionUseCase = DuplicateTransactionUseCase(repository: transactionRepository)
        getDaySummaryUseCase = GetDaySummaryUseCase(
            budgetRepository: budgetRepository,
            transactionRepository: transactionRepository,
            dateGrouper: dateGrouper,
            aggregator: aggregator,
            calculator: macroCalculator
        )
        getWeekSummaryUseCase = GetWeekSummaryUseCase(
            budgetRepository: budgetRepository,
            transactionRepository: transactionRepository,
            dateGrouper: dateGrouper,
            aggregator: aggregator
        )
        getMonthSummaryUseCase = GetMonthSummaryUseCase(
            budgetRepository: budgetRepository,
            transactionRepository: transactionRepository,
            dateGrouper: dateGrouper,
            aggregator: aggregator
        )
        resetDataUseCase = ResetDataUseCase(
            budgetRepository: budgetRepository,
            transactionRepository: transactionRepository,
            presetRepository: presetRepository
        )
        getPresetsUseCase = GetPresetsUseCase(repository: presetRepository)
        savePresetUseCase = SavePresetUseCase(repository: presetRepository)
        deletePresetUseCase = DeletePresetUseCase(repository: presetRepository)
        applyPresetUseCase = ApplyPresetUseCase(repository: budgetRepository)
        exportTransactionsCSVUseCase = ExportTransactionsCSVUseCase(
            repository: transactionRepository,
            encoder: csvEncoder,
            exporter: fileExporter
        )
        backupJSONUseCase = BackupJSONUseCase(
            budgetRepository: budgetRepository,
            transactionRepository: transactionRepository,
            encoder: jsonBackupEncoder,
            exporter: fileExporter
        )
        restoreBackupUseCase = RestoreBackupUseCase(
            budgetRepository: budgetRepository,
            transactionRepository: transactionRepository,
            encoder: jsonBackupEncoder
        )
    }
}
