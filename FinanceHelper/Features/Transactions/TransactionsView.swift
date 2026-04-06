import SwiftData
import SwiftUI

struct TransactionsView: View {
    private enum KindFilter: String, CaseIterable, Identifiable {
        case all
        case expense
        case income

        var id: String { rawValue }

        var title: String {
            switch self {
            case .all: "All"
            case .expense: "Expense"
            case .income: "Income"
            }
        }

        var transactionKind: TransactionKind? {
            switch self {
            case .all: nil
            case .expense: .expense
            case .income: .income
            }
        }
    }

    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\TransactionRecord.date, order: .reverse)])
    private var transactions: [TransactionRecord]

    let onAddTransaction: () -> Void

    @State private var searchText = ""
    @State private var selectedKindFilter: KindFilter = .all
    @State private var selectedCategory: TransactionCategory?
    @State private var selectedDateRange: DateRangeFilter = .thisMonth
    @State private var transactionToEdit: TransactionRecord?
    @State private var transactionToDelete: TransactionRecord?
    @State private var isLoading = false
    @State private var loadError: String?

    init(onAddTransaction: @escaping () -> Void) {
        self.onAddTransaction = onAddTransaction
    }

    private var filteredTransactions: [TransactionRecord] {
        transactions.filter { transaction in
            let matchesSearch = searchText.isEmpty
                || transaction.note.localizedCaseInsensitiveContains(searchText)
                || transaction.category.title.localizedCaseInsensitiveContains(searchText)

            let matchesKind = selectedKindFilter.transactionKind == nil || transaction.kind == selectedKindFilter.transactionKind
            let matchesCategory = selectedCategory == nil || transaction.category == selectedCategory
            let matchesDateRange = selectedDateRange.contains(transaction.date)

            return matchesSearch && matchesKind && matchesCategory && matchesDateRange
        }
    }

    private var groupedTransactions: [(Date, [TransactionRecord])] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            transaction.date.startOfDay()
        }

        return grouped.keys
            .sorted(by: >)
            .map { date in
                (date, grouped[date]?.sorted(by: { $0.date > $1.date }) ?? [])
            }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if let loadError {
                    ErrorStateView(message: loadError, actionTitle: "Retry") { refreshData() }
                } else if isLoading {
                    LoadingStateView(message: "Loading transactions…")
                } else {
                    ScrollView {
                        VStack(spacing: FinanceSpacing.cardGap) {
                            filterHeader
                                .padding(.horizontal, FinanceSpacing.screenHorizontal)

                            spendingHeaderChart
                                .padding(.horizontal, FinanceSpacing.screenHorizontal)

                            if filteredTransactions.isEmpty {
                                emptyStateView
                            } else {
                                transactionsStack
                            }
                        }
                        .padding(.vertical, FinanceSpacing.screenVertical)
                    }
                }
            }
            .background(FinanceTheme.background.ignoresSafeArea())
            .navigationTitle("All Transactions")
            .navigationBarTitleDisplayMode(.automatic)
            .searchable(text: $searchText, prompt: "Search notes or categories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onAddTransaction) {
                        Image(systemName: "plus")
                            .foregroundStyle(FinanceTheme.accent)
                    }
                }
            }
            .sheet(item: $transactionToEdit) { transaction in
                NavigationStack {
                    TransactionFormView(mode: .edit(transaction))
                }
            }
            .confirmationDialog(
                "Delete this transaction?",
                isPresented: Binding(
                    get: { transactionToDelete != nil },
                    set: { isPresented in
                        if !isPresented {
                            transactionToDelete = nil
                        }
                    }
                ),
                presenting: transactionToDelete
            ) { transaction in
                Button("Delete", role: .destructive) {
                    let repository = FinanceRepository(context: modelContext)
                    try? repository.deleteTransaction(transaction)
                    transactionToDelete = nil
                }

                Button("Cancel", role: .cancel) {
                    transactionToDelete = nil
                }
            } message: { _ in
                Text("This action cannot be undone.")
            }
        }
    }

    private var filterHeader: some View {
        VStack(alignment: .leading, spacing: FinanceSpacing.cardGap) {
            HStack(spacing: FinanceSpacing.small) {
                ForEach(KindFilter.allCases) { filter in
                    Button {
                        selectedKindFilter = filter
                    } label: {
                        Text(filter.title)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FinancePillButtonStyle(filled: selectedKindFilter == filter))
                }
            }

            HStack(spacing: FinanceSpacing.small) {
                Menu {
                    Button("All Categories") { selectedCategory = nil }
                    Divider()
                    ForEach(TransactionCategory.allCases) { category in
                        Button(category.title) { selectedCategory = category }
                    }
                } label: {
                    filterChip(title: selectedCategory?.title ?? "All Categories", systemImage: "square.grid.2x2")
                        .frame(maxWidth: .infinity)
                }

                Menu {
                    ForEach(DateRangeFilter.allCases) { range in
                        Button(range.title) { selectedDateRange = range }
                    }
                } label: {
                    filterChip(title: selectedDateRange.title, systemImage: "calendar")
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        EmptyView() // content handled in body ScrollView
    }

    private var emptyStateView: some View {
        VStack {
            FinanceSurface {
                EmptyStateView(
                    title: transactions.isEmpty ? "No transactions yet" : "No matches found",
                    message: transactions.isEmpty
                        ? "Add your first transaction to start building your finance history."
                        : "Try changing your filters or search term.",
                    systemImage: "tray.fill",
                    actionTitle: transactions.isEmpty ? "Add Transaction" : "Show All Transactions",
                    action: transactions.isEmpty ? onAddTransaction : resetFiltersAndSearch
                )
            }
            .frame(maxWidth: 520)
            .padding(.horizontal, FinanceSpacing.screenHorizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var transactionsStack: some View {
        LazyVStack(alignment: .leading, spacing: FinanceSpacing.cardGap, pinnedViews: []) {
            ForEach(groupedTransactions, id: \.0) { day, dayTransactions in
                Text(day, format: .dateTime.weekday(.wide).day().month(.abbreviated))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(FinanceTheme.textSecondary)
                    .padding(.horizontal, FinanceSpacing.screenHorizontal)

                VStack(spacing: FinanceSpacing.small) {
                    ForEach(dayTransactions) { transaction in
                        FinanceSurface(padding: FinanceSpacing.regular) {
                            TransactionRowView(transaction: transaction)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { transactionToEdit = transaction }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", role: .destructive) {
                                transactionToDelete = transaction
                            }

                            Button("Edit") {
                                transactionToEdit = transaction
                            }
                            .tint(FinanceTheme.accent)
                        }
                    }
                }
                .padding(.horizontal, FinanceSpacing.screenHorizontal)
            }
        }
    }

    private var spendingHeaderChart: some View {
        VStack(alignment: .leading, spacing: FinanceSpacing.small) {
            Text("April 1 - April 30")
                .font(.caption.weight(.semibold))
                .foregroundStyle(FinanceTheme.textSecondary)

            HStack(spacing: FinanceSpacing.medium) {
                CircleChartView(expenseTotal: expenseTotal, incomeTotal: incomeTotal)
                    .frame(width: 132, height: 132)

                VStack(alignment: .leading, spacing: FinanceSpacing.xSmall) {
                    metricLegend(title: "Expenses", value: expenseTotal, color: FinanceTheme.accent)
                    metricLegend(title: "Income", value: incomeTotal, color: FinanceTheme.success)

                    if let topCategory = topExpenseCategory {
                        Text("Top: \(topCategory.key.title)")
                            .font(.caption)
                            .foregroundStyle(FinanceTheme.textSecondary)
                    }
                }
            }
        }
    }

    private var expenseTotal: Double {
        filteredTransactions.filter { $0.kind == .expense }.reduce(0) { $0 + $1.amount }
    }

    private var incomeTotal: Double {
        filteredTransactions.filter { $0.kind == .income }.reduce(0) { $0 + $1.amount }
    }

    private var topExpenseCategory: (key: TransactionCategory, value: Double)? {
        let totals = filteredTransactions
            .filter { $0.kind == .expense }
            .reduce(into: [TransactionCategory: Double]()) { partial, item in
                partial[item.category, default: 0] += item.amount
            }

        return totals.max(by: { $0.value < $1.value })
    }

    private func metricLegend(title: String, value: Double, color: Color) -> some View {
        HStack(spacing: FinanceSpacing.xSmall) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(FinanceTheme.textPrimary)
            Spacer()
            Text(CurrencyFormatting.currencyString(value))
                .font(.caption)
                .foregroundStyle(FinanceTheme.textSecondary)
        }
    }

    private func filterChip(title: String, systemImage: String) -> some View {
        FinanceChip(title: title, systemImage: systemImage)
    }

    private func resetFiltersAndSearch() {
        searchText = ""
        selectedKindFilter = .all
        selectedCategory = nil
        selectedDateRange = .thisMonth
        loadError = nil
    }

    private func refreshData() {
        // Hook for future async data; currently instant local data.
        loadError = nil
        isLoading = false
    }
}

private struct CircleChartView: View {
    let expenseTotal: Double
    let incomeTotal: Double

    private var total: Double { max(expenseTotal + incomeTotal, 1) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(FinanceTheme.secondaryCard, lineWidth: 22)

            Circle()
                .trim(from: 0, to: expenseTotal / total)
                .stroke(FinanceTheme.accent, style: StrokeStyle(lineWidth: 22, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Circle()
                .trim(from: expenseTotal / total, to: 1)
                .stroke(FinanceTheme.success.opacity(incomeTotal > 0 ? 0.9 : 0), style: StrokeStyle(lineWidth: 22, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: FinanceSpacing.xxSmall) {
                Text("Flow")
                    .font(.caption)
                    .foregroundStyle(FinanceTheme.textSecondary)
                Text(CurrencyFormatting.currencyString(expenseTotal + incomeTotal))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(FinanceTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(6)
    }
}
