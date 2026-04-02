import SwiftUI
import Charts

struct IndicatorsTab: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 720 : .infinity }
    private var horizontalPadding: CGFloat { isRegular ? 32 : 20 }

    private var allIndicators: [(icon: String, title: String, value: String, status: String, statusColor: Color, detail: String)] {
        var items: [(String, String, String, String, Color, String)] = []

        if let ma = viewModel.movingAverages {
            items.append((
                "chart.xyaxis.line",
                "200-Day EMA",
                formatPrice(ma.ema200Day),
                ma.isAboveEMA ? "Bull" : "Bear",
                ma.isAboveEMA ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3),
                "Price is \(String(format: "%.1f%%", abs(ma.priceVsEMA))) \(ma.isAboveEMA ? "above" : "below") the 200-day exponential moving average. This long-term trend line separates bullish and bearish market structure."
            ))

            items.append((
                "chart.line.flattrend.xyaxis",
                "200-Week MA",
                formatPrice(ma.estimated200WMA),
                ma.isAbove200WMA ? "Above" : "Below",
                ma.isAbove200WMA ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3),
                "Price is \(String(format: "%.1f%%", abs(ma.priceVs200WMA))) \(ma.isAbove200WMA ? "above" : "below") the estimated 200-week moving average. This acts as a long-term floor in Bitcoin's history."
            ))
        }

        items.append((
            "waveform.path.ecg",
            "MVRV Z-Score",
            String(format: "%.2f", viewModel.mvrvZScore),
            viewModel.mvrvZone.label,
            viewModel.mvrvZone.color,
            viewModel.mvrvZone.description
        ))

        items.append((
            "pickaxe",
            "Puell Multiple",
            String(format: "%.2f", viewModel.puellMultiple),
            viewModel.puellZone.label,
            viewModel.puellZone.color,
            viewModel.puellZone.description
        ))

        let s2f = s2fStatus
        items.append((
            "cube.box",
            "Stock-to-Flow",
            String(format: "%.2fx", viewModel.stockToFlowRatio),
            s2f.label,
            s2f.color,
            s2f.detail
        ))

        if let sp = viewModel.supplyInProfit {
            items.append((
                "chart.pie",
                "Supply in Profit",
                String(format: "%.0f%%", sp.estimatedPercent),
                sp.zone.label,
                sp.zone.color,
                sp.zone.description
            ))
        }

        return items
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading && viewModel.price == 0 {
                        loadingView
                    } else {
                        sentimentCard
                            .padding(.top, 8)

                        indicatorGrid

                        disclaimer
                    }
                }
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .refreshable { await viewModel.loadData() }
            .navigationTitle("Indicators")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.1)
                .tint(.orange.opacity(0.5))
            Text("Loading")
                .font(.caption)
                .foregroundStyle(.quaternary)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 400)
    }

    private var sentimentCard: some View {
        let level = viewModel.fearGreedLevel

        return VStack(spacing: 14) {
            HStack {
                Text("MARKET SENTIMENT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .tracking(1)
                Spacer()
            }

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(level.color.opacity(0.15), lineWidth: 5)
                    Circle()
                        .trim(from: 0, to: Double(viewModel.fearGreedValue) / 100.0)
                        .stroke(level.color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(duration: 0.6), value: viewModel.fearGreedValue)

                    Text("\(viewModel.fearGreedValue)")
                        .font(.system(.title3, design: .monospaced, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Fear & Greed Index")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(level.label)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(level.color)

                    Text(level.signalDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
    }

    private var indicatorGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(allIndicators.enumerated()), id: \.offset) { _, indicator in
                IndicatorCardView(
                    icon: indicator.icon,
                    title: indicator.title,
                    value: indicator.value,
                    status: indicator.status,
                    statusColor: indicator.statusColor,
                    detail: indicator.detail
                )
            }
        }
    }

    private var s2fStatus: (label: String, color: Color, detail: String) {
        let ratio = viewModel.stockToFlowRatio
        if ratio < 0.5 {
            return ("Undervalued", .green, "Price is significantly below the Stock-to-Flow model price. Historically, these periods precede major price appreciation as scarcity becomes the dominant narrative.")
        } else if ratio < 1.5 {
            return ("Fair Value", .blue, "Price is near the Stock-to-Flow model estimate. The market is fairly priced relative to Bitcoin's scarcity schedule and halving-driven supply reduction.")
        } else {
            return ("Extended", .orange, "Price is above the Stock-to-Flow model estimate. Historically, extended periods may indicate overvaluation relative to the scarcity model.")
        }
    }

    private var disclaimer: some View {
        Text("BitShrug provides general market context for informational purposes only. It does not provide financial advice or predict future price movements.")
            .font(.caption2)
            .foregroundStyle(.quaternary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }

    private func formatPrice(_ value: Double) -> String {
        "$\(Int(value).formatted(.number))"
    }
}
