import Foundation

extension String {
    func normalizedDecimalValue() -> Double? {
        Double(replacingOccurrences(of: ",", with: "."))
    }
}
