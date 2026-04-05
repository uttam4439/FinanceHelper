//
//  TransactionCategory.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import SwiftUI

enum TransactionCategory: String, Codable, CaseIterable, Identifiable {
    case salary
    case freelance
    case gifts
    case groceries
    case dining
    case transport
    case housing
    case utilities
    case entertainment
    case shopping
    case health
    case travel
    case savings
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .salary: "Salary"
        case .freelance: "Freelance"
        case .gifts: "Gift"
        case .groceries: "Groceries"
        case .dining: "Dining"
        case .transport: "Transport"
        case .housing: "Housing"
        case .utilities: "Utilities"
        case .entertainment: "Fun"
        case .shopping: "Shopping"
        case .health: "Health"
        case .travel: "Travel"
        case .savings: "Savings"
        case .other: "Other"
        }
    }

    var symbol: String {
        switch self {
        case .salary: "briefcase.fill"
        case .freelance: "laptopcomputer"
        case .gifts: "gift.fill"
        case .groceries: "cart.fill"
        case .dining: "fork.knife"
        case .transport: "car.fill"
        case .housing: "house.fill"
        case .utilities: "bolt.fill"
        case .entertainment: "gamecontroller.fill"
        case .shopping: "bag.fill"
        case .health: "cross.case.fill"
        case .travel: "airplane"
        case .savings: "banknote.fill"
        case .other: "square.grid.2x2.fill"
        }
    }

    var color: Color {
        switch self {
        case .salary: .green
        case .freelance: .mint
        case .gifts: .teal
        case .groceries: .orange
        case .dining: .pink
        case .transport: .indigo
        case .housing: .brown
        case .utilities: .yellow
        case .entertainment: .purple
        case .shopping: .blue
        case .health: .red
        case .travel: .cyan
        case .savings: .green
        case .other: .gray
        }
    }

    var supportedKinds: [TransactionKind] {
        switch self {
        case .salary, .freelance, .gifts:
            [.income]
        default:
            [.expense]
        }
    }

    static func options(for kind: TransactionKind) -> [TransactionCategory] {
        allCases.filter { $0.supportedKinds.contains(kind) }
    }
}
