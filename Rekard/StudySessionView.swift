import SwiftUI

struct StudySessionView: View {
    let deck: Deck
    @EnvironmentObject private var store: DeckStore

    // soft colors
    private let softRed = Color(red: 0.95, green: 0.65, blue: 0.65)
    private let softYellow = Color(red: 0.98, green: 0.85, blue: 0.55)
    private let softGreen = Color(red: 0.70, green: 0.90, blue: 0.70)

    var body: some View {
        ZStack {
            LinearGradient.appBackground.ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(deck.color.swiftUIColor)
                            .frame(width: 72, height: 72)
                        Image(systemName: deck.icon)
                            .font(.system(size: 28, weight: .semibold))
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

                Spacer(minLength: 8)

                VStack(spacing: 14) {
                    // Box 1 — Don't Know
                    NavigationLink {
                        StudyCardsView(deck: deck, box: 1)
                            .environmentObject(store)
                    } label: {
                        boxCard(title: "Box 1 — Don't Know", subtitle: "\(store.cards(inDeck: deck.id, box: 1).count) cards", color: softRed)
                    }

                    // Box 2 — Kind of Know
                    NavigationLink {
                        StudyCardsView(deck: deck, box: 2)
                            .environmentObject(store)
                    } label: {
                        boxCard(title: "Box 2 — Kind of Know", subtitle: "\(store.cards(inDeck: deck.id, box: 2).count) cards", color: softYellow)
                    }

                    // Box 3 — Know
                    NavigationLink {
                        StudyCardsView(deck: deck, box: 3)
                            .environmentObject(store)
                    } label: {
                        boxCard(title: "Box 3 — Know", subtitle: "\(store.cards(inDeck: deck.id, box: 3).count) cards", color: softGreen)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)

                Spacer()
            }
        }
    }

    @ViewBuilder
    private func boxCard(title: String, subtitle: String, color: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(LinearGradient(colors: [color.opacity(0.95), color.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 6)
    }
}
