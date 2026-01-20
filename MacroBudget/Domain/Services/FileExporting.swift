import Foundation

protocol FileExporting {
    func write(_ data: Data, fileName: String) throws -> URL
}
