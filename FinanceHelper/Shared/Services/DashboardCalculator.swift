import Foundation

enum DashboardCalculator {
    static func makeSummary(
        transactions: [TransactionRecord],
        goal: SavingsGoal?,
        calendar: Calendar = .current
    ) -> DashboardSummary {
        let balance = transactions.reduce(into: 0.0) { partialResult, transaction in
            partialResult += transaction.kind == .income ? transaction.amount : -transaction.amount
        }

        let monthTransactions = transactions.filter {
            calendar.isDate($0.date, equalTo: .now, toGranularity: .month)
        }

        let incomeTotal = monthTransactions
            .filter { $0.kind == .income }
            .reduce(0) { $0 + $1.amount }
        let expenseTotal = monthTransactions
            .filter { $0.kind == .expense }
            .reduce(0) { $0 + $1.amount }
        let savedThisMonth = incomeTotal - expenseTotal
        let target = goal?.monthlyTarget ?? 0
        let clampedProgress = target > 0 ? min(max(savedThisMonth / target, 0), 1) : 0
        let remainingToGoal = max(target - savedThisMonth, 0)

        let categoryBreakdown = Dictionary(
            grouping: monthTransactions.filter { $0.kind == .expense },
            by: \.category
        )
        .map { category, values in
            CategoryTotal(category: category, total: values.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.total > $1.total }

        return DashboardSummary(
            balance: balance,
            incomeTotal: incomeTotal,
            expenseTotal: expenseTotal,
            goalProgress: clampedProgress,
            remainingToGoal: remainingToGoal,
            savedThisMonth: savedThisMonth,
            recentTransactions: Array(transactions.prefix(5)),
            categoryBreakdown: categoryBreakdown
        )
    }
}
