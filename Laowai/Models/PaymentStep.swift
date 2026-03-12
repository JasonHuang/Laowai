import Foundation

struct PaymentProvider: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let tagline: String
    let steps: [PaymentStep]
}

struct PaymentStep: Identifiable, Codable {
    let id: String
    let stepNumber: Int
    let title: String
    let description: String
    let tips: [String]
    let showAndPointCard: ShowAndPointContent?

    struct ShowAndPointContent: Codable {
        let chineseText: String
        let context: String
    }
}
