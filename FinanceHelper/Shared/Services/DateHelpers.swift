//
//  DateHelpers.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import Foundation

extension Date {
    func startOfMonth(calendar: Calendar = .current) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: self)) ?? self
    }

    func startOfDay(calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }
}
