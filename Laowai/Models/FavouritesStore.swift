import Foundation

@MainActor
final class FavouritesStore: ObservableObject {
    @Published private(set) var favouriteIDs: Set<String> = []

    private let key = "favouriteCardIDs"

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        favouriteIDs = Set(saved)
    }

    func toggle(_ card: Card) {
        if favouriteIDs.contains(card.id) {
            favouriteIDs.remove(card.id)
        } else {
            favouriteIDs.insert(card.id)
        }
        persist()
    }

    func isFavourite(_ card: Card) -> Bool {
        favouriteIDs.contains(card.id)
    }

    private func persist() {
        UserDefaults.standard.set(Array(favouriteIDs), forKey: key)
    }
}
