//
//  LibraryView.swift
//  SnapCards
//
//  The All Cards screen: a list of every saved card, newest first.
//  Swipe a row to delete it; tap a row to see its details.
//

import SwiftUI
import SwiftData

struct LibraryView: View {

    @Environment(\.modelContext) private var modelContext

    /// Every saved card, newest first.
    @Query(sort: \Flashcard.createdAt, order: .reverse) private var cards: [Flashcard]

    var body: some View {
        List {
            ForEach(cards) { card in
                NavigationLink {
                    CardDetailView(card: card)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.front)
                            .font(.headline)
                            .lineLimit(2)
                        Text(card.topic)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteCards)     // swipe-to-delete
        }
        .overlay {
            // Empty state when there are no cards yet
            if cards.isEmpty {
                ContentUnavailableView(
                    "No Cards Yet",
                    systemImage: "rectangle.stack",
                    description: Text("Scan some notes to make your first cards.")
                )
            }
        }
        .navigationTitle("All Cards")
    }

    // MARK: - Actions

    /// Deletes the swiped rows from SwiftData.
    private func deleteCards(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(cards[index])
        }
    }
}

#Preview {
    NavigationStack {
        LibraryView()
    }
    .modelContainer(for: Flashcard.self, inMemory: true)
}
