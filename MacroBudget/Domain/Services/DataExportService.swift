import Foundation

protocol DataExportService {
    func exportData() throws -> URL
    func importData(from url: URL) throws
}
