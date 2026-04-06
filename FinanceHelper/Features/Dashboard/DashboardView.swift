import Charts
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\TransactionRecord.date, order: .reverse)])
    private var transactions: [TransactionRecord]
    @Query(sort: [SortDescriptor(\SavingsGoal.monthAnchor, order: .reverse)])
    private var goals: [SavingsGoal]

    let onAddTransaction: () -> Void

    @State private var showingGoalSheet = false
    @State private var showingMarketSheet = false
    @State private var isLoading = false
    @State private var loadError: String?

    init(onAddTransaction: @escaping () -> Void) {
        self.onAddTransaction = onAddTransaction
    }

    private var currentGoal: SavingsGoal? {
        goals.first(where: { Calendar.current.isDate($0.monthAnchor, equalTo: .now, toGranularity: .month) })
    }

    private var summary: DashboardSummary {
        DashboardCalculator.makeSummary(
            transactions: transactions,
            goal: currentGoal
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if let loadError {
                    ErrorStateView(message: loadError, actionTitle: "Retry") {
                        refreshData()
                    }
                } else if isLoading {
                    LoadingStateView(message: "Loading dashboard…")
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: FinanceSpacing.sectionGap) {
                            heroSection
                            totalsStrip
                            weeklyTrendSection

                            savingsGoalSection

                            recentTransactionsSection
                        }
                        .padding(.horizontal, FinanceSpacing.screenHorizontal)
                        .padding(.vertical, FinanceSpacing.screenVertical)
                    }
                }
            }
            .background(FinanceTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingMarketSheet = true
                    } label: {
                        Label("Markets", systemImage: "dollarsign.circle.fill")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(FinanceTheme.accent)
                    }
                    .accessibilityLabel("Open market and investing tools")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onAddTransaction) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(FinanceTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingGoalSheet) {
                NavigationStack {
                    SavingsGoalEditorView(goal: currentGoal)
                }
            }
            .sheet(isPresented: $showingMarketSheet) {
                NavigationStack {
                    MarketHubView()
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var heroSection: some View {
        FinanceSurface {
            VStack(alignment: .leading, spacing: 18) {
                Text("Hello!")
                    .font(.headline)
                    .foregroundStyle(FinanceTheme.textSecondary)

                VStack(alignment: .leading, spacing: FinanceSpacing.xSmall) {
                    Text("Total balance")
                        .font(.caption)
                        .foregroundStyle(FinanceTheme.textSecondary)

                    Text(CurrencyFormatting.currencyString(summary.balance))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(FinanceTheme.textPrimary)
                }

                HStack(spacing: FinanceSpacing.medium) {
                    SummaryCardView(
                        title: "Expenses",
                        value: CurrencyFormatting.currencyString(summary.expenseTotal),
                        caption: "This month",
                        systemImage: "basket.fill",
                        tint: FinanceTheme.accent,
                        filled: true
                    )

                    SummaryCardView(
                        title: "Income",
                        value: CurrencyFormatting.currencyString(summary.incomeTotal),
                        caption: "This month",
                        systemImage: "banknote.fill",
                        tint: FinanceTheme.secondaryCard
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var totalsStrip: some View {
        HStack(spacing: FinanceSpacing.rowGap) {
            SummaryCardView(
                title: "Saved",
                value: CurrencyFormatting.currencyString(summary.savedThisMonth),
                caption: summary.savedThisMonth >= 0 ? "Income minus spend" : "Needs attention",
                systemImage: "sparkles",
                tint: FinanceTheme.accentSoft
            )

            SummaryCardView(
                title: "Balance",
                value: CurrencyFormatting.currencyString(summary.balance),
                caption: "Across all records",
                systemImage: "wallet.bifold.fill",
                tint: Color.white
            )
        }
    }

    private var weeklyTrendSection: some View {
        SectionCardView(
            title: "Weekly Activity",
            subtitle: "A compact view of recent movement"
        ) {
            let weeklyData = weeklyAmounts

            if weeklyData.allSatisfy({ $0.amount == 0 }) {
                EmptyStateView(
                    title: "No activity yet",
                    message: "Add a few transactions to unlock your weekly chart.",
                    systemImage: "chart.bar.fill"
                )
            } else {
                Chart(weeklyData) { item in
                    BarMark(
                        x: .value("Day", item.label),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(barStyle(for: item))
                    .clipShape(RoundedRectangle(cornerRadius: FinanceSpacing.xSmall, style: .continuous))
                }
                .chartYAxis(.hidden)
                .chartXAxis {
                    AxisMarks(values: .automatic) {
                        AxisValueLabel()
                            .foregroundStyle(FinanceTheme.textSecondary)
                    }
                }
                .frame(height: 190)
            }
        }
    }

    private var savingsGoalSection: some View {
        SectionCardView(
            title: "Monthly Savings Goal",
            subtitle: currentGoal == nil ? "Set a target to stay motivated this month." : "Track your progress against the target."
        ) {
            if let goal = currentGoal {
                VStack(alignment: .leading, spacing: FinanceSpacing.rowGap) {
                    ProgressView(value: summary.goalProgress)
                        .progressViewStyle(.linear)
                        .tint(FinanceTheme.accent)

                    HStack {
                        VStack(alignment: .leading, spacing: FinanceSpacing.xxSmall) {
                            Text("Target")
                                .font(.caption)
                                .foregroundStyle(FinanceTheme.textSecondary)
                            Text(CurrencyFormatting.currencyString(goal.monthlyTarget))
                                .font(.headline)
                                .foregroundStyle(FinanceTheme.textPrimary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: FinanceSpacing.xxSmall) {
                            Text(summary.remainingToGoal > 0 ? "Remaining" : "Status")
                                .font(.caption)
                                .foregroundStyle(FinanceTheme.textSecondary)
                            Text(goalStatusText)
                                .font(.headline)
                                .foregroundStyle(summary.remainingToGoal > 0 ? AnyShapeStyle(FinanceTheme.textPrimary) : AnyShapeStyle(FinanceTheme.success))
                        }
                    }

                    Button("Edit Goal") {
                        showingGoalSheet = true
                    }
                    .buttonStyle(FinancePillButtonStyle(filled: false))
                }
            } else {
                EmptyStateView(
                    title: "No goal yet",
                    message: "Set a monthly target so the dashboard can show how your savings are tracking.",
                    systemImage: "target",
                    actionTitle: "Create Goal",
                    action: { showingGoalSheet = true }
                )
            }
        }
    }

    private var recentTransactionsSection: some View {
        SectionCardView(
            title: "Recent Transactions",
            subtitle: "Your latest money activity"
        ) {
            if summary.recentTransactions.isEmpty {
                EmptyStateView(
                    title: "Start tracking",
                    message: "Add your first transaction to build your spending history.",
                    systemImage: "list.bullet.rectangle.portrait",
                    actionTitle: "Add Transaction",
                    action: onAddTransaction
                )
            } else {
                ForEach(summary.recentTransactions) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            }
        }
    }

    private var goalStatusText: String {
        if summary.remainingToGoal == 0 {
            return "Goal reached"
        }

        if summary.goalProgress >= 0.75 {
            return "Nearly there"
        }

        return CurrencyFormatting.currencyString(summary.remainingToGoal)
    }

    private var weeklyAmounts: [WeeklyAmount] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "E"

        return (0..<6).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: .now) else { return nil }
            let total = transactions
                .filter { calendar.isDate($0.date, inSameDayAs: date) && $0.kind == .expense }
                .reduce(0) { partial, item in partial + item.amount }

            return WeeklyAmount(
                label: formatter.string(from: date),
                amount: total,
                isAccent: offset == 0
            )
        }
    }

    private func barStyle(for item: WeeklyAmount) -> AnyShapeStyle {
        if item.isAccent {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        FinanceTheme.accent,
                        FinanceTheme.accent.opacity(0.85)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        } else {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        FinanceTheme.accentSoft.opacity(0.95),
                        FinanceTheme.accent.opacity(0.7)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
    }

    private func refreshData() {
        // Hook for future async data; currently instant local data.
        loadError = nil
        isLoading = false
    }
}

private struct WeeklyAmount: Identifiable {
    let id = UUID()
    let label: String
    let amount: Double
    let isAccent: Bool
}
