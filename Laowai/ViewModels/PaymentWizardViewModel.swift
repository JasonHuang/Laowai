import Foundation

@MainActor
final class PaymentWizardViewModel: ObservableObject {
    @Published var providers: [PaymentProvider] = []
    @Published var selectedProvider: PaymentProvider?
    @Published var currentStepIndex: Int = 0
    @Published var completedSteps: Set<String> = []

    var currentStep: PaymentStep? {
        guard let provider = selectedProvider,
              currentStepIndex < provider.steps.count else { return nil }
        return provider.steps[currentStepIndex]
    }

    var isLastStep: Bool {
        guard let provider = selectedProvider else { return false }
        return currentStepIndex == provider.steps.count - 1
    }

    var progress: Double {
        guard let provider = selectedProvider, !provider.steps.isEmpty else { return 0 }
        return Double(currentStepIndex + 1) / Double(provider.steps.count)
    }

    init() {
        loadProviders()
    }

    func selectProvider(_ provider: PaymentProvider) {
        selectedProvider = provider
        currentStepIndex = 0
        completedSteps = []
    }

    func nextStep() {
        guard let provider = selectedProvider,
              currentStepIndex < provider.steps.count - 1 else { return }
        completedSteps.insert(provider.steps[currentStepIndex].id)
        currentStepIndex += 1
    }

    func previousStep() {
        guard currentStepIndex > 0 else { return }
        currentStepIndex -= 1
    }

    func reset() {
        selectedProvider = nil
        currentStepIndex = 0
        completedSteps = []
    }

    private func loadProviders() {
        guard
            let url = Bundle.main.url(forResource: "payment_steps", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([PaymentProvider].self, from: data)
        else { return }
        providers = decoded
    }
}
