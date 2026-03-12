import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0D0D1A").ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HomeHeaderSection()
                        PhaseFilterBar(currentPhase: $appState.currentPhase)
                        QuickActionsSection()
                        TipsSection(phase: appState.currentPhase)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Header

private struct HomeHeaderSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("老外")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(hex: "#E63946").opacity(0.8))
                        .tracking(2)
                    Text("Welcome to China")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color(hex: "#161630"))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.fill")
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            Text("Your travel assistant for navigating China")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 2)
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
}

// MARK: - Phase Filter

private struct PhaseFilterBar: View {
    @Binding var currentPhase: AppState.JourneyPhase

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AppState.JourneyPhase.allCases, id: \.self) { phase in
                    PhaseChip(phase: phase, isSelected: currentPhase == phase) {
                        currentPhase = phase
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 24)
    }
}

private struct PhaseChip: View {
    let phase: AppState.JourneyPhase
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(phase.rawValue)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.45))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "#E63946") : Color.white.opacity(0.06))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Quick Actions

private struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick access")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.4))
                .padding(.horizontal, 24)

            NavigationLink(destination: CardLibraryView()) {
                ActionCard(
                    label: "SHOW & POINT",
                    icon: "hand.point.up.left.fill",
                    accentHex: "#E63946",
                    title: "Point at Chinese text to communicate instantly",
                    subtitle: "Restaurant · Transport · Hotel · Emergency"
                )
            }
            .padding(.horizontal, 20)

            NavigationLink(destination: PaymentWizardView()) {
                ActionCard(
                    label: "PAYMENT SETUP",
                    icon: "creditcard.fill",
                    accentHex: "#F4A261",
                    title: "Set up Alipay or WeChat Pay with your foreign card",
                    subtitle: "Step-by-step guide · ~10 minutes"
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 28)
    }
}

private struct ActionCard: View {
    let label: String
    let icon: String
    let accentHex: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: accentHex))
                    Text(label)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color(hex: accentHex))
                        .tracking(1.5)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(20)
        .background(Color(hex: "#161630"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: accentHex).opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Tips

private struct TipsSection: View {
    let phase: AppState.JourneyPhase

    private var tips: [String] {
        switch phase {
        case .preDeparture:
            return [
                "Download Alipay and WeChat before you land — App Store access may be restricted.",
                "Screenshot your hotel address in Chinese characters.",
                "Notify your bank you're travelling to China to avoid card blocks."
            ]
        case .arrival:
            return [
                "Set up Alipay Tour Pass at the airport — free Wi-Fi is available.",
                "Download offline maps for your city.",
                "Exchange a small amount of cash (¥300–500) as backup."
            ]
        case .cityLife:
            return [
                "Most shops accept both Alipay and WeChat Pay QR codes.",
                "Use the Show & Point cards when language is a barrier.",
                "Didi (滴滴) is the main ride-hailing app — works with foreign cards."
            ]
        case .emergency:
            return [
                "Police: 110 · Ambulance: 120 · Fire: 119",
                "Your embassy can assist with lost passports.",
                "Use the emergency Show & Point cards to communicate quickly."
            ]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Before you go")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.4))
                .padding(.horizontal, 24)

            VStack(spacing: 10) {
                ForEach(tips.indices, id: \.self) { i in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color(hex: "#E63946").opacity(0.5))
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        Text(tips[i])
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                }
            }
            .padding(18)
            .background(Color(hex: "#161630"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 40)
    }
}
