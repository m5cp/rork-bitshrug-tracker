import Foundation
import SwiftUI

// MARK: - Finnhub

nonisolated struct FinnhubQuoteResponse: Codable, Sendable {
    let c: Double
    let d: Double?
    let dp: Double?
    let h: Double
    let l: Double
    let o: Double
    let pc: Double
    let t: Int?
}

// MARK: - CryptoCompare

nonisolated struct CryptoCompareTopResponse: Codable, Sendable {
    let Data: [CryptoCompareTopCoin]?

    nonisolated enum CodingKeys: String, CodingKey {
        case Data = "Data"
    }
}

nonisolated struct CryptoCompareTopCoin: Codable, Sendable {
    let CoinInfo: CryptoCompareCoinInfo?
    let RAW: CryptoCompareRAW?

    nonisolated enum CodingKeys: String, CodingKey {
        case CoinInfo = "CoinInfo"
        case RAW = "RAW"
    }
}

nonisolated struct CryptoCompareCoinInfo: Codable, Sendable {
    let Name: String?

    nonisolated enum CodingKeys: String, CodingKey {
        case Name = "Name"
    }
}

nonisolated struct CryptoCompareRAW: Codable, Sendable {
    let USD: CryptoCompareUSD?

    nonisolated enum CodingKeys: String, CodingKey {
        case USD = "USD"
    }
}

nonisolated struct CryptoCompareUSD: Codable, Sendable {
    let PRICE: Double?
    let MKTCAP: Double?
    let TOTALVOLUME24HTO: Double?
    let CHANGEPCT24HOUR: Double?
    let SUPPLY: Double?
    let VOLUME24HOUR: Double?

    nonisolated enum CodingKeys: String, CodingKey {
        case PRICE
        case MKTCAP
        case TOTALVOLUME24HTO
        case CHANGEPCT24HOUR
        case SUPPLY
        case VOLUME24HOUR
    }
}

nonisolated struct CryptoCompareHistoryResponse: Codable, Sendable {
    let Data: CryptoCompareHistoryData?

    nonisolated enum CodingKeys: String, CodingKey {
        case Data = "Data"
    }
}

nonisolated struct CryptoCompareHistoryData: Codable, Sendable {
    let Data: [CryptoCompareHistoryEntry]?

    nonisolated enum CodingKeys: String, CodingKey {
        case Data = "Data"
    }
}

nonisolated struct CryptoCompareHistoryEntry: Codable, Sendable {
    let time: Int
    let close: Double
    let high: Double
    let low: Double
    let open: Double
}

// MARK: - Alternative.me Fear & Greed

nonisolated struct FearGreedResponse: Codable, Sendable {
    let data: [FearGreedEntry]
}

nonisolated struct FearGreedEntry: Codable, Sendable {
    let value: String
    let valueClassification: String

    nonisolated enum CodingKeys: String, CodingKey {
        case value
        case valueClassification = "value_classification"
    }
}

// MARK: - CoinGecko Fallback

nonisolated struct CoinGeckoSimpleResponse: Codable, Sendable {
    let bitcoin: CoinGeckoBTC
}

nonisolated struct CoinGeckoBTC: Codable, Sendable {
    let usd: Double
    let usdMarketCap: Double?
    let usd24hVol: Double?
    let usd24hChange: Double?

    nonisolated enum CodingKeys: String, CodingKey {
        case usd
        case usdMarketCap = "usd_market_cap"
        case usd24hVol = "usd_24h_vol"
        case usd24hChange = "usd_24h_change"
    }
}

// MARK: - Blockchain.info

nonisolated struct BlockchainStatsResponse: Codable, Sendable {
    let hashRate: Double?
    let nBlocksTotal: Int?
    let difficulty: Double?

    nonisolated enum CodingKeys: String, CodingKey {
        case hashRate = "hash_rate"
        case nBlocksTotal = "n_blocks_total"
        case difficulty
    }
}

