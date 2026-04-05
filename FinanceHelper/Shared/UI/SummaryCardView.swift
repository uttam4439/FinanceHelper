//
//  SummaryCardView.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import SwiftUI

struct SummaryCardView: View {
    let title: String
    let value: String
    let caption: String
    let systemImage: String
    let tint: Color
    var filled = false

    var body: some View {
        VStack(alignment: .leading, spacing: FinanceSpacing.small) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(filled ? Color.white.opacity(0.9) : FinanceTheme.textSecondary)

            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(filled ? Color.white : FinanceTheme.textPrimary)
                .minimumScaleFactor(0.8)

            Text(caption)
                .font(.caption)
                .foregroundStyle(filled ? Color.white.opacity(0.8) : FinanceTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FinanceSpacing.regular)
        .background(
            RoundedRectangle(cornerRadius: FinanceRadius.medium, style: .continuous)
                .fill(filled ? tint : tint.opacity(0.12))
        )
    }
}
