//
//  Flashcard.swift
//  SnapCards
//
//  The one data model in the app: a flashcard with a question (front),
//  an answer (back) and the spaced-repetition schedule that decides when it is due.
//

import Foundation
import SwiftData

// MARK: - Flashcard model

/// A flashcard saved on the device.
/// something SwiftData can save to the phone's storage, so cards survive closing the app.
/// SwiftData needs a `class` (not a `struct`) so it can track changes to each card.
@Model
final class Flashcard {
    var front: String       // the question side
    var back: String        // the answer side
    var topic: String       // a simple label like "Biology"
    var createdAt: Date     // when the card was made
    var dueDate: Date       // when the card should come back
    var interval: Int       // days until next review
    var repetitions: Int    // correct answers in a row
    var ease: Double        // how easy the card is (starts 2.5)

    init(front: String, back: String, topic: String) {
        self.front = front
        self.back = back
        self.topic = topic
        self.createdAt = Date()
        self.dueDate = Date()      // a new card is due straight away
        self.interval = 0
        self.repetitions = 0
        self.ease = 2.5
    }

    // MARK: - Computed properties

    /// True when the due date is now or in the past.
    var isDue: Bool { dueDate <= Date() }

    // MARK: - Spaced repetition

    /// Simplified SM-2 spaced repetition. quality: 1 = forgot, 4 = got it.
    func review(quality: Int) {
        if quality < 3 {
            repetitions = 0
            interval = 1                         // forgot: see it tomorrow
        } else {
            if repetitions == 0 { interval = 1 }          // 1st correct: 1 day
            else if repetitions == 1 { interval = 6 }     // 2nd correct: 6 days
            else { interval = Int((Double(interval) * ease).rounded()) }  // then grow by ease
            repetitions += 1
        }

        // Adjust ease: with quality 4 ("got it") the change works out to 0,
        // with quality 1 ("forgot") ease drops by 0.54.
        // It can never go below 1.3, so intervals never shrink to nothing.
        let q = Double(5 - quality)
        ease = max(1.3, ease + (0.1 - q * (0.08 + q * 0.02)))

        // Next due date = today + interval days (fall back to now if the date maths fails).
        dueDate = Calendar.current.date(byAdding: .day, value: interval, to: Date()) ?? Date()
    }
}
