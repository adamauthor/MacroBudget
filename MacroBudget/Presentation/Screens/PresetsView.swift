import SwiftUI
import UIKit

struct PresetsView: View {
    @State private var viewModel: PresetsViewModel
    @State private var showAdd = false
    @State private var draft = PresetDraft()
    @State private var editingPreset: MacroPreset?
    @State private var editDraft = PresetEditDraft()

    init(container: AppContainer) {
        _viewModel = State(initialValue: PresetsViewModel(
            getPresetsUseCase: container.getPresetsUseCase,
            savePresetUseCase: container.savePresetUseCase,
            deletePresetUseCase: container.deletePresetUseCase,
            applyPresetUseCase: container.applyPresetUseCase,
            upsertPresetUseCase: container.upsertPresetUseCase,
            getActiveBudgetUseCase: container.getActiveBudgetUseCase
        ))
    }

    var body: some View {
        List {
            if viewModel.presets.isEmpty {
                Text("No presets yet")
                    .foregroundStyle(DSColor.mutedText)
            } else {
                ForEach(viewModel.presets) { preset in
                    HStack {
                        Image(systemName: preset.iconName)
                            .foregroundStyle(PresetColorOption(rawValue: preset.colorName)?.color ?? DSColor.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(preset.name)
                            Text("\(preset.calories) kcal • P \(preset.protein) • F \(preset.fat) • C \(preset.carbs)")
                                .font(.caption)
                                .foregroundStyle(DSColor.mutedText)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingPreset = preset
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.easeInOut(duration: 0.25), value: viewModel.presets.count)
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Presets")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    draft = PresetDraft(from: viewModel.baseTotals)
                    showAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear { viewModel.load() }
        .onChange(of: editingPreset) { _, newValue in
            if let preset = newValue {
                editDraft = PresetEditDraft(from: preset)
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                Form {
                    Section("Template") {
                        Picker("Template", selection: $draft.template) {
                            ForEach(PresetTemplate.allCases) { template in
                                Text(template.title).tag(template)
                            }
                        }
                        .onChange(of: draft.template) { _, newValue in
                            draft.applyTemplate(newValue, base: viewModel.baseTotals)
                        }
                    }

                    Section("Preset") {
                        TextField("Name", text: $draft.name)
                        Picker("Color", selection: $draft.color) {
                            ForEach(PresetColorOption.allCases) { option in
                                Text(option.rawValue.capitalized).tag(option)
                            }
                        }
                        Picker("Icon", selection: $draft.icon) {
                            ForEach(PresetIconOption.allCases) { option in
                                Text(option.rawValue.capitalized).tag(option)
                            }
                        }
                    }

                    Section("Macros") {
                        TextField("Protein (g)", text: $draft.protein)
                            .keyboardType(.decimalPad)
                            .onChange(of: draft.protein) { _, _ in
                                draft.recalculateCalories()
                                Haptics.lightTick()
                            }
                        TextField("Fat (g)", text: $draft.fat)
                            .keyboardType(.decimalPad)
                            .onChange(of: draft.fat) { _, _ in
                                draft.recalculateCalories()
                                Haptics.lightTick()
                            }
                        TextField("Carbs (g)", text: $draft.carbs)
                            .keyboardType(.decimalPad)
                            .onChange(of: draft.carbs) { _, _ in
                                draft.recalculateCalories()
                                Haptics.lightTick()
                            }
                        Text("Calories: \(draft.calories) kcal")
                            .font(.caption)
                            .foregroundStyle(DSColor.mutedText)
                    }
                }
                .navigationTitle("New Preset")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            viewModel.savePreset(
                                name: draft.name.isEmpty ? draft.template.title : draft.name,
                                calories: draft.caloriesValue,
                                protein: draft.proteinValue,
                                fat: draft.fatValue,
                                carbs: draft.carbsValue,
                                iconName: draft.icon.systemName,
                                colorName: draft.color.rawValue
                            )
                            showAdd = false
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showAdd = false }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .sheet(item: $editingPreset) { preset in
            NavigationStack {
                Form {
                    Section("Preset") {
                        TextField("Name", text: $editDraft.name)
                        Picker("Color", selection: $editDraft.color) {
                            ForEach(PresetColorOption.allCases) { option in
                                Text(option.rawValue.capitalized).tag(option)
                            }
                        }
                        Picker("Icon", selection: $editDraft.icon) {
                            ForEach(PresetIconOption.allCases) { option in
                                Text(option.rawValue.capitalized).tag(option)
                            }
                        }
                    }

                    Section("Macros") {
                        HStack {
                            TextField("Protein (g)", text: $editDraft.protein)
                                .keyboardType(.decimalPad)
                                .onChange(of: editDraft.protein) { _, _ in
                                    editDraft.recalculateCalories()
                                    Haptics.lightTick()
                                }
                            Text("P")
                                .foregroundStyle(DSColor.mutedText)
                        }
                        HStack {
                            TextField("Fat (g)", text: $editDraft.fat)
                                .keyboardType(.decimalPad)
                                .onChange(of: editDraft.fat) { _, _ in
                                    editDraft.recalculateCalories()
                                    Haptics.lightTick()
                                }
                            Text("F")
                                .foregroundStyle(DSColor.mutedText)
                        }
                        HStack {
                            TextField("Carbs (g)", text: $editDraft.carbs)
                                .keyboardType(.decimalPad)
                                .onChange(of: editDraft.carbs) { _, _ in
                                    editDraft.recalculateCalories()
                                    Haptics.lightTick()
                                }
                            Text("C")
                                .foregroundStyle(DSColor.mutedText)
                        }
                        Text("Calories: \(editDraft.caloriesValue) kcal")
                            .font(.caption)
                            .foregroundStyle(DSColor.mutedText)
                    }

                    Section {
                        Button(role: .destructive) {
                            viewModel.deletePreset(id: preset.id)
                            editingPreset = nil
                        } label: {
                            Text("Delete preset")
                        }
                    }
                }
                .navigationTitle("Edit Preset")
                .task(id: preset.id) {
                    editDraft = PresetEditDraft(from: preset)
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let name = editDraft.name.isEmpty ? preset.name : editDraft.name
                            if viewModel.updatePreset(
                                preset: preset,
                                name: name,
                                calories: editDraft.caloriesValue,
                                protein: editDraft.proteinValue,
                                fat: editDraft.fatValue,
                                carbs: editDraft.carbsValue,
                                iconName: editDraft.icon.systemName,
                                colorName: editDraft.color.rawValue
                            ) {
                                editingPreset = nil
                            }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { editingPreset = nil }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

private struct PresetTemplate: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let multiplier: Double
    let color: PresetColorOption
    let icon: PresetIconOption

    static let allCases: [PresetTemplate] = [
        PresetTemplate(title: "Regular Day", multiplier: 1.0, color: .blue, icon: .bolt),
        PresetTemplate(title: "Training Day", multiplier: 1.1, color: .green, icon: .dumbbell),
        PresetTemplate(title: "Low Activity", multiplier: 0.9, color: .gray, icon: .moon),
        PresetTemplate(title: "Celebration Day", multiplier: 1.05, color: .orange, icon: .sun),
        PresetTemplate(title: "Cut", multiplier: 0.85, color: .red, icon: .flame),
        PresetTemplate(title: "Maintain", multiplier: 1.0, color: .blue, icon: .bolt)
    ]
}

private struct PresetDraft {
    var template: PresetTemplate = PresetTemplate.allCases[0]
    var name: String = ""
    var color: PresetColorOption = .blue
    var icon: PresetIconOption = .bolt
    var protein: String = ""
    var fat: String = ""
    var carbs: String = ""
    var calories: String = ""

    init() {}

    init(from base: MacroTotals) {
        applyTemplate(template, base: base)
    }

    mutating func applyTemplate(_ template: PresetTemplate, base: MacroTotals) {
        self.template = template
        name = template.title
        color = template.color
        icon = template.icon
        protein = String(Int(round(Double(base.protein) * template.multiplier)))
        fat = String(Int(round(Double(base.fat) * template.multiplier)))
        carbs = String(Int(round(Double(base.carbs) * template.multiplier)))
        recalculateCalories()
    }

    mutating func recalculateCalories() {
        calories = String(caloriesValue)
    }

    var proteinValue: Int { Int(round(protein.normalizedDecimalValue() ?? 0)) }
    var fatValue: Int { Int(round(fat.normalizedDecimalValue() ?? 0)) }
    var carbsValue: Int { Int(round(carbs.normalizedDecimalValue() ?? 0)) }
    var caloriesValue: Int { proteinValue * 4 + fatValue * 9 + carbsValue * 4 }
}

private struct PresetEditDraft {
    var name: String = ""
    var color: PresetColorOption = .blue
    var icon: PresetIconOption = .bolt
    var protein: String = ""
    var fat: String = ""
    var carbs: String = ""
    var calories: String = ""

    init() {}

    init(from preset: MacroPreset) {
        name = preset.name
        color = PresetColorOption(rawValue: preset.colorName) ?? .blue
        icon = PresetIconOption(rawValue: preset.iconName) ?? .bolt
        protein = String(preset.protein)
        fat = String(preset.fat)
        carbs = String(preset.carbs)
        recalculateCalories()
    }

    mutating func recalculateCalories() {
        calories = String(caloriesValue)
    }

    var proteinValue: Int { Int(round(protein.normalizedDecimalValue() ?? 0)) }
    var fatValue: Int { Int(round(fat.normalizedDecimalValue() ?? 0)) }
    var carbsValue: Int { Int(round(carbs.normalizedDecimalValue() ?? 0)) }
    var caloriesValue: Int { proteinValue * 4 + fatValue * 9 + carbsValue * 4 }
}
