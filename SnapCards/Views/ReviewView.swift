//
//  ReviewView.swift
//  SnapCards
//
//  The Review screen: shows one due card at a time. Tap to flip it,
//  swipe right (or tap Got it) if you knew it, swipe left (or tap Again) if not.
//

import SwiftUI
import SwiftData

struct ReviewView: View {

    // MARK: - Data

    @Query private var allCards: [Flashcard]

    // MARK: - State

    @State private var queue: [Flashcard] = []   // cards left in this session
    @State private var hasLoaded = false         // so the queue is only built once
    @State private var flipped = false           // false = question, true = answer
    @State private var offset: CGSize = .zero    // how far the card has been dragged
    @State private var isBusy = false            // blocks double taps while a card flies away

    /// How far (in points) a card must be dragged to count as a swipe.
    private let swipeThreshold: CGFloat = 120

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            if let card = queue.first {
                Text("\(queue.count) left")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                cardView(for: card)

                answerButtons(for: card)

                Text("Tap to flip · swipe right = got it · swipe left = again")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else if hasLoaded {
                ContentUnavailableView(
                    "All done!",
                    systemImage: "checkmark.seal.fill",
                    description: Text("No more cards are due. Come back later.")
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Build the queue once: only due cards, in random order.
            guard !hasLoaded else { return }
            queue = allCards.filter(\.isDue).shuffled()
            hasLoaded = true
        }
    }

    // MARK: - Card

    /// The flippable, swipeable card.
    private func cardView(for card: Flashcard) -> some View {
        ZStack {
            CardFace(title: "Question", text: card.front)
                .opacity(flipped ? 0 : 1)

            // The back is pre-rotated 180° so it reads the right way round after the flip.
            CardFace(title: "Answer", text: card.back)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(flipped ? 1 : 0)
        }
        // rotation3DEffect spins the view around the
        // vertical (y) axis, like turning over a real card.
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        // Faint green (right) or red (left) tint while dragging.
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(offset.width > 0 ? Color.green : Color.red)
                .opacity(min(abs(offset.width) / 300, 0.25))
                .allowsHitTesting(false)
        }
        .offset(offset)                                          // follow the finger
        .rotationEffect(.degrees(Double(offset.width / 20)))     // slight tilt
        .onTapGesture {
            withAnimation(.spring(duration: 0.4)) {
                flipped.toggle()
            }
        }
        // DragGesture reports how far the finger has moved.
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                }
                .onEnded { value in
                    if value.translation.width > swipeThreshold {
                        finish(card, quality: 4, direction: 1)       // swiped right
                    } else if value.translation.width < -swipeThreshold {
                        finish(card, quality: 1, direction: -1)      // swiped left
                    } else {
                        withAnimation(.spring(duration: 0.4)) {      // not far enough: snap back
                            offset = .zero
                        }
                    }
                }
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(flipped ? "Answer: \(card.back)" : "Question: \(card.front)")
        .accessibilityHint("Double tap to flip")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Buttons

    /// Buttons that do the same as the swipes (for accessibility).
    private func answerButtons(for card: Flashcard) -> some View {
        HStack(spacing: 16) {
            Button {
                finish(card, quality: 1, direction: -1)
            } label: {
                Label("Again", systemImage: "arrow.uturn.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)

            Button {
                finish(card, quality: 4, direction: 1)
            } label: {
                Label("Got it", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .controlSize(.large)
    }

    // MARK: - Actions

    /// Flies the card off screen, updates its schedule and moves to the next card.
    /// direction: 1 = right, -1 = left.
    /// `@MainActor` keeps this on the main thread, where screen state must be changed.
    @MainActor
    private func finish(_ card: Flashcard, quality: Int, direction: CGFloat) {
        guard !isBusy else { return }
        isBusy = true

        withAnimation(.easeInOut(duration: 0.25)) {
            offset = CGSize(width: direction * 600, height: 0)
        }

        Task {
            // Wait for the fly-away animation (250 ms) before showing the next card.
            try? await Task.sleep(for: .milliseconds(250))

            card.review(quality: quality)          // SwiftData saves the new schedule
            if !queue.isEmpty {
                queue.removeFirst()
            }
            if quality < 3 {
                queue.append(card)                 // forgot: see it again this session
            }

            offset = .zero
            flipped = false
            isBusy = false
        }
    }
}

#Preview {
    NavigationStack {
        ReviewView()
    }
    .modelContainer(for: Flashcard.self, inMemory: true)
}
