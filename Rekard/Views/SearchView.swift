import SwiftUI

struct SearchView: View {
    @EnvironmentObject var store: DeckStore
    @State private var searchText = ""
    @FocusState private var isSearching: Bool

    var filteredDecks: [Deck] {
        if searchText.isEmpty {
            return store.decks
        } else {
            return store.decks.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.cards.contains { $0.question.localizedCaseInsensitiveContains(searchText) || $0.answer.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.appBackground.ignoresSafeArea()

                VStack(spacing: 16) {
                    // MARK: - Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search decks or cards...", text: $searchText)
                            .focused($isSearching)
                            .textFieldStyle(PlainTextFieldStyle())
                            .submitLabel(.done)
                            .toolbar {
                                
                            }

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // MARK: - Search Results
                    if filteredDecks.isEmpty {
                        Spacer()
                        Text("No results found")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 16) {
                                ForEach(filteredDecks) { deck in
                                    // DECK RESULT
                                    NavigationLink {
                                        CardsView(deck: deck)
                                            .environmentObject(store)
                                    } label: {
                                        HStack {
                                            Image(systemName: deck.icon)
                                                .foregroundColor(deck.color.swiftUIColor)
                                                .frame(width: 36, height: 36)
                                            VStack(alignment: .leading) {
                                                Text(deck.name)
                                                    .font(.headline)
                                                Text("\(deck.cards.count) cards")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.4)))
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    // CARD RESULTS inside the deck
                                    ForEach(deck.cards.filter {
                                        searchText.isEmpty ? true :
                                        $0.question.localizedCaseInsensitiveContains(searchText) ||
                                        $0.answer.localizedCaseInsensitiveContains(searchText)
                                    }) { card in
                                        NavigationLink {
                                            CardsView(deck: deck)
                                                .environmentObject(store)
                                        } label: {
                                            HStack {
                                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                                    .foregroundColor(.blue)
                                                    .frame(width: 36, height: 36)
                                                VStack(alignment: .leading) {
                                                    Text(card.question)
                                                        .font(.subheadline)
                                                        .lineLimit(1)
                                                    Text(card.answer)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(1)
                                                }
                                                Spacer()
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 6)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(DeckStore())
}
