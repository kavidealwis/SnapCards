//
//  CardDetailView.swift
//  SnapCards
//
//  Shows one card: its question, its answer and its review schedule.
//

import SwiftUI
import SwiftData

struct CardDetailView: View {

    let card: Flashcard

    /// "1 day" or "6 days" (and "Not reviewed yet" for new cards).
    private var intervalText: String {
        switch card.interval {
        case 0: return "Not reviewed yet"
        case 1: return "1 day"
        default: return "\(card.interval) days"
        }
    }

    /// "Due now" or the date, e.g. "18 Oct 2026".
    private var nextReviewText: String {
        card.isDue ? "Due now" : card.dueDate.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        List {
            Section("Question") {
                Text(card.front)
            }

            Section("Answer") {
                Text(card.back)
            }

            Section("Schedule") {
                LabeledContent("Next review", value: nextReviewText)
                LabeledContent("Interval", value: intervalText)
                LabeledContent("Correct in a row", value: "\(card.repetitions)")
                LabeledContent("Topic", value: card.topic)
            }
        }
        .navigationTitle("Card")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    // A preview needs a container to exist before a @Model object is made.
    let container = try! ModelContainer(
        for: Flashcard.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let card = Flashcard(front: "What is Osmosis?",
                         back: "The movement of water across a membrane.",
                         topic: "Biology")
    container.mainContext.insert(card)

    return NavigationStack {
        CardDetailView(card: card)
    }
    .modelContainer(container)
}
