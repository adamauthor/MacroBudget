import SwiftUI
import Charts

struct AnalyticsView: View {
    @State private var viewModel: AnalyticsViewModel

    init(container: AppContainer) {
        _viewModel = State(initialValue: AnalyticsViewModel(
            getDaySummaryUseCase: container.getDaySummaryUseCase,
            getWeekSummaryUseCase: container.getWeekSummaryUseCase,
            getMonthSummaryUseCase: container.getMonthSummaryUseCase
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Picker("Range", selection: $viewModel.selectedRange) {
                        ForEach(AnalyticsViewModel.Range.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)

                    DatePicker("", selection: $viewModel.selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)

                    switch viewModel.selectedRange {
                    case .day:
                        daySection
                    case .week, .month:
                        periodSection
                    }
                }
                .padding(Spacing.md)
            }
            .navigationTitle("Analytics")
            .onAppear { viewModel.refresh() }
            .onChange(of: viewModel.selectedRange) { _, _ in viewModel.refresh() }
            .onChange(of: viewModel.selectedDate) { _, _ in viewModel.refresh() }
        }
    }

    private var daySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Calories")
                .font(.headline)
            if let summary = viewModel.daySummary {
                Chart {
                    BarMark(
                        x: .value("Type", "Consumed"),
                        y: .value("Calories", summary.totals.calories)
                    )
                    .foregroundStyle(DSColor.accent)
                    BarMark(
                        x: .value("Type", "Limit"),
                        y: .value("Calories", summary.limit.calories)
                    )
                    .foregroundStyle(DSColor.divider)
                }
                .frame(height: 160)

                Text("Macros split")
                    .font(.headline)
                Chart {
                    ForEach(macroDonutData(summary: summary), id: \.label) { item in
                        SectorMark(
                            angle: .value("Value", item.value),
                            innerRadius: .ratio(0.6)
                        )
                        .foregroundStyle(item.color)
                    }
                }
                .frame(height: 180)
            } else {
                Text("No data for selected day.")
                    .foregroundStyle(DSColor.mutedText)
            }
        }
    }

    private var periodSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Calories trend")
                .font(.headline)
            if !viewModel.chartPoints.isEmpty {
                Chart(viewModel.chartPoints) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Calories", point.calories)
                    )
                    .foregroundStyle(DSColor.accent)
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Calories", point.calories)
                    )
                    .foregroundStyle(DSColor.accent)
                }
                .frame(height: 180)
            } else {
                Text("No data for selected range.")
                    .foregroundStyle(DSColor.mutedText)
            }

            if let summary = viewModel.periodSummary {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Within limit")
                            .font(.caption)
                            .foregroundStyle(DSColor.mutedText)
                        Text("\(summary.withinLimitPercent, specifier: "%.0f")%")
                            .font(.headline)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Avg calories")
                            .font(.caption)
                            .foregroundStyle(DSColor.mutedText)
                        Text("\(summary.averageTotals.calories)")
                            .font(.headline)
                    }
                }
            }
        }
    }

    private func macroDonutData(summary: DaySummary) -> [(label: String, value: Int, color: Color)] {
        [
            ("Protein", summary.totals.protein, Color(.systemGreen).opacity(0.6)),
            ("Fat", summary.totals.fat, Color(.systemOrange).opacity(0.6)),
            ("Carbs", summary.totals.carbs, Color(.systemTeal).opacity(0.6))
        ]
    }
}
