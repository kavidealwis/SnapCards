# SnapCards

SnapCards is an iOS app that turns photos of printed study notes into flashcards.
It reads the text with Apple's **Vision** framework, finds definition-style lines
with **NaturalLanguage** and simple patterns, saves the cards with **SwiftData**, and
schedules reviews with spaced repetition (simplified SM-2). You review cards by swiping.

SE4041 Mobile Application Design & Development, Assignment 02, Part A.

## Screenshots

_Added on the Mac. See `docs/screenshots/`._

| Home | Scan | Review | All Cards |
|---|---|---|---|
| _todo_ | _todo_ | _todo_ | _todo_ |

## Requirements

- A Mac with **Xcode 15 or later**
- **iOS 17.0+** (Simulator or device). SwiftData and `ContentUnavailableView` need iOS 17.
- No third-party packages.

## Project structure

```
SnapCards/
├── SnapCardsApp.swift        app entry point + SwiftData container
├── Models/Flashcard.swift    @Model + spaced-repetition schedule
├── Services/
│   ├── TextRecognizer.swift  Vision: photo -> text
│   └── CardGenerator.swift   NaturalLanguage + patterns: text -> cards
├── Views/                    Home, Scan, Review, All Cards, Card Detail
└── Style/CardStyle.swift     custom ViewModifier + CardFace
SnapCardsTests/               XCTest unit tests
SnapCardsUITests/             XCTest UI test
docs/                         report, user guide, technical doc, viva notes, AI log
```

## Setting up the Xcode project (Mac)

The source files were written first; the Xcode project is created on the Mac like this:

1. `git clone` the repo.
2. Xcode → File → New → Project → iOS → App. Product Name exactly `SnapCards`,
   Interface **SwiftUI**, Language **Swift**, Storage **None**, **Include Tests ticked**.
   Save it **inside the cloned repo folder** (untick "Create Git repository").
3. Delete the template `ContentView.swift`, the template `SnapCardsApp.swift` and the template test files.
4. Drag `SnapCardsApp.swift` and the `Models/`, `Services/`, `Views/`, `Style/` folders into the
   `SnapCards` group (Create groups, **Copy items if needed OFF** since they are already in place,
   correct target ticked). Drag the test files into `SnapCardsTests` and `SnapCardsUITests`.
5. Set the deployment target to **iOS 17.0**.
6. Cmd + R.

## How to run

- Pick an iPhone Simulator and press **Cmd + R**.
- To try scanning in the Simulator, drag an image of printed notes onto the Simulator window
  (it is saved to Photos), then use **Scan Notes → Choose Photo**.
- No photo? Use **Scan Notes → Try sample text**.

## How to run the tests

- **Cmd + U** runs the unit tests (`FlashcardTests`, `CardGeneratorTests`) and the UI test.

## Known limitations

- Only **definition-style** text makes cards ("Term: definition" lines or "X is a / refers to Y"
  sentences). Other text produces no cards.
- **Printed** text works well; **handwriting** is unreliable.
- Photos come from the photo library only (no camera capture yet).
- Cards are stored on this device only (no iCloud sync, no accounts).

## Third-party resources

None. Only Apple frameworks: SwiftUI, SwiftData, Vision, NaturalLanguage, PhotosUI, XCTest.
Icons are SF Symbols.

## AI use disclosure

AI tools (Claude Code) were used to help plan and draft code and documentation.
Every prompt and how it was used is recorded in [`docs/AI_USAGE_LOG.md`](docs/AI_USAGE_LOG.md).
All code was reviewed, built and tested by the student, who can explain every line.
