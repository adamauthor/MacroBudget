import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showResetAlert = false
    @State private var showSavedToast = false
    @State private var showRestoreConfirm = false
    @State private var showFileImporter = false
    @State private var pendingRestoreURL: URL?
    @State private var shareURL: ShareItem?
    let container: AppContainer
    @AppStorage("accentColor") private var accentColorName = AccentColorOption.default.rawValue

    init(container: AppContainer) {
        _viewModel = State(initialValue: SettingsViewModel(
            getActiveBudgetUseCase: container.getActiveBudgetUseCase,
            saveBudgetUseCase: container.saveBudgetUseCase,
            resetDataUseCase: container.resetDataUseCase,
            exportTransactionsCSVUseCase: container.exportTransactionsCSVUseCase,
            backupJSONUseCase: container.backupJSONUseCase,
            restoreBackupUseCase: container.restoreBackupUseCase
        ))
        self.container = container
    }

    var body: some View {
        let accent = AccentColorOption(rawValue: accentColorName)?.color ?? AccentColorOption.default.color
        NavigationStack {
            Form {
                Section("Daily Budget") {
                    HStack {
                        TextField("Protein", text: $viewModel.protein)
                            .keyboardType(.decimalPad)
                            .onChange(of: viewModel.protein) { _, _ in
                                viewModel.recalculateCalories()
                                Haptics.lightTick()
                            }
                        Text("P")
                            .foregroundStyle(DSColor.mutedText)
                    }
                    HStack {
                        TextField("Fat", text: $viewModel.fat)
                            .keyboardType(.decimalPad)
                            .onChange(of: viewModel.fat) { _, _ in
                                viewModel.recalculateCalories()
                                Haptics.lightTick()
                            }
                        Text("F")
                            .foregroundStyle(DSColor.mutedText)
                    }
                    HStack {
                        TextField("Carbs", text: $viewModel.carbs)
                            .keyboardType(.decimalPad)
                            .onChange(of: viewModel.carbs) { _, _ in
                                viewModel.recalculateCalories()
                                Haptics.lightTick()
                            }
                        Text("C")
                            .foregroundStyle(DSColor.mutedText)
                    }
                    Text("Calories: \(viewModel.calories) kcal")
                        .font(.caption)
                        .foregroundStyle(DSColor.mutedText)
                    Button("Save Budget") {
                        if viewModel.save() {
                            showSavedToast = true
                        }
                    }
                }

                Section("Appearance") {
                    Picker("Accent color", selection: $accentColorName) {
                        ForEach(AccentColorOption.allCases) { option in
                            Text(option.title).tag(option.rawValue)
                        }
                    }
                    .tint(accent)
                }

                Section {
                    NavigationLink("Calculate Norm") {
                        NormCalculatorView(container: container)
                    }
                    NavigationLink("Presets") {
                        PresetsView(container: container)
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

                    Button("Backup data") {
                        viewModel.backupData()
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
            .id(accentColorName)
            .navigationTitle("Settings")
            .onAppear { viewModel.load() }
            .scrollDismissesKeyboard(.immediately)
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
                        let didAccess = url.startAccessingSecurityScopedResource()
                        viewModel.restoreBackup(from: url)
                        if didAccess {
                            url.stopAccessingSecurityScopedResource()
                        }
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
            .sheet(item: $shareURL) { item in
                ShareSheet(items: [item.url])
            }
            .onChange(of: viewModel.exportCSVURL) { _, newValue in
                if let url = newValue {
                    shareURL = ShareItem(url: url)
                    viewModel.exportCSVURL = nil
                }
            }
            .onChange(of: viewModel.backupURL) { _, newValue in
                if let url = newValue {
                    shareURL = ShareItem(url: url)
                    viewModel.backupURL = nil
                }
            }
        }
        .tint(accent)
    }
}

private struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}
