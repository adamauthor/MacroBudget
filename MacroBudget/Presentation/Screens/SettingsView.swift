import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showResetAlert = false
    @State private var showSavedToast = false
    @State private var showRestoreConfirm = false
    @State private var showFileImporter = false
    @State private var pendingRestoreURL: URL?
    let container: AppContainer

    init(container: AppContainer) {
        _viewModel = State(initialValue: SettingsViewModel(
            getActiveBudgetUseCase: container.getActiveBudgetUseCase,
            saveBudgetUseCase: container.saveBudgetUseCase,
            resetDataUseCase: container.resetDataUseCase,
            getPresetsUseCase: container.getPresetsUseCase,
            deletePresetUseCase: container.deletePresetUseCase,
            applyPresetUseCase: container.applyPresetUseCase,
            exportTransactionsCSVUseCase: container.exportTransactionsCSVUseCase,
            backupJSONUseCase: container.backupJSONUseCase,
            restoreBackupUseCase: container.restoreBackupUseCase
        ))
        self.container = container
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Budget") {
                    TextField("Calories", text: $viewModel.calories)
                        .keyboardType(.numberPad)
                    TextField("Protein", text: $viewModel.protein)
                        .keyboardType(.numberPad)
                    TextField("Fat", text: $viewModel.fat)
                        .keyboardType(.numberPad)
                    TextField("Carbs", text: $viewModel.carbs)
                        .keyboardType(.numberPad)
                    Button("Save Budget") {
                        if viewModel.save() {
                            showSavedToast = true
                        }
                    }
                }

                Section("Presets") {
                    if viewModel.presets.isEmpty {
                        Text("No presets yet")
                            .foregroundStyle(DSColor.mutedText)
                    } else {
                        ForEach(viewModel.presets) { preset in
                            Button {
                                viewModel.applyPreset(preset)
                            } label: {
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
                                    Text("Apply")
                                        .font(.caption)
                                        .foregroundStyle(DSColor.mutedText)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deletePreset(id: preset.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }

                Section {
                    NavigationLink("Calculate Norm") {
                        NormCalculatorView(container: container)
                    }
                }

                Section("Data") {
                    Text("Your data stays on your device.")
                        .font(.caption)
                        .foregroundStyle(DSColor.mutedText)

                    DatePicker("From", selection: $viewModel.exportFromDate, displayedComponents: [.date])
                    DatePicker("To", selection: $viewModel.exportToDate, displayedComponents: [.date])

                    Button("Export CSV") {
                        viewModel.exportCSV()
                    }

                    if let exportURL = viewModel.exportCSVURL {
                        ShareLink(item: exportURL) {
                            Label("Share CSV", systemImage: "square.and.arrow.up")
                        }
                    }

                    Button("Backup data") {
                        viewModel.backupData()
                    }

                    if let backupURL = viewModel.backupURL {
                        ShareLink(item: backupURL) {
                            Label("Share backup", systemImage: "square.and.arrow.up")
                        }
                    }

                    Button("Restore from backup") {
                        showFileImporter = true
                    }
                }

                Section("Danger Zone") {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Text("Reset all data")
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Settings")
            .onAppear { viewModel.load() }
            .alert("Reset all data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    _ = viewModel.resetAll()
                }
            } message: {
                Text("This will delete all budgets, transactions, and presets.")
            }
            .alert("Saved", isPresented: $showSavedToast) {
                Button("OK", role: .cancel) {}
            }
            .alert("Restore backup?", isPresented: $showRestoreConfirm) {
                Button("Cancel", role: .cancel) {
                    pendingRestoreURL = nil
                }
                Button("Restore", role: .destructive) {
                    if let url = pendingRestoreURL {
                        viewModel.restoreBackup(from: url)
                    }
                    pendingRestoreURL = nil
                }
            } message: {
                Text("Current budgets and transactions will be replaced.")
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json]) { result in
                switch result {
                case .success(let url):
                    pendingRestoreURL = url
                    showRestoreConfirm = true
                case .failure:
                    viewModel.errorMessage = "Unable to read the selected file."
                }
            }
        }
    }
}
