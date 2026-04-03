import SwiftUI

@Observable
class BitcoinViewModel {
    var price: Double = 0
    var marketCap: Double = 0
    var volume24h: Double = 0
    var change24h: Double = 0
    var fearGreedValue: Int = 50
    var mvrvZScore: Double = 0
    var stockToFlowRatio: Double = 1.0
    var powerLawPosition: PowerLawPosition = .withinCorridor
    var powerLawPercent: Double = 0.5
    var powerLawSupport: Double = 0
    var powerLawResistance: Double = 0
    var halvingInfo: HalvingInfo?
    var rainbowBand: RainbowBand = .hold
    var puellMultiple: Double = 1.0
    var movingAverages: MovingAverageData?
    var supplyInProfit: SupplyProfitData?
    var historicalPrices: [PricePoint] = []
    var currentSupply: Double = 19_900_000
    var actual200WMA: Double?
    var hashRate: Double = 0
    var blockHeight: Int = 0
    var isLoading: Bool = false
    var lastUpdated: Date?
    var errorMessage: String?
    var previousSignalStrength: Int?
    private var previousComponentStatuses: [String: String]?

    private let service = BitcoinService.shared

    var fearGreedLevel: FearGreedLevel {
        FearGreedLevel(value: fearGreedValue)
    }

    var mvrvZone: MVRVZone {
        MVRVZone(score: mvrvZScore)
    }

    var puellZone: PuellZone {
        PuellZone(multiple: puellMultiple)
    }

    var compositeSignal: CompositeSignal {
        let score = environmentScore
        if score >= 70 {
            return CompositeSignal(label: "Macro Bullish", color: .green)
        } else if score >= 50 {
            return CompositeSignal(label: "Leaning Bullish", color: Color(red: 0.4, green: 0.8, blue: 0.3))
        } else if score >= 35 {
            return CompositeSignal(label: "Mixed / Neutral", color: .orange)
        } else {
            return CompositeSignal(label: "Macro Bearish", color: .red)
        }
    }

    var formattedPrice: String {
        "$\(Int(price).formatted(.number))"
    }

    var formattedMarketCap: String {
        formatLargeNumber(marketCap)
    }

    var formattedVolume: String {
        formatLargeNumber(volume24h)
    }

    var changeColor: Color {
        change24h >= 0 ? .orange : .secondary
    }

    var formattedChange: String {
        let sign = change24h >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", change24h))%"
    }

    var change7d: Double? { service.percentChange(prices: historicalPrices, days: 7) }
    var change30d: Double? { service.percentChange(prices: historicalPrices, days: 30) }
    var yearHighLow: (high: Double, low: Double)? { service.yearHighLow(prices: historicalPrices) }
    var volatility30d: Double? { service.calculate30DayVolatility(prices: historicalPrices) }

    var environmentStatus: EnvironmentStatus {
        let score = environmentScore
        if score >= 75 { return .strong }
        if score >= 55 { return .moderate }
        if score >= 35 { return .weak }
        return .highRisk
    }

    // MARK: - Trend (0–30)
    var trendScore: Int {
        guard let ma = movingAverages else { return 15 }
        let aboveMA50 = price > ma.sma50Day
        let aboveMA200 = price > ma.sma200Day
        let ma50AboveMA200 = ma.sma50Day > ma.sma200Day

        if aboveMA50 && ma50AboveMA200 { return 30 }
        if aboveMA200 && !ma50AboveMA200 { return 20 }
        if !aboveMA200 && !aboveMA50 && !ma50AboveMA200 { return 5 }
        if !aboveMA200 { return 10 }
        return 15
    }

    // MARK: - Momentum (0–25)
    var momentumScore: Int {
        let c7 = change7d ?? 0
        let c30 = change30d ?? 0

        if c7 > 5 && c30 > 10 { return 25 }
        if c7 >= 0 && c7 <= 5 && c30 >= 0 && c30 <= 10 { return 18 }
        if c7 < 0 && c7 >= -7 { return 10 }
        if c7 < -7 && c30 < -10 { return 5 }
        return 12
    }

