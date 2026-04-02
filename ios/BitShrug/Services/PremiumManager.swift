import SwiftUI

@Observable
class PremiumManager {
    static let shared = PremiumManager()

    var isPremium: Bool = false
    var hasSeenPaywall: Bool = false

    private init() {
        isPremium = UserDefaults.standard.bool(forKey: "bitshrug_premium")
        hasSeenPaywall = UserDefaults.standard.bool(forKey: "bitshrug_seen_paywall")
    }

    func unlock() {
        isPremium = true
        UserDefaults.standard.set(true, forKey: "bitshrug_premium")
    }

    func markPaywallSeen() {
        hasSeenPaywall = true
        UserDefaults.standard.set(true, forKey: "bitshrug_seen_paywall")
    }

    var freeIndicatorLimit: Int { 3 }
    var canAccessAllIndicators: Bool { isPremium }
    var canAccessNotifications: Bool { isPremium }
    var canAccessWeeklySummary: Bool { isPremium }
    var canAccessDetailedInsights: Bool { isPremium }
}
