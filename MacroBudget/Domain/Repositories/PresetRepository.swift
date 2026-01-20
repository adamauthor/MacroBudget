import Foundation

protocol PresetRepository {
    func fetchAllPresets() throws -> [MacroPreset]
    func savePreset(_ preset: MacroPreset) throws
    func deletePreset(id: UUID) throws
    func deleteAllPresets() throws
}
