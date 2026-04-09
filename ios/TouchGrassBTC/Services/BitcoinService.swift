import Foundation

nonisolated class BitcoinService: Sendable {
    static let shared = BitcoinService()

    private init() {}

    // MARK: - Finnhub Price

    func fetchFinnhubPrice() async throws -> BitcoinPriceData {
        let apiKey = Config.EXPO_PUBLIC_FINNHUB_API_KEY
        let url = URL(string: "https://finnhub.io/api/v1/quote?symbol=BINANCE:BTCUSDT&token=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let quote = try JSONDecoder().decode(FinnhubQuoteResponse.self, from: data)

        let price = quote.c
        let change24h = quote.dp ?? 0

        return BitcoinPriceData(
            price: price,
            marketCap: 0,
            volume24h: 0,
            change24h: change24h
        )
    }

    // MARK: - CryptoCompare Market Data

    func fetchCryptoCompareMarketData() async throws -> (marketCap: Double, volume: Double, supply: Double, price: Double?, changePct24h: Double?) {
        let url = URL(string: "https://min-api.cryptocompare.com/data/top/mktcapfull?limit=1&tsym=USD")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(CryptoCompareTopResponse.self, from: data)

        guard let btc = response.Data?.first(where: { $0.CoinInfo?.Name == "BTC" }) ?? response.Data?.first,
              let usd = btc.RAW?.USD else {
            return (0, 0, 0, nil, nil)
        }

        return (
            marketCap: usd.MKTCAP ?? 0,
            volume: usd.TOTALVOLUME24HTO ?? usd.VOLUME24HOUR ?? 0,
            supply: usd.SUPPLY ?? 19_900_000,
            price: usd.PRICE,
            changePct24h: usd.CHANGEPCT24HOUR
        )
    }

    // MARK: - CryptoCompare Historical Prices

    func fetchHistoricalPrices(days: Int = 365) async throws -> [PricePoint] {
        let url = URL(string: "https://min-api.cryptocompare.com/data/v2/histoday?fsym=BTC&tsym=USD&limit=\(days)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(CryptoCompareHistoryResponse.self, from: data)

        guard let entries = response.Data?.Data else { return [] }

        return entries.map { entry in
            PricePoint(date: Date(timeIntervalSince1970: Double(entry.time)), price: entry.close)
        }
    }

    // MARK: - Fetch 200-Week MA from long history

    func fetch200WeekMA() async throws -> Double {
        let url = URL(string: "https://min-api.cryptocompare.com/data/v2/histoday?fsym=BTC&tsym=USD&limit=1400")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(CryptoCompareHistoryResponse.self, from: data)

        guard let entries = response.Data?.Data, entries.count >= 1000 else {
            print("[TouchGrassBTC] 200-Week MA: only \(response.Data?.Data?.count ?? 0) entries, using estimate")
            return estimate200WeekMA()
        }

        let weeklyPrices = stride(from: 0, to: entries.count, by: 7).map { i -> Double in
            let end = min(i + 7, entries.count)
            let week = entries[i..<end]
            return week.map(\.close).reduce(0, +) / Double(week.count)
        }

        let count = min(200, weeklyPrices.count)
        guard count > 0 else { return estimate200WeekMA() }
        let last200 = weeklyPrices.suffix(count)
        return last200.reduce(0, +) / Double(count)
    }

    // MARK: - Fear & Greed

    func fetchFearGreed() async throws -> Int {
        let url = URL(string: "https://api.alternative.me/fng/")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(FearGreedResponse.self, from: data)
        guard let entry = response.data.first, let value = Int(entry.value) else {
            return 50
        }
        return value
    }

    // MARK: - Blockchain.info Stats

    func fetchBlockchainStats() async throws -> (hashRate: Double, blockHeight: Int) {
        let url = URL(string: "https://api.blockchain.info/stats")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(BlockchainStatsResponse.self, from: data)
        return (
            hashRate: response.hashRate ?? 0,
            blockHeight: response.nBlocksTotal ?? 0
        )
    }

    // MARK: - CoinGecko Fallback Price

    func fetchCoinGeckoPrice() async throws -> BitcoinPriceData {
        let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(CoinGeckoSimpleResponse.self, from: data)
        return BitcoinPriceData(
            price: response.bitcoin.usd,
            marketCap: response.bitcoin.usdMarketCap ?? 0,
            volume24h: response.bitcoin.usd24hVol ?? 0,
            change24h: response.bitcoin.usd24hChange ?? 0
        )
    }

    // MARK: - Combined Price Fetch (Finnhub + CryptoCompare, CoinGecko fallback)

    func fetchPrice() async throws -> BitcoinPriceData {
        async let marketTask = fetchCryptoCompareMarketData()

        var priceSource: BitcoinPriceData?

        do {
            priceSource = try await fetchFinnhubPrice()
        } catch {
            print("[TouchGrassBTC] Finnhub failed: \(error.localizedDescription), trying CoinGecko...")
            do {
                let gecko = try await fetchCoinGeckoPrice()
                let market = try await marketTask
                return BitcoinPriceData(
                    price: gecko.price,
                    marketCap: market.marketCap > 0 ? market.marketCap : gecko.marketCap,
                    volume24h: market.volume > 0 ? market.volume : gecko.volume24h,
                    change24h: gecko.change24h
                )
            } catch {
                print("[TouchGrassBTC] CoinGecko also failed: \(error.localizedDescription)")
                let market = try await marketTask
                if let ccPrice = market.price, ccPrice > 0 {
                    return BitcoinPriceData(
                        price: ccPrice,
                        marketCap: market.marketCap,
                        volume24h: market.volume,
                        change24h: market.changePct24h ?? 0
                    )
                }
                throw error
            }
        }

        let finnhub = priceSource!
        let market = try await marketTask

        return BitcoinPriceData(
            price: finnhub.price,
            marketCap: market.marketCap,
            volume24h: market.volume,
            change24h: finnhub.change24h
        )
    }

    // MARK: - Moving Average Calculations

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

    func estimate200WeekMA() -> Double {
        let days = Double(daysSince(genesisDate()))
        let logDays = log10(days)
        let log200WMA = 5.82 * logDays - 17.97
        return pow(10, log200WMA)
    }

    func calculateMovingAverages(price: Double, historicalPrices: [PricePoint], actual200WMA: Double?) -> MovingAverageData {
        let ema200 = calculate200DayEMA(prices: historicalPrices) ?? price * 0.85
        let sma50 = calculate50DaySMA(prices: historicalPrices) ?? price * 0.95
        let sma200 = calculate200DaySMA(prices: historicalPrices) ?? price * 0.85
        let weekMA = actual200WMA ?? estimate200WeekMA()

        let priceVsEMA = ((price - ema200) / ema200) * 100
        let priceVs200WMA = ((price - weekMA) / weekMA) * 100

        return MovingAverageData(
            ema200Day: ema200,
            sma50Day: sma50,
            sma200Day: sma200,
            currentPrice: price,
            estimated200WMA: weekMA,
            priceVsEMA: priceVsEMA,
            priceVs200WMA: priceVs200WMA,
            isAboveEMA: price > ema200,
            isAbove200WMA: price > weekMA
        )
    }

    func calculateMVRVZScore(price: Double) -> Double {
        let daysSinceGenesis = daysSince(genesisDate())
        let logDays = log10(Double(daysSinceGenesis))
        let estimatedRealizedPrice = pow(10, 4.84 * logDays - 13.74)
        guard estimatedRealizedPrice > 0 else { return 0 }
        let mvrvRatio = price / estimatedRealizedPrice
        let zScore = mvrvRatio - 1.0
        return min(max(zScore, -1.0), 10.0)
    }

    func calculateStockToFlow(currentPrice: Double, currentSupply: Double) -> Double {
        let blocksPerDay: Double = 144
        let currentReward: Double = 3.125
        let annualFlow = blocksPerDay * currentReward * 365.25
        let supply = currentSupply > 0 ? currentSupply : 19_900_000
        let s2fRatio = supply / annualFlow
        let lnS2F = log(s2fRatio)
        let lnModelMarketCap = 3.3 * lnS2F + 14.6
        let modelMarketCap = exp(lnModelMarketCap)
        let modelPrice = modelMarketCap / supply
        guard modelPrice > 0 else { return 1.0 }
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
        if mvrvZScore < -0.5 {
            estimatedPercent = max(20, 45 + mvrvZScore * 20)
        } else if mvrvZScore < 0.5 {
            estimatedPercent = 55 + mvrvZScore * 30
        } else if mvrvZScore < 1.5 {
            estimatedPercent = 70 + (mvrvZScore - 0.5) * 15
        } else if mvrvZScore < 3.0 {
            estimatedPercent = 85 + (mvrvZScore - 1.5) * 6
        } else {
            estimatedPercent = min(99, 94 + (mvrvZScore - 3.0) * 1.5)
        }
        let clamped = min(max(estimatedPercent, 5), 99)
        return SupplyProfitData(estimatedPercent: clamped, zone: SupplyProfitZone(percent: clamped))
    }

    func calculatePowerLaw(price: Double) -> (position: PowerLawPosition, percentInCorridor: Double, supportPrice: Double, fairValuePrice: Double, resistancePrice: Double) {
        let days = Double(daysSince(genesisDate()))
        let logDays = log10(days)

        let logSupport = 5.82 * logDays - 17.47
        let logFairValue = 5.82 * logDays - 17.01
        let logResistance = 5.82 * logDays - 16.61
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
        let fairValuePrice = pow(10, logFairValue)
        let resistancePrice = pow(10, logResistance)

        return (position, min(max(positionInCorridor, 0), 1), supportPrice, fairValuePrice, resistancePrice)
    }

    func calculateRainbowBand(price: Double) -> RainbowBand {
        let days = Double(daysSince(genesisDate()))
        let logDays = log10(days)
        let logPrice = log10(price)

        let logFairValue = 5.82 * logDays - 17.01
        let bandWidth = 0.09

        let deviation = (logPrice - logFairValue) / bandWidth

        switch deviation {
        case ..<(-4.5): return .fireZone
        case ..<(-3.5): return .deepValue
        case ..<(-2.5): return .accumulation
        case ..<(-1.5): return .cheap
        case ..<(-0.5): return .neutral
        case ..<0.5: return .hold
        case ..<1.5: return .caution
        case ..<2.5: return .fomo
        case ..<3.5: return .bubble
        default: return .maxBubble
        }
    }

    func halvingInfo(currentPrice: Double = 0, historicalPrices: [PricePoint] = []) -> HalvingInfo {
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

        let phase: CyclePhase
        if currentPrice > 0 && !historicalPrices.isEmpty {
            let cycleHigh = historicalPrices.map(\.price).max() ?? currentPrice
            let drawdown = cycleHigh > 0 ? (1.0 - currentPrice / cycleHigh) * 100 : 0
            phase = CyclePhase(progress: clampedProgress, drawdownPercent: drawdown)
        } else {
            phase = CyclePhase(progress: clampedProgress)
        }

        return HalvingInfo(
            lastHalvingDate: lastHalving.date,
            nextHalvingDate: estimatedNextHalving,
            cycleProgress: clampedProgress,
            daysUntilNext: max(daysUntilNext, 0),
            daysSinceLast: max(daysSinceLast, 0),
            currentEra: lastHalving.era,
            currentPhase: phase,
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

    // MARK: - RSI Calculation

    func calculateRSI(prices: [PricePoint], period: Int = 14) -> Double? {
        guard prices.count > period else { return nil }
        let closingPrices = prices.map(\.price)
        var gains: [Double] = []
        var losses: [Double] = []

        for i in 1..<closingPrices.count {
            let change = closingPrices[i] - closingPrices[i - 1]
            gains.append(max(change, 0))
            losses.append(max(-change, 0))
        }

        guard gains.count >= period else { return nil }

        var avgGain = gains.prefix(period).reduce(0, +) / Double(period)
        var avgLoss = losses.prefix(period).reduce(0, +) / Double(period)

        for i in period..<gains.count {
            avgGain = (avgGain * Double(period - 1) + gains[i]) / Double(period)
            avgLoss = (avgLoss * Double(period - 1) + losses[i]) / Double(period)
        }

        guard avgLoss > 0 else { return 100 }
        let rs = avgGain / avgLoss
        return 100 - (100 / (1 + rs))
    }

    // MARK: - MACD Calculation

    func calculateMACD(prices: [PricePoint]) -> (macd: Double, signal: Double, histogram: Double)? {
        guard prices.count >= 35 else { return nil }
        let closingPrices = prices.map(\.price)

        guard let ema12 = calculateEMA(values: closingPrices, period: 12),
              let ema26 = calculateEMA(values: closingPrices, period: 26) else { return nil }

        let macdLine = ema12 - ema26

        var macdValues: [Double] = []
        let mult12 = 2.0 / 13.0
        let mult26 = 2.0 / 27.0
        var runEma12 = closingPrices.prefix(12).reduce(0, +) / 12.0
        var runEma26 = closingPrices.prefix(26).reduce(0, +) / 26.0

        for i in 26..<closingPrices.count {
            if i >= 12 {
                runEma12 = (closingPrices[i] - runEma12) * mult12 + runEma12
            }
            runEma26 = (closingPrices[i] - runEma26) * mult26 + runEma26
            macdValues.append(runEma12 - runEma26)
        }

        guard macdValues.count >= 9 else { return nil }
        var signalLine = macdValues.prefix(9).reduce(0, +) / 9.0
        let signalMult = 2.0 / 10.0
        for i in 9..<macdValues.count {
            signalLine = (macdValues[i] - signalLine) * signalMult + signalLine
        }

        return (macd: macdLine, signal: signalLine, histogram: macdLine - signalLine)
    }

    private func calculateEMA(values: [Double], period: Int) -> Double? {
        guard values.count >= period else { return nil }
        let multiplier = 2.0 / Double(period + 1)
        var ema = values.prefix(period).reduce(0, +) / Double(period)
        for i in period..<values.count {
            ema = (values[i] - ema) * multiplier + ema
        }
        return ema
    }
}
