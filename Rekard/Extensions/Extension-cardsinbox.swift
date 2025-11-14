//
//  Extension-cardsinbox.swift
//  Rekard
//
//  Created by Erfan Yarahmadi on 13/11/25.
//

import Foundation
 
extension DeckStore {
    func totalCards(inBox box: Int) -> Int {
        decks.reduce(0) { $0 + $1.cardsInBox(box) }
    }

    func totalTimeSpent() -> Double {
        // Mock or real tracking
        return 45
    }
}

extension Deck {
    func cardsInBox(_ box: Int) -> Int {
        cards.filter { $0.box == box }.count
    }
}