    // MARK: - Positioning (0–25)
    var positioningScore: Int {
        guard let ma = movingAverages, let hl = yearHighLow else {
            return 12
        }
        let aboveMA200 = price > ma.sma200Day
        let highThreshold = hl.high * 0.85
        let range = hl.high - hl.low
        let positionInRange = range > 0 ? (price - hl.low) / range : 0.5

        if aboveMA200 && price < highThreshold { return 25 }
        if aboveMA200 && price >= highThreshold && positionInRange < 0.92 { return 18 }
        if price >= hl.high * 0.95 || (aboveMA200 && positionInRange > 0.92) { return 10 }
        if !aboveMA200 {
            let c7 = change7d ?? 0
            if c7 < -3 { return 5 }
            return 10
        }
        return 12
    }

    // MARK: - Volatility / Risk (0–20)
    var volatilityScore: Int {
        guard let vol = volatility30d else { return 10 }
        if vol < 1.5 { return 20 }
        if vol < 2.5 { return 14 }
        if vol < 4.0 { return 8 }
        return 4
    }

    var environmentScore: Int {
        let total = trendScore + momentumScore + positioningScore + volatilityScore
        return max(0, min(100, total))
    }

    var signalStrength: Int { environmentScore }

    var environmentScoreLabel: String {
        let s = environmentScore
        if s >= 75 { return "Strong" }
        if s >= 55 { return "Moderate" }
        if s >= 35 { return "Weak" }
        return "High Risk"
    }

    var signalStrengthLabel: String { environmentScoreLabel }

    var homeStatusLabel: String {
        let s = environmentScore
        if s >= 75 { return "Bullish" }
        if s >= 55 { return "Neutral" }
        if s >= 35 { return "Risk Elevated" }
        return "High Risk"
    }

    var cyclePhaseSummary: String {
        halvingInfo?.currentPhase.label ?? "Loading"
    }

    var trendSummary: String {
        guard let ma = movingAverages else { return "Loading" }
        if ma.isAboveEMA && ma.isAbove200WMA { return "Uptrend" }
        if !ma.isAboveEMA && !ma.isAbove200WMA { return "Downtrend" }
        return "Mixed"
    }

    var macroSummary: String {
        let score = signalStrength
        if score >= 65 { return "Favorable" }
        if score <= 35 { return "Cautious" }
        return "Neutral"
    }

    var trendStatus: DriverStatus {
        let s = trendScore
        if s >= 25 { return .bullish }
        if s >= 15 { return .neutral }
        return .bearish
    }

    var trendExplanation: String {
        switch trendStatus {
        case .bullish: return "Price remains above its long-term trend."
        case .neutral: return "Trend direction is mixed across timeframes."
        case .bearish: return "Price has fallen below key long-term averages."
        }
    }

    var momentumStatus: DriverStatus {
        let s = momentumScore
        if s >= 20 { return .bullish }
        if s >= 12 { return .neutral }
        return .bearish
    }

    var momentumExplanation: String {
        switch momentumStatus {
        case .bullish: return "Momentum is strong and accelerating."
        case .neutral: return "Momentum is stable but not decisive."
        case .bearish: return "Momentum is fading with recent weakness."
        }
    }

    var positioningStatus: DriverStatus {
        let s = positioningScore
        if s >= 20 { return .bullish }
        if s >= 12 { return .neutral }
        return .bearish
    }

    var positioningExplanation: String {
        switch positioningStatus {
        case .bullish: return "Positioning is attractive relative to long-term context."
        case .neutral: return "Positioning is within the expected range."
        case .bearish: return "Positioning is less attractive than earlier in the cycle."
        }
    }

    var volatilityStatus: DriverStatus {
        let s = volatilityScore
        if s >= 16 { return .bullish }
        if s >= 10 { return .neutral }
        return .bearish
    }

