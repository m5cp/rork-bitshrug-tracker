import Foundation
import UserNotifications

@Observable
class NotificationManager {
    static let shared = NotificationManager()

    var environmentAlerts: Bool = false {
        didSet { UserDefaults.standard.set(environmentAlerts, forKey: "notif_environment") }
    }
    var signalStrengthAlerts: Bool = false {
        didSet { UserDefaults.standard.set(signalStrengthAlerts, forKey: "notif_signal") }
    }
    var indicatorAlerts: Bool = false {
        didSet { UserDefaults.standard.set(indicatorAlerts, forKey: "notif_indicator") }
    }
    var dailyBriefingEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(dailyBriefingEnabled, forKey: "notif_daily_briefing")
            if dailyBriefingEnabled {
                scheduleDailyBriefing()
            } else {
                cancelDailyBriefing()
            }
        }
    }
    var briefingHour: Int = 8 {
        didSet {
            UserDefaults.standard.set(briefingHour, forKey: "notif_briefing_hour")
            if dailyBriefingEnabled {
                scheduleDailyBriefing()
            }
        }
    }

    var isAuthorized: Bool = false

    private let center = UNUserNotificationCenter.current()
    private let lastEnvironmentKey = "last_notif_environment"
    private let lastMomentumKey = "last_notif_momentum"
    private let lastTrendKey = "last_notif_trend"
    private let lastVolatilityKey = "last_notif_volatility"
    private let lastPositioningKey = "last_notif_positioning"
    private let lastSignalKey = "last_notif_signal"
    private let lastNotifDateKey = "last_notif_date"
    private let dailyNotifCountKey = "daily_notif_count"
    private let dailyBriefingIdentifier = "bitshrug_daily_briefing"

    private init() {
        environmentAlerts = UserDefaults.standard.bool(forKey: "notif_environment")
        signalStrengthAlerts = UserDefaults.standard.bool(forKey: "notif_signal")
        indicatorAlerts = UserDefaults.standard.bool(forKey: "notif_indicator")
        dailyBriefingEnabled = UserDefaults.standard.bool(forKey: "notif_daily_briefing")
        briefingHour = UserDefaults.standard.object(forKey: "notif_briefing_hour") != nil
            ? UserDefaults.standard.integer(forKey: "notif_briefing_hour") : 8

        Task { await checkAuthorization() }
    }

    var hasAnyAlertEnabled: Bool {
        environmentAlerts || signalStrengthAlerts || indicatorAlerts || dailyBriefingEnabled
    }

    func requestPermission() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
        } catch {
            isAuthorized = false
        }
    }

    func checkAuthorization() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func evaluateAndNotify(
        environmentScore: Int,
        environment: String,
        momentum: String,
        trend: String,
        volatility: String,
        positioning: String
    ) {
        guard hasAnyAlertEnabled, isAuthorized else { return }

        resetDailyCountIfNeeded()
        guard dailyCount() < 1 else { return }

        let ud = UserDefaults.standard
        var triggered = false

        if signalStrengthAlerts || environmentAlerts {
            let lastScore = ud.object(forKey: lastSignalKey) as? Int
            if let lastScore {
                let delta = environmentScore - lastScore
                let absDelta = abs(delta)
                if absDelta >= 5 {
                    let narrative = buildScoreChangeNarrative(
                        delta: delta,
                        momentum: momentum,
                        trend: trend,
                        volatility: volatility
                    )
                    scheduleNotification(
                        title: "TouchGrass BTC",
                        body: narrative
                    )
                    triggered = true
                }
            }
            ud.set(environmentScore, forKey: lastSignalKey)
        }

        if !triggered && indicatorAlerts {
            let lastMomentum = ud.string(forKey: lastMomentumKey)
            let lastTrend = ud.string(forKey: lastTrendKey)
            let lastVolatility = ud.string(forKey: lastVolatilityKey)
            let lastPositioning = ud.string(forKey: lastPositioningKey)

            var changedComponent: String?
            var changedFrom: String?
            var changedTo: String?

            if let lastTrend, lastTrend != trend {
                changedComponent = "Trend"
                changedFrom = lastTrend
                changedTo = trend
            } else if let lastMomentum, lastMomentum != momentum {
                changedComponent = "Momentum"
                changedFrom = lastMomentum
                changedTo = momentum
            } else if let lastPositioning, lastPositioning != positioning {
                changedComponent = "Positioning"
                changedFrom = lastPositioning
                changedTo = positioning
            } else if let lastVolatility, lastVolatility != volatility {
                changedComponent = "Volatility"
                changedFrom = lastVolatility
                changedTo = volatility
            }

            if let component = changedComponent, let to = changedTo {
                let narrative = buildComponentChangeNarrative(
                    component: component,
                    to: to
                )
                scheduleNotification(
                    title: "TouchGrass BTC",
                    body: narrative
                )
            }
        }

        ud.set(momentum, forKey: lastMomentumKey)
        ud.set(trend, forKey: lastTrendKey)
        ud.set(volatility, forKey: lastVolatilityKey)
        ud.set(positioning, forKey: lastPositioningKey)
        if !environmentAlerts && !signalStrengthAlerts {
            ud.set(environmentScore, forKey: lastSignalKey)
        }
        ud.set(environment, forKey: lastEnvironmentKey)
    }

    private func buildScoreChangeNarrative(delta: Int, momentum: String, trend: String, volatility: String) -> String {
        if delta >= 5 {
            if momentum.lowercased() == "bullish" {
                return "Environment improving \u{2014} momentum strengthening"
            }
            if trend.lowercased() == "bullish" {
                return "Environment improving \u{2014} trend remains supportive"
            }
            return "Environment improving \u{2014} conditions stabilizing"
        } else {
            if volatility.lowercased() == "bearish" {
                return "Risk increasing \u{2014} volatility expanding"
            }
            if momentum.lowercased() == "bearish" {
                return "Risk increasing \u{2014} momentum weakening"
            }
            return "Risk increasing \u{2014} conditions softening"
        }
    }

    private func buildComponentChangeNarrative(component: String, to: String) -> String {
        let direction = to.lowercased()
        switch component {
        case "Trend":
            if direction == "bullish" { return "Trend shifting \u{2014} long-term direction improving" }
            if direction == "bearish" { return "Trend shifting \u{2014} long-term support weakening" }
            return "Trend conditions changing \u{2014} direction mixed"
        case "Momentum":
            if direction == "bullish" { return "Momentum turning \u{2014} conditions strengthening" }
            if direction == "bearish" { return "Momentum fading \u{2014} conditions softening" }
            return "Momentum stabilizing \u{2014} no strong direction"
        case "Positioning":
            if direction == "bullish" { return "Positioning improving \u{2014} more attractive entry context" }
            if direction == "bearish" { return "Positioning extended \u{2014} cycle awareness matters" }
            return "Positioning shifting \u{2014} conditions changing"
        case "Volatility":
            if direction == "bullish" { return "Volatility settling \u{2014} conditions calming" }
            if direction == "bearish" { return "Volatility expanding \u{2014} risk increasing" }
            return "Volatility shifting \u{2014} stay aware"
        default:
            return "Conditions stable \u{2014} no major changes"
        }
    }

    private func scheduleNotification(title: String, body: String) {
        guard dailyCount() < 1 else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        center.add(request)
        incrementDailyCount()
    }

    private func dailyCount() -> Int {
        UserDefaults.standard.integer(forKey: dailyNotifCountKey)
    }

    private func incrementDailyCount() {
        UserDefaults.standard.set(dailyCount() + 1, forKey: dailyNotifCountKey)
    }

    private func resetDailyCountIfNeeded() {
        let ud = UserDefaults.standard
        let stored = ud.double(forKey: lastNotifDateKey)
        let storedDate = Date(timeIntervalSinceReferenceDate: stored)
        let today = Calendar.current.startOfDay(for: Date())

        if !Calendar.current.isDate(storedDate, inSameDayAs: today) {
            ud.set(0, forKey: dailyNotifCountKey)
            ud.set(today.timeIntervalSinceReferenceDate, forKey: lastNotifDateKey)
        }
    }

    func updateDailyBriefingContent(
        score: Int,
        scoreDelta: Int?,
        price: String,
        trend: String,
        cyclePhase: String? = nil,
        cycleDay: Int? = nil,
        fearGreed: Int? = nil
    ) {
        guard dailyBriefingEnabled else { return }

        let deltaArrow: String
        if let delta = scoreDelta {
            if delta > 0 { deltaArrow = " \u{2191}\(delta)" }
            else if delta < 0 { deltaArrow = " \u{2193}\(abs(delta))" }
            else { deltaArrow = " \u{2014}" }
        } else {
            deltaArrow = ""
        }

        var body = "BTC \(price) \u{00B7} Score \(score)\(deltaArrow) \u{00B7} Trend: \(trend)"

        if let phase = cyclePhase, let day = cycleDay {
            body += "\nCycle: \(phase) \u{00B7} Day \(day)"
        }

        if let fg = fearGreed {
            let sentiment: String
            switch fg {
            case 0..<25: sentiment = "Extreme Fear"
            case 25..<45: sentiment = "Fear"
            case 45..<55: sentiment = "Neutral"
            case 55..<75: sentiment = "Greed"
            default: sentiment = "Extreme Greed"
            }
            body += " \u{00B7} Sentiment: \(sentiment) (\(fg))"
        }

        UserDefaults.standard.set(body, forKey: "daily_briefing_body")
        scheduleDailyBriefing()
    }

    func scheduleDailyBriefing() {
        center.removePendingNotificationRequests(withIdentifiers: [dailyBriefingIdentifier])

        let body = UserDefaults.standard.string(forKey: "daily_briefing_body")
            ?? "Open TouchGrass BTC for your daily market update."

        let content = UNMutableNotificationContent()
        content.title = "\u{2615} TouchGrass BTC Morning Brief"
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = briefingHour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: dailyBriefingIdentifier,
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    private func cancelDailyBriefing() {
        center.removePendingNotificationRequests(withIdentifiers: [dailyBriefingIdentifier])
    }
}