struct BitcoinPriceData: Sendable {
    let price: Double
    let marketCap: Double
    let volume24h: Double
    let change24h: Double
}

struct PricePoint: Sendable, Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}

nonisolated enum FearGreedLevel: Sendable {
    case extremeFear
    case fear
    case neutral
    case greed
    case extremeGreed

    init(value: Int) {
        switch value {
        case 0..<25: self = .extremeFear
        case 25..<45: self = .fear
        case 45..<55: self = .neutral
        case 55..<75: self = .greed
        default: self = .extremeGreed
        }
    }

    var label: String {
        switch self {
        case .extremeFear: return "Extreme Fear"
        case .fear: return "Fear"
        case .neutral: return "Neutral"
        case .greed: return "Greed"
        case .extremeGreed: return "Extreme Greed"
        }
    }

    var color: Color {
        switch self {
        case .extremeFear: return .red
        case .fear: return .orange
        case .neutral: return .yellow
        case .greed: return .green
        case .extremeGreed: return .green
        }
    }

    var signalDescription: String {
        switch self {
        case .extremeFear: return "Historically a strong buying signal"
        case .fear: return "Market uncertainty — accumulation zone"
        case .neutral: return "Market indecision"
        case .greed: return "Caution — market heating up"
        case .extremeGreed: return "Historically signals cycle tops"
        }
    }
}

nonisolated enum PowerLawPosition: Sendable {
    case belowSupport
    case withinCorridor
    case aboveResistance

    var label: String {
        switch self {
        case .belowSupport: return "Below Support"
        case .withinCorridor: return "Within Corridor"
        case .aboveResistance: return "Above Resistance"
        }
    }

    var description: String {
        switch self {
        case .belowSupport: return "Price is below the long-term power law support — historically a strong buy zone."
        case .withinCorridor: return "Price is within the expected power law corridor — on track with the long-term trend."
        case .aboveResistance: return "Price is above the power law ceiling — historically signals overheated conditions."
        }
    }

    var color: Color {
        switch self {
        case .belowSupport: return .green
        case .withinCorridor: return .blue
        case .aboveResistance: return .red
        }
    }
}

nonisolated enum RainbowBand: Int, CaseIterable, Sendable {
    case fireZone = 0
    case buy
    case accumulate
    case cheap
    case holdBuy
    case hold
    case holdSell
    case fomo
    case bubble
    case maxBubble

    var label: String {
        switch self {
        case .fireZone: return "Fire Sale"
        case .buy: return "Buy"
        case .accumulate: return "Accumulate"
        case .cheap: return "Still Cheap"
        case .holdBuy: return "Hold / Buy"
        case .hold: return "Hold"
        case .holdSell: return "Hold / Sell"
        case .fomo: return "FOMO Intensifies"
        case .bubble: return "Bubble Territory"
        case .maxBubble: return "Maximum Bubble"
        }
    }

    var color: Color {
        switch self {
        case .fireZone: return Color(red: 0.1, green: 0.1, blue: 0.6)
        case .buy: return Color(red: 0.1, green: 0.3, blue: 0.8)
        case .accumulate: return Color(red: 0.0, green: 0.6, blue: 0.5)
        case .cheap: return Color(red: 0.0, green: 0.7, blue: 0.2)
        case .holdBuy: return Color(red: 0.4, green: 0.8, blue: 0.0)
        case .hold: return Color(red: 0.8, green: 0.8, blue: 0.0)
        case .holdSell: return Color(red: 1.0, green: 0.6, blue: 0.0)
        case .fomo: return Color(red: 1.0, green: 0.4, blue: 0.0)
        case .bubble: return Color(red: 1.0, green: 0.2, blue: 0.0)
        case .maxBubble: return Color(red: 0.8, green: 0.0, blue: 0.0)
        }
    }

    var signalType: String {
        switch self {
        case .fireZone, .buy, .accumulate, .cheap: return "Bullish"
        case .holdBuy, .hold: return "Neutral"
        case .holdSell, .fomo, .bubble, .maxBubble: return "Bearish"
        }
    }
}

