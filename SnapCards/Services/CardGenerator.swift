//
//  CardGenerator.swift
//  SnapCards
//
//  Turns raw text into proposed flashcards. It looks for "Term: definition" lines
//  and "X is a / refers to Y" sentences. Only definition-style text produces cards.
//

import Foundation
import NaturalLanguage

// MARK: - Generated card

/// A card proposed by the generator (not saved yet).
/// It is a plain struct; it only becomes a saved `Flashcard` when the user taps Save.
struct GeneratedCard: Identifiable {
    let id = UUID()
    var front: String
    var back: String
    var isSelected = true     // the user can untick cards they don't want
}

// MARK: - Card generator

enum CardGenerator {

    /// Finds "Term: definition" lines and "X is a / refers to Y" sentences.
    static func generate(from rawText: String) -> [GeneratedCard] {
        var cards: [GeneratedCard] = []
        var usedTerms = Set<String>()     // stops the same term making two cards

        // Pass 1: lines like "Term: definition"
        for line in rawText.components(separatedBy: .newlines) {
            if let pair = splitOnSeparator(line),
               !usedTerms.contains(pair.term.lowercased()) {
                cards.append(GeneratedCard(front: "What is \(pair.term)?", back: pair.definition))
                usedTerms.insert(pair.term.lowercased())
            }
        }

        // Pass 2: sentences (split with NaturalLanguage) like "X is a Y"
        for sentence in splitSentences(rawText) {
            if let pair = splitOnVerb(sentence),
               !usedTerms.contains(pair.term.lowercased()) {
                cards.append(GeneratedCard(front: "What is \(pair.term)?", back: pair.definition))
                usedTerms.insert(pair.term.lowercased())
            }
        }
        return cards
    }

    // MARK: - Pattern 1: "Term: definition"

    /// Splits "Osmosis: movement of water" into ("Osmosis", "movement of water").
    /// Returns nil if the line does not look like a definition.
    static func splitOnSeparator(_ line: String) -> (term: String, definition: String)? {
        guard let range = line.range(of: ": ") else { return nil }
        let term = String(line[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        let def = String(line[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard isGoodTerm(term), wordCount(def) >= 3 else { return nil }
        return (term: term, definition: def)
    }

    // MARK: - Pattern 2: "X is a Y"

    /// Splits "A mitochondrion is the organelle that ..." into ("mitochondrion", "organelle that ...").
    static func splitOnVerb(_ sentence: String) -> (term: String, definition: String)? {
        let markers = [" is defined as ", " refers to ", " is known as ",
                       " means ", " is a ", " is an ", " is the "]
        for marker in markers {
            if let range = sentence.range(of: marker, options: .caseInsensitive) {
                var term = String(sentence[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                let def = String(sentence[range.upperBound...])
                    .trimmingCharacters(in: CharacterSet(charactersIn: ". "))
                // Drop a leading article: "A mitochondrion" -> "mitochondrion"
                for article in ["The ", "A ", "An "] where term.hasPrefix(article) {
                    term = String(term.dropFirst(article.count))
                }
                if isGoodTerm(term) && wordCount(def) >= 3 { return (term: term, definition: def) }
            }
        }
        return nil
    }

    // MARK: - Helpers

    /// A good term is short (1 to 4 words), has no commas and does not start with a pronoun.
    private static func isGoodTerm(_ term: String) -> Bool {
        let words = term.split(separator: " ")
        guard (1...4).contains(words.count), term.count <= 40, !term.contains(",") else { return false }
        let bad: Set<String> = ["this", "that", "it", "there", "these", "those",
                                "he", "she", "they", "we", "you", "i", "which"]
        return !bad.contains(words[0].lowercased())
    }

    private static func wordCount(_ text: String) -> Int {
        text.split(separator: " ").count
    }

    /// NaturalLanguage sentence tokenizer.
    /// NEW CONCEPT (not in labs): `NLTokenizer` is Apple's language tool that knows where
    /// sentences start and end (it handles "e.g." and "Dr." better than splitting on ".").
    static func splitSentences(_ text: String) -> [String] {
        let flat = text.replacingOccurrences(of: "\n", with: " ")   // OCR breaks lines mid-sentence
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = flat
        var result: [String] = []
        // The closure is called once per sentence; returning true means "keep going".
        tokenizer.enumerateTokens(in: flat.startIndex..<flat.endIndex) { range, _ in
            let s = flat[range].trimmingCharacters(in: .whitespaces)
            if !s.isEmpty { result.append(s) }
            return true
        }
        return result
    }
}
