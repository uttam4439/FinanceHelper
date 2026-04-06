import Foundation

struct TransactionDraft: Equatable {
    var amountText = ""
    var kind: TransactionKind = .expense
    var category: TransactionCategory = .groceries
    var date: Date = .now
    var note = ""

    init() {}

    init(
        amountText: String,
        kind: TransactionKind,
        category: TransactionCategory,
        date: Date,
        note: String
    ) {
        self.amountText = amountText
        self.kind = kind
        self.category = category
        self.date = date
        self.note = note
    }

    init(transaction: TransactionRecord) {
        self.amountText = CurrencyFormatting.editingString(from: transaction.amount)
        self.kind = transaction.kind
        self.category = transaction.category
        self.date = transaction.date
        self.note = transaction.note
    }

    var trimmedNote: String {
        note.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var amountValue: Double? {
        CurrencyFormatting.decimalValue(from: amountText)
    }
}
