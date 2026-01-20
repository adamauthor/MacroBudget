import SwiftUI
import SwiftData

struct TodayView: View {
    @State private var viewModel: TodayViewModel
    @State private var showAdd = false
    let container: AppContainer
    @Query private var streakTransactionModels: [MacroTransactionModel]

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
                    Section {
                        if let profile = budget.budgetProfile {
                            Text("Preset: \(profile)")
                                .font(.caption)
                                .foregroundStyle(DSColor.mutedText)
                        }
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
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, Spacing.sm)
                    }

                    Section {
                        StreakCard(streakCount: viewModel.streakCount, lastDays: viewModel.lastDaysStatus)
                            .listRowInsets(EdgeInsets())
                            .padding(.vertical, Spacing.sm)
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
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.presets.isEmpty {
                        Menu {
                            ForEach(viewModel.presets) { preset in
                                Button {
                                    viewModel.applyPreset(preset)
                                } label: {
                                    Text(preset.name)
                                }
                            }
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddTransactionView(container: container) {
                    viewModel.refresh()
                }
            }
            .onAppear {
                viewModel.refresh()
                viewModel.updateStreak(transactions: streakTransactionModels.map { $0.toDomain() })
            }
            .onChange(of: streakTransactionModels) { _, newValue in
                viewModel.updateStreak(transactions: newValue.map { $0.toDomain() })
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
