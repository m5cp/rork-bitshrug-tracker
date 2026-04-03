import SwiftUI

struct ProjectedCycleBottomView: View {
    let currentPrice: Double

    private var cycleHigh: Double {
        CycleHistoryData.currentEpoch?.cycleHighPrice ?? 126279
    }

    private var peakDate: Date {
        CycleHistoryData.currentEpoch?.cycleHighDate ?? Date()
    }

    private var shallow: Double { CycleHistoryData.projectedBottomShallow(from: cycleHigh) }
    private var average: Double { CycleHistoryData.projectedBottomAverage(from: cycleHigh) }
    private var deep: Double { CycleHistoryData.projectedBottomDeep(from: cycleHigh) }

    private var currentDrawdown: Double {
        guard cycleHigh > 0 else { return 0 }
        return (1 - currentPrice / cycleHigh) * 100
    }

    private var daysSincePeak: Int { CycleHistoryData.daysSincePeak(from: peakDate) }
    private var daysUntilBottom: Int { CycleHistoryData.daysUntilEstimatedBottom(from: peakDate) }
    private var estBottomDate: Date { CycleHistoryData.estimatedBottomDate(from: peakDate) }
    private var avgHighToLow: Int { CycleHistoryData.averageHighToLowDays }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "chart.line.downtrend.xyaxis", iconColor: Color(red: 0.95, green: 0.3, blue: 0.3), title: "PROJECTED CYCLE BOTTOM")

            HStack(spacing: 8) {
                projectionCard(
                    label: "SHALLOW (LIKE CYCLE 3)",
                    labelColor: Color(red: 0.2, green: 0.85, blue: 0.5),
                    price: shallow,
                    drawdown: -77.6
                )
                projectionCard(
                    label: "AVERAGE OF PRIOR CYCLES",
                    labelColor: .orange,
                    price: average,
                    drawdown: CycleHistoryData.averageDrawdown
                )
                projectionCard(
                    label: "DEEP (LIKE CYCLE 1)",
                    labelColor: Color(red: 0.95, green: 0.3, blue: 0.3),
                    price: deep,
                    drawdown: -86.9
                )
            }

            drawdownProgressBar

            HStack(spacing: 8) {
                bottomStatCell(
                    label: "EST. BOTTOM",
                    value: formatBottomDate(estBottomDate),
                    detail: "\(daysUntilBottom)d away"
                )
                bottomStatCell(
                    label: "HIGH → LOW",
                    value: "\(avgHighToLow)d",
                    detail: "~\(Int((Double(avgHighToLow) / 30.44).rounded()))  months"
                )
                bottomStatCell(
                    label: "SINCE PEAK",
                    value: "\(daysSincePeak)d",
                    detail: "\(Int(Double(daysSincePeak) / Double(max(avgHighToLow, 1)) * 100))% of avg"
                )
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.orange.opacity(0.6))

                Text("Projected bottom estimates are based on historical drawdown percentages from cycle tops. Each post-peak bear market has shown diminishing drawdown severity (86.9% → 84.2% → 77.6%). If the trend of shallower bear markets continues, the actual bottom could be closer to the optimistic estimate.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(Color.orange.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.orange.opacity(0.08), lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: 10))
        }
        .premiumCard(.highlighted)
    }

    private func projectionCard(label: String, labelColor: Color, price: Double, drawdown: Double) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 8, weight: .heavy))
                .foregroundStyle(labelColor)
                .tracking(0.3)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("$\(Int(price).formatted(.number))")
                .font(.system(.subheadline, design: .monospaced, weight: .bold))
                .foregroundStyle(labelColor)

            Text("\(String(format: "%.1f", drawdown))%")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .background(labelColor.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(labelColor.opacity(0.1), lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 12))
    }

    private var drawdownProgressBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Current drawdown vs historical bottoms")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("-\(String(format: "%.1f", currentDrawdown))%")
                    .font(.system(.caption2, design: .monospaced, weight: .bold))
                    .foregroundStyle(Color(red: 0.95, green: 0.3, blue: 0.3))
            }

            GeometryReader { geo in
                let totalWidth = geo.size.width
                let maxDrawdown: Double = 90
                let currentFill = min(currentDrawdown / maxDrawdown, 1.0)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.06))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.3, blue: 0.3), .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: totalWidth * currentFill)

                    drawdownMarker(at: 86.9 / maxDrawdown, totalWidth: totalWidth, label: "C1: -86.9%")
                    drawdownMarker(at: 84.2 / maxDrawdown, totalWidth: totalWidth, label: "C2: -84.2%")
                    drawdownMarker(at: 77.6 / maxDrawdown, totalWidth: totalWidth, label: "C3: -77.6%")
                }
            }
            .frame(height: 8)

            HStack {
                Text("0%")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(.quaternary)
                Spacer()
                Text("C1: -86.9%")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(.quaternary)
                Text("C2: -84.2%")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(.quaternary)
                Text("C3: -77.6%")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(.quaternary)
            }
        }
    }

    private func drawdownMarker(at fraction: Double, totalWidth: CGFloat, label: String) -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.6))
            .frame(width: 2, height: 12)
            .offset(x: totalWidth * min(fraction, 1.0))
    }

    private func bottomStatCell(label: String, value: String, detail: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .heavy))
                .foregroundStyle(.tertiary)
                .tracking(0.3)

            Text(value)
                .font(.system(.footnote, design: .monospaced, weight: .bold))
                .foregroundStyle(.primary)

            Text(detail)
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(.quaternary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.03))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 10))
    }

    private func formatBottomDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