    var volatilityExplanation: String {
        switch volatilityStatus {
        case .bullish: return "Volatility is controlled and manageable."
        case .neutral: return "Volatility is elevated but manageable."
        case .bearish: return "Volatility is high with large price swings."
        }
    }

    var marketContext: String {
        let phase = halvingInfo?.currentPhase ?? .accumulation
        let phaseName = phase.label.lowercased()
        let envLabel = environmentScoreLabel.lowercased()
        let score = environmentScore

        let positioningFragment: String = {
            switch powerLawPosition {
            case .belowSupport:
                return "positioning below long-term trend support"
            case .aboveResistance:
                return "positioning above long-term trend levels"
            case .withinCorridor:
                if powerLawPercent < 0.35 {
                    return "positioning near long-term support"
                } else if powerLawPercent > 0.65 {
                    return "positioning toward the upper end of the long-term corridor"
                } else {
                    return "positioning within the expected long-term range"
                }
            }
        }()

        let envFragment: String = {
            switch environmentStatus {
            case .strong:
                return "The environment reflects favorable conditions."
            case .moderate:
                if momentumStatus == .bullish {
                    return "The environment is moderate with improving momentum."
                } else if volatilityStatus == .bearish {
                    return "The environment is moderate, though volatility remains elevated."
                }
                return "The environment reflects mixed conditions."
            case .weak:
                if trendStatus == .bearish {
                    return "The environment reflects weakening conditions as the trend fades."
                }
                return "The environment reflects increased caution."
            case .highRisk:
                return "The environment reflects elevated risk."
            }
        }()

        let cycleFragment: String = {
            switch phase {
            case .accumulation, .recovery:
                return "Bitcoin remains early in the cycle"
            case .earlyBull:
                return "Bitcoin is in the early stages of a potential expansion"
            case .acceleration:
                return "Bitcoin is in an acceleration phase"
            case .euphoria:
                return "Bitcoin is in the late stages of the cycle"
            case .distribution:
                return "Bitcoin is currently in the distribution phase"
            case .earlyBear:
                return "Bitcoin has entered a cooling period"
            case .capitulation:
                return "Bitcoin is in a historically stressed phase"
            }
        }()

        return "\(cycleFragment), with \(positioningFragment). \(envFragment)"
    }

