import SwiftUI
import Charts

struct ScoreHistoryChartView: View {
    let entries: [ScoreHistoryEntry]

    private var chartEntries: [ScoreHistoryEntry] {
        Array(entries.suffix(30))
    }

    private var scoreRange: ClosedRange<Int> {
        guard !chartEntries.isEmpty else { return 0...100 }
        let scores = chartEntries.map(\.score)
        let mn = max(0, (scores.min() ?? 0) - 10)
        let mx = min(100, (scores.max() ?? 100) + 10)
        return mn...mx
    }

    private var scoreColor: Color {
        guard let last = chartEntries.last else { return .orange }
        return AppColors.scoreColor(for: last.score)
    }

    private var averageScore: Int {
        guard !chartEntries.isEmpty else { return 0 }
        return chartEntries.map(\.score).reduce(0, +) / chartEntries.count
    }

    private var highScore: Int {
        chartEntries.map(\.score).max() ?? 0
    }

    private var lowScore: Int {
        chartEntries.map(\.score).min() ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "chart.line.uptrend.xyaxis", title: "SCORE HISTORY") {
                if chartEntries.count >= 2 {
                    let first = chartEntries.first!.score
                    let last = chartEntries.last!.score
                    let delta = last - first
                    Text("\(delta >= 0 ? "+" : "")\(delta) pts")
                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                        .foregroundStyle(AppColors.changeColor(positive: delta >= 0))
                }
            }

            if chartEntries.count >= 2 {
                Chart {
                    ForEach(chartEntries) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Score", entry.score)
                        )
                        .foregroundStyle(scoreColor)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                    }

                    ForEach(chartEntries) { entry in
                        AreaMark(
                            x: .value("Date", entry.date),
                            y: .value("Score", entry.score)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [scoreColor.opacity(0.2), scoreColor.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: scoreRange)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(.dateTime.month(.abbreviated).day()))
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { value in
                        AxisValueLabel {
                            if let score = value.as(Int.self) {
                                Text("\(score)")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                .frame(height: 120)
                if chartEntries.count >= 2 {
                    HStack(spacing: 0) {
                        statPill(label: "Avg", value: "\(averageScore)")
                        Spacer()
                        statPill(label: "High", value: "\(highScore)")
                        Spacer()
                        statPill(label: "Low", value: "\(lowScore)")
                        Spacer()
                        statPill(label: "Days", value: "\(chartEntries.count)")
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24))
                        .foregroundStyle(.tertiary)
                    Text("Score history builds over time")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
            }
        }
        .premiumCard(.highlighted)
    }

    private func statPill(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}
