import Foundation
import Observation

@Observable
final class RootViewModel {
    private let getActiveBudgetUseCase: GetActiveBudgetUseCase

    var activeBudget: DailyBudget?

    init(getActiveBudgetUseCase: GetActiveBudgetUseCase) {
        self.getActiveBudgetUseCase = getActiveBudgetUseCase
    }

    func load() {
        activeBudget = try? getActiveBudgetUseCase.execute()
    }
}
