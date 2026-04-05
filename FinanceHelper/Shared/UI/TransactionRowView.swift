//
//  TransactionRowView.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: TransactionRecord

    var signedAmount: String {
        let amount = transaction.kind == .income ? transaction.amount : -transaction.amount
        return CurrencyFormatting.signedCurrencyString(amount)
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(transaction.category.color.opacity(0.14))
                    .frame(width: 42, height: 42)

                Image(systemName: transaction.category.symbol)
                    .foregroundStyle(transaction.category.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.title)
                    .font(.body.weight(.semibold))

                Text(transaction.note.isEmpty ? transaction.kind.title : transaction.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(signedAmount)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(transaction.kind == .income ? .green : .primary)

                Text(transaction.date, format: .dateTime.day().month(.abbreviated))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
