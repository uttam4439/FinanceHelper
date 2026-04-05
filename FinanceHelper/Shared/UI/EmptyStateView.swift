//
//  EmptyStateView.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: FinanceSpacing.regular) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(FinanceTheme.accent)
                .frame(width: 72, height: 72)
                .background(FinanceTheme.accentSoft, in: RoundedRectangle(cornerRadius: FinanceRadius.large, style: .continuous))

            VStack(spacing: FinanceSpacing.xSmall) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FinanceTheme.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(FinanceTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(FinancePillButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, FinanceSpacing.xxLarge)
        .padding(.horizontal, FinanceSpacing.large)
    }
}
