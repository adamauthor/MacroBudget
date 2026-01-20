import Foundation

protocol CSVEncoding {
    func encode(transactions: [MacroTransaction]) -> String
}