    var environmentMessage: String {
        switch environmentStatus {
        case .strong:
            return "Conditions suggest a favorable environment."
        case .moderate:
            return "Conditions are mixed with no strong bias."
        case .weak:
            return "Conditions are weakening — stay aware."
        case .highRisk:
            return "Conditions suggest elevated risk."
        }
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        halvingInfo = service.halvingInfo()

        async let priceTask = service.fetchPrice()
        async let fngTask = service.fetchFearGreed()
        async let historyTask = service.fetchHistoricalPrices(days: 365)
        async let weekMATask = service.fetch200WeekMA()
        async let blockchainTask = service.fetchBlockchainStats()

        do {
            let priceData = try await priceTask
            price = priceData.price
            marketCap = priceData.marketCap
            volume24h = priceData.volume24h
            change24h = priceData.change24h
            print("[BitShrug] Price: $\(Int(price)), Change: \(String(format: "%.1f", change24h))%")
        } catch {
            print("[BitShrug] Price fetch failed: \(error.localizedDescription)")
            errorMessage = "Failed to load price data"
        }

        do {
            fearGreedValue = try await fngTask
            print("[BitShrug] Fear & Greed: \(fearGreedValue)")
        } catch {
            print("[BitShrug] Fear & Greed failed: \(error.localizedDescription)")
        }

        do {
            actual200WMA = try await weekMATask
            print("[BitShrug] 200-Week MA: $\(Int(actual200WMA ?? 0))")
        } catch {
            print("[BitShrug] 200-Week MA failed: \(error.localizedDescription)")
        }

        do {
            let stats = try await blockchainTask
            hashRate = stats.hashRate
            blockHeight = stats.blockHeight
        } catch {
            print("[BitShrug] Blockchain stats failed: \(error.localizedDescription)")
        }

        do {
            let history = try await historyTask
            historicalPrices = history
            print("[BitShrug] Historical prices: \(history.count) days")
        } catch {
            print("[BitShrug] Historical prices failed: \(error.localizedDescription)")
        }

        if price > 0 {
            halvingInfo = service.halvingInfo(currentPrice: price, historicalPrices: historicalPrices)

            mvrvZScore = service.calculateMVRVZScore(price: price)
            stockToFlowRatio = service.calculateStockToFlow(currentPrice: price, currentSupply: currentSupply)

            let powerLaw = service.calculatePowerLaw(price: price)
            powerLawPosition = powerLaw.position
            powerLawPercent = powerLaw.percentInCorridor
            powerLawSupport = powerLaw.supportPrice
            powerLawResistance = powerLaw.resistancePrice

            rainbowBand = service.calculateRainbowBand(price: price)

            if !historicalPrices.isEmpty {
                movingAverages = service.calculateMovingAverages(price: price, historicalPrices: historicalPrices, actual200WMA: actual200WMA)
                puellMultiple = service.calculatePuellMultiple(currentPrice: price, historicalPrices: historicalPrices)
            }
            supplyInProfit = service.calculateSupplyInProfit(price: price, mvrvZScore: mvrvZScore)

            print("[BitShrug] MVRV Z-Score: \(String(format: "%.2f", mvrvZScore))")
            print("[BitShrug] S2F Ratio: \(String(format: "%.2f", stockToFlowRatio))")
            print("[BitShrug] Puell: \(String(format: "%.2f", puellMultiple))")
            if let sp = supplyInProfit {
                print("[BitShrug] Supply in Profit: \(String(format: "%.0f", sp.estimatedPercent))%")
            }
        }

        previousSignalStrength = loadPreviousSignalStrength()
        previousComponentStatuses = loadPreviousComponentStatuses()
        saveTodaySignalStrength(signalStrength)
        saveTodayComponentStatuses()

        NotificationManager.shared.evaluateAndNotify(
            environmentScore: environmentScore,
            environment: environmentStatus.label,
            momentum: momentumStatus.label,
            trend: trendStatus.label,
            volatility: volatilityStatus.label,
            positioning: positioningStatus.label
        )

        ScoreHistoryManager.shared.record(score: environmentScore, price: price)
        ScoreHistoryManager.shared.writeToSharedDefaults(
            score: environmentScore,
            price: price,
            label: environmentScoreLabel,
            change24h: change24h
        )

        PriceAlertManager.shared.evaluate(
            price: price,
            support: powerLawSupport,
            resistance: powerLawResistance
        )

        SpotlightManager.shared.indexContent(
            score: environmentScore,
            label: environmentScoreLabel,
            price: formattedPrice
        )

        lastUpdated = Date()
        isLoading = false
    }

    var dailyDelta: Int? {
        guard let prev = previousSignalStrength else { return nil }
        return environmentScore - prev
    }

    var dailyChangeClassification: String {
        guard let delta = dailyDelta else { return "Stable" }
        if delta >= 5 { return "Improving" }
        if delta <= -5 { return "Weakening" }
        return "Stable"
    }

    var changedComponents: [(name: String, from: String, to: String)] {
        guard let prev = previousComponentStatuses else { return [] }
        var changes: [(String, String, String)] = []
        let current: [(String, String)] = [
            ("Trend", trendStatus.label),
            ("Momentum", momentumStatus.label),
            ("Positioning", positioningStatus.label),
            ("Volatility", volatilityStatus.label)
        ]
        for (name, status) in current {
            if let old = prev[name], old != status {
                changes.append((name, old, status))
            }
        }
        return changes
    }

    var dailyInsight: String {
        guard let prev = previousSignalStrength else {
            return "Gathering baseline data for daily updates."
        }
        let delta = environmentScore - prev
        return buildDailyNarrative(delta: delta)
    }

