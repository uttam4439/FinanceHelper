import SwiftUI
import SwiftData

@main
struct FinanceHelperApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TransactionRecord.self,
            SavingsGoal.self,
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .task {
                    SampleDataSeeder.seedIfNeeded(in: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
