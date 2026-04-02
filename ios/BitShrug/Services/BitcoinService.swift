import Foundation

nonisolated class BitcoinService: Sendable {
    static let shared = BitcoinService()

    private init() {}

    func fetchPrice() async throws -> BitcoinPriceData {
        let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(CoinGeckoResponse.self, from: data)
        return BitcoinPriceData(
            price: response.bitcoin.usd,
            marketCap: response.bitcoin.usdMarketCap,
            volume24h: response.bitcoin.usd24hVol,
            change24h: response.bitcoin.usd24hChange
        )
    }

    func fetchHistoricalPrices(days: Int = 365) async throws -> [PricePoint] {
        let url = URL(string: "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=\(days)&interval=daily")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MarketChartResponse.self, from: data)
        return response.prices.compactMap { entry in
            guard entry.count >= 2 else { return nil }
            let date = Date(timeIntervalSince1970: entry[0] / 1000)
            return PricePoint(date: date, price: entry[1])
        }
    }

    func fetchFearGreed() async throws -> Int {
        let url = URL(string: "https://api.alternative.me/fng/")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(FearGreedResponse.self, from: data)
        guard let entry = response.data.first, let value = Int(entry.value) else {
            return 50
        }
        return value
    }

    func calculate200DayEMA(prices: [PricePoint]) -> Double? {
        guard prices.count >= 200 else { return nil }
        let closingPrices = prices.map(\.price)
        let period = 200
        let multiplier = 2.0 / Double(period + 1)

        let sma = closingPrices.prefix(period).reduce(0, +) / Double(period)
        var ema = sma

        for i in period..<closingPrices.count {
            ema = (closingPrices[i] - ema) * multiplier + ema
        }
        return ema
    }

    func calculate50DaySMA(prices: [PricePoint]) -> Double? {
        guard prices.count >= 50 else { return nil }
        let last50 = prices.suffix(50).map(\.price)
        return last50.reduce(0, +) / Double(last50.count)
    }

    func calculate200DaySMA(prices: [PricePoint]) -> Double? {
        guard prices.count >= 200 else { return nil }
        let last200 = prices.suffix(200).map(\.price)
        return last200.reduce(0, +) / Double(last200.count)
    }

    func percentChange(prices: [PricePoint], days: Int) -> Double? {
        guard prices.count > days else { return nil }
        let current = prices.last?.price ?? 0
        let past = prices[prices.count - 1 - days].price
        guard past > 0 else { return nil }
        return ((current - past) / past) * 100
    }

    func yearHighLow(prices: [PricePoint]) -> (high: Double, low: Double)? {
        guard !prices.isEmpty else { return nil }
        let allPrices = prices.map(\.price)
        guard let high = allPrices.max(), let low = allPrices.min() else { return nil }
        return (high, low)
    }

    func calculate30DayVolatility(prices: [PricePoint]) -> Double? {
        guard prices.count >= 31 else { return nil }
        let last31 = prices.suffix(31).map(\.price)
        var dailyReturns: [Double] = []
        for i in 1..<last31.count {
            guard last31[i - 1] > 0 else { continue }
            let ret = (last31[i] - last31[i - 1]) / last31[i - 1]
            dailyReturns.append(ret)
        }
        guard !dailyReturns.isEmpty else { return nil }
        let mean = dailyReturns.reduce(0, +) / Double(dailyReturns.count)
        let variance = dailyReturns.map { ($0 - mean) * ($0 - mean) }.reduce(0, +) / Double(dailyReturns.count)
        return sqrt(variance) * 100
    }

    func estimate200WeekMA(currentPrice: Double) -> Double {
        let days = Double(daysSince(genesisDate()))
        let logDays = log10(days)
        let log200WMA = 5.71 * logDays - 17.51
        return pow(10, log200WMA)
    }

    func calculateMovingAverages(price: Double, historicalPrices: [PricePoint]) -> MovingAverageData {
        let ema200 = calculate200DayEMA(prices: historicalPrices) ?? price * 0.85
        let sma50 = calculate50DaySMA(prices: historicalPrices) ?? price * 0.95
        let sma200 = calculate200DaySMA(prices: historicalPrices) ?? price * 0.85
        let estimated200WMA = estimate200WeekMA(currentPrice: price)

        let priceVsEMA = ((price - ema200) / ema200) * 100
        let priceVs200WMA = ((price - estimated200WMA) / estimated200WMA) * 100

        return MovingAverageData(
            ema200Day: ema200,
            sma50Day: sma50,
            sma200Day: sma200,
            currentPrice: price,
            estimated200WMA: estimated200WMA,
            priceVsEMA: priceVsEMA,
            priceVs200WMA: priceVs200WMA,
            isAboveEMA: price > ema200,
            isAbove200WMA: price > estimated200WMA
        )
    }

    func calculateMVRVZScore(price: Double) -> Double {
        let daysSinceGenesis = daysSince(genesisDate())
        let logDays = log10(Double(daysSinceGenesis))
        let estimatedRealizedPrice = pow(10, 4.84 * logDays - 14.6)
        let zScore = (price - estimatedRealizedPrice) / estimatedRealizedPrice
        return min(max(zScore, -1.0), 10.0)
    }

    func calculateStockToFlow(currentPrice: Double) -> Double {
        let currentSupply: Double = 19_900_000
        let blocksPerDay: Double = 144
        let currentReward: Double = 3.125
        let annualFlow = blocksPerDay * currentReward * 365.25
        let s2fRatio = currentSupply / annualFlow
        let modelPrice = exp(3.21 * log(s2fRatio) - 1.02)
        return currentPrice / modelPrice
    }

    func calculatePuellMultiple(currentPrice: Double, historicalPrices: [PricePoint]) -> Double {
        let blocksPerDay: Double = 144
        let currentReward: Double = 3.125
        let dailyIssuanceBTC = blocksPerDay * currentReward
        let currentDailyRevenue = dailyIssuanceBTC * currentPrice

        let avgPrice: Double
        if historicalPrices.count >= 365 {
            avgPrice = historicalPrices.suffix(365).map(\.price).reduce(0, +) / 365.0
        } else if !historicalPrices.isEmpty {
            avgPrice = historicalPrices.map(\.price).reduce(0, +) / Double(historicalPrices.count)
        } else {
            avgPrice = currentPrice
        }

        let avgDailyRevenue = dailyIssuanceBTC * avgPrice
        guard avgDailyRevenue > 0 else { return 1.0 }
        return currentDailyRevenue / avgDailyRevenue
    }

    func calculateSupplyInProfit(price: Double, mvrvZScore: Double) -> SupplyProfitData {
        let estimatedPercent: Double
        if mvrvZScore < 0 {
            estimatedPercent = max(20, 50 + mvrvZScore * 15)
        } else if mvrvZScore < 2 {
            estimatedPercent = 50 + mvrvZScore * 15
        } else if mvrvZScore < 5 {
            estimatedPercent = 80 + (mvrvZScore - 2) * 5
        } else {
            estimatedPercent = min(99, 95 + (mvrvZScore - 5) * 0.5)
        }
        let clamped = min(max(estimatedPercent, 5), 99)
        return SupplyProfitData(estimatedPercent: clamped, zone: SupplyProfitZone(percent: clamped))
    }

    func calculatePowerLaw(price: Double) -> (position: PowerLawPosition, percentInCorridor: Double, supportPrice: Double, resistancePrice: Double) {
        let days = Double(daysSince(genesisDate()))
        let logDays = log10(days)

        let logSupport = 5.71 * logDays - 17.01
        let logResistance = 5.71 * logDays - 15.51
        let logPrice = log10(price)

        let corridorWidth = logResistance - logSupport
        let positionInCorridor = (logPrice - logSupport) / corridorWidth

        let position: PowerLawPosition
        if logPrice < logSupport {
            position = .belowSupport
        } else if logPrice > logResistance {
            position = .aboveResistance
        } else {
            position = .withinCorridor
        }

        let supportPrice = pow(10, logSupport)
        let resistancePrice = pow(10, logResistance)

        return (position, min(max(positionInCorridor, 0), 1), supportPrice, resistancePrice)
    }

    func calculateRainbowBand(price: Double) -> RainbowBand {
        let days = Double(daysSince(genesisDate()))
        let logDays = log10(days)
        let logPrice = log10(price)

        let logFairValue = 5.71 * logDays - 16.26
        let bandWidth = 0.15

        let deviation = (logPrice - logFairValue) / bandWidth

        switch deviation {
        case ..<(-4.5): return .fireZone
        case ..<(-3.5): return .buy
        case ..<(-2.5): return .accumulate
        case ..<(-1.5): return .cheap
        case ..<(-0.5): return .holdBuy
        case ..<0.5: return .hold
        case ..<1.5: return .holdSell
        case ..<2.5: return .fomo
        case ..<3.5: return .bubble
        default: return .maxBubble
        }
    }

    func halvingInfo() -> HalvingInfo {
        let halvings: [(date: Date, era: Int, reward: Double)] = [
            (date(2012, 11, 28), 2, 25),
            (date(2016, 7, 9), 3, 12.5),
            (date(2020, 5, 11), 4, 6.25),
            (date(2024, 4, 20), 5, 3.125),
        ]

        let estimatedNextHalving = date(2028, 4, 15)
        let lastHalving = halvings.last!

        let now = Date()
        let totalCycleDays = Calendar.current.dateComponents([.day], from: lastHalving.date, to: estimatedNextHalving).day ?? 1461
        let daysSinceLast = Calendar.current.dateComponents([.day], from: lastHalving.date, to: now).day ?? 0
        let daysUntilNext = Calendar.current.dateComponents([.day], from: now, to: estimatedNextHalving).day ?? 0
        let progress = Double(daysSinceLast) / Double(totalCycleDays)
        let clampedProgress = min(max(progress, 0), 1)

        return HalvingInfo(
            lastHalvingDate: lastHalving.date,
            nextHalvingDate: estimatedNextHalving,
            cycleProgress: clampedProgress,
            daysUntilNext: max(daysUntilNext, 0),
            daysSinceLast: max(daysSinceLast, 0),
            currentEra: lastHalving.era,
            currentPhase: CyclePhase(progress: clampedProgress),
            blockReward: lastHalving.reward
        )
    }

    func genesisDate() -> Date {
        date(2009, 1, 3)
    }

    func daysSince(_ startDate: Date) -> Int {
        Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 1
    }

    func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}
