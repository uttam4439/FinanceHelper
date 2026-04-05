//
//  TransactionFormValidator.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import Foundation

struct TransactionFormValidation {
    let amountMessage: String?

    var isValid: Bool {
        amountMessage == nil
    }
}

enum TransactionFormValidator {
    static func validate(_ draft: TransactionDraft) -> TransactionFormValidation {
        guard let amount = draft.amountValue else {
            return TransactionFormValidation(amountMessage: "Enter a valid amount.")
        }

        guard amount > 0 else {
            return TransactionFormValidation(amountMessage: "Amount should be greater than zero.")
        }

        return TransactionFormValidation(amountMessage: nil)
    }
}
