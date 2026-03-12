import SwiftUI

private let bgColor       = Color(hex: "#0D0D1A")
private let cardBg        = Color(hex: "#161630")
private let accentRed     = Color(hex: "#E63946")
private let accentGold    = Color(hex: "#F4A261")

struct CardLibraryView: View {
    @StateObject private var viewModel = CardLibraryViewModel()
    @EnvironmentObject private var favourites: FavouritesStore
    @State private var presentedCard: Card?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                VStack(spacing: 0) {
                    categoryFilter
                    cardGrid
                }
            }
            .navigationTitle("Show & Point")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $viewModel.searchText, prompt: "Search in English, Chinese or pinyin…")
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(item: $presentedCard) { card in
            ShowAndPointView(card: card)
        }
    }

    // MARK: - Category filter bar

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Favourites chip
                CategoryChip(
                    title: "Favourites",
                    icon: "heart.fill",
                    color: accentGold,
                    isSelected: viewModel.showFavouritesOnly
                ) {
                    viewModel.showFavouritesOnly.toggle()
                    viewModel.selectedCategory = nil
                }

                // All chip
                CategoryChip(
                    title: "All",
                    color: accentRed,
                    isSelected: !viewModel.showFavouritesOnly && viewModel.selectedCategory == nil
                ) {
                    viewModel.showFavouritesOnly = false
                    viewModel.selectedCategory = nil
                }

                // Category chips
                ForEach(Card.Category.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        color: Color(hex: category.color),
                        isSelected: !viewModel.showFavouritesOnly && viewModel.selectedCategory == category
                    ) {
                        viewModel.showFavouritesOnly = false
                        viewModel.selectedCategory = (viewModel.selectedCategory == category) ? nil : category
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Card grid

    private var cardGrid: some View {
        let cards = viewModel.filteredCards(favourites: favourites)
        return ScrollView {
            if cards.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(cards) { card in
                        CardCell(card: card, isFavourite: favourites.isFavourite(card)) {
                            favourites.toggle(card)
                        }
                        .onTapGesture { presentedCard = card }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.showFavouritesOnly ? "heart.slash" : "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.25))
                .padding(.top, 80)
            Text(viewModel.showFavouritesOnly ? "No favourites yet" : "No cards found")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.45))
            if viewModel.showFavouritesOnly {
                Text("Tap the heart on any card to save it here")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Card Cell

private struct CardCell: View {
    let card: Card
    let isFavourite: Bool
    let onFavouriteTap: () -> Void

    private var accentColor: Color { Color(hex: card.category.color) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: card.category.icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accentColor)
                    .frame(width: 20, height: 20)
                    .padding(6)
                    .background(accentColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Spacer()

                Button(action: onFavouriteTap) {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isFavourite ? Color(hex: "#F4A261") : .white.opacity(0.3))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Text(card.chineseText)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(card.title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.55))
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isFavourite ? Color(hex: "#F4A261").opacity(0.35) : accentColor.opacity(0.12), lineWidth: 1)
        )
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let title: String
    var icon: String?
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon).font(.caption2.weight(.semibold))
                }
                Text(title).font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color.white.opacity(0.08))
            .foregroundStyle(isSelected ? .white : .white.opacity(0.65))
            .clipShape(Capsule())
        }
    }
}
