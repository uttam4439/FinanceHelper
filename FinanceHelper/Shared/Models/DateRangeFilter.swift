//
//  DateRangeFilter.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import Foundation

enum DateRangeFilter: String, CaseIterable, Identifiable {
    case thisMonth
    case last30Days
    case allTime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .thisMonth: "This Month"
        case .last30Days: "Last 30 Days"
        case .allTime: "All Time"
        }
    }

    func contains(_ date: Date, calendar: Calendar = .current) -> Bool {
        switch self {
        case .thisMonth:
            return calendar.isDate(date, equalTo: .now, toGranularity: .month)
        case .last30Days:
            guard let start = calendar.date(byAdding: .day, value: -30, to: .now) else { return true }
            return date >= start
        case .allTime:
            return true
        }
    }
}
