import Foundation
import SwiftData

@MainActor
enum PreviewSampleData {
    static let container: ModelContainer = {
        let schema = Schema([
            TransactionRecord.self,
            SavingsGoal.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext
        SampleDataSeeder.seedIfNeeded(in: context)

        return container
    }()
}
