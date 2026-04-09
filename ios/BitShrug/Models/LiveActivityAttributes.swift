import ActivityKit
import Foundation

nonisolated struct BitShrugLiveAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable, Sendable {
        var price: Double
        var change24h: Double
        var environmentScore: Int
        var environmentLabel: String
        var lastUpdated: Date
    }

    var appName: String
}