nonisolated enum MVRVZone: Sendable {
    case deepValue
    case undervalued
    case fairValue
    case warming
    case overheated
    case euphoria

    init(score: Double) {
        switch score {
        case ..<0: self = .deepValue
        case 0..<1: self = .undervalued
        case 1..<3: self = .fairValue
        case 3..<5: self = .warming
        case 5..<7: self = .overheated
        default: self = .euphoria
        }
    }

    var label: String {
        switch self {
        case .deepValue: return "Deep Value"
        case .undervalued: return "Undervalued"
        case .fairValue: return "Fair Value"
        case .warming: return "Getting Heated"
        case .overheated: return "Overheated"
        case .euphoria: return "Euphoria"
        }
    }

    var color: Color {
        switch self {
        case .deepValue: return .green
        case .undervalued: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .fairValue: return .blue
        case .warming: return .yellow
        case .overheated: return .orange
        case .euphoria: return .red
        }
    }

    var description: String {
        switch self {
        case .deepValue: return "Below aggregate cost basis — generational buy"
        case .undervalued: return "Price near holder cost basis — accumulation zone"
        case .fairValue: return "Healthy valuation range"
        case .warming: return "Market heating up — exercise caution"
        case .overheated: return "Significantly above cost basis — risk rising"
        case .euphoria: return "Extreme overvaluation — historically signals tops"
        }
    }
}

nonisolated enum PuellZone: Sendable {
    case minerCapitulation
    case lowRevenue
    case normal
    case highRevenue
    case minerEuphoria

    init(multiple: Double) {
        switch multiple {
        case ..<0.5: self = .minerCapitulation
        case 0.5..<0.8: self = .lowRevenue
        case 0.8..<2.5: self = .normal
        case 2.5..<4.0: self = .highRevenue
        default: self = .minerEuphoria
        }
    }

    var label: String {
        switch self {
        case .minerCapitulation: return "Miner Capitulation"
        case .lowRevenue: return "Low Revenue"
        case .normal: return "Normal"
        case .highRevenue: return "High Revenue"
        case .minerEuphoria: return "Miner Euphoria"
        }
    }

    var color: Color {
        switch self {
        case .minerCapitulation: return .green
        case .lowRevenue: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .normal: return .blue
        case .highRevenue: return .orange
        case .minerEuphoria: return .red
        }
    }

    var description: String {
        switch self {
        case .minerCapitulation: return "Miners under extreme stress — historically signals bottoms"
        case .lowRevenue: return "Below-average miner revenue — accumulation zone"
        case .normal: return "Miner revenue within normal range"
        case .highRevenue: return "Above-average miner profits — caution"
        case .minerEuphoria: return "Extreme miner profits — historically signals tops"
        }
    }
}

struct HalvingInfo: Sendable {
    let lastHalvingDate: Date
    let nextHalvingDate: Date
    let cycleProgress: Double
    let daysUntilNext: Int
    let daysSinceLast: Int
    let currentEra: Int
    let currentPhase: CyclePhase
    let blockReward: Double
}

