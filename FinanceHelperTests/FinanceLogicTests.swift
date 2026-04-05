//
//  FinanceLogicTests.swift
//  FinanceHelperTests
//
//  Created by Codex on 05/04/26.
//

import Foundation
import Testing
@testable import FinanceHelper

struct FinanceLogicTests {
    @Test
    func dashboardSummaryCalculatesMonthlyTotalsAndGoalProgress() {
        let calendar = Calendar.current
        let transactions = [
            makeTransaction(amount: 5000, kind: .income, category: .salary, daysAgo: 4),
            makeTransaction(amount: 1200, kind: .expense, category: .housing, daysAgo: 3),
            makeTransaction(amount: 300, kind: .expense, category: .groceries, daysAgo: 2),
            makeTransaction(amount: 250, kind: .income, category: .freelance, daysAgo: 1),
            makeTransaction(amount: 100, kind: .expense, category: .dining, daysAgo: 45),
        ]
        let goal = SavingsGoal(monthlyTarget: 2000, monthAnchor: .now)

        let summary = DashboardCalculator.makeSummary(
            transactions: transactions,
            goal: goal,
            calendar: calendar
        )

        #expect(summary.balance == 3650)
        #expect(summary.incomeTotal == 5250)
        #expect(summary.expenseTotal == 1500)
        #expect(summary.savedThisMonth == 3750)
        #expect(summary.goalProgress == 1)
        #expect(summary.remainingToGoal == 0)
        #expect(summary.categoryBreakdown.first?.category == .housing)
    }

    @Test
    func insightsSnapshotBuildsTrendAndCategoryMetrics() {
        let transactions = [
            makeTransaction(amount: 120, kind: .expense, category: .groceries, daysAgo: 2),
            makeTransaction(amount: 80, kind: .expense, category: .groceries, daysAgo: 4),
            makeTransaction(amount: 45, kind: .expense, category: .dining, daysAgo: 9),
            makeTransaction(amount: 2100, kind: .income, category: .salary, daysAgo: 5),
        ]

        let snapshot = InsightsCalculator.makeSnapshot(transactions: transactions)

        #expect(snapshot.topCategory?.category == .groceries)
        #expect(snapshot.topCategory?.total == 200)
        #expect(snapshot.frequentExpenseCategory == .groceries)
        #expect(snapshot.incomeExpenseSplit.count == 2)
        #expect(snapshot.monthlySeries.count == 6)
    }

    @Test
    func validatorRejectsInvalidAmounts() {
        let empty = TransactionFormValidator.validate(
            TransactionDraft(amountText: "", kind: .expense, category: .groceries, date: .now, note: "")
        )
        let zero = TransactionFormValidator.validate(
            TransactionDraft(amountText: "0", kind: .expense, category: .groceries, date: .now, note: "")
        )
        let valid = TransactionFormValidator.validate(
            TransactionDraft(amountText: "54.25", kind: .expense, category: .groceries, date: .now, note: "")
        )

        #expect(empty.isValid == false)
        #expect(zero.isValid == false)
        #expect(valid.isValid == true)
    }

    private func makeTransaction(
        amount: Double,
        kind: TransactionKind,
        category: TransactionCategory,
        daysAgo: Int
    ) -> TransactionRecord {
        TransactionRecord(
            amount: amount,
            kind: kind,
            category: category,
            date: Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now,
            note: ""
        )
    }
}
