import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("selectedCity") private var selectedCity = ""
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Color(red: 0.051, green: 0.051, blue: 0.102).ignoresSafeArea()

            TabView(selection: $currentPage) {
                HeroPage(onNext: { withAnimation { currentPage = 1 } })
                    .tag(0)

                ValuePropsPage(onNext: { withAnimation { currentPage = 2 } })
                    .tag(1)

                CitySelectorPage(
                    selectedCity: $selectedCity,
                    onFinish: { hasOnboarded = true }
                )

                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Page 01: Hero

private struct HeroPage: View {
    let onNext: () -> Void

    var body: some View {
        ZStack {
            // Background "老外" watermark
            Text("老外")
                .font(.system(size: 195, weight: .black))
                .foregroundStyle(.white.opacity(0.05))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .offset(x: -10, y: 40)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                // Brand label
                HStack(spacing: 6) {
                    Text("LAOWAI")
                        .font(.caption2.weight(.bold))
                        .tracking(2)
                    Text("老外")
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(Color(red: 0.902, green: 0.224, blue: 0.275))
                .padding(.bottom, 14)

                // Headline
                Text("China,\nunlocked.")
                    .font(.system(size: 46, weight: .black))
                    .foregroundStyle(.white)
                    .lineSpacing(2)
                    .padding(.bottom, 16)

                // Subtitle
                Text("Your no-BS guide to surviving and thriving in China.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineSpacing(4)
                    .padding(.bottom, 48)

                // CTA
                Button(action: onNext) {
                    Text("Let's go →")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 0.902, green: 0.224, blue: 0.275))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.bottom, 16)

                // Sign in ghost
                Button(action: {}) {
                    Text("Already have the app? Sign in")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.35))
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 52)
            }
            .padding(.horizontal, 28)
        }
    }
}

// MARK: - Page 02: Value Props

private struct ValuePropsPage: View {
    let onNext: () -> Void

    private let features: [(icon: String, color: Color, text: String)] = [
        ("creditcard.fill",   Color(red: 0.361, green: 0.533, blue: 0.965), "Set up WeChat Pay in 5 minutes"),
        ("camera.fill",       Color(red: 0.957, green: 0.635, blue: 0.380), "Point at any menu. Instant translation."),
        ("wifi.slash",        Color(red: 0.298, green: 0.686, blue: 0.314), "Works offline. Always."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Step indicator
            Text("02 / 03")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.35))
                .padding(.top, 72)
                .padding(.bottom, 24)

            // Headline
            Text("What's inside.")
                .font(.system(size: 38, weight: .black))
                .foregroundStyle(.white)
                .padding(.bottom, 36)

            // Feature rows
            VStack(spacing: 12) {
                ForEach(features.indices, id: \.self) { i in
                    FeatureRow(
                        icon: features[i].icon,
                        color: features[i].color,
                        text: features[i].text
                    )
                }
            }

            Spacer()

            // Page dots
            HStack(spacing: 8) {
                Spacer()
                ForEach(0..<3) { i in
                    Circle()
                        .fill(i == 1
                              ? Color(red: 0.902, green: 0.224, blue: 0.275)
                              : Color.white.opacity(0.25))
                        .frame(width: 7, height: 7)
                }
                Spacer()
            }
            .padding(.bottom, 48)
        }
        .padding(.horizontal, 28)
        .contentShape(Rectangle())
        .onTapGesture(count: 1) {}          // absorb taps so TabView still swipes
    }
}

private struct FeatureRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
            }
            Text(text)
                .font(.body.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Page 03: City Selector

private struct CitySelectorPage: View {
    @Binding var selectedCity: String
    let onFinish: () -> Void

    private let cities: [(name: String, chinese: String, gradient: [Color])] = [
        ("Beijing",    "北京", [Color(red: 0.10, green: 0.20, blue: 0.45), Color(red: 0.05, green: 0.10, blue: 0.25)]),
        ("Shanghai",   "上海", [Color(red: 0.25, green: 0.10, blue: 0.45), Color(red: 0.12, green: 0.05, blue: 0.25)]),
        ("Chengdu",    "成都", [Color(red: 0.08, green: 0.28, blue: 0.18), Color(red: 0.04, green: 0.14, blue: 0.10)]),
        ("Xi'an",      "西安", [Color(red: 0.35, green: 0.20, blue: 0.05), Color(red: 0.20, green: 0.10, blue: 0.03)]),
        ("Guangzhou",  "广州", [Color(red: 0.06, green: 0.25, blue: 0.28), Color(red: 0.03, green: 0.14, blue: 0.16)]),
    ]

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Step indicator
            Text("03 / 03")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.35))
                .padding(.top, 72)
                .padding(.bottom, 24)

            // Headline
            Text("Where are you\nheaded?")
                .font(.system(size: 38, weight: .black))
                .foregroundStyle(.white)
                .lineSpacing(2)
                .padding(.bottom, 8)

            Text("Tap a city to download its offline pack.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.45))
                .padding(.bottom, 24)

            // 2-column grid for first 4 cities
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(cities.prefix(4).indices, id: \.self) { i in
                    CityTile(
                        city: cities[i],
                        isSelected: selectedCity == cities[i].name,
                        action: { selectedCity = cities[i].name }
                    )
                }
            }
            .padding(.bottom, 12)

            // Full-width last city
            CityTile(
                city: cities[4],
                isSelected: selectedCity == cities[4].name,
                isWide: true,
                action: { selectedCity = cities[4].name }
            )

            Spacer()

            // CTA
            Button(action: onFinish) {
                Text("I'm ready →")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(red: 0.902, green: 0.224, blue: 0.275))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.bottom, 52)
        }
        .padding(.horizontal, 28)
    }
}

private struct CityTile: View {
    let city: (name: String, chinese: String, gradient: [Color])
    let isSelected: Bool
    var isWide: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: city.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(city.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(city.chinese)
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.902, green: 0.224, blue: 0.275))
                }
                .padding(14)
            }
            .frame(height: isWide ? 64 : 100)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected
                            ? Color(red: 0.902, green: 0.224, blue: 0.275)
                            : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 0.97 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }
}
