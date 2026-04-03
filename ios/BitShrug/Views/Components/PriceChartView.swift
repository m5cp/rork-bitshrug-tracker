import SwiftUI
import Charts

struct PriceChartView: View {
    let prices: [PricePoint]
    let movingAverages: MovingAverageData?
    @State private var selectedRange: ChartRange = .threeMonth
    @State private var selectedPoint: PricePoint?

    private var filteredPrices: [PricePoint] {
        let cutoff: Int
        switch selectedRange {
        case .oneWeek: cutoff = 7
        case .oneMonth: cutoff = 30
        case .threeMonth: cutoff = 90
        case .sixMonth: cutoff = 180
        case .oneYear: cutoff = 365
        }
        return Array(prices.suffix(min(cutoff, prices.count)))
    }

    private var priceRange: ClosedRange<Double> {
        let pts = filteredPrices.map(\.price)
        guard let mn = pts.min(), let mx = pts.max(), mn < mx else {
            return 0...1
        }
        let padding = (mx - mn) * 0.05
        return (mn - padding)...(mx + padding)
    }

    private var isPositive: Bool {
        guard let first = filteredPrices.first, let last = filteredPrices.last else { return true }
        return last.price >= first.price
    }

    private var chartColor: Color {
        isPositive ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3)
    }

    var body: some View {
        VStack(spacing: 12) {
            if let point = selectedPoint {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(point.date.formatted(.dateTime.month(.abbreviated).day().year()))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("$\(Int(point.price).formatted(.number))")
                            .font(.system(.title3, design: .monospaced, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 4)
            }

            chart
                .frame(height: 200)
                .chartYScale(domain: priceRange)

            rangePicker
        }
    }

    private var chart: some View {
        Chart {
            ForEach(filteredPrices, id: \.date) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Price", point.price)
                )
                .foregroundStyle(chartColor)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }

            ForEach(filteredPrices, id: \.date) { point in
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Price", point.price)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [chartColor.opacity(0.2), chartColor.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }

            if let ma = movingAverages, selectedRange == .oneYear || selectedRange == .sixMonth {
                RuleMark(y: .value("200 EMA", ma.ema200Day))
                    .foregroundStyle(.orange.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("200 EMA")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(.orange.opacity(0.6))
                    }
            }

            if let point = selectedPoint {
                RuleMark(x: .value("Selected", point.date))
                    .foregroundStyle(.white.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Price", point.price)
                )
                .foregroundStyle(.white)
                .symbolSize(40)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
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
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
                AxisValueLabel {
                    if let price = value.as(Double.self) {
                        Text("$\(Int(price / 1000))k")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x
                                if let date: Date = proxy.value(atX: x) {
                                    selectedPoint = filteredPrices.min(by: {
                                        abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                                    })
                                }
                            }
                            .onEnded { _ in
                                selectedPoint = nil
                            }
                    )
            }
        }
    }

    private var rangePicker: some View {
        HStack(spacing: 0) {
            ForEach(ChartRange.allCases, id: \.self) { range in
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        selectedRange = range
                    }
                } label: {
                    Text(range.label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(selectedRange == range ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(
                            selectedRange == range
                                ? Color.primary.opacity(0.12)
                                : Color.clear
                        )
                        .clipShape(.rect(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color.primary.opacity(0.05))
        .clipShape(.rect(cornerRadius: 10))
        .sensoryFeedback(.selection, trigger: selectedRange)
    }
}

nonisolated enum ChartRange: CaseIterable, Sendable {
    case oneWeek, oneMonth, threeMonth, sixMonth, oneYear

    var label: String {
        switch self {
        case .oneWeek: return "1W"
        case .oneMonth: return "1M"
        case .threeMonth: return "3M"
        case .sixMonth: return "6M"
        case .oneYear: return "1Y"
        }
    }
}
