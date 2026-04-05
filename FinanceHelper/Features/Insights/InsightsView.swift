//
//  InsightsView.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import Charts
import SwiftData
import SwiftUI

struct InsightsView: View {
    @Query(sort: [SortDescriptor(\TransactionRecord.date, order: .reverse)])
    private var transactions: [TransactionRecord]

    init() {}

    private var snapshot: InsightsSnapshot {
        InsightsCalculator.makeSnapshot(transactions: transactions)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if transactions.isEmpty {
                    EmptyStateView(
                        title: "Insights need history",
                        message: "Add a few transactions and this screen will highlight your spending patterns.",
                        systemImage: "chart.bar.xaxis"
                    )
                    .padding(20)
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        metricCards
                        monthlyTrendCard
                        splitCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .background(FinanceTheme.background.ignoresSafeArea())
            .navigationTitle("All Transactions")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var metricCards: some View {
        VStack(spacing: 16) {
            categoryDonutCard

            SectionCardView(
                title: "Top Spending Category",
                subtitle: "Where most of your expenses are going"
            ) {
                if let topCategory = snapshot.topCategory {
                    insightMetricRow(
                        title: topCategory.category.title,
                        subtitle: CurrencyFormatting.currencyString(topCategory.total),
                        systemImage: topCategory.category.symbol,
                        tint: topCategory.category.color
                    )
                } else {
                    Text("Not enough spending data yet.")
                        .foregroundStyle(FinanceTheme.textSecondary)
                }
            }

            SectionCardView(
                title: "This Week vs Last Week",
                subtitle: "How your spending is shifting"
            ) {
                insightMetricRow(
                    title: weeklyChangeMessage,
                    subtitle: "A quick pulse on weekly habits",
                    systemImage: "chart.line.uptrend.xyaxis",
                    tint: weeklyChangeTint
                )
            }

            SectionCardView(
                title: "Most Frequent Expense",
                subtitle: "The category you log most often"
            ) {
                if let frequentExpenseCategory = snapshot.frequentExpenseCategory {
                    insightMetricRow(
                        title: frequentExpenseCategory.title,
                        subtitle: "Repeated most often",
                        systemImage: frequentExpenseCategory.symbol,
                        tint: frequentExpenseCategory.color
                    )
                } else {
                    Text("Not enough expense history yet.")
                        .foregroundStyle(FinanceTheme.textSecondary)
                }
            }
        }
    }

    private var categoryDonutCard: some View {
        SectionCardView(
            title: "April Overview",
            subtitle: "Category share"
        ) {
            if snapshot.categoryBreakdown.isEmpty {
                Text("No category data yet.")
                    .foregroundStyle(FinanceTheme.textSecondary)
            } else {
                HStack(spacing: 18) {
                    Chart(snapshot.categoryBreakdown.prefix(5)) { item in
                        SectorMark(
                            angle: .value("Amount", item.total),
                            innerRadius: .ratio(0.56),
                            angularInset: 3
                        )
                        .foregroundStyle(item.category.color)
                    }
                    .frame(width: 150, height: 150)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(snapshot.categoryBreakdown.prefix(4))) { item in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(item.category.color)
                                    .frame(width: 8, height: 8)
                                Text(item.category.title)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(FinanceTheme.textPrimary)
                                Spacer()
                                Text(CurrencyFormatting.currencyString(item.total))
                                    .font(.caption)
                                    .foregroundStyle(FinanceTheme.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private var monthlyTrendCard: some View {
        SectionCardView(
            title: "Monthly Trend",
            subtitle: "Last six months of expenses"
        ) {
            if snapshot.monthlySeries.allSatisfy({ $0.amount == 0 }) {
                Text("Add more expense entries to unlock a stronger monthly trend.")
                    .foregroundStyle(FinanceTheme.textSecondary)
            } else {
                Chart(snapshot.monthlySeries) { point in
                    BarMark(
                        x: .value("Month", point.monthLabel),
                        y: .value("Spent", point.amount)
                    )
                    .foregroundStyle(FinanceTheme.accent.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .frame(height: 220)
            }
        }
    }

    private var splitCard: some View {
        SectionCardView(
            title: "Income vs Expenses",
            subtitle: "Overall split in your recorded data"
        ) {
            if snapshot.incomeExpenseSplit.allSatisfy({ $0.amount == 0 }) {
                Text("No totals available yet.")
                    .foregroundStyle(FinanceTheme.textSecondary)
            } else {
                Chart(snapshot.incomeExpenseSplit) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.56),
                        angularInset: 2
                    )
                    .foregroundStyle(item.label == "Income" ? FinanceTheme.success : FinanceTheme.accent)
                }
                .frame(height: 220)

                HStack {
                    ForEach(snapshot.incomeExpenseSplit) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.label)
                                .font(.caption)
                                .foregroundStyle(FinanceTheme.textSecondary)
                            Text(CurrencyFormatting.currencyString(item.amount))
                                .font(.headline)
                                .foregroundStyle(FinanceTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private func insightMetricRow(title: String, subtitle: String, systemImage: String, tint: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(FinanceTheme.secondaryCard, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(FinanceTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(FinanceTheme.textSecondary)
            }

            Spacer()
        }
    }

    private var weeklyChangeMessage: String {
        if snapshot.weekOverWeekDelta > 0 {
            return "\(CurrencyFormatting.currencyString(snapshot.weekOverWeekDelta)) more spent this week"
        }

        if snapshot.weekOverWeekDelta < 0 {
            return "\(CurrencyFormatting.currencyString(abs(snapshot.weekOverWeekDelta))) less spent this week"
        }

        return "Your spending is flat week over week"
    }

    private var weeklyChangeTint: Color {
        snapshot.weekOverWeekDelta > 0 ? FinanceTheme.accent : FinanceTheme.success
    }
}
