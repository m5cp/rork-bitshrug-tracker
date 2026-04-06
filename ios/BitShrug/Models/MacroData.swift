import SwiftUI

nonisolated struct FREDObservationResponse: Codable, Sendable {
    let observations: [FREDObservation]?
}

nonisolated struct FREDObservation: Codable, Sendable {
    let date: String
    let value: String
}

nonisolated enum MacroDirection: String, Sendable {
    case up = "up"
    case down = "down"
    case flat = "flat"

    var icon: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .flat: return "arrow.right"
        }
    }

    var color: Color {
        switch self {
        case .up: return AppColors.bullish
        case .down: return AppColors.bearish
        case .flat: return .secondary
        }
    }
}

nonisolated enum MacroBackdrop: String, Sendable {
    case supportive = "Supportive"
    case neutral = "Neutral"
    case restrictive = "Restrictive"

    var color: Color {
        switch self {
        case .supportive: return AppColors.bullish
        case .neutral: return .orange
        case .restrictive: return AppColors.bearish
        }
    }

    var icon: String {
        switch self {
        case .supportive: return "checkmark.circle.fill"
        case .neutral: return "minus.circle.fill"
        case .restrictive: return "exclamationmark.circle.fill"
        }
    }
}

struct MacroIndicator: Identifiable, Sendable {
    let id: String
    let title: String
    let value: Double?
    let previousValue: Double?
    let direction: MacroDirection
    let lastUpdated: Date?
    let displayFormat: MacroDisplayFormat
    let seriesID: String

    var formattedValue: String {
        guard let value else { return "Unavailable" }
        switch displayFormat {
        case .percent:
            return String(format: "%.2f%%", value)
        case .index:
            return String(format: "%.2f", value)
        }
    }

    var isAvailable: Bool { value != nil }

    nonisolated enum MacroDisplayFormat: Sendable {
        case percent
        case index
    }
}

struct MacroIntelligenceData: Sendable {
    var indicators: [MacroIndicator] = []
    var backdrop: MacroBackdrop = .neutral
    var isLoaded: Bool = false
    var lastFetched: Date?
    var hasError: Bool = false
}
