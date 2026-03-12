import SwiftUI

private let bgColor = Color(hex: "#0D0D1A")
private let cardBackground = Color(hex: "#161630")
private let accentRed = Color(hex: "#E63946")

struct CardLibraryView: View {
    @StateObject private var viewModel = CardLibraryViewModel()
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
            .searchable(text: $viewModel.searchText, prompt: "Search cards")
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(item: $presentedCard) { card in
            ShowAndPointView(card: card)
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(title: "All", color: accentRed, isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }
                ForEach(Card.Category.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        color: Color(hex: category.color),
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = (viewModel.selectedCategory == category) ? nil : category
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var cardGrid: some View {
        ScrollView {
            if viewModel.filteredCards.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.filteredCards) { card in
                        CardCell(card: card)
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
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.3))
            Text("No cards found")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

private struct CardCell: View {
    let card: Card
    private var accentColor: Color { Color(hex: card.category.color) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: card.category.icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accentColor)
                    .frame(width: 20, height: 20)
                    .padding(6)
                    .background(accentColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Spacer()
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
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(accentColor.opacity(0.15), lineWidth: 1)
        )
    }
}

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

