import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

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

// MARK: - DeckStore
final class DeckStore: ObservableObject {
    @Published private(set) var decks: [Deck] = []

    private let userDefaultsKey = "rekard.decks.v3"

    init() {
        load()
        // keep empty allowed — no placeholder deck needed now
    }

    // MARK: Deck CRUD
    func add(_ deck: Deck) {
        decks.insert(deck, at: 0)
        save()
    }

    func update(_ deck: Deck) {
        guard let idx = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[idx] = deck
        save()
    }

    func remove(_ deck: Deck) {
        decks.removeAll { $0.id == deck.id }
        save()
    }

    // MARK: Card CRUD (within a deck)
    func addCard(_ card: Card, toDeck deckID: UUID) {
        guard let idx = decks.firstIndex(where: { $0.id == deckID }) else { return }
        decks[idx].cards.insert(card, at: 0)
        save()
    }

    func updateCard(_ card: Card, inDeck deckID: UUID) {
        guard let dIdx = decks.firstIndex(where: { $0.id == deckID }) else { return }
        guard let cIdx = decks[dIdx].cards.firstIndex(where: { $0.id == card.id }) else { return }
        decks[dIdx].cards[cIdx] = card
        save()
    }

    func removeCard(_ cardID: UUID, fromDeck deckID: UUID) {
        guard let dIdx = decks.firstIndex(where: { $0.id == deckID }) else { return }
        decks[dIdx].cards.removeAll { $0.id == cardID }
        save()
    }

    // MARK: Study helpers (Leitner actions)

    /// Promote card to next box (max 3) and update lastReviewed
    func promoteCard(_ cardID: UUID, inDeck deckID: UUID) {
        guard let dIdx = decks.firstIndex(where: { $0.id == deckID }) else { return }
        guard let cIdx = decks[dIdx].cards.firstIndex(where: { $0.id == cardID }) else { return }
        var card = decks[dIdx].cards[cIdx]
        card.box = min(3, card.box + 1)
        card.lastReviewed = Date()
        decks[dIdx].cards[cIdx] = card
        save()
    }

    /// Demote card to previous box (min 1) and update lastReviewed
    func demoteCard(_ cardID: UUID, inDeck deckID: UUID) {
        guard let dIdx = decks.firstIndex(where: { $0.id == deckID }) else { return }
        guard let cIdx = decks[dIdx].cards.firstIndex(where: { $0.id == cardID }) else { return }
        var card = decks[dIdx].cards[cIdx]
        card.box = max(1, card.box - 1)
        card.lastReviewed = Date()
        decks[dIdx].cards[cIdx] = card
        save()
    }

    /// Mark as seen but keep box same (useful if user wants to manually set lastReviewed)
    func markReviewed(_ cardID: UUID, inDeck deckID: UUID) {
        guard let dIdx = decks.firstIndex(where: { $0.id == deckID }) else { return }
        guard let cIdx = decks[dIdx].cards.firstIndex(where: { $0.id == cardID }) else { return }
        var card = decks[dIdx].cards[cIdx]
        card.lastReviewed = Date()
        decks[dIdx].cards[cIdx] = card
        save()
    }

    // Get cards for a deck filtered by box (optionally apply ordering)
    func cards(inDeck deckID: UUID, box: Int) -> [Card] {
        guard let deck = decks.first(where: { $0.id == deckID }) else { return [] }
        // Sort by lastReviewed ascending (older reviewed first) so due items show earlier
        return deck.cards.filter { $0.box == box }
            .sorted { (a, b) -> Bool in
                switch (a.lastReviewed, b.lastReviewed) {
                case (nil, nil): return a.id.uuidString < b.id.uuidString
                case (nil, _): return true
                case (_, nil): return false
                case (let d1?, let d2?): return d1 < d2
                }
            }
    }

    // MARK: Persistence
    private func save() {
        do {
            let data = try JSONEncoder().encode(decks)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save decks:", error)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            decks = try JSONDecoder().decode([Deck].self, from: data)
        } catch {
            print("Failed to load decks:", error)
        }
    }
}
