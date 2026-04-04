import SwiftUI
import Charts

struct PortfolioSparklineView: View {
    let historicalPrices: [PricePoint]
    let btcHoldings: Double

    private var portfolioData: [(date: Date, value: Double)] {
        historicalPrices.suffix(90).map { point in
            (date: point.date, value: point.price * btcHoldings)
        }
    }

    private var minValue: Double {
        portfolioData.map(\.value).min() ?? 0
    }

    private var maxValue: Double {
        portfolioData.map(\.value).max() ?? 1
    }

    private var isPositive: Bool {
        guard let first = portfolioData.first?.value, let last = portfolioData.last?.value else { return true }
        return last >= first
    }

    private var changePercent: Double {
        guard let first = portfolioData.first?.value, first > 0, let last = portfolioData.last?.value else { return 0 }
        return ((last - first) / first) * 100
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                SectionHeader(icon: "chart.xyaxis.line", title: "90-DAY VALUE")
                Spacer()
                Text("\(isPositive ? "+" : "")\(String(format: "%.1f", changePercent))%")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundStyle(AppColors.changeColor(positive: isPositive))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.changeColor(positive: isPositive).opacity(0.12))
                    .clipShape(Capsule())
            }

            if portfolioData.count >= 2 {
                Chart {
                    ForEach(Array(portfolioData.enumerated()), id: \.offset) { _, point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Value", point.value)
                        )
                        .foregroundStyle(isPositive ? AppColors.bullish : AppColors.bearish)
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("Date", point.date),
                            yStart: .value("Min", minValue),
                            yEnd: .value("Value", point.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    (isPositive ? AppColors.bullish : AppColors.bearish).opacity(0.2),
                                    (isPositive ? AppColors.bullish : AppColors.bearish).opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: minValue * 0.98...maxValue * 1.02)
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { value in
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text(formatCompact(v))
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(height: 120)
            } else {
                Text("Not enough price history")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
            }
        }
        .premiumCard()
    }

    private func formatCompact(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return "$\(Int(value / 1000))k"
        }
        return "$\(Int(value))"
    }
}
