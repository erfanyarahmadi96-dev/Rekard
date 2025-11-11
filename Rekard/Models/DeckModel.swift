import SwiftUI

// MARK: - Card Model (updated for study)
struct Card: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var question: String
    var answer: String

    // Leitner box: 1 = Don't Know, 2 = Kind of Know, 3 = Know
    var box: Int = 1

    // When the card was last reviewed
    var lastReviewed: Date? = nil
}

// MARK: - ColorData (codable wrapper for Color)
struct ColorData: Codable, Equatable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double = 1.0

    init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    init(color: Color) {
        #if canImport(UIKit)
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
        #else
        self.red = 0.85; self.green = 0.45; self.blue = 0.45; self.opacity = 1.0
        #endif
    }

    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue).opacity(opacity)
    }
}

// MARK: - Deck Model
struct Deck: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var color: ColorData
    var cards: [Card] = []

    init(id: UUID = UUID(), name: String, icon: String = "book.fill", color: ColorData, cards: [Card] = []) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.cards = cards
    }
}
