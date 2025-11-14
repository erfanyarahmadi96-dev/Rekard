import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: DeckStore

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.appBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack {
                        ForEach(store.decks) { deck in
                            NavigationLink {
                                StudySessionView(deck: deck)
                                    .environmentObject(store)
                            } label: {
                                DeckProgressCard(deck: deck)
                                    .frame(width: 340, height: 140)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }

                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Progress")
            .toolbarBackground(.hidden, for: .navigationBar, .tabBar)
            .toolbar(.visible, for: .tabBar)

        }
    }
}

struct DeckProgressCard: View {
    let deck: Deck

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(deck.color.swiftUIColor)
                    .frame(width: 72, height: 72)
                    .shadow(radius: 4)
                Image(systemName: deck.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading) {
                HStack(spacing: 6) {
                    Text(deck.name)
                        .font(.headline)

                }
                HStack(spacing: 6) {
                    BoxIndicator(color: .red, count: deck.cardsInBox(1))
                    BoxIndicator(color: .yellow, count: deck.cardsInBox(2))
                    BoxIndicator(color: .green, count: deck.cardsInBox(3))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)

        }
        .padding()
    }
}

struct BoxIndicator: View {
    let color: Color
    let count: Int

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color.opacity(0.6))
                .frame(width: 25, height: 25)
                .overlay(
                    Text("\(count)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                )
        }
    }
}

#Preview {
    HomeView()
}
