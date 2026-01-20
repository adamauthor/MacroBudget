import Foundation
import SwiftData

final class SwiftDataPresetRepository: PresetRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAllPresets() throws -> [MacroPreset] {
        let descriptor = FetchDescriptor<MacroPresetModel>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func savePreset(_ preset: MacroPreset) throws {
        context.insert(MacroPresetModel.fromDomain(preset))
        try context.save()
    }

    func deletePreset(id: UUID) throws {
        let descriptor = FetchDescriptor<MacroPresetModel>(predicate: #Predicate { $0.id == id })
        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
        }
    }

    func deleteAllPresets() throws {
        let descriptor = FetchDescriptor<MacroPresetModel>()
        let presets = try context.fetch(descriptor)
        presets.forEach { context.delete($0) }
        try context.save()
    }
}
