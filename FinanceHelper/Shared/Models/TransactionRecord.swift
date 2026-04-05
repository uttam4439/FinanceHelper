//
//  TransactionRecord.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import Foundation
import SwiftData

@Model
final class TransactionRecord {
    var id: UUID
    var amount: Double
    var kind: TransactionKind
    var category: TransactionCategory
    var date: Date
    var note: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        amount: Double,
        kind: TransactionKind,
        category: TransactionCategory,
        date: Date,
        note: String,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.amount = amount
        self.kind = kind
        self.category = category
        self.date = date
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
