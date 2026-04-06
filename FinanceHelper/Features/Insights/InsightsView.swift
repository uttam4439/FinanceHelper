import Charts
import SwiftData
import SwiftUI

struct InsightsView: View {
    @Query(sort: [SortDescriptor(\TransactionRecord.date, order: .reverse)])
    private var transactions: [TransactionRecord]

    init() {}

    @State private var selectedMonth: String?
    @State private var isLoading = false
    @State private var loadError: String?

    private var snapshot: InsightsSnapshot {
        InsightsCalculator.makeSnapshot(transactions: transactions)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if let loadError {
                    ErrorStateView(message: loadError, actionTitle: "Retry") { refreshData() }
                } else if isLoading {
                    LoadingStateView(message: "Loading insights…")
                } else {
                    ScrollView {
                        if transactions.isEmpty {
                            EmptyStateView(
                                title: "Insights need history",
                                message: "Add a few transactions and this screen will highlight your spending patterns.",
                                systemImage: "chart.bar.xaxis"
                            )
                            .padding(FinanceSpacing.large)
                        } else {
                            VStack(alignment: .leading, spacing: FinanceSpacing.sectionGap) {
                                metricCards
                                monthlyTrendCard
                                splitCard
                            }
                            .padding(.horizontal, FinanceSpacing.screenHorizontal)
                            .padding(.vertical, FinanceSpacing.screenVertical)
                        }
                    }
                }
            }
            .background(FinanceTheme.background.ignoresSafeArea())
            .navigationTitle("All Transactions")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var metricCards: some View {
        VStack(spacing: FinanceSpacing.cardGap) {
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

                    VStack(alignment: .leading, spacing: FinanceSpacing.small) {
                        ForEach(Array(snapshot.categoryBreakdown.prefix(4))) { item in
                            HStack(spacing: FinanceSpacing.xSmall) {
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
            subtitle: "Last six months of expenses (line)"
        ) {
            if snapshot.monthlySeries.allSatisfy({ $0.amount == 0 }) {
                Text("Add more expense entries to unlock a stronger monthly trend.")
                    .foregroundStyle(FinanceTheme.textSecondary)
            } else {
                Chart(snapshot.monthlySeries) { point in
                    AreaMark(
                        x: .value("Month", point.monthLabel),
                        y: .value("Spent", point.amount)
                    )
                    .foregroundStyle(FinanceTheme.accent.opacity(0.25))

                    LineMark(
                        x: .value("Month", point.monthLabel),
                        y: .value("Spent", point.amount)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(.init(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(FinanceTheme.accent)

                    PointMark(
                        x: .value("Month", point.monthLabel),
                        y: .value("Spent", point.amount)
                    )
                    .symbolSize(50)
                    .foregroundStyle(FinanceTheme.accent)
                    .opacity(selectedMonth == nil || selectedMonth == point.monthLabel ? 1 : 0.35)
                    .annotation(position: .top) {
                        if selectedMonth == point.monthLabel {
                            Text(CurrencyFormatting.currencyString(point.amount))
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, FinanceSpacing.medium)
                                .padding(.vertical, FinanceSpacing.xSmall)
                                .background(FinanceTheme.card, in: Capsule(style: .continuous))
                                .shadow(color: FinanceTheme.shadow, radius: FinanceSpacing.small, y: FinanceSpacing.xxSmall)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXSelection(value: $selectedMonth)
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
                        VStack(alignment: .leading, spacing: FinanceSpacing.xxSmall) {
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
        HStack(spacing: FinanceSpacing.rowGap) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(FinanceTheme.secondaryCard, in: RoundedRectangle(cornerRadius: FinanceRadius.chip, style: .continuous))

            VStack(alignment: .leading, spacing: FinanceSpacing.xxSmall) {
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

    private func refreshData() {
        // Hook for future async data; currently instant local data.
        loadError = nil
        isLoading = false
    }
}
