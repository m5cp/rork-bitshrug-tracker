import AppIntents

struct GetEnvironmentIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Bitcoin Environment"
    static var description = IntentDescription("Check the current Bitcoin Environment Score and conditions.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = BitcoinService.shared
        do {
            let priceData = try await service.fetchPrice()
            let history = try await service.fetchHistoricalPrices(days: 365)

            let sma50 = service.calculate50DaySMA(prices: history) ?? priceData.price * 0.95
            let sma200 = service.calculate200DaySMA(prices: history) ?? priceData.price * 0.85

            let aboveMA50 = priceData.price > sma50
            let aboveMA200 = priceData.price > sma200
            let ma50AboveMA200 = sma50 > sma200

            let trendScore: Int
            if aboveMA50 && ma50AboveMA200 { trendScore = 30 }
            else if aboveMA200 && !ma50AboveMA200 { trendScore = 20 }
            else if !aboveMA200 && !aboveMA50 && !ma50AboveMA200 { trendScore = 5 }
            else if !aboveMA200 { trendScore = 10 }
            else { trendScore = 15 }

            let c7 = service.percentChange(prices: history, days: 7) ?? 0
            let c30 = service.percentChange(prices: history, days: 30) ?? 0

            let momentumScore: Int
            if c7 > 5 && c30 > 10 { momentumScore = 25 }
            else if c7 >= 0 && c7 <= 5 && c30 >= 0 && c30 <= 10 { momentumScore = 18 }
            else if c7 < 0 && c7 >= -7 { momentumScore = 10 }
            else if c7 < -7 && c30 < -10 { momentumScore = 5 }
            else { momentumScore = 12 }

            let vol = service.calculate30DayVolatility(prices: history) ?? 2.0
            let volatilityScore: Int
            if vol < 1.5 { volatilityScore = 20 }
            else if vol < 2.5 { volatilityScore = 14 }
            else if vol < 4.0 { volatilityScore = 8 }
            else { volatilityScore = 4 }

            let score = trendScore + momentumScore + 15 + volatilityScore
            let clampedScore = max(0, min(100, score))

            let label: String
            if clampedScore >= 75 { label = "Strong" }
            else if clampedScore >= 55 { label = "Moderate" }
            else if clampedScore >= 35 { label = "Weak" }
            else { label = "High Risk" }

            let priceFormatted = "$\(Int(priceData.price).formatted(.number))"

            return .result(dialog: "Bitcoin is at \(priceFormatted). The Environment Score is \(clampedScore) out of 100 \u{2014} \(label).")
        } catch {
            return .result(dialog: "I couldn't fetch the latest Bitcoin data right now. Try opening BitShrug directly.")
        }
    }
}

struct BitShrugShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetEnvironmentIntent(),
            phrases: [
                "What's the Bitcoin environment in \(.applicationName)",
                "Check Bitcoin conditions with \(.applicationName)",
                "Bitcoin score on \(.applicationName)",
                "How's Bitcoin doing on \(.applicationName)"
            ],
            shortTitle: "Bitcoin Environment",
            systemImageName: "bitcoinsign.circle.fill"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .orange
}
