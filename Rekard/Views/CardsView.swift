import SwiftUI
import AuthenticationServices
struct CardsView: View {
    let deck: Deck
    @EnvironmentObject private var store: DeckStore

    @State private var showingCardEditor = false
    @State private var editingCard: Card? = nil

    // track flipped cards by id
    @State private var flipped: Set<UUID> = []

    private var currentCards: [Card] {
        currentDeck()?.cards ?? []
    }

    private var isEmpty: Bool {
        currentCards.isEmpty
    }

    var body: some View {
        ZStack {
            LinearGradient.appBackground.ignoresSafeArea()

            VStack {
                // Header preview
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(deck.color.swiftUIColor)
                            .frame(width: 86, height: 86)
                            .shadow(radius: 6)
                        Image(systemName: deck.icon)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading) {
                        Text(deck.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("\(deck.cards.count) cards")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Divider()
                    .padding(.vertical, 8)

                if isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Text("No cards yet")
                            .font(.headline)
                        Text(
                            "Tap + to add a new flashcard (question & answer)."
                        )
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(currentCards) { card in
                                FlipCardView(
                                    card: card,
                                    isFront: !flipped.contains(card.id)
                                )
                                .onTapGesture {
                                    toggleFlip(card)
                                }
                                .contextMenu {
                                    Button {
                                        editingCard = card
                                        showingCardEditor = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }

                                    Button(role: .destructive) {
                                        store.removeCard(
                                            card.id,
                                            fromDeck: deck.id
                                        )
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }

            // Floating Add button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        editingCard = nil
                        showingCardEditor = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle().fill(Color.black.opacity(0.85))
                            )
                            .shadow(radius: 8)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .sheet(isPresented: $showingCardEditor) {
            CardEditorView(
                card: $editingCard,
                deckID: deck.id,
                onSave: { card in
                    if currentCards.contains(where: { $0.id == card.id }) {
                        store.updateCard(card, inDeck: deck.id)
                    } else {
                        store.addCard(card, toDeck: deck.id)
                    }
                    showingCardEditor = false
                },
                onDelete: { card in
                    store.removeCard(card.id, fromDeck: deck.id)
                    showingCardEditor = false
                }
            )
            .presentationDetents([.medium, .large])
        }
    }

    private func currentDeck() -> Deck? {
        store.decks.first(where: { $0.id == deck.id })
    }

    private func toggleFlip(_ card: Card) {
        if flipped.contains(card.id) {
            flipped.remove(card.id)
        } else {
            flipped.insert(card.id)
        }
    }
}

// MARK: - Flip Card View

struct FlipCardView: View {
    let card: Card
    var isFront: Bool

    var body: some View {
        ZStack {
            // Front side
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 4)
                .overlay(
                    VStack {
                        Text(card.question)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                )
                .opacity(isFront ? 1 : 0)

            // Back side
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 4)
                .overlay(
                    VStack {
                        Text(card.answer)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                )
                .opacity(isFront ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFront ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )  // ✅ fix
        }
        .frame(height: 200)
        .animation(
            .spring(response: 0.75, dampingFraction: 0.75),
            value: isFront
        )
    }
}