    var insightHeadline: String {
        let m = momentumStatus
        let t = trendStatus
        let v = volatilityStatus
        let p = positioningStatus
        let score = environmentScore
        let changes = changedComponents
        let classification = dailyChangeClassification

        if !changes.isEmpty {
            let first = changes[0]
            if classification == "Improving" {
                if first.name == "Momentum" && first.to == "Bullish" {
                    return "Conditions are improving as momentum strengthens and trend remains supportive."
                }
                if first.name == "Trend" && first.to == "Bullish" {
                    return "Conditions are improving as the trend aligns positively."
                }
                return "Conditions are improving as \(first.name.lowercased()) shifts toward \(first.to.lowercased())."
            }
            if classification == "Weakening" {
                if first.name == "Volatility" && first.to == "Bearish" {
                    return "Conditions are weakening as volatility increases and momentum softens."
                }
                if first.name == "Momentum" && first.to == "Bearish" {
                    return "Risk is increasing as momentum fades."
                }
                return "Conditions are weakening as \(first.name.lowercased()) shifts toward \(first.to.lowercased())."
            }
        }

        if t == .bullish && m == .bullish && p == .bullish {
            return "Conditions are strong, but remain aware of cycle positioning."
        }
        if t == .bullish && m == .bullish {
            return "The environment is constructive, though not fully decisive."
        }
        if t == .bearish && m == .bearish && v == .bearish {
            return "Conditions are fragile, with elevated downside risk."
        }
        if t == .bearish && m == .bearish {
            return "Risk is increasing as conditions weaken."
        }
        if m == .bullish && t == .neutral {
            return "Momentum is improving, but the broader environment remains mixed."
        }
        if t == .neutral && m == .neutral {
            return "The environment remains stable with no significant changes in conditions."
        }
        if p == .bearish && score < 55 {
            return "Positioning is becoming extended relative to long-term context."
        }
        if t == .bearish && m == .neutral {
            return "Long-term trend support is becoming less reliable."
        }
        if score >= 75 {
            return "Conditions are favorable, but remain aware of cycle positioning."
        }
        if score <= 34 {
            return "Risk is elevated \u{2014} positioning and patience matter here."
        }
        if score <= 54 {
            return "Conditions are weakening \u{2014} stay grounded."
        }
        return "The environment remains stable with no significant changes in conditions."
    }

    var insightExpansion: String {
        let m = momentumStatus
        let t = trendStatus
        let v = volatilityStatus

        if t == .bullish && m == .bullish && positioningStatus == .bullish {
            return "All factors are aligned, which has historically supported continued strength. However, when everything looks favorable, conditions can shift quickly."
        }
        if t == .bullish && m == .bullish {
            return "Improving momentum with a confirmed trend is a positive environment, but not all factors have caught up. Long-term positioning remains key."
        }
        if t == .bearish && m == .bearish && v == .bearish {
            return "When all factors point to risk, historically this has been a period of caution. Conditions may take time to recover."
        }
        if t == .bearish && m == .bearish {
            return "Weakening momentum combined with a bearish trend increases uncertainty. Long-term awareness helps navigate these periods."
        }
        if m == .bullish && t == .neutral {
            return "Improving momentum can support continued strength, but mixed conditions mean the environment is not fully confirmed."
        }
        if environmentScore >= 75 {
            return "Favorable conditions don\u{2019}t guarantee outcomes. Staying grounded and watching for early signs of change helps maintain perspective."
        }
        if environmentScore <= 34 {
            return "Elevated risk periods have historically preceded recovery, but timing is unpredictable. Long-term positioning matters most here."
        }
        if environmentScore <= 54 {
            return "Weakening conditions increase uncertainty. Patience and long-term positioning matter more than reaction."
        }
        return "When conditions are mixed, there is no clear edge in either direction. Patience and positioning matter more than action."
    }

