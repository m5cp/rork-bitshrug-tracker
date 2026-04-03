import WidgetKit
import SwiftUI

nonisolated struct BitShrugEntry: TimelineEntry {
    let date: Date
    let score: Int
    let price: String
    let label: String
    let change24h: Double
    let fearGreed: Int
    let cyclePhase: String
    let trend: String
    let momentum: String
}

nonisolated struct BitShrugProvider: TimelineProvider {
    func placeholder(in context: Context) -> BitShrugEntry {
        BitShrugEntry(date: .now, score: 62, price: "$84,250", label: "Moderate", change24h: 1.5, fearGreed: 55, cyclePhase: "Early Bull", trend: "Bullish", momentum: "Neutral")
    }

    func getSnapshot(in context: Context, completion: @escaping (BitShrugEntry) -> Void) {
        let entry = readFromDefaults()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BitShrugEntry>) -> Void) {
        let entry = readFromDefaults()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func readFromDefaults() -> BitShrugEntry {
        let shared = UserDefaults(suiteName: "group.app.rork.mh5qf4z0nqy7olvg1im36")
        let score = shared?.integer(forKey: "widget_score") ?? 0
        let price = shared?.double(forKey: "widget_price") ?? 0
        let label = shared?.string(forKey: "widget_label") ?? "Loading"
        let change = shared?.double(forKey: "widget_change24h") ?? 0
        let fearGreed = shared?.integer(forKey: "widget_fear_greed") ?? 50
        let cyclePhase = shared?.string(forKey: "widget_cycle_phase") ?? "Loading"
        let trend = shared?.string(forKey: "widget_trend") ?? "Neutral"
        let momentum = shared?.string(forKey: "widget_momentum") ?? "Neutral"

        let priceString = price > 0 ? "$\(Int(price).formatted(.number))" : "--"

        return BitShrugEntry(
            date: .now,
            score: score > 0 ? score : 62,
            price: priceString,
            label: score > 0 ? label : "Moderate",
            change24h: change,
            fearGreed: fearGreed > 0 ? fearGreed : 55,
            cyclePhase: cyclePhase,
            trend: trend,
            momentum: momentum
        )
    }
}

private func widgetScoreColor(_ score: Int) -> Color {
    if score >= 75 { return Color(red: 0.2, green: 0.85, blue: 0.5) }
    if score >= 55 { return .orange }
    if score >= 35 { return Color(red: 0.95, green: 0.6, blue: 0.2) }
    return Color(red: 0.95, green: 0.3, blue: 0.3)
}

private func widgetChangeColor(_ change: Double) -> Color {
    change >= 0 ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3)
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    var entry: BitShrugEntry

    private var scoreColor: Color { widgetScoreColor(entry.score) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("BitShrug")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(scoreColor.opacity(0.2), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: Double(entry.score) / 100.0)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(entry.score)")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary)
                }
            }
            .frame(width: 56, height: 56)
            .frame(maxWidth: .infinity)

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.price)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)

                Text(entry.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(scoreColor)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    var entry: BitShrugEntry

    private var scoreColor: Color { widgetScoreColor(entry.score) }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(scoreColor.opacity(0.2), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: Double(entry.score) / 100.0)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(entry.score)")
                        .font(.system(size: 26, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary)
                    Text(entry.label.uppercased())
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(scoreColor)
                        .tracking(0.5)
                }
            }
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("BitShrug")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                Text(entry.price)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    let sign = entry.change24h >= 0 ? "+" : ""
                    Text("\(sign)\(String(format: "%.1f", entry.change24h))%")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(widgetChangeColor(entry.change24h))

                    Text("24h")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                }

                Text("Environment: \(entry.label)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    var entry: BitShrugEntry

    private var scoreColor: Color { widgetScoreColor(entry.score) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("BitShrug")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(entry.date.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(scoreColor.opacity(0.2), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: Double(entry.score) / 100.0)
                        .stroke(scoreColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 1) {
                        Text("\(entry.score)")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundStyle(.primary)
                        Text(entry.label.uppercased())
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(scoreColor)
                            .tracking(0.5)
                    }
                }
                .frame(width: 80, height: 80)

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.price)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.primary)

                    HStack(spacing: 6) {
                        let sign = entry.change24h >= 0 ? "+" : ""
                        Text("\(sign)\(String(format: "%.1f", entry.change24h))%")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(widgetChangeColor(entry.change24h))
                        Text("24h")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()
            }

            Divider()

            VStack(spacing: 8) {
                widgetDataRow(icon: "heart.text.square", label: "Fear & Greed", value: "\(entry.fearGreed)")
                widgetDataRow(icon: "arrow.triangle.2.circlepath", label: "Cycle Phase", value: entry.cyclePhase)
                widgetDataRow(icon: "chart.xyaxis.line", label: "Trend", value: entry.trend)
                widgetDataRow(icon: "bolt.fill", label: "Momentum", value: entry.momentum)
            }

            Spacer(minLength: 0)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func widgetDataRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Lock Screen Widgets

struct AccessoryCircularView: View {
    var entry: BitShrugEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text("\(entry.score)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                Text("ENV")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct AccessoryRectangularView: View {
    var entry: BitShrugEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 10))
                Text("BitShrug")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
            }
            Text(entry.price)
                .font(.system(size: 14, weight: .bold))
            Text("Score: \(entry.score) \u{2022} \(entry.label)")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Widget Configuration

struct BitShrugWidget: Widget {
    let kind: String = "BitShrugWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BitShrugProvider()) { entry in
            BitShrugWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("BitShrug")
        .description("Bitcoin Environment Score and price at a glance.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}

struct BitShrugWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: BitShrugEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}
