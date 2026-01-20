import Foundation

struct GetPresetsUseCase {
    private let repository: PresetRepository

    init(repository: PresetRepository) {
        self.repository = repository
    }

    func execute() throws -> [MacroPreset] {
        try repository.fetchAllPresets()
    }
}
