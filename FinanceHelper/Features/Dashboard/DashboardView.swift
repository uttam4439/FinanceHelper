//
//  DashboardView.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroSection

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 14),
                        GridItem(.flexible(), spacing: 14),
                    ], spacing: 14) {
                        SummaryCardView(
                            title: "Current Balance",
                            value: CurrencyFormatting.currencyString(summary.balance),
                            caption: "All recorded activity",
                            systemImage: "wallet.bifold.fill",
                            tint: .blue
                        )

                        SummaryCardView(
                            title: "This Month In",
                            value: CurrencyFormatting.currencyString(summary.incomeTotal),
                            caption: "Income tracked this month",
                            systemImage: "arrow.down.circle.fill",
                            tint: .green
                        )

                        SummaryCardView(
                            title: "This Month Out",
                            value: CurrencyFormatting.currencyString(summary.expenseTotal),
                            caption: "Spending tracked this month",
                            systemImage: "arrow.up.circle.fill",
                            tint: .orange
                        )

                        SummaryCardView(
                            title: "Saved So Far",
                            value: CurrencyFormatting.currencyString(summary.savedThisMonth),
                            caption: summary.savedThisMonth >= 0 ? "Income minus expenses" : "You are over budget",
                            systemImage: "chart.line.uptrend.xyaxis.circle.fill",
                            tint: .purple
                        )
                    }

                    savingsGoalSection

                    spendingChartSection

                    recentTransactionsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onAddTransaction) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingGoalSheet) {
                NavigationStack {
                    SavingsGoalEditorView(goal: currentGoal)
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your money at a glance")
                .font(.largeTitle.bold())

            Text("Stay aware of where your money is going and how close you are to this month’s goal.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: onAddTransaction) {
                Label("Add Transaction", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var savingsGoalSection: some View {
        SectionCardView(
            title: "Monthly Savings Goal",
            subtitle: currentGoal == nil ? "Set a target to stay motivated this month." : "Track your progress against the target."
        ) {
            if let goal = currentGoal {
                VStack(alignment: .leading, spacing: 14) {
                    ProgressView(value: summary.goalProgress)
                        .progressViewStyle(.linear)
                        .tint(.green)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Target")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(CurrencyFormatting.currencyString(goal.monthlyTarget))
                                .font(.headline)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(summary.remainingToGoal > 0 ? "Remaining" : "Status")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(goalStatusText)
                                .font(.headline)
                                .foregroundStyle(summary.remainingToGoal > 0 ? AnyShapeStyle(.primary) : AnyShapeStyle(.green))
                        }
                    }

                    Button("Edit Goal") {
                        showingGoalSheet = true
                    }
                    .buttonStyle(.bordered)
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

    private var spendingChartSection: some View {
        SectionCardView(
            title: "Spending Breakdown",
            subtitle: "This month by category"
        ) {
            if summary.categoryBreakdown.isEmpty {
                EmptyStateView(
                    title: "No expenses yet",
                    message: "Once you log spending, your category mix will show up here.",
                    systemImage: "chart.pie"
                )
            } else {
                VStack(spacing: 16) {
                    Chart(summary.categoryBreakdown) { item in
                        SectorMark(
                            angle: .value("Amount", item.total),
                            innerRadius: .ratio(0.58),
                            angularInset: 1
                        )
                        .foregroundStyle(item.category.color)
                    }
                    .frame(height: 220)

                    ForEach(summary.categoryBreakdown.prefix(4)) { item in
                        HStack {
                            Label(item.category.title, systemImage: item.category.symbol)
                                .foregroundStyle(item.category.color)

                            Spacer()

                            Text(CurrencyFormatting.currencyString(item.total))
                                .fontWeight(.semibold)
                        }
                    }
                }
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
}
