//
//  SnapCardsUITests.swift
//  SnapCardsUITests
//
//  One UI test that drives the real app: Scan Notes -> Try sample text -> Save,
//  then checks the Home screen shows cards due.
//

import XCTest

final class SnapCardsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false     // stop at the first failure
    }

    func testSampleTextCreatesDueCards() throws {
        let app = XCUIApplication()
        app.launch()

        // Open the Scan Notes sheet and use the built-in sample text.
        app.buttons["Scan Notes"].tap()
        app.buttons["Try sample text"].tap()

        // A Toggle row joins its texts into one label, so search for any element
        // whose label contains the question.
        let photosynthesis = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@", "What is Photosynthesis?"))
            .firstMatch
        XCTAssertTrue(photosynthesis.waitForExistence(timeout: 5))

        // Save and go back to Home.
        app.navigationBars.buttons["Save"].tap()

        // The big number on Home should now be above 0.
        let dueCount = app.staticTexts["dueCount"]
        XCTAssertTrue(dueCount.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(Int(dueCount.label) ?? 0, 0)
    }
}
