//
//  DeckStore.swift
//  Rekard
//
//  Created by Erfan Yarahmadi on 11/11/25.
//

import Combine
import Foundation

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
        guard let idx = decks.firstIndex(where: { $0.id == deck.id }) else {
            return
        }
        decks[idx] = deck
        save()
    }

    func remove(_ deck: Deck) {
        decks.removeAll { $0.id == deck.id }
        save()
    }

    // MARK: Card CRUD (within a deck)
    func addCard(_ card: Card, toDeck deckID: UUID) {
        guard let idx = decks.firstIndex(where: { $0.id == deckID }) else {
            return
        }
        decks[idx].cards.insert(card, at: 0)
        save()
    }

    func updateCard(_ card: Card, inDeck deckID: UUID) {
        guard let dIdx = decks.firstIndex(where: { $0.id == deckID }) else {
            return
        }
        guard
            let cIdx = decks[dIdx].cards.firstIndex(where: { $0.id == card.id })
        else { return }
        decks[dIdx].cards[cIdx] = card
        save()
    }

    func removeCard(_ cardID: UUID, fromDeck deckID: UUID) {
        guard let dIdx = decks.firstIndex(where: { $0.id == deckID }) else {
            return
        }
        decks[dIdx].cards.removeAll { $0.id == cardID }
        save()
    }

    // MARK: Study helpers (Leitner actions)

    /// Promote card to next box (max 3) and update lastReviewed
    func promoteCard(_ cardID: UUID, inDeck deckID: UUID) {
        guard let dIdx = decks.firstIndex(where: { $0.id == deckID }) else {
            return
        }
        guard
            let cIdx = decks[dIdx].cards.firstIndex(where: { $0.id == cardID })
        else { return }
        var card = decks[dIdx].cards[cIdx]
        card.box = min(3, card.box + 1)
        card.lastReviewed = Date()
        decks[dIdx].cards[cIdx] = card
        save()
    }

    /// Demote card to previous box (min 1) and update lastReviewed
    func demoteCard(_ cardID: UUID, inDeck deckID: UUID) {
        guard let dIdx = decks.firstIndex(where: { $0.id == deckID }) else {
            return
        }
        guard
            let cIdx = decks[dIdx].cards.firstIndex(where: { $0.id == cardID })
        else { return }
        var card = decks[dIdx].cards[cIdx]
        card.box = max(1, card.box - 1)
        card.lastReviewed = Date()
        decks[dIdx].cards[cIdx] = card
        save()
    }

    /// Mark as seen but keep box same (useful if user wants to manually set lastReviewed)
    func markReviewed(_ cardID: UUID, inDeck deckID: UUID) {
        guard let dIdx = decks.firstIndex(where: { $0.id == deckID }) else {
            return
        }
        guard
            let cIdx = decks[dIdx].cards.firstIndex(where: { $0.id == cardID })
        else { return }
        var card = decks[dIdx].cards[cIdx]
        card.lastReviewed = Date()
        decks[dIdx].cards[cIdx] = card
        save()
    }

    // Get cards for a deck filtered by box (optionally apply ordering)
    func cards(inDeck deckID: UUID, box: Int) -> [Card] {
        guard let deck = decks.first(where: { $0.id == deckID }) else {
            return []
        }
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
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey)
        else { return }
        do {
            decks = try JSONDecoder().decode([Deck].self, from: data)
        } catch {
            print("Failed to load decks:", error)
        }
    }
}