    var signalChangeText: String? {
        guard let prev = previousSignalStrength else { return nil }
        let current = environmentScore
        if current == prev { return "Environment Score unchanged at \(current)" }
        let arrow = current > prev ? "↑" : "↓"
        return "Environment Score \(arrow) from \(prev) to \(current)"
    }

    var weeklyDirection: String {
        guard let startScore = loadWeekStartScore() else { return "Unchanged" }
        let current = environmentScore
        let delta = current - startScore
        if delta > 3 { return "Improving" }
        if delta < -3 { return "Weakening" }
        return "Unchanged"
    }

    var weeklyScoreChange: String? {
        guard let startScore = loadWeekStartScore() else { return nil }
        let current = environmentScore
        if current == startScore { return nil }
        return "\(startScore) → \(current)"
    }

    var weeklyExplanation: String {
        let dir = weeklyDirection
        let env = environmentStatus.label.lowercased()
        let m = momentumStatus
        let t = trendStatus
        let v = volatilityStatus
        let p = positioningStatus

        switch dir {
        case "Improving":
            if t == .bullish && m == .bullish {
                return "This week: conditions improved as trend strengthened and momentum stabilized. \(p == .bearish ? "Positioning is becoming more extended." : "The broader environment is supportive.")"
            }
            if m == .bullish {
                return "This week: conditions improved as momentum strengthened. \(v == .bearish ? "Volatility remains elevated." : "Risk conditions are manageable.")"
            }
            if t == .bullish {
                return "This week: conditions improved as the trend aligned positively. \(p == .bearish ? "Positioning is becoming more extended." : "Conditions are gradually improving.")"
            }
            return "This week: conditions gradually improved with no single dominant factor."
        case "Weakening":
            if m == .bearish && v == .bearish {
                return "This week: conditions weakened as momentum declined and volatility increased. The broader trend remains mixed."
            }
            if m == .bearish {
                return "This week: conditions weakened as momentum faded. \(t == .bearish ? "The trend is also under pressure." : "The trend remains stable for now.")"
            }
            if v == .bearish {
                return "This week: conditions weakened as volatility expanded. Environment remains \(env)."
            }
            return "This week: conditions softened slightly. Environment remains \(env)."
        default:
            if m == .neutral && t == .neutral {
                return "This week: conditions remained relatively stable with no major structural changes."
            }
            return "This week: little movement \u{2014} environment remains \(env) with no major shifts."
        }
    }

    private func saveWeekStartScore(_ value: Int) {
        let cal = Calendar.current
        let currentWeek = cal.component(.weekOfYear, from: Date())
        let currentYear = cal.component(.yearForWeekOfYear, from: Date())
        let storedWeek = UserDefaults.standard.integer(forKey: "weeklyWeek")
        let storedYear = UserDefaults.standard.integer(forKey: "weeklyYear")

        if storedWeek == currentWeek && storedYear == currentYear { return }

        let todayScore = UserDefaults.standard.integer(forKey: "signalToday")
        if todayScore != 0 || UserDefaults.standard.object(forKey: "signalToday") != nil {
            UserDefaults.standard.set(todayScore, forKey: "weeklyStartScore")
        }
        UserDefaults.standard.set(currentWeek, forKey: "weeklyWeek")
        UserDefaults.standard.set(currentYear, forKey: "weeklyYear")
    }

    private func loadWeekStartScore() -> Int? {
        guard UserDefaults.standard.object(forKey: "weeklyStartScore") != nil else { return nil }
        return UserDefaults.standard.integer(forKey: "weeklyStartScore")
    }

    private func saveTodaySignalStrength(_ value: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        let stored = UserDefaults.standard.double(forKey: "signalDate")
        let storedDate = Date(timeIntervalSinceReferenceDate: stored)

        if Calendar.current.isDate(storedDate, inSameDayAs: today) { return }

        let yesterday = UserDefaults.standard.integer(forKey: "signalToday")
        if yesterday != 0 || UserDefaults.standard.object(forKey: "signalToday") != nil {
            UserDefaults.standard.set(yesterday, forKey: "signalYesterday")
        }
        UserDefaults.standard.set(value, forKey: "signalToday")
        UserDefaults.standard.set(today.timeIntervalSinceReferenceDate, forKey: "signalDate")
        saveWeekStartScore(value)
    }

