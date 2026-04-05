//
//  FinanceHelperUITests.swift
//  FinanceHelperUITests
//
//  Created by Codex on 05/04/26.
//

import XCTest

final class FinanceHelperUITests: XCTestCase {
    func testLaunchShowsDashboardTab() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Dashboard"].waitForExistence(timeout: 3))
    }
}
