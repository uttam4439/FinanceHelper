import SwiftUI

struct TransactionRowView: View {
    let transaction: TransactionRecord

    var signedAmount: String {
        let amount = transaction.kind == .income ? transaction.amount : -transaction.amount
        return CurrencyFormatting.signedCurrencyString(amount)
    }

    var body: some View {
        HStack(spacing: FinanceSpacing.rowGap) {
            ZStack {
                RoundedRectangle(cornerRadius: FinanceRadius.chip, style: .continuous)
                    .fill(FinanceTheme.secondaryCard)
                    .frame(width: 44, height: 44)

                Image(systemName: transaction.category.symbol)
                    .foregroundStyle(transaction.category.color)
            }

            VStack(alignment: .leading, spacing: FinanceSpacing.xxSmall) {
                Text(transaction.category.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(FinanceTheme.textPrimary)

                Text(transaction.note.isEmpty ? transaction.kind.title : transaction.note)
                    .font(.caption)
                    .foregroundStyle(FinanceTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: FinanceSpacing.xxSmall) {
                Text(signedAmount)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(transaction.kind == .income ? FinanceTheme.success : FinanceTheme.textPrimary)

                Text(transaction.date, format: .dateTime.day().month(.abbreviated))
                    .font(.caption)
                    .foregroundStyle(FinanceTheme.textSecondary)
            }
        }
        .padding(.vertical, 6)
    }
}
