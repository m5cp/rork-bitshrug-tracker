import SwiftUI

struct ContentView: View {
    @State private var viewModel = BitcoinViewModel()
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "bitcoinsign.circle.fill", value: .home) {
                HomeTab(viewModel: viewModel)
            }

            Tab("Signals", systemImage: "waveform.path.ecg", value: .signals) {
                SignalsTab(viewModel: viewModel)
            }

            Tab("Analysis", systemImage: "chart.line.uptrend.xyaxis", value: .analysis) {
                AnalysisTab(viewModel: viewModel)
            }

            Tab("Portfolio", systemImage: "wallet.bifold", value: .portfolio) {
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
    }
}

enum AppTab: Hashable {
    case home
    case signals
    case analysis
    case portfolio
    case learn
}
