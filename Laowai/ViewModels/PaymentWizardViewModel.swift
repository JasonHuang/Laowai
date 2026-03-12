import Foundation

private enum Keys {
    static let providerId   = "payment_providerId"
    static let stepIndex    = "payment_stepIndex"
    static let completed    = "payment_completedSteps"
}

@MainActor
final class PaymentWizardViewModel: ObservableObject {
    @Published var providers: [PaymentProvider] = []

    @Published var selectedProvider: PaymentProvider? {
        didSet { save() }
    }
    @Published var currentStepIndex: Int = 0 {
        didSet { save() }
    }
    @Published var completedSteps: Set<String> = [] {
        didSet { save() }
    }

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
        restore()
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

    // MARK: - Persistence

    private func save() {
        let ud = UserDefaults.standard
        ud.set(selectedProvider?.id, forKey: Keys.providerId)
        ud.set(currentStepIndex,     forKey: Keys.stepIndex)
        ud.set(Array(completedSteps), forKey: Keys.completed)
    }

    private func restore() {
        let ud = UserDefaults.standard
        let savedId    = ud.string(forKey: Keys.providerId)
        let savedIndex = ud.integer(forKey: Keys.stepIndex)
        let savedDone  = ud.stringArray(forKey: Keys.completed) ?? []

        if let id = savedId {
            selectedProvider = providers.first { $0.id == id }
        }
        if let provider = selectedProvider {
            currentStepIndex = min(savedIndex, provider.steps.count - 1)
        }
        completedSteps = Set(savedDone)
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
