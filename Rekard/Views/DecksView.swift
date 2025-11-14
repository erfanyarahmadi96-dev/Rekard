import SwiftUI

struct DecksView: View {
    @EnvironmentObject private var store: DeckStore

    @State private var showingEditor = false
    @State private var editingDeck: Deck? = nil
    @State private var animateIn = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.appBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        ForEach(
                            Array(store.decks.enumerated()),
                            id: \.element.id
                        ) { index, deck in
                            NavigationLink(value: deck) {
                                DeckCardView(
                                    deck: deck,
                                    index: index,
                                    total: store.decks.count
                                )
                                .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button {
                                    editingDeck = deck
                                    showingEditor = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }

                                Button(role: .destructive) {
                                    store.remove(deck)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .animation(
                                .spring(response: 0.45, dampingFraction: 0.8),
                                value: store.decks
                            )
                        }
                    }
                    .padding(.vertical)
                }
                .navigationDestination(for: Deck.self) { deck in
                    CardsView(deck: deck)
                        .environmentObject(store)
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            editingDeck = nil
                            showingEditor = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle().fill(Color.gray.opacity(0.85))
                                )
                                .shadow(radius: 8)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 16)
                        .accessibilityLabel("Add Deck")
                    }
                }
            }
            .navigationTitle("Decks")
            .sheet(isPresented: $showingEditor) {
                DeckEditorView(
                    deck: $editingDeck,
                    onSave: { deck in
                        if store.decks.firstIndex(where: { $0.id == deck.id })
                            != nil
                        {
                            store.update(deck)
                        } else {
                            store.add(deck)
                        }
                        showingEditor = false
                    },
                    onDelete: { deck in
                        store.remove(deck)
                        showingEditor = false
                    }
                )
                .presentationDetents([.medium, .large])
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    animateIn = true
                }
            }
        }
    }
}

struct DeckCardView: View {
    let deck: Deck
    let index: Int
    let total: Int

    var body: some View {
        let base = deck.color.swiftUIColor
        let darker = Color(
            red: max(deck.color.red - 0.08, 0),
            green: max(deck.color.green - 0.08, 0),
            blue: max(deck.color.blue - 0.08, 0)
        )

        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [base, darker],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 120)
                .shadow(
                    color: Color.black.opacity(0.18),
                    radius: 12,
                    x: 0,
                    y: 8
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )

            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 78, height: 78)
                        .shadow(radius: 4)
                    Image(systemName: deck.icon)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(deck.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("\(deck.cards.count) cards")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

            }
            .padding(.horizontal, 22)
        }

    }
}
