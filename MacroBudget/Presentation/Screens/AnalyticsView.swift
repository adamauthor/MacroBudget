import SwiftUI
import Charts

struct AnalyticsView: View {
    @State private var viewModel: AnalyticsViewModel
    @State private var presets: [MacroPreset] = []
    @State private var showSettings = false
    let container: AppContainer
    @AppStorage("accentColor") private var accentColorName = AccentColorOption.default.rawValue
    private let dateGrouper = DateGrouper()

    init(container: AppContainer) {
        self.container = container
        _viewModel = State(initialValue: AnalyticsViewModel(
            getDaySummaryUseCase: container.getDaySummaryUseCase,
            getWeekSummaryUseCase: container.getWeekSummaryUseCase,
            getMonthSummaryUseCase: container.getMonthSummaryUseCase
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    controlsSection

                    switch viewModel.selectedRange {
                    case .day:
                        daySection
                    case .week, .month:
                        periodSection
                    }
                }
                .padding(Spacing.md)
                .animation(.easeInOut(duration: 0.25), value: viewModel.selectedRange)
                .animation(.easeInOut(duration: 0.25), value: viewModel.selectedDate)
            }
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        if presets.isEmpty {
                            Button("No presets yet") {}
                                .disabled(true)
                        } else {
                            ForEach(presets) { preset in
                                Button {
                                    try? container.applyPresetUseCase.execute(preset: preset)
                                    NotificationCenter.default.post(name: .dataDidChange, object: nil)
                                } label: {
                                    Text(preset.name)
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
            .onAppear {
                viewModel.refresh()
                presets = (try? container.getPresetsUseCase.execute()) ?? []
                normalizeSelectedDate()
            }
            .onChange(of: viewModel.selectedRange) { _, newValue in
                normalizeSelectedDate()
                viewModel.refresh()
            }
            .onChange(of: viewModel.selectedDate) { _, _ in viewModel.refresh() }
            .onReceive(NotificationCenter.default.publisher(for: .dataDidChange)) { _ in
                presets = (try? container.getPresetsUseCase.execute()) ?? []
            }
        }
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Picker("Range", selection: $viewModel.selectedRange) {
                ForEach(AnalyticsViewModel.Range.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)

            switch viewModel.selectedRange {
            case .day:
                Picker(dayLabel(for: viewModel.selectedDate), selection: $viewModel.selectedDate) {
                    ForEach(dayOptions, id: \.self) { day in
                        Text(dayLabel(for: day)).tag(day)
                    }
                }
                .pickerStyle(.menu)
            case .week:
                Picker(weekLabel(for: viewModel.selectedDate), selection: $viewModel.selectedDate) {
                    ForEach(weekOptions, id: \.self) { weekStart in
                        Text(weekLabel(for: weekStart)).tag(weekStart)
                    }
                }
                .pickerStyle(.menu)
            case .month:
                Picker(monthLabel(for: viewModel.selectedDate), selection: $viewModel.selectedDate) {
                    ForEach(monthOptions, id: \.self) { monthStart in
                        Text(monthLabel(for: monthStart)).tag(monthStart)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding(Spacing.md)
    }

    private var daySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Calories")
                .font(.headline)
            if let summary = viewModel.daySummary {
                let accent = AccentColorOption(rawValue: accentColorName)?.color ?? AccentColorOption.default.color
                let previousLabel = previousDayLabel(for: summary.date)
                let selectedDayLabel = dayLabel(for: summary.date)
                let previousCalories = viewModel.previousDaySummary?.totals.calories ?? 0
                Chart {
                    BarMark(
                        x: .value("Type", previousLabel),
                        y: .value("Calories", previousCalories)
                    )
                    .foregroundStyle(accent)
                    BarMark(
                        x: .value("Type", selectedDayLabel),
                        y: .value("Calories", summary.totals.calories)
                    )
                    .foregroundStyle(accent)
                    RuleMark(y: .value("Limit", summary.limit.calories))
                        .foregroundStyle(accent)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                        .annotation(position: .trailing, alignment: .leading) {
                            Text("\(summary.limit.calories)")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(accent)
                        }
                }
                .chartXScale(domain: [previousLabel, selectedDayLabel])
                .frame(height: 160, alignment: .top)

                Spacer(minLength: Spacing.md)
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
                .frame(height: 180, alignment: .top)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    ForEach(macroDonutData(summary: summary), id: \.label) { item in
                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 8, height: 8)
                            Text(item.label)
                                .font(.caption)
                            Spacer()
                            Text("\(item.value) g")
                                .font(.caption)
                                .foregroundStyle(DSColor.mutedText)
                        }
                    }
                }
            } else {
                Text("No data for selected day.")
                    .foregroundStyle(DSColor.mutedText)
            }
        }
        .cardStyle()
    }

    private var periodSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Calories trend")
                .font(.headline)
            if !viewModel.chartPoints.isEmpty {
                let accent = AccentColorOption(rawValue: accentColorName)?.color ?? AccentColorOption.default.color
                Group {
                    if let domain = chartXDomain {
                        Chart(viewModel.chartPoints) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Calories", point.calories)
                            )
                            .foregroundStyle(accent)
                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("Calories", point.calories)
                            )
                            .foregroundStyle(accent)
                        }
                        .chartXScale(domain: domain)
                        .chartXAxis { axisMarks }
                    } else {
                        Chart(viewModel.chartPoints) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Calories", point.calories)
                            )
                            .foregroundStyle(accent)
                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("Calories", point.calories)
                            )
                            .foregroundStyle(accent)
                        }
                        .chartXAxis { axisMarks }
                    }
                }
                .frame(height: 180, alignment: .top)
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
        .cardStyle()
    }

    private func macroDonutData(summary: DaySummary) -> [(label: String, value: Int, color: Color)] {
        [
            ("Protein", summary.totals.protein, Color(.systemGreen).opacity(0.6)),
            ("Fat", summary.totals.fat, Color(.systemOrange).opacity(0.6)),
            ("Carbs", summary.totals.carbs, Color(.systemTeal).opacity(0.6))
        ]
    }

    private var weekOptions: [Date] {
        let start = dateGrouper.startOfWeek(containing: Date())
        return (0..<52).compactMap { offset in
            dateGrouper.date(byAdding: .weekOfYear, value: -offset, to: start)
        }
    }

    private var monthOptions: [Date] {
        let start = dateGrouper.startOfMonth(containing: Date())
        return (0..<24).compactMap { offset in
            dateGrouper.date(byAdding: .month, value: -offset, to: start)
        }
    }

    private func weekLabel(for start: Date) -> String {
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
        return "\(Self.shortDayFormatter.string(from: start)) – \(Self.shortDayFormatter.string(from: end))"
    }

    private func monthLabel(for start: Date) -> String {
        Self.monthFormatter.string(from: start)
    }

    private var dayOptions: [Date] {
        let start = dateGrouper.startOfDay(Date())
        return (0..<30).map { offset in
            dateGrouper.date(byAdding: .day, value: -offset, to: start)
        }
    }

    private func dayLabel(for date: Date) -> String {
        Self.dayFormatter.string(from: date)
    }

    private func previousDayLabel(for date: Date) -> String {
        let previousDate = dateGrouper.date(byAdding: .day, value: -1, to: date)
        return Self.shortDayFormatter.string(from: previousDate)
    }

    private func normalizeSelectedDate() {
        switch viewModel.selectedRange {
        case .day:
            viewModel.selectedDate = dateGrouper.startOfDay(Date())
        case .week:
            viewModel.selectedDate = dateGrouper.startOfWeek(containing: Date())
        case .month:
            viewModel.selectedDate = dateGrouper.startOfMonth(containing: Date())
        }
    }

    @AxisContentBuilder
    private var axisMarks: some AxisContent {
        switch viewModel.selectedRange {
        case .week:
            AxisMarks(values: weekAxisDates) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel(Self.weekDayFormatter.string(from: date))
                }
            }
        case .month:
            AxisMarks(values: monthAxisDates) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel(Self.monthDayFormatter.string(from: date))
                        .font(.caption2)
                }
            }
        case .day:
            AxisMarks()
        }
    }

    private var weekAxisDates: [Date] {
        guard viewModel.selectedRange == .week, let summary = viewModel.periodSummary else { return [] }
        let start = dateGrouper.startOfWeek(containing: summary.startDate)
        return (0..<7).map { offset in
            dateGrouper.date(byAdding: .day, value: offset, to: start)
        }
    }

    private var monthAxisDates: [Date] {
        guard viewModel.selectedRange == .month, let summary = viewModel.periodSummary else { return [] }
        let start = dateGrouper.startOfMonth(containing: summary.startDate)
        let days = Calendar.current.range(of: .day, in: .month, for: start)?.count ?? 30
        let stride = 2
        return (0..<days).compactMap { offset in
            guard offset % stride == 0 else { return nil }
            return dateGrouper.date(byAdding: .day, value: offset, to: start)
        }
    }

    private var chartXDomain: ClosedRange<Date>? {
        switch viewModel.selectedRange {
        case .week:
            guard let first = weekAxisDates.first, let last = weekAxisDates.last else { return nil }
            return first...last
        case .month:
            guard let first = monthAxisDates.first, let last = monthAxisDates.last else { return nil }
            return first...last
        case .day:
            return nil
        }
    }

    private static let shortDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        return formatter
    }()

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("LLLL yyyy")
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d MMM")
        return formatter
    }()

    private static let weekDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter
    }()

    private static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter
    }()
}
