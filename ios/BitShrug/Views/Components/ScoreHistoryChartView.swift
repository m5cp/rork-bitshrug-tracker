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
        if last.score >= 75 { return Color(red: 0.2, green: 0.85, blue: 0.5) }
        if last.score >= 55 { return .orange }
        if last.score >= 35 { return Color(red: 0.95, green: 0.6, blue: 0.2) }
        return Color(red: 0.95, green: 0.3, blue: 0.3)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.orange)
                Text("SCORE HISTORY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .tracking(1)
                Spacer()

                if chartEntries.count >= 2 {
                    let first = chartEntries.first!.score
                    let last = chartEntries.last!.score
                    let delta = last - first
                    Text("\(delta >= 0 ? "+" : "")\(delta) pts")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(delta >= 0 ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3))
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
                        .lineStyle(StrokeStyle(lineWidth: 2))
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
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
    }
}
