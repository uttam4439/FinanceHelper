//
//  AppRootView.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import SwiftUI

struct AppRootView: View {
    @State private var selectedTab: AppTab = .dashboard
    @State private var showingAddTransaction = false

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(
                onAddTransaction: { showingAddTransaction = true }
            )
            .tabItem {
                Label(AppTab.dashboard.title, systemImage: AppTab.dashboard.symbol)
            }
            .tag(AppTab.dashboard)

            TransactionsView(
                onAddTransaction: { showingAddTransaction = true }
            )
            .tabItem {
                Label(AppTab.transactions.title, systemImage: AppTab.transactions.symbol)
            }
            .tag(AppTab.transactions)

            InsightsView()
                .tabItem {
                    Label(AppTab.insights.title, systemImage: AppTab.insights.symbol)
                }
                .tag(AppTab.insights)
        }
        .tint(.blue)
        .sheet(isPresented: $showingAddTransaction) {
            NavigationStack {
                TransactionFormView(mode: .create)
            }
        }
    }
}

private enum AppTab {
    case dashboard
    case transactions
    case insights

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .transactions: "Transactions"
        case .insights: "Insights"
        }
    }

    var symbol: String {
        switch self {
        case .dashboard: "rectangle.3.group.fill"
        case .transactions: "list.bullet.clipboard.fill"
        case .insights: "chart.xyaxis.line"
        }
    }
}
