import SwiftUI

struct HistoricalCycleComparisonView: View {
    let currentPrice: Double

    private let epochs = CycleHistoryData.epochs

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "chart.bar.xaxis", title: "HISTORICAL CYCLE COMPARISON")

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    headerRow
                    ForEach(epochs) { epoch in
                        epochRow(epoch)
                    }
                }
                .padding(.horizontal, 2)
            }
            .contentMargins(.horizontal, 0)

            Text("Diminishing returns with shallower drawdowns each cycle. Past patterns don't guarantee future outcomes.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .premiumCard(.highlighted)
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            headerCell("EPOCH", width: 48)
            headerCell("HALVING", width: 78)
            headerCell("CYCLE LOW", width: 80)
            headerCell("CYCLE HIGH", width: 86)
            headerCell("LOW→HIGH", width: 72)
            headerCell("HIGH→LOW", width: 72)
            headerCell("RETURN", width: 76)
            headerCell("DRAWDOWN", width: 72)
        }
        .padding(.vertical, 10)
        .background(Color.primary.opacity(0.04))
        .clipShape(.rect(cornerRadius: 8))
    }

    private func headerCell(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .heavy))
            .foregroundStyle(.tertiary)
            .tracking(0.5)
            .frame(width: width)
            .multilineTextAlignment(.center)
    }

    private func epochRow(_ epoch: CycleEpoch) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 4) {
                Text("\(epoch.id)")
                    .font(.system(.caption, design: .monospaced, weight: .heavy))
                    .foregroundStyle(.orange)
                if epoch.isCurrent {
                    Text("NOW")
                        .font(.system(size: 7, weight: .heavy))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.orange.opacity(0.15))
                        .clipShape(.rect(cornerRadius: 3))
                }
            }
            .frame(width: 48)

            Text(epoch.halvingDateFormatted)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 78)

            VStack(spacing: 1) {
                Text(formatPrice(epoch.cycleLowPrice))
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(red: 0.2, green: 0.85, blue: 0.5))
                Text(epoch.cycleLowDateFormatted)
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundStyle(.quaternary)
            }
            .frame(width: 80)

            VStack(spacing: 1) {
                Text(formatPrice(epoch.cycleHighPrice))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
                Text(epoch.cycleHighDateFormatted)
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundStyle(.quaternary)
            }
            .frame(width: 86)

            VStack(spacing: 1) {
                Text("\(epoch.lowToHighDays)d")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(red: 0.2, green: 0.85, blue: 0.5))
                Text("~\(epoch.lowToHighMonths)mo")
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundStyle(.quaternary)
            }
            .frame(width: 72)

            VStack(spacing: 1) {
                if let days = epoch.highToLowDays {
                    Text("\(days)d")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.95, green: 0.3, blue: 0.3))
                    if let months = epoch.highToLowMonths {
                        Text("~\(months)mo")
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundStyle(.quaternary)
                    }
                } else {
                    Text("\(CycleHistoryData.daysSincePeak(from: epoch.cycleHighDate))d")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.95, green: 0.3, blue: 0.3))
                    Text("ongoing")
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundStyle(.quaternary)
                }
            }
            .frame(width: 72)

            if let ret = epoch.returnPercent {
                Text("+\(formatReturn(ret))")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(red: 0.2, green: 0.85, blue: 0.5))
                    .frame(width: 76)
            } else {
                Text("TBD")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .frame(width: 76)
            }

            Text("\(String(format: "%.1f", epoch.drawdownPercent))%")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Color(red: 0.95, green: 0.3, blue: 0.3))
                .frame(width: 72)
        }
        .padding(.vertical, 10)
        .background(epoch.isCurrent ? Color.orange.opacity(0.04) : .clear)
        .overlay(alignment: .bottom) {
            if epoch.id < 4 {
                Divider().overlay(Color.primary.opacity(0.04))
            }
        }
    }

    private func formatPrice(_ price: Double) -> String {
        if price >= 1000 {
            return "$\(Int(price).formatted(.number))"
        }
        if price >= 1 {
            return "$\(Int(round(price)).formatted(.number))"
        }
        return "$\(String(format: "%.2f", price))"
    }

    private func formatReturn(_ value: Double) -> String {
        if value >= 1000 {
            return "\(Int(value).formatted(.number))%"
        }
        return "\(String(format: "%.0f", value))%"
    }
}
