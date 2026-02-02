import SwiftUI

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditTransactionViewModel
    @FocusState private var focusedField: Field?

    enum Field {
        case protein
        case fat
        case carbs
    }

    init(container: AppContainer, transaction: MacroTransaction) {
        _viewModel = State(initialValue: EditTransactionViewModel(
            transaction: transaction,
            updateTransactionUseCase: container.updateTransactionUseCase,
            deleteTransactionUseCase: container.deleteTransactionUseCase
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Meal") {
                    Picker("Meal Type", selection: $viewModel.mealType) {
                        ForEach(MealType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("Title (optional)", text: $viewModel.title)
                }

                Section("Macros") {
                    TextField("Protein (g)", text: $viewModel.protein)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .protein)
                        .onChange(of: viewModel.protein) { _, _ in
                            viewModel.recalculateCalories()
                            Haptics.lightTick()
                        }
                    TextField("Fat (g)", text: $viewModel.fat)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .fat)
                        .onChange(of: viewModel.fat) { _, _ in
                            viewModel.recalculateCalories()
                            Haptics.lightTick()
                        }
                    TextField("Carbs (g)", text: $viewModel.carbs)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .carbs)
                        .onChange(of: viewModel.carbs) { _, _ in
                            viewModel.recalculateCalories()
                            Haptics.lightTick()
                        }
                }

                Section("Total") {
                    Text("Calories: \(viewModel.calories) kcal")
                        .font(.subheadline)
                        .foregroundStyle(DSColor.mutedText)
                }

                Section("Date") {
                    DatePicker("", selection: $viewModel.dateTime, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }

                Section("Note") {
                    TextField("Optional note", text: $viewModel.note)
                }

                Section {
                    Button(role: .destructive) {
                        if viewModel.delete() {
                            dismiss()
                        }
                    } label: {
                        Text("Delete meal")
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .animation(.easeInOut(duration: 0.2), value: focusedField)
            .navigationTitle("Edit Meal")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
