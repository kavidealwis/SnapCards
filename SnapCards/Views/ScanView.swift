//
//  ScanView.swift
//  SnapCards
//
//  The Scan Notes sheet: pick a photo (or use sample text), read the text with Vision,
//  turn it into cards, let the user choose which to keep, then save them.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ScanView: View {

    // MARK: - Environment

    /// NEW CONCEPT (not in labs): the modelContext is SwiftData's "scratch pad".
    /// `modelContext.insert(card)` adds a card, and SwiftData saves it for us.
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss       // closes this sheet

    // MARK: - State

    @State private var pickerItem: PhotosPickerItem?   // the photo the user picked
    @State private var image: UIImage?                 // thumbnail preview
    @State private var text = ""                       // text read from the photo
    @State private var cards: [GeneratedCard] = []     // proposed cards
    @State private var topic = ""
    @State private var isWorking = false
    @State private var errorMessage: String?

    /// Save is only allowed when at least one card is ticked.
    private var hasSelection: Bool {
        cards.contains { $0.isSelected }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {

                // Section 1: where the text comes from
                Section {
                    // NEW CONCEPT (not in labs): PhotosPicker shows the photo library.
                    // The chosen photo is written into `pickerItem`.
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                    }

                    Button {
                        useSampleText()
                    } label: {
                        Label("Try sample text", systemImage: "text.badge.plus")
                    }

                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .accessibilityLabel("Selected photo")
                    }

                    if isWorking {
                        ProgressView("Reading text…")
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Source")
                } footer: {
                    Text("Printed notes work best. Handwriting is not supported.")
                }

                // Section 2: the text, which the user can fix before making cards
                if !text.isEmpty {
                    Section("Extracted text") {
                        TextEditor(text: $text)
                            .frame(minHeight: 150)

                        Button("Regenerate cards") {
                            generateCards()
                        }
                    }
                }

                // Section 3: the proposed cards
                if !cards.isEmpty {
                    Section("Topic") {
                        TextField("e.g. Biology", text: $topic)
                    }

                    Section("Cards (\(cards.count))") {
                        // `$cards` gives a binding to each card so the Toggle can change it.
                        ForEach($cards) { $card in
                            Toggle(isOn: $card.isSelected) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(card.front)
                                        .font(.headline)
                                    Text(card.back)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Scan Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!hasSelection)
                }
            }
            // Runs every time the user picks a new photo.
            .onChange(of: pickerItem) {
                loadPhoto()
            }
        }
    }

    // MARK: - Actions

    /// Photo -> UIImage -> Vision text -> cards.
    /// `@MainActor` keeps this on the main thread, where screen state must be changed.
    @MainActor
    private func loadPhoto() {
        guard let pickerItem else { return }
        isWorking = true
        errorMessage = nil

        // NEW CONCEPT (not in labs): `Task { }` starts work that can `await` (pause)
        // without freezing the screen. `defer` runs when the block ends, however it ends.
        Task {
            defer { isWorking = false }
            do {
                // Load the photo's raw bytes, then turn them into an image.
                guard let data = try await pickerItem.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else {
                    errorMessage = "Could not open that photo."
                    return
                }
                image = uiImage

                let found = try await TextRecognizer.recognize(from: uiImage)
                guard !found.isEmpty else {
                    errorMessage = "No text found. Try a clear photo of printed notes."
                    return
                }
                text = found
                generateCards()
            } catch {
                errorMessage = "Something went wrong reading that photo. Please try another."
            }
        }
    }

    /// Fills the text with three example definitions (works without any photo).
    private func useSampleText() {
        image = nil
        text = """
        Photosynthesis: the process plants use to turn sunlight into food.
        A mitochondrion is the organelle that produces energy for the cell.
        Osmosis: the movement of water across a membrane.
        """
        generateCards()
    }

    /// Runs the generator on the current text and shows a message if nothing was found.
    private func generateCards() {
        cards = CardGenerator.generate(from: text)
        if cards.isEmpty {
            errorMessage = "No cards could be made. Try lines like “Term: definition” or sentences like “X is a …”."
        } else {
            errorMessage = nil
        }
    }

    /// Saves every ticked card to SwiftData, then closes the sheet.
    private func save() {
        let name = topic.trimmingCharacters(in: .whitespaces)
        let finalTopic = name.isEmpty ? "General" : name

        for card in cards.filter({ $0.isSelected }) {
            let flashcard = Flashcard(front: card.front, back: card.back, topic: finalTopic)
            modelContext.insert(flashcard)
        }
        dismiss()
    }
}

#Preview {
    ScanView()
        .modelContainer(for: Flashcard.self, inMemory: true)
}
