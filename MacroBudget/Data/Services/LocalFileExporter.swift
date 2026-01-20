import Foundation

final class LocalFileExporter: FileExporting {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func write(_ data: Data, fileName: String) throws -> URL {
        let directory = fileManager.temporaryDirectory
        let url = directory.appendingPathComponent(fileName)
        try data.write(to: url, options: [.atomic])
        return url
    }
}
