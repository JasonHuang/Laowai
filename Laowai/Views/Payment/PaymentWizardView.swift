import SwiftUI

private let vermillion = Color(hex: "#E63946")
private let gold = Color(hex: "#F4A261")
private let deepBg = Color(hex: "#0D0D1A")
private let cardBg = Color(hex: "#161630")
private let elevated = Color(hex: "#1C1433")

struct PaymentWizardView: View {
    @StateObject private var viewModel = PaymentWizardViewModel()

    var body: some View {
        ZStack {
            deepBg.ignoresSafeArea()

            if viewModel.selectedProvider == nil {
                ProviderSelectionView(viewModel: viewModel)
                    .transition(.opacity)
            } else {
                PaymentOverviewView(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedProvider?.id)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Provider Selection

private struct ProviderSelectionView: View {
    @ObservedObject var viewModel: PaymentWizardViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 10) {
                    Text("Set Up Mobile Payment")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Cash is rarely accepted in China. Choose an app to get started.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.55))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 24)
                .padding(.top, 64)
                .padding(.bottom, 32)

                // Provider cards
                VStack(spacing: 14) {
                    ForEach(viewModel.providers) { provider in
                        ProviderCard(provider: provider) {
                            viewModel.selectProvider(provider)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

private struct ProviderCard: View {
    let provider: PaymentProvider
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(provider.icon)
                    .font(.system(size: 36))
                    .frame(width: 60, height: 60)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 5) {
                    Text(provider.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(provider.tagline)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(18)
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

// MARK: - Payment Overview (Screen 09)

private struct PaymentOverviewView: View {
    @ObservedObject var viewModel: PaymentWizardViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            HStack {
                Button(action: { viewModel.reset() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.semibold))
                        Text("Payments")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
                }

                Spacer()

                if let provider = viewModel.selectedProvider {
                    Text(provider.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "#4CAF50"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#1A2E1F"))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)
            .padding(.bottom, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero
                    if let provider = viewModel.selectedProvider {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(provider.icon)
                                .font(.system(size: 36))
                                .padding(14)
                                .background(Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 16))

                            Text("Set up \(provider.name)")
                                .font(.title.bold())
                                .foregroundStyle(.white)

                            Text("Complete these steps to pay anywhere in China with your foreign card")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.55))
                                .lineSpacing(3)

                            HStack(spacing: 6) {
                                Circle().fill(gold).frame(width: 6, height: 6)
                                Text("~\(estimatedMinutes(provider)) minutes remaining")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(gold)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }

                    // Steps timeline
                    if let provider = viewModel.selectedProvider {
                        VStack(spacing: 0) {
                            ForEach(Array(provider.steps.enumerated()), id: \.element.id) { index, step in
                                StepTimelineRow(
                                    step: step,
                                    index: index,
                                    totalSteps: provider.steps.count,
                                    isCurrent: index == viewModel.currentStepIndex,
                                    isCompleted: viewModel.completedSteps.contains(step.id),
                                    onTapCurrent: { viewModel.currentStepIndex = index }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }

            // Bottom CTA
            VStack(spacing: 12) {
                // Progress bar
                VStack(spacing: 6) {
                    HStack {
                        Text("Progress")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.4))
                        Spacer()
                        Text("\(Int(viewModel.progress * 100))%")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(vermillion)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(vermillion)
                                .frame(width: geo.size.width * viewModel.progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }

                // CTA button
                if let provider = viewModel.selectedProvider,
                   let step = viewModel.currentStep {
                    NavigationLink {
                        PaymentStepDetailView(
                            step: step,
                            stepIndex: viewModel.currentStepIndex,
                            totalSteps: provider.steps.count,
                            isLastStep: viewModel.isLastStep,
                            onNext: { viewModel.nextStep() },
                            onPrevious: { viewModel.previousStep() }
                        )
                    } label: {
                        Text("Continue: \(step.title) →")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(vermillion)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 36)
            .background(deepBg)
        }
        .navigationBarHidden(true)
    }

    private func estimatedMinutes(_ provider: PaymentProvider) -> Int {
        max(1, provider.steps.count * 2 - viewModel.currentStepIndex * 2)
    }
}

private struct StepTimelineRow: View {
    let step: PaymentStep
    let index: Int
    let totalSteps: Int
    let isCurrent: Bool
    let isCompleted: Bool
    let onTapCurrent: () -> Void

    private var isPending: Bool { !isCurrent && !isCompleted }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Left: badge + connector line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(badgeFill)
                        .frame(width: isCurrent ? 36 : 32, height: isCurrent ? 36 : 32)
                        .shadow(color: isCurrent ? vermillion.opacity(0.5) : .clear, radius: 8)
                    Text(statusIcon)
                        .font(.system(size: isCurrent ? 17 : 15))
                }

                if index < totalSteps - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(isCompleted ? 0.2 : 0.08))
                        .frame(width: 2, height: isCurrent ? 90 : 36)
                }
            }

            // Right: content
            VStack(alignment: .leading, spacing: isCurrent ? 8 : 2) {
                Text("Step \(index + 1)\(isCurrent ? " · CURRENT" : "")")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isCurrent ? vermillion : .white.opacity(isCompleted ? 0.4 : 0.25))

                Text(step.title)
                    .font(isCurrent ? .callout.bold() : .callout)
                    .foregroundStyle(.white.opacity(isPending ? 0.3 : isCurrent ? 1 : 0.6))

                if isCurrent {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(step.description)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .background(elevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(vermillion.opacity(0.25), lineWidth: 1)
                    )
                }
            }
            .padding(.top, 6)
            .padding(.bottom, isCurrent ? 20 : 16)

            Spacer()
        }
    }

    private var statusIcon: String {
        if isCompleted { return "✅" }
        if isCurrent { return "🔄" }
        return "⏳"
    }

    private var badgeFill: Color {
        if isCompleted { return Color(hex: "#1A3B2E") }
        if isCurrent { return vermillion }
        return Color.white.opacity(0.06)
    }
}
