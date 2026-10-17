//
//  FlashcardTests.swift
//  SnapCardsTests
//
//  Unit tests for the spaced-repetition schedule in Flashcard.review(quality:).
//  Run with Cmd + U.
//

import XCTest
import SwiftData
@testable import SnapCards

// NEW CONCEPT (not in labs): XCTest is Apple's testing framework. Each method whose name
// starts with "test" is run automatically; XCTAssert... checks a result and fails if wrong.
final class FlashcardTests: XCTestCase {

    // The cards in these tests are never inserted, so nothing is saved.
    // We still create an empty in-memory container because some iOS versions
    // expect one to exist before a @Model object is created.
    private var container: ModelContainer!

    override func setUpWithError() throws {
        container = try ModelContainer(
            for: Flashcard.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    override func tearDownWithError() throws {
        container = nil
    }

    /// A helper so each test starts with a fresh card.
    private func makeCard() -> Flashcard {
        Flashcard(front: "What is Osmosis?", back: "Movement of water", topic: "Biology")
    }

    // MARK: - Tests

    func testNewCardIsDueWithDefaults() {
        let card = makeCard()
        XCTAssertTrue(card.isDue)
        XCTAssertEqual(card.interval, 0)
        XCTAssertEqual(card.ease, 2.5)
    }

    func testFirstCorrectAnswerGivesOneDay() {
        let card = makeCard()
        card.review(quality: 4)
        XCTAssertEqual(card.interval, 1)
        XCTAssertEqual(card.repetitions, 1)
    }

    func testSecondCorrectAnswerGivesSixDays() {
        let card = makeCard()
        card.review(quality: 4)
        card.review(quality: 4)
        XCTAssertEqual(card.interval, 6)
    }

    func testForgettingResetsProgress() {
        let card = makeCard()
        card.review(quality: 4)
        card.review(quality: 4)
        card.review(quality: 1)
        XCTAssertEqual(card.repetitions, 0)
        XCTAssertEqual(card.interval, 1)
    }

    func testEaseNeverDropsBelowMinimum() {
        let card = makeCard()
        for _ in 1...10 {
            card.review(quality: 1)
        }
        XCTAssertGreaterThanOrEqual(card.ease, 1.3)
    }

    func testCardIsNotDueAfterCorrectAnswer() {
        let card = makeCard()
        card.review(quality: 4)
        XCTAssertFalse(card.isDue)
    }
}
