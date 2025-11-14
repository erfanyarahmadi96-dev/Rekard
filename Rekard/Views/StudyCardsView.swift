import SwiftUI

struct StudyCardsView: View {
    let deck: Deck
    let box: Int  // 1,2,3
    @EnvironmentObject private var store: DeckStore
    @Environment(\.dismiss) private var dismiss

    @State private var cards: [Card] = []
    @State private var currentIndex: Int = 0
    @State private var isFlipped: Bool = false

    var body: some View {
        ZStack {
            LinearGradient.appBackground.ignoresSafeArea()

            VStack(spacing: 12) {
                // header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("Box \(box)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(cards.count) total")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()

                if cards.isEmpty {
                    VStack(spacing: 12) {
                        Text("No cards in this box")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(
                            "You can move cards into this box by studying other cards or from the Decks tab."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                    }
                    Spacer()
                } else {
                    // Card area (stack with only top card interactive)
                    ZStack {
                        ForEach(
                            Array(cards.enumerated()).reversed(),
                            id: \.element.id
                        ) { idx, card in
                            if idx >= currentIndex {
                                FlipCardLarge(
                                    card: card,
                                    isFront: idx == currentIndex
                                        ? !isFlipped : true
                                )
                                .offset(y: CGFloat(idx - currentIndex) * 10)
                                .scaleEffect(
                                    idx == currentIndex
                                        ? 1.0
                                        : (1.0 - CGFloat(idx - currentIndex)
                                            * 0.03)
                                )
                                .animation(
                                    .spring(
                                        response: 0.45,
                                        dampingFraction: 0.8
                                    ),
                                    value: currentIndex
                                )
                                .allowsHitTesting(idx == currentIndex)
                                .onTapGesture {
                                    if idx == currentIndex {
                                        withAnimation(
                                            .spring(
                                                response: 0.5,
                                                dampingFraction: 0.75
                                            )
                                        ) {
                                            isFlipped.toggle()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 380)
                    .padding(.horizontal, 24)
                    Spacer(minLength: 24)

                    // Action buttons
                    HStack(spacing: 18) {
                        // Don't Know -> Box 1
                        Button {
                            markAsDontKnow()
                        } label: {
                            actionButtonLabel(
                                symbol: "xmark",
                                text: "Don't Know",
                                color: Color(red: 0.95, green: 0.65, blue: 0.65)
                            )
                        }

                        // Kind of Know -> Box 2
                        Button {
                            markAsKindOfKnow()
                        } label: {
                            actionButtonLabel(
                                symbol: "hand.thumbsup",
                                text: "Kind of Know",
                                color: Color(red: 0.98, green: 0.85, blue: 0.55)
                            )
                        }

                        // Know -> promote
                        Button {
                            markAsKnow()
                        } label: {
                            actionButtonLabel(
                                symbol: "checkmark",
                                text: "Know",
                                color: Color(red: 0.70, green: 0.90, blue: 0.70)
                            )
                        }
                    }
                    .padding(.bottom, 28)
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            reloadCards()
        }
    }

    // MARK: - Actions & Helpers

    private func reloadCards() {
        cards = store.cards(inDeck: deck.id, box: box)
        currentIndex = 0
        isFlipped = false
    }

    private func advance() {
        isFlipped = false
        currentIndex += 1
        if currentIndex >= cards.count {
            // session finished — small delay then go back
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                reloadCards()
                dismiss()
            }
        }
    }

    private func markAsDontKnow() {
        guard currentIndex < cards.count else { return }
        let card = cards[currentIndex]
        // demote to box 1 and update lastReviewed
        store.demoteCard(card.id, inDeck: deck.id)
        // proceed to next
        advanceAfterChange()
    }

    private func markAsKindOfKnow() {
        guard currentIndex < cards.count else { return }
        let card = cards[currentIndex]
        var updated = card
        updated.box = 2
        updated.lastReviewed = Date()
        store.updateCard(updated, inDeck: deck.id)
        advanceAfterChange()
    }

    private func markAsKnow() {
        guard currentIndex < cards.count else { return }
        let card = cards[currentIndex]
        store.promoteCard(card.id, inDeck: deck.id)
        advanceAfterChange()
    }

    private func advanceAfterChange() {
        // small delay for animation feel then advance & reload
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            // reload current set and advance to next
            let currentCardID =
                currentIndex < cards.count ? cards[currentIndex].id : nil
            reloadCards()
            // If current card still exists in list, move to its index + 1
            if let cid = currentCardID,
                let idx = cards.firstIndex(where: { $0.id == cid })
            {
                // If the card is still in the list (same box), advance past it
                currentIndex = idx + 1
            } else {
                // otherwise keep currentIndex (which effectively moves to next)
                // clamp
                if currentIndex >= cards.count {
                    // finished
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        reloadCards()
                        dismiss()
                    }
                }
            }
            isFlipped = false
        }
    }

    // MARK: - Views

    private func actionButtonLabel(symbol: String, text: String, color: Color)
        -> some View
    {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(Circle().fill(color))
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

// Large flip card view (3D flip)
struct FlipCardLarge: View {
    let card: Card
    var isFront: Bool

    var body: some View {
        ZStack {
            // Front
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 8)
                .overlay(
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Question")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        Text(card.question)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding()
                )
                .opacity(isFront ? 1 : 0)

            // Back
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 8)
                .overlay(
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Answer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        Text(card.answer)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding()

                )
                .opacity(isFront ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFront ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )  // ✅ fix
        }
        .frame(maxWidth: .infinity)
        .frame(height: 360)
        .animation(
            .spring(response: 0.75, dampingFraction: 0.75),
            value: isFront
        )

    }
}
