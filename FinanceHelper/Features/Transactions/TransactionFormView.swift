//
//  TransactionFormView.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

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
        let options = TransactionCategory.options(for: draft.kind)
        return options.isEmpty ? [.other] : options
    }

    private var canSave: Bool {
        validation.isValid
    }

    var body: some View {
        Form {
            Section("Amount") {
                TextField("0.00", text: $draft.amountText)
                    .keyboardType(.decimalPad)

                if let amountMessage = validation.amountMessage {
                    Text(amountMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section("Details") {
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

                Picker("Category", selection: $draft.category) {
                    ForEach(categoryOptions) { category in
                        Label(category.title, systemImage: category.symbol).tag(category)
                    }
                }

                DatePicker("Date", selection: $draft.date, displayedComponents: .date)

                TextField("Notes", text: $draft.note, axis: .vertical)
                    .lineLimit(2...4)
            }
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(!canSave)
            }
        }
        .onAppear {
            validation = TransactionFormValidator.validate(draft)
        }
        .onChange(of: draft) { _, newValue in
            validation = TransactionFormValidator.validate(newValue)
        }
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
}
