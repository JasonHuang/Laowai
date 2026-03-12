import SwiftUI

@main
struct LaowaiApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var favourites = FavouritesStore()
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                JourneyView()
                    .environmentObject(appState)
                    .environmentObject(favourites)
            } else {
                OnboardingView()
            }
        }
    }
}
