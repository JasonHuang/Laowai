import SwiftUI

@main
struct LaowaiApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            JourneyView()
                .environmentObject(appState)
        }
    }
}
