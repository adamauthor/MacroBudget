import SwiftUI
import SwiftData

struct TodayView: View {
    @State private var viewModel: TodayViewModel
    @State private var showSettings = false
    @State private var editingTransaction: MacroTransaction?
    let container: AppContainer
    @Query private var streakTransactionModels: [MacroTransactionModel]
    @AppStorage("accentColor") private var accentColorName = AccentColorOption.default.rawValue

    init(container: AppContainer) {
        _viewModel = State(initialValue: TodayViewModel(
            getDaySummaryUseCase: container.getDaySummaryUseCase,
            getActiveBudgetUseCase: container.getActiveBudgetUseCase,
            deleteTransactionUseCase: container.deleteTransactionUseCase,
            duplicateTransactionUseCase: container.duplicateTransactionUseCase,
            getPresetsUseCase: container.getPresetsUseCase,
            applyPresetUseCase: container.applyPresetUseCase,
            streakCalculator: container.streakCalculator
        ))
        self.container = container
    }

    var body: some View {
        NavigationStack {
            List {
                if let budget = viewModel.budget, let summary = viewModel.summary {
                    if let profile = budget.budgetProfile {
                        let accent = AccentColorOption(rawValue: accentColorName)?.color ?? AccentColorOption.default.color
                        Section {
                            BudgetCard(
                                title: "Budget remaining",
                                totals: summary.totals,
                                limit: MacroTotals(
                                    calories: budget.caloriesLimit,
                                    protein: budget.proteinLimit,
                                    fat: budget.fatLimit,
                                    carbs: budget.carbsLimit
                                ),
                                remaining: summary.remaining,
                                overBy: summary.overBy
                            )
                            .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.xs, bottom: Spacing.xs, trailing: Spacing.xs))
                            .listRowBackground(DSColor.cardBackground)
                            .listRowSeparator(.hidden)
                        } header: {
                            Text(profile)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(accent)
                                .padding(.top, Spacing.xs)
                                .padding(.bottom, Spacing.sm)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .textCase(nil)
                    } else {
                        Section {
                            BudgetCard(
                                title: "Budget remaining",
                                totals: summary.totals,
                                limit: MacroTotals(
                                    calories: budget.caloriesLimit,
                                    protein: budget.proteinLimit,
                                    fat: budget.fatLimit,
                                    carbs: budget.carbsLimit
                                ),
                                remaining: summary.remaining,
                                overBy: summary.overBy
                            )
                            .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.xs, bottom: Spacing.xs, trailing: Spacing.xs))
                            .listRowBackground(DSColor.cardBackground)
                            .listRowSeparator(.hidden)
                        }
                    }

                    Section {
                        StreakCard(streakCount: viewModel.streakCount, lastDays: viewModel.lastDaysStatus)
                            .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.xs, bottom: Spacing.xs, trailing: Spacing.xs))
                            .listRowBackground(DSColor.cardBackground)
                            .listRowSeparator(.hidden)
                    }
                }

                ForEach(MealType.allCases) { meal in
                    Section(header: MealSectionHeader(title: meal.title)) {
                        let transactions = viewModel.summary?.groupedTransactions[meal] ?? []
                        if transactions.isEmpty {
                            Text("No entries")
                                .foregroundStyle(DSColor.mutedText)
                        } else {
                            ForEach(transactions) { transaction in
                                TransactionRow(transaction: transaction)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        editingTransaction = transaction
                                    }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            viewModel.deleteTransaction(id: transaction.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        Button {
                                            viewModel.duplicate(transaction: transaction)
                                        } label: {
                                            Label("Duplicate", systemImage: "doc.on.doc")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .animation(.easeInOut(duration: 0.25), value: viewModel.summary?.totals.calories ?? 0)
            .animation(.easeInOut(duration: 0.25), value: viewModel.streakCount)
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        if viewModel.presets.isEmpty {
                            Button("No presets yet") {}
                                .disabled(true)
                        } else {
                            ForEach(viewModel.presets) { preset in
                                Button {
                                    viewModel.applyPreset(preset)
                                } label: {
                                    HStack {
                                        Text(preset.name)
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    SettingsView(container: container)
                }
            }
            .sheet(item: $editingTransaction) { transaction in
                EditTransactionView(container: container, transaction: transaction)
            }
            .onAppear {
                viewModel.refresh()
                viewModel.updateStreak(transactions: streakTransactionModels.map { $0.toDomain() })
            }
            .onChange(of: streakTransactionModels) { _, newValue in
                viewModel.updateStreak(transactions: newValue.map { $0.toDomain() })
            }
            .onReceive(NotificationCenter.default.publisher(for: .dataDidChange)) { _ in
                viewModel.refresh()
                viewModel.updateStreak(transactions: streakTransactionModels.map { $0.toDomain() })
            }
        }
    }
}

private struct TransactionRow: View {
    let transaction: MacroTransaction

    private var timeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: transaction.dateTime)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(transaction.title ?? "Meal")
                    .font(.headline)
                Spacer()
                Text(timeText)
                    .font(.caption)
                    .foregroundStyle(DSColor.mutedText)
            }
            Text("\(transaction.calories) kcal • P \(transaction.protein) • F \(transaction.fat) • C \(transaction.carbs)")
                .font(.subheadline)
                .foregroundStyle(DSColor.mutedText)
        }
        .padding(.vertical, Spacing.xs)
    }
}
