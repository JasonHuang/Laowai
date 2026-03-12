import SwiftUI

final class AppState: ObservableObject {
    @Published var currentPhase: JourneyPhase = .preDeparture

    enum JourneyPhase: String, CaseIterable {
        case preDeparture = "Pre-Departure"
        case arrival = "Arrival"
        case cityLife = "City Life"
        case emergency = "Emergency"
    }
}
