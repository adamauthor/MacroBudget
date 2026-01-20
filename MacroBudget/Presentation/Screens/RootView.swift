import SwiftUI

struct RootView: View {
    @State private var viewModel: RootViewModel
    let container: AppContainer

    init(container: AppContainer) {
        _viewModel = State(initialValue: RootViewModel(getActiveBudgetUseCase: container.getActiveBudgetUseCase))
        self.container = container
    }

    var body: some View {
        Group {
            if viewModel.activeBudget == nil {
                SetupView(container: container) {
                    viewModel.load()
                }
            } else {
                MainTabView(container: container)
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
}
