import SwiftUI

struct ContentView: View {
    @State private var viewModel = BitcoinViewModel()
    @State private var selectedTab: AppTab = .home
    @State private var premium = PremiumManager.shared
    @State private var showConversionPaywall: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "bitcoinsign.circle.fill", value: .home) {
                HomeTab(viewModel: viewModel, selectedTab: $selectedTab)
            }

            Tab("Signals", systemImage: "waveform.path.ecg", value: .signals) {
                SignalsTab(viewModel: viewModel)
            }

            Tab("Analysis", systemImage: "chart.line.uptrend.xyaxis", value: .analysis) {
                AnalysisTab(viewModel: viewModel)
            }

            Tab("Tools", systemImage: "wrench.and.screwdriver", value: .portfolio) {
                PortfolioTab(viewModel: viewModel)
            }

            Tab("Learn", systemImage: "book.closed", value: .learn) {
                LearnTab(viewModel: viewModel)
            }
        }
        .tint(.orange)
        .sensoryFeedback(.selection, trigger: selectedTab)
        .task {
            await viewModel.loadData()
        }
        .onChange(of: viewModel.environmentScore) { _, newScore in
            guard newScore > 0, !premium.isPremium else { return }
            if !premium.hasSeenFirstAnalysis {
                premium.markFirstAnalysisSeen()
            } else if premium.shouldShowPaywallAfterAnalysis {
                premium.incrementAnalysisCount()
                if premium.analysisCount <= 3 {
                    Task {
                        try? await Task.sleep(for: .seconds(1.5))
                        showConversionPaywall = true
                    }
                }
            }
        }
        .sheet(isPresented: $showConversionPaywall) {
            PaywallView(
                triggerScore: viewModel.environmentScore,
                triggerLabel: viewModel.environmentScoreLabel
            )
            .interactiveDismissDisabled()
        }
    }
}

enum AppTab: Hashable {
    case home
    case signals
    case analysis
    case portfolio
    case learn
}
