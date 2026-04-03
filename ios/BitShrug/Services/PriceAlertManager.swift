import Foundation
import SwiftUI
import UserNotifications

@Observable
class PriceAlertManager {
    static let shared = PriceAlertManager()

    var powerLawSupportAlert: Bool = false {
        didSet { UserDefaults.standard.set(powerLawSupportAlert, forKey: "alert_pl_support") }
    }
    var powerLawResistanceAlert: Bool = false {
        didSet { UserDefaults.standard.set(powerLawResistanceAlert, forKey: "alert_pl_resistance") }
    }

    var customTargets: [Double] = []

    private let lastSupportCrossKey = "last_support_cross"
    private let lastResistanceCrossKey = "last_resistance_cross"
    private let customTargetsKey = "custom_price_targets"

    private init() {
        powerLawSupportAlert = UserDefaults.standard.bool(forKey: "alert_pl_support")
        powerLawResistanceAlert = UserDefaults.standard.bool(forKey: "alert_pl_resistance")
        loadCustomTargets()
    }

    func addTarget(_ price: Double) {
        guard !customTargets.contains(price) else { return }
        customTargets.append(price)
        customTargets.sort()
        saveCustomTargets()
    }

    func removeTargets(at offsets: IndexSet) {
        customTargets.remove(atOffsets: offsets)
        saveCustomTargets()
    }

    private func loadCustomTargets() {
        guard let data = UserDefaults.standard.data(forKey: customTargetsKey),
              let targets = try? JSONDecoder().decode([Double].self, from: data) else { return }
        customTargets = targets
    }

    private func saveCustomTargets() {
        guard let data = try? JSONEncoder().encode(customTargets) else { return }
        UserDefaults.standard.set(data, forKey: customTargetsKey)
    }

    func evaluate(price: Double, support: Double, resistance: Double) {
        let ud = UserDefaults.standard
        let prevPrice = ud.double(forKey: "prev_alert_price")
        guard prevPrice > 0 else {
            ud.set(price, forKey: "prev_alert_price")
            return
        }

        if powerLawSupportAlert {
            let wasBelowSupport = prevPrice < support
            let isAboveSupport = price >= support
            let wasAboveSupport = prevPrice >= support
            let isBelowSupport = price < support

            if wasBelowSupport && isAboveSupport && !alreadyNotified(key: lastSupportCrossKey) {
                sendAlert(
                    title: "BitShrug",
                    body: "Price crossed above Power Law support at \(formatPrice(support))"
                )
                markNotified(key: lastSupportCrossKey)
            } else if wasAboveSupport && isBelowSupport && !alreadyNotified(key: lastSupportCrossKey) {
                sendAlert(
                    title: "BitShrug",
                    body: "Price dropped below Power Law support at \(formatPrice(support))"
                )
                markNotified(key: lastSupportCrossKey)
            }
        }

        if powerLawResistanceAlert {
            let wasBelowResistance = prevPrice < resistance
            let isAboveResistance = price >= resistance
            let wasAboveResistance = prevPrice >= resistance
            let isBelowResistance = price < resistance

            if wasBelowResistance && isAboveResistance && !alreadyNotified(key: lastResistanceCrossKey) {
                sendAlert(
                    title: "BitShrug",
                    body: "Price crossed above Power Law resistance at \(formatPrice(resistance))"
                )
                markNotified(key: lastResistanceCrossKey)
            } else if wasAboveResistance && isBelowResistance && !alreadyNotified(key: lastResistanceCrossKey) {
                sendAlert(
                    title: "BitShrug",
                    body: "Price dropped below Power Law resistance at \(formatPrice(resistance))"
                )
                markNotified(key: lastResistanceCrossKey)
            }
        }

        for target in customTargets {
            let crossKey = "custom_target_\(Int(target))"
            let wasBelow = prevPrice < target
            let isAbove = price >= target
            let wasAbove = prevPrice >= target
            let isBelow = price < target

            if wasBelow && isAbove && !alreadyNotified(key: crossKey) {
                sendAlert(
                    title: "BitShrug",
                    body: "Bitcoin crossed above \(formatPrice(target))"
                )
                markNotified(key: crossKey)
            } else if wasAbove && isBelow && !alreadyNotified(key: crossKey) {
                sendAlert(
                    title: "BitShrug",
                    body: "Bitcoin dropped below \(formatPrice(target))"
                )
                markNotified(key: crossKey)
            }
        }

        ud.set(price, forKey: "prev_alert_price")
    }

    private func alreadyNotified(key: String) -> Bool {
        let stored = UserDefaults.standard.double(forKey: key)
        let storedDate = Date(timeIntervalSinceReferenceDate: stored)
        return Calendar.current.isDateInToday(storedDate)
    }

    private func markNotified(key: String) {
        UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: key)
    }

    private func sendAlert(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func formatPrice(_ value: Double) -> String {
        "$\(Int(value).formatted(.number))"
    }
}
