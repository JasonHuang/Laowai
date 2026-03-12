import SwiftUI

struct JourneyView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, cards, payment, translate
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            CardLibraryView()
                .tabItem {
                    Label("Cards", systemImage: "hand.point.up.left.fill")
                }
                .tag(Tab.cards)

            PaymentWizardView()
                .tabItem {
                    Label("Pay", systemImage: "creditcard.fill")
                }
                .tag(Tab.payment)

            TranslatePlaceholderView()
                .tabItem {
                    Label("Translate", systemImage: "camera.viewfinder")
                }
                .tag(Tab.translate)
        }
        .tint(Color(hex: "#E63946"))
        .preferredColorScheme(.dark)
    }
}

// MARK: - Translate placeholder

private struct TranslatePlaceholderView: View {
    var body: some View {
        ZStack {
            Color(hex: "#0D0D1A").ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 52))
                    .foregroundStyle(Color(hex: "#E63946").opacity(0.6))

                Text("Camera Translate")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("Point your camera at any Chinese text\nto get an instant translation")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("Coming soon")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(hex: "#E63946"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#E63946").opacity(0.12))
                    .clipShape(Capsule())
                    .padding(.top, 4)
            }
            .padding(.horizontal, 40)
        }
    }
}
