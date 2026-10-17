//
//  SnapCardsApp.swift
//  SnapCards
//
//  The app's starting point (@main). It shows ContentView and sets up
//  SwiftData storage for Flashcard so every screen can load and save cards.
//

import SwiftUI
import SwiftData

@main
struct SnapCardsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // NEW CONCEPT (not in labs): creates the on-device database for Flashcard
        // and hands it to every view (used by @Query and modelContext).
        .modelContainer(for: Flashcard.self)
    }
}
