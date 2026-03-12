import SwiftUI

struct ShowAndPointView: View {
    let card: Card
    @Environment(\.dismiss) private var dismiss
    @State private var previousBrightness: CGFloat = 0.5

    var body: some View {
        ZStack(alignment: .top) {
            // Vermillion gradient background
            LinearGradient(
                colors: [Color(red: 0.902, green: 0.224, blue: 0.275),
                         Color(red: 0.753, green: 0.224, blue: 0.169)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Main content — vertically centred
            VStack(spacing: 20) {
                Spacer()

                Text(card.chineseText)
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.4)
                    .padding(.horizontal, 32)

                if let pinyin = card.pinyin {
                    Text(pinyin)
                        .font(.title2.weight(.medium))
                        .foregroundStyle(Color(red: 0.957, green: 0.635, blue: 0.380))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Rectangle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 48, height: 2)
                    .clipShape(Capsule())

                Text(card.englishNote)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                categoryBadge

                Spacer()
            }

            // Top bar: close + category
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.25))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 56)
            .padding(.horizontal, 20)

            // Bottom tip
            VStack {
                Spacer()
                brightnessBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            let screen = UIScreen.main
            previousBrightness = screen.brightness
            screen.brightness = 1.0
        }
        .onDisappear {
            UIScreen.main.brightness = previousBrightness
        }
        .statusBarHidden()
    }

    private var categoryBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(.white)
                .frame(width: 6, height: 6)
            Text(card.category.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.white.opacity(0.2))
        .clipShape(Capsule())
    }

    private var brightnessBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "sun.max.fill")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            Text("Screen brightness set to maximum")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
