import Foundation

nonisolated class FREDService: Sendable {
    static let shared = FREDService()

    private init() {}

    nonisolated struct SeriesConfig: Sendable {
        let id: String
        let title: String
        let displayFormat: MacroIndicator.MacroDisplayFormat
    }

    static let seriesConfigs: [SeriesConfig] = [
        SeriesConfig(id: "FEDFUNDS", title: "Federal Funds Rate", displayFormat: .percent),
        SeriesConfig(id: "DGS10", title: "10-Year Treasury", displayFormat: .percent),
        SeriesConfig(id: "DGS2", title: "2-Year Treasury", displayFormat: .percent),
        SeriesConfig(id: "CPIAUCSL", title: "CPI (Inflation)", displayFormat: .index),
        SeriesConfig(id: "UNRATE", title: "Unemployment Rate", displayFormat: .percent),
        SeriesConfig(id: "STLFSI2", title: "Financial Stress", displayFormat: .index),
        SeriesConfig(id: "WALCL", title: "Fed Balance Sheet", displayFormat: .index),
    ]

    func fetchAllSeries() async -> [MacroIndicator] {
        let apiKey = Config.EXPO_PUBLIC_FRED_API_KEY
        guard !apiKey.isEmpty else {
            print("[TouchGrassBTC] FRED: No API key configured")
            return Self.seriesConfigs.map { config in
                MacroIndicator(
                    id: config.id,
                    title: config.title,
                    value: nil,
                    previousValue: nil,
                    direction: .flat,
                    lastUpdated: nil,
                    displayFormat: config.displayFormat,
                    seriesID: config.id
                )
            }
        }

        return await withTaskGroup(of: MacroIndicator.self, returning: [MacroIndicator].self) { group in
            for config in Self.seriesConfigs {
                group.addTask {
                    await self.fetchSeries(config: config, apiKey: apiKey)
                }
            }

            var results: [MacroIndicator] = []
            for await indicator in group {
                results.append(indicator)
            }

            return Self.seriesConfigs.compactMap { config in
                results.first(where: { $0.seriesID == config.id })
            }
        }
    }

    private func fetchSeries(config: SeriesConfig, apiKey: String) async -> MacroIndicator {
        let urlString = "https://api.stlouisfed.org/fred/series/observations?series_id=\(config.id)&api_key=\(apiKey)&file_type=json&sort_order=desc&limit=2"

        guard let url = URL(string: urlString) else {
            return unavailableIndicator(for: config)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("[TouchGrassBTC] FRED \(config.id): HTTP \(httpResponse.statusCode)")
                return unavailableIndicator(for: config)
            }

            let decoded = try JSONDecoder().decode(FREDObservationResponse.self, from: data)

            guard let observations = decoded.observations, !observations.isEmpty else {
                return unavailableIndicator(for: config)
            }

            let latestObs = observations[0]
            let previousObs = observations.count > 1 ? observations[1] : nil

            let currentValue = Double(latestObs.value)
            let previousValue = previousObs.flatMap { Double($0.value) }

            let direction: MacroDirection
            if let current = currentValue, let previous = previousValue {
                let diff = current - previous
                let threshold = abs(previous) * 0.001
                if diff > threshold {
                    direction = .up
                } else if diff < -threshold {
                    direction = .down
                } else {
                    direction = .flat
                }
            } else {
                direction = .flat
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let lastUpdated = dateFormatter.date(from: latestObs.date)

            return MacroIndicator(
                id: config.id,
                title: config.title,
                value: currentValue,
                previousValue: previousValue,
                direction: direction,
                lastUpdated: lastUpdated,
                displayFormat: config.displayFormat,
                seriesID: config.id
            )
        } catch {
            print("[TouchGrassBTC] FRED \(config.id) failed: \(error.localizedDescription)")
            return unavailableIndicator(for: config)
        }
    }

    private func unavailableIndicator(for config: SeriesConfig) -> MacroIndicator {
        MacroIndicator(
            id: config.id,
            title: config.title,
            value: nil,
            previousValue: nil,
            direction: .flat,
            lastUpdated: nil,
            displayFormat: config.displayFormat,
            seriesID: config.id
        )
    }

    func calculateBackdrop(indicators: [MacroIndicator]) -> MacroBackdrop {
        var restrictiveCount = 0
        var supportiveCount = 0

        for indicator in indicators {
            guard let value = indicator.value else { continue }

            switch indicator.seriesID {
            case "FEDFUNDS":
                if value >= 5.0 { restrictiveCount += 1 }
                else if value <= 2.0 { supportiveCount += 1 }
            case "DGS10":
                if value >= 4.5 { restrictiveCount += 1 }
                else if value <= 2.5 { supportiveCount += 1 }
            case "DGS2":
                if value >= 4.5 { restrictiveCount += 1 }
                else if value <= 2.0 { supportiveCount += 1 }
            case "UNRATE":
                if value >= 5.0 { restrictiveCount += 1 }
                else if value <= 4.0 { supportiveCount += 1 }
            case "STLFSI2":
                if value > 1.0 { restrictiveCount += 1 }
                else if value < -0.5 { supportiveCount += 1 }
            case "WALCL":
                if indicator.direction == .up { supportiveCount += 1 }
                else if indicator.direction == .down { restrictiveCount += 1 }
            default:
                break
            }
        }

        if supportiveCount >= 3 && restrictiveCount <= 1 {
            return .supportive
        } else if restrictiveCount >= 3 && supportiveCount <= 1 {
            return .restrictive
        }
        return .neutral
    }
}
