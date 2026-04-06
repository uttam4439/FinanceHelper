import Foundation
import SwiftData

@Model
final class SavingsGoal {
    var id: UUID
    var monthlyTarget: Double
    var monthAnchor: Date
    var carryOverEnabled: Bool

    init(
        id: UUID = UUID(),
        monthlyTarget: Double,
        monthAnchor: Date,
        carryOverEnabled: Bool = false
    ) {
        self.id = id
        self.monthlyTarget = monthlyTarget
        self.monthAnchor = monthAnchor.startOfMonth()
        self.carryOverEnabled = carryOverEnabled
    }
}
