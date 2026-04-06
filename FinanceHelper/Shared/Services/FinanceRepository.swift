import Foundation
import SwiftData

protocol FinanceRepositoryProtocol {
    func fetchTransactions() throws -> [TransactionRecord]
    func fetchTransactions(
        searchText: String,
        kind: TransactionKind?,
        category: TransactionCategory?,
        dateRange: DateRangeFilter
    ) throws -> [TransactionRecord]
    func addTransaction(from draft: TransactionDraft) throws
    func updateTransaction(_ transaction: TransactionRecord, with draft: TransactionDraft) throws
    func deleteTransaction(_ transaction: TransactionRecord) throws
    func goal(for month: Date) throws -> SavingsGoal?
    func saveGoal(target: Double, carryOverEnabled: Bool, month: Date) throws
}

@MainActor
struct FinanceRepository: FinanceRepositoryProtocol {
    let context: ModelContext

    func fetchTransactions() throws -> [TransactionRecord] {
        let descriptor = FetchDescriptor<TransactionRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func fetchTransactions(
        searchText: String,
        kind: TransactionKind?,
        category: TransactionCategory?,
        dateRange: DateRangeFilter
    ) throws -> [TransactionRecord] {
        let records = try fetchTransactions()

        return records.filter { record in
            let matchesSearch = searchText.isEmpty
                || record.note.localizedCaseInsensitiveContains(searchText)
                || record.category.title.localizedCaseInsensitiveContains(searchText)

            let matchesKind = kind == nil || record.kind == kind
            let matchesCategory = category == nil || record.category == category
            let matchesDate = dateRange.contains(record.date)

            return matchesSearch && matchesKind && matchesCategory && matchesDate
        }
    }

    func addTransaction(from draft: TransactionDraft) throws {
        guard let amount = draft.amountValue else { return }

        let transaction = TransactionRecord(
            amount: amount,
            kind: draft.kind,
            category: draft.category,
            date: draft.date,
            note: draft.trimmedNote
        )

        context.insert(transaction)
        try context.save()
    }

    func updateTransaction(_ transaction: TransactionRecord, with draft: TransactionDraft) throws {
        guard let amount = draft.amountValue else { return }

        transaction.amount = amount
        transaction.kind = draft.kind
        transaction.category = draft.category
        transaction.date = draft.date
        transaction.note = draft.trimmedNote
        transaction.updatedAt = .now

        try context.save()
    }

    func deleteTransaction(_ transaction: TransactionRecord) throws {
        context.delete(transaction)
        try context.save()
    }

    func goal(for month: Date) throws -> SavingsGoal? {
        let monthAnchor = month.startOfMonth()
        let descriptor = FetchDescriptor<SavingsGoal>(
            sortBy: [SortDescriptor(\.monthAnchor, order: .reverse)]
        )
        return try context.fetch(descriptor)
            .first(where: { Calendar.current.isDate($0.monthAnchor, equalTo: monthAnchor, toGranularity: .month) })
    }

    func saveGoal(target: Double, carryOverEnabled: Bool, month: Date) throws {
        let monthAnchor = month.startOfMonth()

        if let existingGoal = try goal(for: monthAnchor) {
            existingGoal.monthlyTarget = target
            existingGoal.carryOverEnabled = carryOverEnabled
        } else {
            let goal = SavingsGoal(
                monthlyTarget: target,
                monthAnchor: monthAnchor,
                carryOverEnabled: carryOverEnabled
            )
            context.insert(goal)
        }

        try context.save()
    }
}
