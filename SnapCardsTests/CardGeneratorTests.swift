//
//  CardGeneratorTests.swift
//  SnapCardsTests
//
//  Unit tests for CardGenerator: which text makes cards and which does not.
//  GeneratedCard is a plain struct, so no SwiftData container is needed here.
//

import XCTest
@testable import SnapCards

final class CardGeneratorTests: XCTestCase {

    func testColonLineMakesOneCard() {
        let cards = CardGenerator.generate(from: "Osmosis: movement of water across a membrane")
        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards.first?.front, "What is Osmosis?")
    }

    func testIsTheSentenceMakesOneCard() {
        let cards = CardGenerator.generate(from: "A mitochondrion is the organelle that produces ATP.")
        XCTAssertEqual(cards.count, 1)
        XCTAssertTrue(cards.first?.front.contains("mitochondrion") ?? false)
    }

    func testEmptyTextMakesNoCards() {
        let cards = CardGenerator.generate(from: "")
        XCTAssertEqual(cards.count, 0)
    }

    func testNonDefinitionMakesNoCards() {
        let cards = CardGenerator.generate(from: "Hello there.")
        XCTAssertEqual(cards.count, 0)
    }

    func testSameTermTwiceMakesOneCard() {
        let text = """
        Osmosis: movement of water across a membrane
        Osmosis: the flow of water through a membrane
        """
        let cards = CardGenerator.generate(from: text)
        XCTAssertEqual(cards.count, 1)
    }
}
