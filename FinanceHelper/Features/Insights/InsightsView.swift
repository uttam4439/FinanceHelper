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
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Insights")
        }
    }

    private var metricCards: some View {
        VStack(spacing: 16) {
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
                        .foregroundStyle(.secondary)
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
                        .foregroundStyle(.secondary)
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
                    .foregroundStyle(.secondary)
            } else {
                Chart(snapshot.monthlySeries) { point in
                    BarMark(
                        x: .value("Month", point.monthLabel),
                        y: .value("Spent", point.amount)
                    )
                    .foregroundStyle(.blue.gradient)
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
                    .foregroundStyle(.secondary)
            } else {
                Chart(snapshot.incomeExpenseSplit) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.56),
                        angularInset: 2
                    )
                    .foregroundStyle(item.label == "Income" ? .green : .orange)
                }
                .frame(height: 220)

                HStack {
                    ForEach(snapshot.incomeExpenseSplit) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(CurrencyFormatting.currencyString(item.amount))
                                .font(.headline)
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
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
        snapshot.weekOverWeekDelta > 0 ? .orange : .green
    }
}
