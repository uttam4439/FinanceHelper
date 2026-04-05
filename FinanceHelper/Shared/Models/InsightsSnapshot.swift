//
//  InsightsSnapshot.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import Foundation

struct InsightsSnapshot {
    let topCategory: CategoryTotal?
    let weekOverWeekDelta: Double
    let monthlySeries: [MonthlySpendingPoint]
    let categoryBreakdown: [CategoryTotal]
    let frequentExpenseCategory: TransactionCategory?
    let incomeExpenseSplit: [SplitMetric]
}

struct MonthlySpendingPoint: Identifiable, Hashable {
    let id = UUID()
    let monthLabel: String
    let amount: Double
}

struct SplitMetric: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let amount: Double
}
