import SwiftUI

struct SavingsGoalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let goal: SavingsGoal?

    @State private var targetText = ""
    @State private var carryOverEnabled = false

    init(goal: SavingsGoal?) {
        self.goal = goal
        _targetText = State(initialValue: goal.map { CurrencyFormatting.editingString(from: $0.monthlyTarget) } ?? "")
        _carryOverEnabled = State(initialValue: goal?.carryOverEnabled ?? false)
    }

    private var targetValue: Double? {
        CurrencyFormatting.decimalValue(from: targetText)
    }

    private var isValid: Bool {
        guard let targetValue else { return false }
        return targetValue > 0
    }

    var body: some View {
        Form {
            Section("Target") {
                TextField("Amount", text: $targetText)
                    .keyboardType(.decimalPad)

                Toggle("Carry unfinished goal into next month", isOn: $carryOverEnabled)
            }

            Section {
                Text("This goal is used to show savings progress on the dashboard for the current month.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(goal == nil ? "New Goal" : "Edit Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveGoal()
                }
                .disabled(!isValid)
            }
        }
    }

    private func saveGoal() {
        guard let targetValue else { return }
        let repository = FinanceRepository(context: modelContext)
        try? repository.saveGoal(target: targetValue, carryOverEnabled: carryOverEnabled, month: .now)
        dismiss()
    }
}
