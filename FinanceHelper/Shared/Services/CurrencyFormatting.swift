import Foundation

enum CurrencyFormatting {
    static let currencyCode = Locale.current.currency?.identifier ?? "USD"

    static func currencyString(_ amount: Double) -> String {
        amount.formatted(.currency(code: currencyCode))
    }

    static func signedCurrencyString(_ amount: Double) -> String {
        let prefix = amount >= 0 ? "+" : "-"
        return prefix + currencyString(abs(amount))
    }

    static func editingString(from amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    static func decimalValue(from text: String) -> Double? {
        let sanitized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: "")

        return Double(sanitized)
    }
}
