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
    var scoreAlertTargets: [ScoreAlertTarget] = []

    private let lastSupportCrossKey = "last_support_cross"
    private let lastResistanceCrossKey = "last_resistance_cross"
    private let customTargetsKey = "custom_price_targets"
    private let scoreTargetsKey = "custom_score_targets"

    private init() {
        powerLawSupportAlert = UserDefaults.standard.bool(forKey: "alert_pl_support")
        powerLawResistanceAlert = UserDefaults.standard.bool(forKey: "alert_pl_resistance")
        loadCustomTargets()
        loadScoreTargets()
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

    func addScoreTarget(_ target: ScoreAlertTarget) {
        guard !scoreAlertTargets.contains(where: { $0.value == target.value && $0.direction == target.direction }) else { return }
        scoreAlertTargets.append(target)
        scoreAlertTargets.sort { $0.value < $1.value }
        saveScoreTargets()
    }

    func removeScoreTargets(at offsets: IndexSet) {
        scoreAlertTargets.remove(atOffsets: offsets)
        saveScoreTargets()
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

    private func loadScoreTargets() {
        guard let data = UserDefaults.standard.data(forKey: scoreTargetsKey),
              let targets = try? JSONDecoder().decode([ScoreAlertTarget].self, from: data) else { return }
        scoreAlertTargets = targets
    }

    private func saveScoreTargets() {
        guard let data = try? JSONEncoder().encode(scoreAlertTargets) else { return }
        UserDefaults.standard.set(data, forKey: scoreTargetsKey)
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

    func evaluateScore(_ score: Int) {
        let ud = UserDefaults.standard
        let prevScore = ud.integer(forKey: "prev_alert_score")
        let hasPrev = ud.object(forKey: "prev_alert_score") != nil

        guard hasPrev else {
            ud.set(score, forKey: "prev_alert_score")
            return
        }

        for target in scoreAlertTargets {
            let crossKey = "score_target_\(target.value)_\(target.direction.rawValue)"

            switch target.direction {
            case .crossesAbove:
                if prevScore < target.value && score >= target.value && !alreadyNotified(key: crossKey) {
                    sendAlert(
                        title: "BitShrug",
                        body: "Environment Score crossed above \(target.value)"
                    )
                    markNotified(key: crossKey)
                }
            case .crossesBelow:
                if prevScore >= target.value && score < target.value && !alreadyNotified(key: crossKey) {
                    sendAlert(
                        title: "BitShrug",
                        body: "Environment Score dropped below \(target.value)"
                    )
                    markNotified(key: crossKey)
                }
            case .crossesEither:
                let crossedUp = prevScore < target.value && score >= target.value
                let crossedDown = prevScore >= target.value && score < target.value
                if (crossedUp || crossedDown) && !alreadyNotified(key: crossKey) {
                    let verb = crossedUp ? "crossed above" : "dropped below"
                    sendAlert(
                        title: "BitShrug",
                        body: "Environment Score \(verb) \(target.value)"
                    )
                    markNotified(key: crossKey)
                }
            }
        }

        ud.set(score, forKey: "prev_alert_score")
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

nonisolated struct ScoreAlertTarget: Codable, Sendable, Identifiable {
    let id: UUID
    let value: Int
    let direction: ScoreAlertDirection

    init(value: Int, direction: ScoreAlertDirection) {
        self.id = UUID()
        self.value = value
        self.direction = direction
    }
}

nonisolated enum ScoreAlertDirection: String, Codable, Sendable, CaseIterable {
    case crossesAbove = "above"
    case crossesBelow = "below"
    case crossesEither = "either"

    var label: String {
        switch self {
        case .crossesAbove: return "Crosses Above"
        case .crossesBelow: return "Crosses Below"
        case .crossesEither: return "Crosses Either Way"
        }
    }
}
