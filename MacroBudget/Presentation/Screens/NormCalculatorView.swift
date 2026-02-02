import SwiftUI

struct NormCalculatorView: View {
    @State private var viewModel: NormCalculatorViewModel
    @State private var showApplied = false
    @FocusState private var focusedField: Field?
    let onApplied: (() -> Void)?

    enum Field {
        case age
        case height
        case weight
    }

    init(container: AppContainer, onApplied: (() -> Void)? = nil) {
        _viewModel = State(initialValue: NormCalculatorViewModel(
            calculator: container.normCalculator,
            saveBudgetUseCase: container.saveBudgetUseCase,
            upsertPresetUseCase: container.upsertPresetUseCase
        ))
        self.onApplied = onApplied
    }

    var body: some View {
        Form {
            Section("Basics") {
                Picker("Sex", selection: $viewModel.sex) {
                    ForEach(BiologicalSex.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .onChange(of: viewModel.sex) { _, _ in viewModel.handleInputChange() }
                TextField("Age", text: $viewModel.age)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .age)
                    .onChange(of: viewModel.age) { _, _ in viewModel.handleInputChange() }
                TextField("Height (cm)", text: $viewModel.height)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .height)
                    .onChange(of: viewModel.height) { _, _ in viewModel.handleInputChange() }
                TextField("Weight (kg)", text: $viewModel.weight)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .weight)
                    .onChange(of: viewModel.weight) { _, _ in
                        viewModel.handleInputChange()
                        Haptics.lightTick()
                    }
            }

            Section("Activity") {
                Picker("Activity", selection: $viewModel.activity) {
                    ForEach(ActivityLevel.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .onChange(of: viewModel.activity) { _, _ in viewModel.handleInputChange() }
            }

            Section("Goal") {
                Picker("Goal", selection: $viewModel.goal) {
                    ForEach(GoalType.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.goal) { _, _ in viewModel.handleInputChange() }

                if viewModel.goal != .maintain {
                    Picker("Pace", selection: $viewModel.pace) {
                        ForEach(PaceType.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.pace) { _, _ in viewModel.handleInputChange() }
                }
            }

                if !viewModel.calories.isEmpty {
                    Section("Recommendation") {
                        TextField("Calories", text: $viewModel.calories)
                            .keyboardType(.decimalPad)
                            .disabled(true)
                        TextField("Protein", text: $viewModel.protein)
                            .keyboardType(.decimalPad)
                            .disabled(!viewModel.isManualMacros)
                            .onChange(of: viewModel.protein) { _, _ in
                                if viewModel.isManualMacros {
                                    viewModel.recalculateCaloriesFromMacros()
                                    Haptics.lightTick()
                                }
                            }
                        TextField("Fat", text: $viewModel.fat)
                            .keyboardType(.decimalPad)
                            .disabled(!viewModel.isManualMacros)
                            .onChange(of: viewModel.fat) { _, _ in
                                if viewModel.isManualMacros {
                                    viewModel.recalculateCaloriesFromMacros()
                                    Haptics.lightTick()
                                }
                            }
                        TextField("Carbs", text: $viewModel.carbs)
                            .keyboardType(.decimalPad)
                            .disabled(!viewModel.isManualMacros)
                            .onChange(of: viewModel.carbs) { _, _ in
                                if viewModel.isManualMacros {
                                    viewModel.recalculateCaloriesFromMacros()
                                    Haptics.lightTick()
                                }
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
                            onApplied?()
                        }
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .animation(.easeInOut(duration: 0.2), value: focusedField)
        .navigationTitle("Calculate Norm")
        .onAppear { viewModel.loadPersistedInputs() }
        .alert("Applied", isPresented: $showApplied) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Daily limits updated.")
        }
    }
}
