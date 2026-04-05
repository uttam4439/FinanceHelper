//
//  DashboardSummary.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import Foundation

struct DashboardSummary {
    let balance: Double
    let incomeTotal: Double
    let expenseTotal: Double
    let goalProgress: Double
    let remainingToGoal: Double
    let savedThisMonth: Double
    let recentTransactions: [TransactionRecord]
    let categoryBreakdown: [CategoryTotal]
}

struct CategoryTotal: Identifiable, Hashable {
    let category: TransactionCategory
    let total: Double

    var id: String { category.rawValue }
}
