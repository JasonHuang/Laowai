import SwiftUI

@main
struct LaowaiApp: App {
    @StateObject private var appState = AppState()
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                JourneyView()
                    .environmentObject(appState)
            } else {
                OnboardingView()
            }
        }
    }
}
