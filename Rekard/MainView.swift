import SwiftUI

// Reusable app background color to match splash

struct MainView: View {
    @State private var selectedTab: Tab = .home

    enum Tab: Hashable {
        case home
        case study
        case decks
        case Search
    }

    var body: some View {

        NavigationStack {
            ZStack {
                LinearGradient.appBackground
                    .ignoresSafeArea()
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Image(systemName: "target")
                            Text("Progress")
                        }
                        .tag(Tab.home)

                   
                        .tag(Tab.study)
                    DecksView()

                        .tabItem {
                            Image(systemName: "square.stack.3d.up")
                            Text("Decks")
                        }
                        .tag(Tab.decks)
                    
                    SearchView()
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                   
                }

                .background(Color.clear)
            }
        }
    }
}

#Preview {
    MainView()
}
