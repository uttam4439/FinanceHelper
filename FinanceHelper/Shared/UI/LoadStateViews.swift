import SwiftUI

struct LoadingStateView: View {
    var message: String = "Loading…"

    var body: some View {
        VStack(spacing: FinanceSpacing.regular) {
            ProgressView()
                .progressViewStyle(.circular)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(FinanceTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(FinanceSpacing.large)
        .background(FinanceTheme.background.opacity(0.6))
    }
}

struct ErrorStateView: View {
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: FinanceSpacing.regular) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(FinanceTheme.accent)
            Text(message)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(FinanceTheme.textSecondary)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(FinancePillButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(FinanceSpacing.large)
        .background(FinanceTheme.background.opacity(0.6))
    }
}
