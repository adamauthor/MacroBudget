import Foundation

struct DeletePresetUseCase {
    private let repository: PresetRepository

    init(repository: PresetRepository) {
        self.repository = repository
    }

    func execute(id: UUID) throws {
        try repository.deletePreset(id: id)
    }
}
