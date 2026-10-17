//
//  ContentView.swift
//  SnapCards
//
//  The Home screen: shows how many cards are due today and the three main actions
//  (Start Review, Scan Notes, All Cards).
//

import SwiftUI
import SwiftData

struct ContentView: View {

    // MARK: - Data

    /// NEW CONCEPT (not in labs): `@Query` asks SwiftData for every saved Flashcard
    /// and keeps this array up to date automatically when cards are added or changed.
    @Query private var cards: [Flashcard]

    @State private var showingScan = false     // controls the Scan Notes sheet

    /// How many cards need reviewing right now.
    private var dueCount: Int {
        cards.filter(\.isDue).count
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // 1. The big "due today" number
                    VStack(spacing: 8) {
                        Text("\(dueCount)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundStyle(.tint)
                            .contentTransition(.numericText())   // digits roll when the number changes
                            .accessibilityIdentifier("dueCount")   // used by the UI test

                        Text("cards due today")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .cardStyle()

                    // 2. Primary action
                    NavigationLink {
                        ReviewView()
                    } label: {
                        Label("Start Review", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(dueCount == 0)

                    // 3. Scan Notes opens a sheet
                    Button {
                        showingScan = true
                    } label: {
                        Label("Scan Notes", systemImage: "camera.viewfinder")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    // 4. Library of all cards
                    NavigationLink {
                        LibraryView()
                    } label: {
                        Label("All Cards (\(cards.count))", systemImage: "books.vertical")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SnapCards")
            .sheet(isPresented: $showingScan) {
                ScanView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Flashcard.self, inMemory: true)
}
