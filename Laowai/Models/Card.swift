import Foundation

struct Card: Identifiable, Codable {
    let id: String
    let category: Category
    let title: String
    let chineseText: String
    let englishNote: String
    let pinyin: String?
    let tags: [String]

    enum Category: String, Codable, CaseIterable {
        case restaurant = "Restaurant"
        case transport = "Transport"
        case hotel = "Hotel"
        case shopping = "Shopping"
        case emergency = "Emergency"
        case general = "General"

        var icon: String {
            switch self {
            case .restaurant: return "fork.knife"
            case .transport: return "car.fill"
            case .hotel: return "bed.double.fill"
            case .shopping: return "bag.fill"
            case .emergency: return "cross.fill"
            case .general: return "ellipsis.bubble.fill"
            }
        }

        var color: String {
            switch self {
            case .restaurant: return "#E63946"
            case .transport: return "#F4A261"
            case .hotel: return "#7BA4FF"
            case .shopping: return "#4CAF50"
            case .emergency: return "#FF6B6B"
            case .general: return "#A78BFA"
            }
        }
    }
}
