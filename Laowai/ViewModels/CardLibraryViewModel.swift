import Foundation

@MainActor
final class CardLibraryViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var selectedCategory: Card.Category?
    @Published var searchText: String = ""

    var filteredCards: [Card] {
        var result = cards
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.englishNote.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    init() {
        loadCards()
    }

    private func loadCards() {
        guard
            let url = Bundle.main.url(forResource: "cards", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([Card].self, from: data)
        else { return }
        cards = decoded
    }
}
