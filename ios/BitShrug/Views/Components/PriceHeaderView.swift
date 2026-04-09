import SwiftUI
import Charts

struct PriceHeaderView: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                if viewModel.price > 0 {
                    Text(viewModel.formattedPrice)
                        .font(.system(size: isRegular ? 48 : 38, weight: .bold, design: .default))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())

                    Text(viewModel.formattedChange)
                        .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                        .foregroundStyle(viewModel.change24h >= 0 ? .green.opacity(0.8) : .red.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            (viewModel.change24h >= 0 ? Color.green : Color.red).opacity(0.1)
                        )
                        .clipShape(Capsule())
                } else {
                    Text("—")
                        .font(.system(size: isRegular ? 48 : 38, weight: .bold))
                        .foregroundStyle(.quaternary)
                }

                Spacer()
            }
            .padding(.bottom, 6)

            HStack(spacing: 16) {
                metricPill(label: "MCap", value: viewModel.formattedMarketCap)
                metricPill(label: "Vol", value: viewModel.formattedVolume)

                if let c7 = viewModel.change7d {
                    metricPill(label: "7d", value: String(format: "%+.1f%%", c7))
                }

                Spacer()
            }

            if viewModel.historicalPrices.count > 30 {
                sparkline
                    .padding(.top, 12)
            }
        }
    }

    private func metricPill(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    private var sparkline: some View {
        let points = Array(viewModel.historicalPrices.suffix(90))
        return Chart(points, id: \.date) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Price", point.price)
            )
            .foregroundStyle(.orange.opacity(0.6))
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Date", point.date),
                y: .value("Price", point.price)
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [.orange.opacity(0.15), .orange.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: .automatic(includesZero: false))
        .frame(height: 50)
        .clipShape(.rect(cornerRadius: 8))
    }
}
