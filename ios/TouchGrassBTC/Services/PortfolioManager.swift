import Foundation

@Observable
class PortfolioManager {
    static let shared = PortfolioManager()

    var btcHoldings: Double = 0 {
        didSet { save() }
    }

    var costBasis: Double = 0 {
        didSet { save() }
    }

    var hasCostBasis: Bool { costBasis > 0 }

    private init() {
        btcHoldings = UserDefaults.standard.double(forKey: "portfolio_btc")
        costBasis = UserDefaults.standard.double(forKey: "portfolio_cost_basis")
    }

    func currentValue(at price: Double) -> Double {
        btcHoldings * price
    }

    func totalCost() -> Double {
        btcHoldings * costBasis
    }

    func unrealizedPL(at price: Double) -> Double {
        currentValue(at: price) - totalCost()
    }

    func plPercent(at price: Double) -> Double {
        guard costBasis > 0 else { return 0 }
        return ((price - costBasis) / costBasis) * 100
    }

    func satoshis() -> Int {
        Int(btcHoldings * 100_000_000)
    }

    func percentOfMaxSupply() -> Double {
        (btcHoldings / 21_000_000) * 100
    }

    func clear() {
        btcHoldings = 0
        costBasis = 0
    }

    private func save() {
        UserDefaults.standard.set(btcHoldings, forKey: "portfolio_btc")
        UserDefaults.standard.set(costBasis, forKey: "portfolio_cost_basis")
    }
}
