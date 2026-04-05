//
//  SampleDataSeeder.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import Foundation
import SwiftData

enum SampleDataSeeder {
    @MainActor
    static func seedIfNeeded(in context: ModelContext) {
        let transactionCount = (try? context.fetchCount(FetchDescriptor<TransactionRecord>())) ?? 0
        let goalCount = (try? context.fetchCount(FetchDescriptor<SavingsGoal>())) ?? 0

        guard transactionCount == 0, goalCount == 0 else { return }
    }
}
