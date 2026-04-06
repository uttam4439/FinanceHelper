import SwiftUI

struct TransactionFormView: View {
    enum Mode {
        case create
        case edit(TransactionRecord)

        var title: String {
            switch self {
            case .create: "Add Transaction"
            case .edit: "Edit Transaction"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let mode: Mode

    @State private var draft: TransactionDraft
    @State private var validation = TransactionFormValidation(amountMessage: nil)

    init(mode: Mode) {
        self.mode = mode

        switch mode {
        case .create:
            _draft = State(initialValue: TransactionDraft())
        case .edit(let transaction):
            _draft = State(initialValue: TransactionDraft(transaction: transaction))
        }
    }

    private var categoryOptions: [TransactionCategory] {
        var options = TransactionCategory.options(for: draft.kind)
        if !options.contains(draft.category) {
            options.insert(draft.category, at: 0)
        }
        return options.isEmpty ? [.other] : options
    }

    private var canSave: Bool {
        validation.isValid
    }

    var body: some View {
        ScrollView {
            VStack(spacing: FinanceSpacing.sectionGap) {
                headerButtons
                formCard
            }
            .padding(.horizontal, FinanceSpacing.screenHorizontal)
            .padding(.vertical, FinanceSpacing.screenVertical)
        }
        .background(FinanceTheme.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { validation = TransactionFormValidator.validate(draft) }
        .onChange(of: draft) { _, newValue in validation = TransactionFormValidator.validate(newValue) }
    }

    private func save() {
        validation = TransactionFormValidator.validate(draft)
        guard validation.isValid else { return }

        let repository = FinanceRepository(context: modelContext)

        switch mode {
        case .create:
            try? repository.addTransaction(from: draft)
        case .edit(let transaction):
            try? repository.updateTransaction(transaction, with: draft)
        }

        dismiss()
    }

    private var headerButtons: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .buttonStyle(FinancePillButtonStyle(filled: false))

            Spacer()

            Text(mode.title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(FinanceTheme.textPrimary)

            Spacer()

            Button("Save") { save() }
                .buttonStyle(FinancePillButtonStyle())
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
        }
    }

    private var formCard: some View {
        FinanceSurface {
            VStack(alignment: .leading, spacing: FinanceSpacing.sectionGap) {
                VStack(alignment: .leading, spacing: FinanceSpacing.small) {
                    Text("Amount")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(FinanceTheme.textSecondary)

                    TextField("0.00", text: $draft.amountText)
                        .keyboardType(.decimalPad)
                        .padding(.vertical, FinanceSpacing.xSmall)
                        .padding(.horizontal, FinanceSpacing.regular)
                        .background(
                            RoundedRectangle(cornerRadius: FinanceRadius.medium, style: .continuous)
                                .fill(FinanceTheme.secondaryCard)
                        )

                    if let amountMessage = validation.amountMessage {
                        Text(amountMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                VStack(alignment: .leading, spacing: FinanceSpacing.regular) {
                    Text("Details")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(FinanceTheme.textSecondary)

                    Picker("Type", selection: $draft.kind) {
                        ForEach(TransactionKind.allCases) { kind in
                            Text(kind.title).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: draft.kind) { _, newKind in
                        if !draft.category.supportedKinds.contains(newKind) {
                            draft.category = TransactionCategory.options(for: newKind).first ?? .other
                        }
                    }

                    VStack(alignment: .leading, spacing: FinanceSpacing.xSmall) {
                        Text("Category")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(FinanceTheme.textSecondary)

                        Picker("", selection: $draft.category) {
                            ForEach(categoryOptions) { category in
                                Label(category.title, systemImage: category.symbol).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }

                    VStack(alignment: .leading, spacing: FinanceSpacing.xSmall) {
                        Text("Date")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(FinanceTheme.textSecondary)
                        DatePicker("", selection: $draft.date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }

                    VStack(alignment: .leading, spacing: FinanceSpacing.xSmall) {
                        Text("Notes")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(FinanceTheme.textSecondary)
                        TextField("Optional notes", text: $draft.note, axis: .vertical)
                            .lineLimit(2...4)
                            .padding(.horizontal, FinanceSpacing.regular)
                            .padding(.vertical, FinanceSpacing.xSmall)
                            .background(
                                RoundedRectangle(cornerRadius: FinanceRadius.medium, style: .continuous)
                                    .fill(FinanceTheme.secondaryCard)
                            )
                    }
                }
            }
        }
    }
}
