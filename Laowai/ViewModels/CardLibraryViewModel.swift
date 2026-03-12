import Foundation

@MainActor
final class CardLibraryViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var selectedCategory: Card.Category?
    @Published var searchText: String = ""
    @Published var showFavouritesOnly: Bool = false

    func filteredCards(favourites: FavouritesStore) -> [Card] {
        var result = cards

        // Favourites filter
        if showFavouritesOnly {
            result = result.filter { favourites.isFavourite($0) }
        }

        // Category filter
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // Search — title, englishNote, chineseText, pinyin
        let query = searchText.trimmingCharacters(in: .whitespaces)
        if !query.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(query) ||
                $0.englishNote.localizedCaseInsensitiveContains(query) ||
                $0.chineseText.contains(query) ||
                ($0.pinyin?.localizedCaseInsensitiveContains(query) ?? false)
            }
        }

        return result
    }

    init() { loadCards() }

    private func loadCards() {
        guard
            let url = Bundle.main.url(forResource: "cards", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([Card].self, from: data)
        else { return }
        cards = decoded
    }
}