nonisolated enum CyclePhase: Sendable, Equatable {
    case accumulation
    case earlyBull
    case acceleration
    case euphoria
    case distribution
    case earlyBear
    case capitulation
    case recovery

    init(progress: Double) {
        switch progress {
        case 0..<0.15: self = .accumulation
        case 0.15..<0.30: self = .earlyBull
        case 0.30..<0.45: self = .acceleration
        case 0.45..<0.55: self = .euphoria
        case 0.55..<0.65: self = .distribution
        case 0.65..<0.78: self = .earlyBear
        case 0.78..<0.90: self = .capitulation
        default: self = .recovery
        }
    }

    var label: String {
        switch self {
        case .accumulation: return "Accumulation"
        case .earlyBull: return "Early Bull"
        case .acceleration: return "Acceleration"
        case .euphoria: return "Euphoria / Peak"
        case .distribution: return "Distribution"
        case .earlyBear: return "Early Bear"
        case .capitulation: return "Capitulation"
        case .recovery: return "Recovery"
        }
    }

    var icon: String {
        switch self {
        case .accumulation: return "tray.and.arrow.down.fill"
        case .earlyBull: return "arrow.up.right"
        case .acceleration: return "arrow.up.right.circle.fill"
        case .euphoria: return "flame.fill"
        case .distribution: return "arrow.left.arrow.right"
        case .earlyBear: return "arrow.down.right"
        case .capitulation: return "arrow.down.to.line"
        case .recovery: return "arrow.uturn.up"
        }
    }

    var color: Color {
        switch self {
        case .accumulation: return .green
        case .earlyBull: return Color(red: 0.4, green: 0.8, blue: 0.2)
        case .acceleration: return .orange
        case .euphoria: return .red
        case .distribution: return Color(red: 0.8, green: 0.4, blue: 0.0)
        case .earlyBear: return Color(red: 0.6, green: 0.2, blue: 0.2)
        case .capitulation: return Color(red: 0.4, green: 0.1, blue: 0.1)
        case .recovery: return .blue
        }
    }

    var description: String {
        switch self {
        case .accumulation: return "Post-halving quiet period. Smart money accumulates while price consolidates near halving levels."
        case .earlyBull: return "Price begins to break out. New all-time highs become possible as momentum builds."
        case .acceleration: return "Rapid price appreciation. Media attention grows, retail interest surges."
        case .euphoria: return "Parabolic price action. Maximum FOMO and media frenzy. Historically the cycle peak zone."
        case .distribution: return "Long-term holders begin taking profits. Price volatility increases with lower highs."
        case .earlyBear: return "Trend shifts bearish. Denial phase as price makes lower lows."
        case .capitulation: return "Maximum pain. Weak hands sell at a loss. Smart money begins accumulating again."
        case .recovery: return "Bottom formation. Market heals as the next halving approaches."
        }
    }
}

struct MovingAverageData: Sendable {
    let ema200Day: Double
    let sma50Day: Double
    let sma200Day: Double
    let currentPrice: Double
    let estimated200WMA: Double
    let priceVsEMA: Double
    let priceVs200WMA: Double
    let isAboveEMA: Bool
    let isAbove200WMA: Bool
}

struct SupplyProfitData: Sendable {
    let estimatedPercent: Double
    let zone: SupplyProfitZone
}

nonisolated enum SupplyProfitZone: Sendable {
    case deepLoss
    case majority_loss
    case mixed
    case majority_profit
    case nearlyAll

    init(percent: Double) {
        switch percent {
        case ..<30: self = .deepLoss
        case 30..<50: self = .majority_loss
        case 50..<75: self = .mixed
        case 75..<95: self = .majority_profit
        default: self = .nearlyAll
        }
    }

    var label: String {
        switch self {
        case .deepLoss: return "Deep Loss"
        case .majority_loss: return "Majority in Loss"
        case .mixed: return "Mixed"
        case .majority_profit: return "Majority in Profit"
        case .nearlyAll: return "Nearly All in Profit"
        }
    }

    var color: Color {
        switch self {
        case .deepLoss: return .green
        case .majority_loss: return Color(red: 0.2, green: 0.7, blue: 0.4)
        case .mixed: return .yellow
        case .majority_profit: return .orange
        case .nearlyAll: return .red
        }
    }

    var description: String {
        switch self {
        case .deepLoss: return "Less than 30% in profit — historically strong buy signal"
        case .majority_loss: return "More holders underwater — accumulation territory"
        case .mixed: return "Market at inflection point"
        case .majority_profit: return "Most holders profitable — distribution may begin"
        case .nearlyAll: return "Nearly all supply in profit — historically signals tops"
        }
    }
}
