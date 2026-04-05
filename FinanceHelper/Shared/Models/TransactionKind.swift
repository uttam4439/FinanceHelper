//
//  TransactionKind.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import Foundation

enum TransactionKind: String, Codable, CaseIterable, Identifiable {
    case expense
    case income

    var id: String { rawValue }

    var title: String {
        switch self {
        case .expense: "Expense"
        case .income: "Income"
        }
    }

    var symbol: String {
        switch self {
        case .expense: "arrow.up.circle.fill"
        case .income: "arrow.down.circle.fill"
        }
    }
}
