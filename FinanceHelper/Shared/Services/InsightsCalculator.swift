import Foundation

enum InsightsCalculator {
    static func makeSnapshot(
        transactions: [TransactionRecord],
        calendar: Calendar = .current
    ) -> InsightsSnapshot {
        let expenses = transactions.filter { $0.kind == .expense }
        let income = transactions.filter { $0.kind == .income }

        let categoryBreakdown = Dictionary(grouping: expenses, by: \.category)
            .map { category, values in
                CategoryTotal(category: category, total: values.reduce(0) { $0 + $1.amount })
            }
            .sorted { $0.total > $1.total }

        let topCategory = categoryBreakdown.first

        let weekOverWeekDelta = weeklyExpenseDifference(expenses: expenses, calendar: calendar)
        let monthlySeries = monthlyTrend(expenses: expenses, calendar: calendar)
        let frequentExpenseCategory = expenses
            .reduce(into: [TransactionCategory: Int]()) { counts, expense in
                counts[expense.category, default: 0] += 1
            }
            .max(by: { $0.value < $1.value })?
            .key

        let incomeTotal = income.reduce(0) { $0 + $1.amount }
        let expenseTotal = expenses.reduce(0) { $0 + $1.amount }

        let split: [SplitMetric] = [
            SplitMetric(label: "Income", amount: incomeTotal),
            SplitMetric(label: "Expenses", amount: expenseTotal),
        ]

        return InsightsSnapshot(
            topCategory: topCategory,
            weekOverWeekDelta: weekOverWeekDelta,
            monthlySeries: monthlySeries,
            categoryBreakdown: categoryBreakdown,
            frequentExpenseCategory: frequentExpenseCategory,
            incomeExpenseSplit: split
        )
    }

    private static func weeklyExpenseDifference(expenses: [TransactionRecord], calendar: Calendar) -> Double {
        guard
            let thisWeekInterval = calendar.dateInterval(of: .weekOfYear, for: .now),
            let lastWeekStart = calendar.date(byAdding: .day, value: -7, to: thisWeekInterval.start),
            let lastWeekInterval = calendar.dateInterval(of: .weekOfYear, for: lastWeekStart)
        else {
            return 0
        }

        let thisWeekTotal = expenses
            .filter { thisWeekInterval.contains($0.date) }
            .reduce(0) { $0 + $1.amount }

        let lastWeekTotal = expenses
            .filter { lastWeekInterval.contains($0.date) }
            .reduce(0) { $0 + $1.amount }

        return thisWeekTotal - lastWeekTotal
    }

    private static func monthlyTrend(expenses: [TransactionRecord], calendar: Calendar) -> [MonthlySpendingPoint] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        return (0..<6).compactMap { offset in
            guard let month = calendar.date(byAdding: .month, value: -offset, to: .now) else { return nil }
            let start = month.startOfMonth(calendar: calendar)
            guard let range = calendar.dateInterval(of: .month, for: start) else { return nil }
            let total = expenses
                .filter { range.contains($0.date) }
                .reduce(0) { $0 + $1.amount }

            return MonthlySpendingPoint(
                monthLabel: formatter.string(from: start),
                amount: total
            )
        }
        .reversed()
    }
}
