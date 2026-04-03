import SwiftUI
import Charts

struct PowerLawChartView: View {
    let prices: [PricePoint]
    let supportPrice: Double
    let resistancePrice: Double
    let currentPrice: Double

    private var chartData: [PowerLawPoint] {
        guard prices.count > 30 else { return [] }
        let sampled = stride(from: 0, to: prices.count, by: max(1, prices.count / 60)).map { prices[$0] }
        return sampled.map { point in
            let daysSinceGenesis = Calendar.current.dateComponents([.day], from: genesisDate(), to: point.date).day ?? 1
            let days = Double(max(daysSinceGenesis, 1))
            let logDays = log10(days)
            let logSupport = 5.82 * logDays - 17.47
            let logFairValue = 5.82 * logDays - 17.01
            let logResistance = 5.82 * logDays - 16.61
            return PowerLawPoint(
                date: point.date,
                price: point.price,
                support: pow(10, logSupport),
                fairValue: pow(10, logFairValue),
                resistance: pow(10, logResistance)
            )
        }
    }

    private var yRange: ClosedRange<Double> {
        guard !chartData.isEmpty else { return 1000...500000 }
        let allValues = chartData.flatMap { [$0.price, $0.support, $0.resistance] }
        let mn = max((allValues.min() ?? 1000) * 0.5, 1)
        let mx = (allValues.max() ?? 500000) * 1.5
        return mn...mx
    }

    var body: some View {
        Chart {
            ForEach(chartData, id: \.date) { point in
                AreaMark(
                    x: .value("Date", point.date),
                    yStart: .value("Support", point.support),
                    yEnd: .value("Resistance", point.resistance)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [Color.green.opacity(0.08), Color.red.opacity(0.08)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .interpolationMethod(.catmullRom)
            }

            ForEach(chartData, id: \.date) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Support", point.support),
                    series: .value("Series", "Support")
                )
                .foregroundStyle(.green.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1))
                .interpolationMethod(.catmullRom)
            }

            ForEach(chartData, id: \.date) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("FairValue", point.fairValue),
                    series: .value("Series", "FairValue")
                )
                .foregroundStyle(.yellow.opacity(0.4))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                .interpolationMethod(.catmullRom)
            }

            ForEach(chartData, id: \.date) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Resistance", point.resistance),
                    series: .value("Series", "Resistance")
                )
                .foregroundStyle(.red.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1))
                .interpolationMethod(.catmullRom)
            }

            ForEach(chartData, id: \.date) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Price", point.price),
                    series: .value("Series", "Price")
                )
                .foregroundStyle(.orange)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartYScale(domain: yRange, type: .log)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date.formatted(.dateTime.month(.abbreviated).year(.twoDigits)))
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 5)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                    .foregroundStyle(.quaternary)
                AxisValueLabel {
                    if let price = value.as(Double.self) {
                        Text(formatAxisPrice(price))
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .chartLegend(.hidden)
        .frame(height: 220)
    }

    private func formatAxisPrice(_ price: Double) -> String {
        if price >= 1_000_000 {
            return "$\(String(format: "%.1fM", price / 1_000_000))"
        } else if price >= 1000 {
            return "$\(Int(price / 1000))k"
        } else {
            return "$\(Int(price))"
        }
    }

    private func genesisDate() -> Date {
        var components = DateComponents()
        components.year = 2009
        components.month = 1
        components.day = 3
        return Calendar.current.date(from: components) ?? Date()
    }
}

nonisolated struct PowerLawPoint: Sendable {
    let date: Date
    let price: Double
    let support: Double
    let fairValue: Double
    let resistance: Double
}
