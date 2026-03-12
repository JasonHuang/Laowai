import SwiftUI

// MARK: - Step Detail (Screen 10)

struct PaymentStepDetailView: View {
    let step: PaymentStep
    let stepIndex: Int
    let totalSteps: Int
    let isLastStep: Bool
    let onNext: () -> Void
    let onPrevious: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showingCard = false

    private let vermillion = Color(hex: "#E63946")
    private let deepBg = Color(hex: "#0D0D1A")
    private let cardBg = Color(hex: "#161630")

    var body: some View {
        ZStack {
            deepBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.white.opacity(0.06))
                        Rectangle()
                            .fill(vermillion)
                            .frame(width: geo.size.width * Double(stepIndex + 1) / Double(totalSteps))
                    }
                }
                .frame(height: 3)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Step tag + title
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Circle().fill(vermillion).frame(width: 6, height: 6)
                                Text("Step \(step.stepNumber) of \(totalSteps)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(vermillion)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(vermillion.opacity(0.12))
                            .clipShape(Capsule())

                            Text(step.title)
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(step.description)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.65))
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Tips
                        if !step.tips.isEmpty {
                            tipsSection
                        }

                        // Show & Point helper
                        if let card = step.showAndPointCard {
                            showAndPointButton(card: card)
                        }

                        // FAQ / common issues
                        faqSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }

                // Navigation buttons
                navButtons
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingCard) {
            if let card = step.showAndPointCard {
                InlineShowAndPointView(chineseText: card.chineseText, context: card.context)
            }
        }
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tips")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.5))

            VStack(spacing: 8) {
                ForEach(Array(step.tips.enumerated()), id: \.offset) { index, tip in
                    HStack(alignment: .top, spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#F4A261").opacity(0.15))
                                .frame(width: 22, height: 22)
                            Text("\(index + 1)")
                                .font(.caption2.bold())
                                .foregroundStyle(Color(hex: "#F4A261"))
                        }
                        Text(tip)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(Color(hex: "#F4A261").opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "#F4A261").opacity(0.15), lineWidth: 1)
            )
        }
    }

    private func showAndPointButton(card: PaymentStep.ShowAndPointContent) -> some View {
        Button(action: { showingCard = true }) {
            HStack(spacing: 12) {
                Text("📱")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Show this to staff →")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(hex: "#7BA4FF"))
                    Text(card.context)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(16)
            .background(Color(hex: "#1C1433"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "#7BA4FF").opacity(0.2), lineWidth: 1)
            )
        }
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Common questions")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.5))

            DisclosureGroup {
                Text("Try notifying your bank before your trip. Amex cards are not accepted. Use Visa or Mastercard.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
                    .lineSpacing(3)
                    .padding(.top, 8)
            } label: {
                Text("Card keeps getting rejected?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .padding(14)
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .tint(vermillion)

            DisclosureGroup {
                Text("You can register with your home country phone number — no Chinese SIM needed for signup.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
                    .lineSpacing(3)
                    .padding(.top, 8)
            } label: {
                Text("Don't have a Chinese phone number?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .padding(14)
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .tint(vermillion)
        }
    }

    private var navButtons: some View {
        HStack(spacing: 12) {
            if stepIndex > 0 {
                Button(action: {
                    onPrevious()
                    dismiss()
                }) {
                    Text("← Back")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                }
            }

            Button(action: {
                if isLastStep {
                    onNext()
                    dismiss()
                } else {
                    onNext()
                    dismiss()
                }
            }) {
                Text(isLastStep ? "All Done ✓" : "Next →")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(vermillion)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 36)
        .padding(.top, 12)
        .background(deepBg)
    }
}

// MARK: - Inline Show & Point (from payment step)

struct InlineShowAndPointView: View {
    let chineseText: String
    let context: String
    @Environment(\.dismiss) private var dismiss
    @State private var previousBrightness: CGFloat = UIScreen.main.brightness

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color(hex: "#E63946"), Color(hex: "#C0392B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Text(chineseText)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.4)
                    .padding(.horizontal, 32)

                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 2)
                    .clipShape(Capsule())

                Text(context)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }

            // Close button
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.25))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 56)
            .padding(.horizontal, 20)

            // Brightness bar
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(.white.opacity(0.8))
                    Text("Screen brightness set to maximum")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            previousBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1.0
        }
        .onDisappear {
            UIScreen.main.brightness = previousBrightness
        }
        .statusBarHidden()
    }
}
