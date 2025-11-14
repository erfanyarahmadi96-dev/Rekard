import SwiftUI

@main
struct RekardApp: App {
    // Create the shared DeckStore instance
    @StateObject private var store = DeckStore()

    var body: some Scene {
        WindowGroup {
            // Inject the environment object for the whole app
            MainView()
                .environmentObject(store)
        }
    }
}
