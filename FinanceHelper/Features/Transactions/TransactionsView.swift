//
//  TransactionsView.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

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
            contentView
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Transactions")
            .searchable(text: $searchText, prompt: "Search notes or categories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onAddTransaction) {
                        Label("Add", systemImage: "plus")
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
        VStack(alignment: .leading, spacing: 12) {
            Picker("Type", selection: $selectedKindFilter) {
                ForEach(KindFilter.allCases) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Menu {
                    ForEach(KindFilter.allCases) { filter in
                        Button(filter.title) { selectedKindFilter = filter }
                    }
                } label: {
                    filterChip(title: selectedKindFilter.title, systemImage: "line.3.horizontal.decrease.circle")
                }

                Menu {
                    Button("All Categories") { selectedCategory = nil }
                    Divider()
                    ForEach(TransactionCategory.allCases) { category in
                        Button(category.title) { selectedCategory = category }
                    }
                } label: {
                    filterChip(title: selectedCategory?.title ?? "All Categories", systemImage: "square.grid.2x2")
                }

                Menu {
                    ForEach(DateRangeFilter.allCases) { range in
                        Button(range.title) { selectedDateRange = range }
                    }
                } label: {
                    filterChip(title: selectedDateRange.title, systemImage: "calendar")
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if filteredTransactions.isEmpty {
            emptyStateView
        } else {
            transactionsList
        }
    }

    private var emptyStateView: some View {
        EmptyStateView(
            title: transactions.isEmpty ? "No transactions yet" : "No matches found",
            message: transactions.isEmpty
                ? "Add your first transaction to start building your finance history."
                : "Try changing your filters or search term.",
            systemImage: "tray.fill",
            actionTitle: transactions.isEmpty ? "Add Transaction" : nil,
            action: transactions.isEmpty ? onAddTransaction : nil
        )
        .padding(.horizontal, 20)
    }

    private var transactionsList: some View {
        List {
            filterHeader
                .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                .listRowBackground(Color.clear)

            ForEach(groupedTransactions, id: \.0) { day, dayTransactions in
                transactionSection(for: day, transactions: dayTransactions)
            }
        }
        .listStyle(.insetGrouped)
    }

    private func transactionSection(for day: Date, transactions dayTransactions: [TransactionRecord]) -> some View {
        Section {
            ForEach(dayTransactions) { transaction in
                transactionRow(for: transaction)
            }
        } header: {
            Text(day, format: .dateTime.weekday(.wide).day().month(.abbreviated))
        }
    }

    private func transactionRow(for transaction: TransactionRecord) -> some View {
        TransactionRowView(transaction: transaction)
            .contentShape(Rectangle())
            .onTapGesture {
                transactionToEdit = transaction
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button("Delete", role: .destructive) {
                    transactionToDelete = transaction
                }

                Button("Edit") {
                    transactionToEdit = transaction
                }
                .tint(.blue)
            }
    }

    private func filterChip(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(Color(uiColor: .tertiarySystemFill))
            )
    }
}
