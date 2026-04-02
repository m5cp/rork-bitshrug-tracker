import Foundation

@Observable
class ScoreHistoryManager {
    static let shared = ScoreHistoryManager()

    private let key = "bitshrug_score_history"
    private let maxEntries = 90

    var entries: [ScoreHistoryEntry] = []

    private init() {
        loadEntries()
    }

    func record(score: Int, price: Double) {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastIndex = entries.lastIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            entries[lastIndex] = ScoreHistoryEntry(date: today, score: score, price: price)
        } else {
            entries.append(ScoreHistoryEntry(date: today, score: score, price: price))
        }

        if entries.count > maxEntries {
            entries = Array(entries.suffix(maxEntries))
        }

        saveEntries()
    }

    func writeToSharedDefaults(score: Int, price: Double, label: String, change24h: Double) {
        let shared = UserDefaults(suiteName: "group.app.rork.mh5qf4z0nqy7olvg1im36")
        shared?.set(score, forKey: "widget_score")
        shared?.set(price, forKey: "widget_price")
        shared?.set(label, forKey: "widget_label")
        shared?.set(change24h, forKey: "widget_change24h")
        shared?.set(Date().timeIntervalSinceReferenceDate, forKey: "widget_updated")
    }

    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            entries = try JSONDecoder().decode([ScoreHistoryEntry].self, from: data)
        } catch {}
    }

    private func saveEntries() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: key)
        } catch {}
    }
}

nonisolated struct ScoreHistoryEntry: Codable, Sendable, Identifiable {
    let date: Date
    let score: Int
    let price: Double

    nonisolated var id: Date { date }
}
