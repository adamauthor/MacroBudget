import SwiftUI

struct SetupView: View {
    @State private var viewModel: SetupViewModel
    let onFinish: () -> Void

    init(container: AppContainer, onFinish: @escaping () -> Void) {
        _viewModel = State(initialValue: SetupViewModel(saveBudgetUseCase: container.saveBudgetUseCase))
        self.onFinish = onFinish
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Limits") {
                    TextField("Calories", text: $viewModel.calories)
                        .keyboardType(.numberPad)
                    TextField("Protein", text: $viewModel.protein)
                        .keyboardType(.numberPad)
                    TextField("Fat", text: $viewModel.fat)
                        .keyboardType(.numberPad)
                    TextField("Carbs", text: $viewModel.carbs)
                        .keyboardType(.numberPad)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Set Daily Budget")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        if viewModel.save() {
                            onFinish()
                        }
                    }
                }
            }
        }
    }
}
