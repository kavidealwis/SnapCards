//
//  TextRecognizer.swift
//  SnapCards
//
//  Reads printed text out of a photo using Apple's Vision framework.
//  Vision is Apple's computer-vision framework. Printed text works well; handwriting is unreliable.
//

import UIKit
import Vision

// MARK: - Text recognizer

enum TextRecognizer {

    /// The one thing that can go wrong before Vision even starts.
    enum RecognizerError: Error {
        case unreadableImage
    }

    /// Returns all the text Vision finds in the image, one line per row of text.
    /// NEW CONCEPT (not in labs): `async throws` means this function takes time and may fail.
    /// The caller writes `try await` and the app keeps running while it waits.
    static func recognize(from image: UIImage) async throws -> String {
        // Vision works with CGImage (the raw pixels), not UIImage.
        guard let cgImage = image.cgImage else {
            throw RecognizerError.unreadableImage
        }
        // Tell Vision which way up the photo is, so sideways photos still read correctly.
        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        // NEW CONCEPT (not in labs): `Task.detached` runs this block on a background thread,
        // so the screen does not freeze while Vision reads the photo.
        let task = Task.detached(priority: .userInitiated) { () throws -> String in
            // 1. The request: "find text in an image".
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate      // slower but more accurate
            request.usesLanguageCorrection = true     // fixes small spelling mistakes

            // 2. The handler: runs the request on our image.
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation)
            try handler.perform([request])

            // 3. The results: one observation per line of text.
            //    topCandidates(1) gives Vision's best guess for that line.
            let observations = request.results ?? []
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            return lines.joined(separator: "\n")
        }
        return try await task.value
    }
}

// MARK: - Orientation helper

/// UIImage and Vision describe "which way up" with two different enums.
/// This converts one into the other.
extension CGImagePropertyOrientation {
    init(_ ui: UIImage.Orientation) {
        switch ui {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
