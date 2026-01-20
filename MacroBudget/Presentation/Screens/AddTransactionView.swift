import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddTransactionViewModel
    @FocusState private var focusedField: Field?

    enum Field {
        case calories
        case protein
        case fat
        case carbs
    }

    let onSave: () -> Void

    init(container: AppContainer, onSave: @escaping () -> Void) {
        _viewModel = State(initialValue: AddTransactionViewModel(addTransactionUseCase: container.addTransactionUseCase))
        self.onSave = onSave
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
                    TextField("Calories", text: $viewModel.calories)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .calories)
                    TextField("Protein", text: $viewModel.protein)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .protein)
                    TextField("Fat", text: $viewModel.fat)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .fat)
                    TextField("Carbs", text: $viewModel.carbs)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .carbs)
                }

                Section("Date") {
                    DatePicker("", selection: $viewModel.dateTime, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }

                Section("Note") {
                    TextField("Optional note", text: $viewModel.note)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Add Meal")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if viewModel.add() {
                            onSave()
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Next") { focusNext() }
                    Button("Done") { focusedField = nil }
                }
            }
            .onAppear {
                focusedField = .calories
            }
        }
    }

    private func focusNext() {
        switch focusedField {
        case .calories:
            focusedField = .protein
        case .protein:
            focusedField = .fat
        case .fat:
            focusedField = .carbs
        case .carbs:
            focusedField = nil
        case .none:
            focusedField = .calories
        }
    }
}
