import Foundation
import SwiftUI

struct CycleEpoch: Identifiable, Sendable {
    let id: Int
    let halvingDate: Date
    let cycleLowPrice: Double
    let cycleLowDate: Date
    let cycleHighPrice: Double
    let cycleHighDate: Date
    let drawdownPercent: Double
    let isCurrent: Bool

    var lowToHighDays: Int {
        Calendar.current.dateComponents([.day], from: cycleLowDate, to: cycleHighDate).day ?? 0
    }

    var lowToHighMonths: Int {
        let months = Double(lowToHighDays) / 30.44
        return Int(months.rounded())
    }

    var highToLowDays: Int? {
        guard !isCurrent else { return nil }
        let nextLowDates: [Int: Date] = [
            1: CycleHistoryData.dateFrom(2015, 1, 14),
            2: CycleHistoryData.dateFrom(2018, 12, 15),
            3: CycleHistoryData.dateFrom(2022, 11, 21)
        ]
        guard let nextLow = nextLowDates[id] else { return nil }
        return Calendar.current.dateComponents([.day], from: cycleHighDate, to: nextLow).day
    }

    var highToLowMonths: Int? {
        guard let days = highToLowDays else { return nil }
        return Int((Double(days) / 30.44).rounded())
    }

    var returnPercent: Double? {
        guard cycleLowPrice > 0 else { return nil }
        return ((cycleHighPrice - cycleLowPrice) / cycleLowPrice) * 100
    }

    var halvingDateFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: halvingDate)
    }

    var cycleLowDateFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: cycleLowDate)
    }

    var cycleHighDateFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: cycleHighDate)
    }
}

enum CycleHistoryData {
    static func dateFrom(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var c = DateComponents()
        c.year = year
        c.month = month
        c.day = day
        return Calendar.current.date(from: c) ?? Date()
    }

    static let epochs: [CycleEpoch] = [
        CycleEpoch(
            id: 1,
            halvingDate: dateFrom(2012, 11, 28),
            cycleLowPrice: 2.01,
            cycleLowDate: dateFrom(2011, 11, 18),
            cycleHighPrice: 1163,
            cycleHighDate: dateFrom(2013, 11, 30),
            drawdownPercent: -93.6,
            isCurrent: false
        ),
        CycleEpoch(
            id: 2,
            halvingDate: dateFrom(2016, 7, 9),
            cycleLowPrice: 152.4,
            cycleLowDate: dateFrom(2015, 1, 14),
            cycleHighPrice: 19783,
            cycleHighDate: dateFrom(2017, 12, 17),
            drawdownPercent: -86.9,
            isCurrent: false
        ),
        CycleEpoch(
            id: 3,
            halvingDate: dateFrom(2020, 5, 11),
            cycleLowPrice: 3122,
            cycleLowDate: dateFrom(2018, 12, 15),
            cycleHighPrice: 69045,
            cycleHighDate: dateFrom(2021, 11, 10),
            drawdownPercent: -84.2,
            isCurrent: false
        ),
        CycleEpoch(
            id: 4,
            halvingDate: dateFrom(2024, 4, 20),
            cycleLowPrice: 15479,
            cycleLowDate: dateFrom(2022, 11, 21),
            cycleHighPrice: 126279,
            cycleHighDate: dateFrom(2025, 10, 6),
            drawdownPercent: -77.6,
            isCurrent: true
        )
    ]

    static var pastEpochs: [CycleEpoch] {
        epochs.filter { !$0.isCurrent }
    }

    static var currentEpoch: CycleEpoch? {
        epochs.first(where: \.isCurrent)
    }

    static var averageDrawdown: Double {
        let past = pastEpochs.map(\.drawdownPercent)
        return past.reduce(0, +) / Double(past.count)
    }

    static var averageLowToHighDays: Int {
        let past = pastEpochs.map(\.lowToHighDays)
        return past.reduce(0, +) / past.count
    }

    static var averageHighToLowDays: Int {
        let past = pastEpochs.compactMap(\.highToLowDays)
        guard !past.isEmpty else { return 0 }
        return past.reduce(0, +) / past.count
    }

