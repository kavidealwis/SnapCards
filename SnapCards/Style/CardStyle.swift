//
//  CardStyle.swift
//  SnapCards
//
//  The app's one custom look: a rounded "card" background, written as a custom
//  ViewModifier so every card in the app looks the same. Also holds CardFace.
//

import SwiftUI

// MARK: - Custom modifier

/// A custom ViewModifier: a reusable bundle of modifiers we can apply to any view.
struct CardStyle: ViewModifier {
    var minHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: minHeight)
            // Semantic color: white in Light Mode, dark grey in Dark Mode.
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)   // very soft shadow
    }
}

/// Lets us write `.cardStyle()` instead of `.modifier(CardStyle())`.
extension View {
    func cardStyle(minHeight: CGFloat = 0) -> some View {
        modifier(CardStyle(minHeight: minHeight))
    }
}

// MARK: - Card face

/// One side of a review card: a small label ("Question" / "Answer") and the text.
struct CardFace: View {
    let title: String
    let text: String

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(text)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
        }
        .cardStyle(minHeight: 320)
    }
}

#Preview {
    CardFace(title: "Question", text: "What is Osmosis?")
        .padding()
        .background(Color(.systemGroupedBackground))
}
