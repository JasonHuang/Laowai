import SwiftUI

final class AppState: ObservableObject {

    @Published var currentPhase: JourneyPhase {
        didSet { UserDefaults.standard.set(currentPhase.rawValue, forKey: "currentPhase") }
    }

    @Published var selectedCity: String {
        didSet { UserDefaults.standard.set(selectedCity, forKey: "selectedCity") }
    }

    init() {
        let savedPhase = UserDefaults.standard.string(forKey: "currentPhase") ?? ""
        currentPhase = JourneyPhase(rawValue: savedPhase) ?? .preDeparture
        selectedCity = UserDefaults.standard.string(forKey: "selectedCity") ?? ""
    }

    enum JourneyPhase: String, CaseIterable {
        case preDeparture = "Pre-Departure"
        case arrival = "Arrival"
        case cityLife = "City Life"
        case emergency = "Emergency"
    }
}