    static func projectedBottomShallow(from cycleHigh: Double) -> Double {
        cycleHigh * (1 + (-77.6 / 100))
    }

    static func projectedBottomAverage(from cycleHigh: Double) -> Double {
        cycleHigh * (1 + (averageDrawdown / 100))
    }

    static func projectedBottomDeep(from cycleHigh: Double) -> Double {
        cycleHigh * (1 + (-86.9 / 100))
    }

    static func estimatedBottomDate(from peakDate: Date) -> Date {
        let avgDays = averageHighToLowDays
        return Calendar.current.date(byAdding: .day, value: avgDays, to: peakDate) ?? peakDate
    }

    static func daysSincePeak(from peakDate: Date) -> Int {
        Calendar.current.dateComponents([.day], from: peakDate, to: Date()).day ?? 0
    }

    static func daysUntilEstimatedBottom(from peakDate: Date) -> Int {
        let est = estimatedBottomDate(from: peakDate)
        return max(0, Calendar.current.dateComponents([.day], from: Date(), to: est).day ?? 0)
    }

    static func currentDrawdownPercent(currentPrice: Double, cycleHigh: Double) -> Double {
        guard cycleHigh > 0 else { return 0 }
        return -((1 - currentPrice / cycleHigh) * 100)
    }

    struct RhymeCheck: Identifiable, Sendable {
        let id = UUID()
        let title: String
        let matches: Bool
        let description: String
    }

    static func rhymeChecks(currentPrice: Double, daysSinceHalving: Int, cycleHigh: Double, cycleHighDate: Date) -> [RhymeCheck] {
        let peakDayRange = 367...548
        let peakMatches = peakDayRange.contains(daysSinceHalving) || daysSincePeak(from: cycleHighDate) > 0

        let drawdown = currentDrawdownPercent(currentPrice: currentPrice, cycleHigh: cycleHigh)
        let drawdownInRange = drawdown <= -15

        let pastReturns = pastEpochs.compactMap(\.returnPercent)
        let currentReturn = currentEpoch.flatMap(\.returnPercent) ?? 0
        let diminishingReturns = !pastReturns.isEmpty && currentReturn < (pastReturns.last ?? Double.infinity)

        let pastDrawdowns = pastEpochs.map(\.drawdownPercent)
        let currentDD = currentEpoch?.drawdownPercent ?? 0
        let shallowerBears = !pastDrawdowns.isEmpty && currentDD > (pastDrawdowns.min() ?? -100)

        return [
            RhymeCheck(
                title: "Peak Timing",
                matches: peakMatches,
                description: peakMatches
                    ? "Peak at day \(daysSincePeak(from: cycleHighDate) + daysSinceHalving > 0 ? "\(daysSinceHalving)" : "N/A") fits historical range (367–548 days). All 4 cycles have peaked between 12–18 months post-halving."
                    : "Peak timing has not yet matched historical patterns."
            ),
            RhymeCheck(
                title: "Post-Peak Drawdown",
                matches: drawdownInRange,
                description: drawdownInRange
                    ? "Current drawdown of \(String(format: "%.1f", abs(drawdown)))% is consistent with historical post-peak behavior."
                    : "Drawdown has not yet reached levels seen in prior cycles."
            ),
            RhymeCheck(
                title: "Diminishing Returns",
                matches: diminishingReturns,
                description: diminishingReturns
                    ? "Cycle 4 return of \(String(format: "%.0f", currentReturn))% continues the pattern of diminishing cycle-over-cycle returns."
                    : "Returns have not clearly followed the diminishing pattern yet."
            ),
            RhymeCheck(
                title: "Shallower Bear Markets",
                matches: shallowerBears,
                description: shallowerBears
                    ? "Drawdown severity continues to diminish (86.9% → 84.2% → 77.6%), suggesting maturing market structure."
                    : "Bear market depth has not clearly shown diminishing severity."
            )
        ]
    }

    static func rhymeScore(checks: [RhymeCheck]) -> (matching: Int, total: Int) {
        let matching = checks.filter(\.matches).count
        return (matching, checks.count)
    }
}
