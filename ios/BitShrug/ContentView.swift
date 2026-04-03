import SwiftUI

struct ContentView: View {
    @State private var viewModel = BitcoinViewModel()
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "bitcoinsign.circle.fill", value: .home) {
                HomeTab(viewModel: viewModel)
            }

            Tab("Portfolio", systemImage: "wallet.bifold", value: .portfolio) {
                PortfolioTab(viewModel: viewModel)
            }

            Tab("Learn", systemImage: "book.closed", value: .learn) {
                LearnTab(viewModel: viewModel)
            }

            Tab("Power Law", systemImage: "chart.line.uptrend.xyaxis", value: .powerLaw) {
                PowerLawTab(viewModel: viewModel)
            }

            Tab("Cycle", systemImage: "arrow.triangle.2.circlepath", value: .cycle) {
                CycleTab(viewModel: viewModel)
            }
        }
        .tint(.orange)
        .task {
            await viewModel.loadData()
        }
    }
}

enum AppTab: Hashable {
    case home
    case portfolio
    case learn
    case powerLaw
    case cycle
}
