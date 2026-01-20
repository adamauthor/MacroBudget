import SwiftUI

struct NormCalculatorView: View {
    @State private var viewModel: NormCalculatorViewModel
    @State private var showSavePreset = false
    @State private var presetName = ""
    @State private var presetColor: PresetColorOption = .blue
    @State private var presetIcon: PresetIconOption = .bolt
    @State private var presetTemplate = PresetTemplate.default
    @State private var showApplied = false

    init(container: AppContainer) {
        _viewModel = State(initialValue: NormCalculatorViewModel(
            calculator: container.normCalculator,
            saveBudgetUseCase: container.saveBudgetUseCase,
            savePresetUseCase: container.savePresetUseCase
        ))
    }

    var body: some View {
        Form {
            Section("Basics") {
                Picker("Sex", selection: $viewModel.sex) {
                    ForEach(BiologicalSex.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                TextField("Age", text: $viewModel.age)
                    .keyboardType(.numberPad)
                TextField("Height (cm)", text: $viewModel.height)
                    .keyboardType(.numberPad)
                TextField("Weight (kg)", text: $viewModel.weight)
                    .keyboardType(.decimalPad)
            }

            Section("Activity") {
                Picker("Activity", selection: $viewModel.activity) {
                    ForEach(ActivityLevel.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
            }

            Section("Goal") {
                Picker("Goal", selection: $viewModel.goal) {
                    ForEach(GoalType.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Pace", selection: $viewModel.pace) {
                    ForEach(PaceType.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Button("Calculate") {
                    _ = viewModel.calculate()
                }
            }

            if !viewModel.calories.isEmpty {
                Section("Recommendation") {
                    TextField("Calories", text: $viewModel.calories)
                        .keyboardType(.numberPad)
                        .disabled(true)
                    TextField("Protein", text: $viewModel.protein)
                        .keyboardType(.numberPad)
                        .disabled(!viewModel.isManualMacros)
                        .onChange(of: viewModel.protein) { _, _ in
                            if viewModel.isManualMacros { viewModel.recalculateCaloriesFromMacros() }
                        }
                    TextField("Fat", text: $viewModel.fat)
                        .keyboardType(.numberPad)
                        .disabled(!viewModel.isManualMacros)
                        .onChange(of: viewModel.fat) { _, _ in
                            if viewModel.isManualMacros { viewModel.recalculateCaloriesFromMacros() }
                        }
                    TextField("Carbs", text: $viewModel.carbs)
                        .keyboardType(.numberPad)
                        .disabled(!viewModel.isManualMacros)
                        .onChange(of: viewModel.carbs) { _, _ in
                            if viewModel.isManualMacros { viewModel.recalculateCaloriesFromMacros() }
                        }

                    Toggle("Edit macros manually", isOn: $viewModel.isManualMacros)
                        .onChange(of: viewModel.isManualMacros) { _, newValue in
                            if newValue { viewModel.recalculateCaloriesFromMacros() }
                        }
                }

                if !viewModel.warnings.isEmpty {
                    Section("Warnings") {
                        ForEach(viewModel.warnings, id: \.self) { warning in
                            Text(warning)
                                .foregroundStyle(.orange)
                        }
                    }
                }

                Section {
                    Button("Apply as daily limit") {
                        if viewModel.applyAsBudget() {
                            showApplied = true
                        }
                    }
                    Button("Save as preset") {
                        presetTemplate = PresetTemplate.default
                        presetName = defaultPresetName()
                        presetColor = presetTemplate.color
                        presetIcon = presetTemplate.icon
                        showSavePreset = true
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Calculate Norm")
        .sheet(isPresented: $showSavePreset) {
            NavigationStack {
                Form {
                    Section("Preset") {
                        Picker("Template", selection: $presetTemplate) {
                            ForEach(PresetTemplate.allCases) { template in
                                Text(template.title).tag(template)
                            }
                        }
                        .onChange(of: presetTemplate) { _, newValue in
                            presetName = newValue.title
                            presetColor = newValue.color
                            presetIcon = newValue.icon
                        }
                        TextField("Name", text: $presetName)
                        Picker("Color", selection: $presetColor) {
                            ForEach(PresetColorOption.allCases) { option in
                                Text(option.rawValue.capitalized).tag(option)
                            }
                        }
                        Picker("Icon", selection: $presetIcon) {
                            ForEach(PresetIconOption.allCases) { option in
                                Text(option.rawValue.capitalized).tag(option)
                            }
                        }
                    }
                }
                .navigationTitle("Save Preset")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if viewModel.savePreset(
                                name: presetName.isEmpty ? "Preset" : presetName,
                                iconName: presetIcon.systemName,
                                colorName: presetColor.rawValue
                            ) {
                                showSavePreset = false
                            }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showSavePreset = false }
                    }
                }
            }
        }
        .alert("Applied", isPresented: $showApplied) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Daily limits updated.")
        }
    }

    private func defaultPresetName() -> String {
        switch viewModel.goal {
        case .cut: return "Cut"
        case .maintain: return "Maintain"
        case .gain: return "Gain"
        }
    }
}

private struct PresetTemplate: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let color: PresetColorOption
    let icon: PresetIconOption

    static let `default` = PresetTemplate(title: "Regular Day", color: .blue, icon: .bolt)

    static let allCases: [PresetTemplate] = [
        .default,
        PresetTemplate(title: "Training Day", color: .green, icon: .dumbbell),
        PresetTemplate(title: "Low Activity", color: .gray, icon: .moon),
        PresetTemplate(title: "Celebration Day", color: .orange, icon: .sun),
        PresetTemplate(title: "Cut", color: .red, icon: .flame),
        PresetTemplate(title: "Maintain", color: .blue, icon: .bolt)
    ]
}
