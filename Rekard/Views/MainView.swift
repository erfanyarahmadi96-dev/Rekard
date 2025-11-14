import SwiftUI

// Reusable app background color to match splash

struct MainView: View {

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
                TabView {

                    HomeView()
                        .tabItem {
                            Image(systemName: "target")
                            Text("Progress")
                        }
                        .tag(Tab.home)

                    DecksView()
                        .tabItem {
                            Image(systemName: "square.stack.3d.up")
                            Text("Leitner Box")
                        }
                        .tag(Tab.decks)

                    SettingView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                    
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
