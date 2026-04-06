import ActivityKit
import WidgetKit
import SwiftUI

struct BitShrugLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BitShrugLiveAttributes.self) { context in
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Fog of Bitcoin")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(.secondary)
                            Text(formatPrice(context.state.price))
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundStyle(.primary)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("ENV")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                        Text("\(context.state.environmentScore)")
                            .font(.system(size: 22, weight: .heavy, design: .monospaced))
                            .foregroundStyle(scoreColor(context.state.environmentScore))
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        changeChip(context.state.change24h)
                        Spacer()
                        Text(context.state.environmentLabel)
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(scoreColor(context.state.environmentScore))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(scoreColor(context.state.environmentScore).opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                    Text(formatCompactPrice(context.state.price))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary)
                }
            } compactTrailing: {
                Text("\(context.state.environmentScore)")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    .foregroundStyle(scoreColor(context.state.environmentScore))
            } minimal: {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.orange)
            }
        }
    }

    private func lockScreenView(context: ActivityViewContext<BitShrugLiveAttributes>) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.orange)
                    Text("Fog of Bitcoin")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                Text(formatPrice(context.state.price))
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(.primary)

                changeChip(context.state.change24h)
            }

            Spacer()

            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .stroke(scoreColor(context.state.environmentScore).opacity(0.2), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: Double(context.state.environmentScore) / 100.0)
                        .stroke(scoreColor(context.state.environmentScore), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    Text("\(context.state.environmentScore)")
                        .font(.system(size: 18, weight: .heavy, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                .frame(width: 52, height: 52)

                Text(context.state.environmentLabel)
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(scoreColor(context.state.environmentScore))
            }
        }
        .padding(16)
        .activityBackgroundTint(.black.opacity(0.8))
    }

    private func changeChip(_ change: Double) -> some View {
        let sign = change >= 0 ? "+" : ""
        let color: Color = change >= 0 ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3)
        return Text("\(sign)\(String(format: "%.1f", change))%")
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 75 { return Color(red: 0.2, green: 0.85, blue: 0.5) }
        if score >= 55 { return .orange }
        if score >= 35 { return Color(red: 0.95, green: 0.6, blue: 0.2) }
        return Color(red: 0.95, green: 0.3, blue: 0.3)
    }

    private func formatPrice(_ value: Double) -> String {
        guard value > 0 else { return "--" }
        return "$\(Int(value).formatted(.number))"
    }

    private func formatCompactPrice(_ value: Double) -> String {
        guard value > 0 else { return "--" }
        if value >= 1000 {
            return "$\(Int(value / 1000))k"
        }
        return "$\(Int(value))"
    }
}