    private func loadPreviousSignalStrength() -> Int? {
        guard UserDefaults.standard.object(forKey: "signalYesterday") != nil else { return nil }
        return UserDefaults.standard.integer(forKey: "signalYesterday")
    }

    private func saveTodayComponentStatuses() {
        let today = Calendar.current.startOfDay(for: Date())
        let stored = UserDefaults.standard.double(forKey: "componentDate")
        let storedDate = Date(timeIntervalSinceReferenceDate: stored)

        if Calendar.current.isDate(storedDate, inSameDayAs: today) { return }

        if let data = UserDefaults.standard.dictionary(forKey: "componentToday") as? [String: String] {
            UserDefaults.standard.set(data, forKey: "componentYesterday")
        }

        let current: [String: String] = [
            "Trend": trendStatus.label,
            "Momentum": momentumStatus.label,
            "Positioning": positioningStatus.label,
            "Volatility": volatilityStatus.label
        ]
        UserDefaults.standard.set(current, forKey: "componentToday")
        UserDefaults.standard.set(today.timeIntervalSinceReferenceDate, forKey: "componentDate")
    }

    private func loadPreviousComponentStatuses() -> [String: String]? {
        UserDefaults.standard.dictionary(forKey: "componentYesterday") as? [String: String]
    }

    private func buildDailyNarrative(delta: Int) -> String {
        let changes = changedComponents
        let m = momentumStatus
        let t = trendStatus
        let v = volatilityStatus
        let p = positioningStatus

        if delta >= 5 {
            if m == .bullish && t == .bullish {
                return "Conditions are improving as momentum strengthens and trend remains supportive."
            }
            if m == .bullish {
                return "Conditions are improving as momentum strengthens.\(p == .bearish ? " Positioning is becoming more extended." : "")"
            }
            if t == .bullish {
                return "Conditions are improving as the trend aligns positively.\(v == .bearish ? " Volatility remains elevated." : "")"
            }
            return "Conditions are improving, though not all factors have confirmed."
        }

        if delta <= -5 {
            if v == .bearish && m == .bearish {
                return "Conditions are weakening as volatility increases and momentum softens."
            }
            if m == .bearish {
                return "Conditions are weakening as momentum fades.\(t == .bearish ? " Long-term trend support is less reliable." : "")"
            }
            if v == .bearish {
                return "Conditions are weakening as volatility expands."
            }
            return "Conditions are softening across multiple factors."
        }

        if !changes.isEmpty {
            let first = changes[0]
            return "\(first.name) shifted from \(first.from.lowercased()) to \(first.to.lowercased()), but the overall environment remains stable."
        }

        let env = environmentStatus.label.lowercased()
        return "The environment remains stable with no significant changes in conditions."
    }

    private func formatLargeNumber(_ value: Double) -> String {
        if value >= 1_000_000_000_000 {
            return String(format: "$%.2fT", value / 1_000_000_000_000)
        } else if value >= 1_000_000_000 {
            return String(format: "$%.2fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        }
        return "$\(Int(value).formatted(.number))"
    }
}

nonisolated enum EnvironmentStatus: Sendable {
    case strong
    case moderate
    case weak
    case highRisk

    var label: String {
        switch self {
        case .strong: return "Strong"
        case .moderate: return "Moderate"
        case .weak: return "Weak"
        case .highRisk: return "High Risk"
        }
    }
}

nonisolated enum DriverStatus: Sendable {
    case bullish
    case neutral
    case bearish

    var label: String {
        switch self {
        case .bullish: return "Bullish"
        case .neutral: return "Neutral"
        case .bearish: return "Bearish"
        }
    }
}

struct CompositeSignal {
    let label: String
    let color: Color
}
