import SwiftUI

struct ReversalTrackerView: View {
    let viewModel: BitcoinViewModel

    @State private var selectedTab: ReversalTab = .bull

    private var bullSignals: [ReversalSignal] {
        computeBullSignals()
    }

    private var bearSignals: [ReversalSignal] {
        computeBearSignals()
    }

    private var activeBullCount: Int { bullSignals.filter(\.isActive).count }
    private var activeBearCount: Int { bearSignals.filter(\.isActive).count }

    private var bullStatus: ReversalStatus {
        switch activeBullCount {
        case 0: return .preReversal
        case 1...2: return .earlySignals
        case 3...4: return .building
        default: return .confirmed
        }
    }

    private var bearStatus: ReversalStatus {
        switch activeBearCount {
        case 0: return .lowRisk
        case 1...2: return .elevatedRisk
        case 3...4: return .highRisk
        default: return .confirmed
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            tabPicker

            if selectedTab == .bull {
                bullContent
            } else {
                bearContent
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.orange)

            Text("Reversal Tracker")
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(.primary)

            Spacer()
        }
    }

    private var tabPicker: some View {
        HStack(spacing: 0) {
            tabButton(.bull)
            tabButton(.bear)
        }
        .background(Color.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func tabButton(_ tab: ReversalTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.spring(duration: 0.3)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab == .bull ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 12, weight: .heavy))
                Text(tab.rawValue.uppercased())
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(0.5)
            }
            .foregroundStyle(isSelected ? .white : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? (tab == .bull
                        ? AnyShapeStyle(LinearGradient(colors: [Color(red: 0.2, green: 0.85, blue: 0.5).opacity(0.3), Color(red: 0.2, green: 0.85, blue: 0.5).opacity(0.1)], startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(LinearGradient(colors: [Color(red: 0.95, green: 0.3, blue: 0.3).opacity(0.3), Color(red: 0.95, green: 0.3, blue: 0.3).opacity(0.1)], startPoint: .top, endPoint: .bottom)))
                    : AnyShapeStyle(Color.clear)
            )
            .clipShape(.rect(cornerRadius: 12))
        }
    }

    // MARK: - Bull Content

    private var bullContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            statusCard(
                title: "BULL REVERSAL STATUS",
                count: activeBullCount,
                total: bullSignals.count,
                status: bullStatus,
                description: bullStatusDescription
            )

            signalCards(bullSignals)

            sequenceSection(
                title: "HISTORICAL BULL REVERSAL SEQUENCE",
                subtitle: "How these signals have historically fired in order at cycle bottoms:",
                steps: bullSequenceSteps
            )
        }
    }

    // MARK: - Bear Content

    private var bearContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            statusCard(
                title: "BEAR REVERSAL STATUS",
                count: activeBearCount,
                total: bearSignals.count,
                status: bearStatus,
                description: bearStatusDescription
            )

            signalCards(bearSignals)

            sequenceSection(
                title: "HISTORICAL BEAR REVERSAL SEQUENCE",
                subtitle: "How these signals have historically fired in order at cycle tops:",
                steps: bearSequenceSteps
            )
        }
    }

    // MARK: - Status Card

    private func statusCard(title: String, count: Int, total: Int, status: ReversalStatus, description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.secondary)
                    .tracking(1.5)

                Spacer()

                Text(status.label)
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(status.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(status.color.opacity(0.12))
                    .clipShape(Capsule())
            }

            Text("\(count)/\(total) indicators active")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .premiumCard(.highlighted)
    }

    // MARK: - Signal Cards

    private func signalCards(_ signals: [ReversalSignal]) -> some View {
        VStack(spacing: 10) {
            ForEach(signals) { signal in
                signalCard(signal)
            }
        }
    }

    private func signalCard(_ signal: ReversalSignal) -> some View {
        let borderColor: Color = signal.isActive
            ? (selectedTab == .bull ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3))
            : Color.white.opacity(0.06)

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: signal.isActive ? "exclamationmark.shield.fill" : "circle")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(signal.isActive
                        ? (selectedTab == .bull ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3))
                        : Color.white.opacity(0.3)
                    )
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(signal.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Spacer()

                        Text(signal.category)
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundStyle(signal.categoryColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(signal.categoryColor.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 4) {
                        Text("Current:")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text(signal.currentValue)
                            .font(.system(.caption, design: .monospaced, weight: .bold))
                            .foregroundStyle(signal.isActive
                                ? (selectedTab == .bull ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3))
                                : .primary
                            )
                    }

                    HStack(spacing: 4) {
                        Text("Trigger:")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text(signal.trigger)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }

                    Text(signal.explanation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)
                }
            }
        }
        .padding(14)
        .background(
            signal.isActive
                ? (selectedTab == .bull ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3)).opacity(0.04)
                : Color.white.opacity(0.03)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(borderColor.opacity(signal.isActive ? 0.3 : 1), lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Sequence Section

    private func sequenceSection(title: String, subtitle: String, steps: [SequenceStep]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
                .overlay(Color.white.opacity(0.06))

            Text(title)
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(.secondary)
                .tracking(1.5)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.tertiary)

            VStack(spacing: 8) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    sequenceRow(number: index + 1, step: step)
                }
            }
        }
        .premiumCard(.highlighted)
    }

    private func sequenceRow(number: Int, step: SequenceStep) -> some View {
        let activeColor: Color = selectedTab == .bull
            ? Color(red: 0.2, green: 0.85, blue: 0.5)
            : Color(red: 0.95, green: 0.3, blue: 0.3)

        return HStack(spacing: 12) {
            Text("\(number)")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(step.isActive ? Color.white : Color.white.opacity(0.3))
                .frame(width: 24, height: 24)
                .background(step.isActive ? activeColor : Color.white.opacity(0.08))
                .clipShape(.rect(cornerRadius: 6))

            Text(step.label)
                .font(.subheadline)
                .fontWeight(step.isActive ? .bold : .regular)
                .foregroundStyle(step.isActive ? activeColor : .secondary)

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            step.isActive
                ? activeColor.opacity(0.08)
                : Color.white.opacity(0.02)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    step.isActive ? activeColor.opacity(0.2) : Color.white.opacity(0.04),
                    lineWidth: 1
                )
        )
        .clipShape(.rect(cornerRadius: 10))
    }

    // MARK: - Bull Signal Computation

    private func computeBullSignals() -> [ReversalSignal] {
        let rsi = viewModel.rsiValue ?? 50
        let fng = viewModel.fearGreedValue
        let ma = viewModel.movingAverages
        let macd = viewModel.macdData
        let price = viewModel.price
        let sma200 = ma?.sma200Day ?? 0
        let sma50 = ma?.sma50Day ?? 0
        let goldenCross = sma50 > sma200 && sma200 > 0
        let priceAbove200 = price > sma200 && sma200 > 0
        let macdBullish = (macd?.macd ?? 0) > (macd?.signal ?? 0)

        let fngExitedExtremeFear = fng > 25

        return [
            ReversalSignal(
                title: "RSI Recovery Above 50",
                category: "technical",
                categoryColor: .blue,
                currentValue: String(format: "%.1f", rsi),
                trigger: "> 50 (momentum shift)",
                isActive: rsi > 50,
                explanation: "RSI crossing above 50 signals momentum shifting from bearish to bullish. Confirms that sellers are losing control."
            ),
            ReversalSignal(
                title: "Price Above 200-Day SMA",
                category: "technical",
                categoryColor: .blue,
                currentValue: sma200 > 0 ? "$\(Int(price).formatted(.number))" : "Loading",
                trigger: sma200 > 0 ? "> $\(Int(sma200).formatted(.number)) (macro trend)" : "Loading",
                isActive: priceAbove200,
                explanation: "The 200-day SMA is the definitive bull/bear dividing line. Reclaiming it confirms the macro trend has shifted bullish."
            ),
            ReversalSignal(
                title: "Golden Cross (50d > 200d SMA)",
                category: "technical",
                categoryColor: .blue,
                currentValue: goldenCross ? "Active" : "Not Active",
                trigger: "50-day SMA crosses above 200-day SMA",
                isActive: goldenCross,
                explanation: "The Golden Cross is the ultimate trend confirmation — 50-day MA crossing above the 200-day MA. Every sustained BTC bull run has been preceded by this signal."
            ),
            ReversalSignal(
                title: "MACD Bullish Crossover",
                category: "technical",
                categoryColor: .blue,
                currentValue: macdBullish ? "Bullish" : "Bearish",
                trigger: "MACD above signal line",
                isActive: macdBullish,
                explanation: "MACD crossing above its signal line confirms bullish momentum. Strongest when occurring below zero."
            ),
            ReversalSignal(
                title: "Fear & Greed Sentiment Shift",
                category: "sentiment",
                categoryColor: .yellow,
                currentValue: "\(fng) (\(viewModel.fearGreedLevel.label))",
                trigger: "Rising from Extreme Fear (<25) through Neutral (>40)",
                isActive: fngExitedExtremeFear && fng > 40,
                explanation: "Sentiment recovering from Extreme Fear through Neutral signals the crowd is transitioning from capitulation to cautious optimism — a precondition for sustained rallies."
            ),
        ]
    }

    // MARK: - Bear Signal Computation

    private func computeBearSignals() -> [ReversalSignal] {
        let rsi = viewModel.rsiValue ?? 50
        let fng = viewModel.fearGreedValue
        let ma = viewModel.movingAverages
        let macd = viewModel.macdData
        let price = viewModel.price
        let sma200 = ma?.sma200Day ?? 0
        let sma50 = ma?.sma50Day ?? 0
        let deathCross = sma50 < sma200 && sma200 > 0
        let macdBearish = (macd?.macd ?? 0) < (macd?.signal ?? 0)

        let extensionAbove200 = sma200 > 0 ? ((price - sma200) / sma200) * 100 : 0

        return [
            ReversalSignal(
                title: "RSI Overbought",
                category: "technical",
                categoryColor: .blue,
                currentValue: String(format: "%.1f", rsi),
                trigger: "> 80 (overheated momentum)",
                isActive: rsi > 80,
                explanation: "RSI above 80 signals extreme overbought conditions. Momentum is stretched and a mean-reversion pullback becomes statistically likely."
            ),
            ReversalSignal(
                title: "Price Extended Above 200d SMA",
                category: "technical",
                categoryColor: .blue,
                currentValue: String(format: "%.1f%% above", max(extensionAbove200, 0)),
                trigger: "> 100% extension above 200-day SMA",
                isActive: extensionAbove200 > 100,
                explanation: "When price extends more than 100% above the 200-day SMA, it signals parabolic overextension. Historically, BTC has always mean-reverted back toward the 200-day SMA after such extremes."
            ),
            ReversalSignal(
                title: "Death Cross (50d < 200d SMA)",
                category: "technical",
                categoryColor: .blue,
                currentValue: deathCross ? "Active" : "Not Active",
                trigger: "50-day SMA crosses below 200-day SMA",
                isActive: deathCross,
                explanation: "The Death Cross — 50-day MA crossing below the 200-day MA — confirms the macro trend has turned bearish and historically precedes extended drawdowns."
            ),
            ReversalSignal(
                title: "MACD Bearish Crossover",
                category: "technical",
                categoryColor: .blue,
                currentValue: macdBearish ? "Bearish" : "Bullish",
                trigger: "MACD below signal line",
                isActive: macdBearish,
                explanation: "MACD crossing below its signal line confirms bearish momentum. Strongest when occurring above zero."
            ),
            ReversalSignal(
                title: "Extreme Greed Sentiment",
                category: "sentiment",
                categoryColor: .yellow,
                currentValue: "\(fng) (\(viewModel.fearGreedLevel.label))",
                trigger: "> 85 (Extreme Greed)",
                isActive: fng > 85,
                explanation: "Extreme Greed above 85 signals maximum euphoria — historically the distribution zone where smart money sells to the crowd."
            ),
        ]
    }

    // MARK: - Sequence Steps

    private var bullSequenceSteps: [SequenceStep] {
        let rsi = viewModel.rsiValue ?? 50
        let fng = viewModel.fearGreedValue
        let ma = viewModel.movingAverages
        let macd = viewModel.macdData
        let price = viewModel.price
        let sma200 = ma?.sma200Day ?? 0
        let sma50 = ma?.sma50Day ?? 0

        return [
            SequenceStep(label: "Fear & Greed exits Extreme Fear", isActive: fng > 25),
            SequenceStep(label: "RSI crosses above 50", isActive: rsi > 50),
            SequenceStep(label: "MACD bullish crossover", isActive: (macd?.macd ?? 0) > (macd?.signal ?? 0)),
            SequenceStep(label: "Price reclaims 200-day SMA", isActive: price > sma200 && sma200 > 0),
            SequenceStep(label: "Golden Cross forms", isActive: sma50 > sma200 && sma200 > 0),
        ]
    }

    private var bearSequenceSteps: [SequenceStep] {
        let rsi = viewModel.rsiValue ?? 50
        let fng = viewModel.fearGreedValue
        let ma = viewModel.movingAverages
        let macd = viewModel.macdData
        let price = viewModel.price
        let sma200 = ma?.sma200Day ?? 0
        let sma50 = ma?.sma50Day ?? 0
        let extensionAbove200 = sma200 > 0 ? ((price - sma200) / sma200) * 100 : 0

        return [
            SequenceStep(label: "RSI pushes above 80", isActive: rsi > 80),
            SequenceStep(label: "Price extends >100% above 200d SMA", isActive: extensionAbove200 > 100),
            SequenceStep(label: "Fear & Greed hits Extreme Greed (>85)", isActive: fng > 85),
            SequenceStep(label: "MACD bearish crossover", isActive: (macd?.macd ?? 0) < (macd?.signal ?? 0)),
            SequenceStep(label: "Death Cross forms", isActive: sma50 < sma200 && sma200 > 0),
        ]
    }

    // MARK: - Status Descriptions

    private var bullStatusDescription: String {
        switch activeBullCount {
        case 0:
            return "Most bull reversal indicators are inactive. Bear market conditions remain dominant. Watch for RSI recovery above 50 and sentiment shift as the first signs of a reversal."
        case 1...2:
            return "Early signs of a potential reversal are appearing. Momentum may be shifting, but confirmation from trend indicators is still needed."
        case 3...4:
            return "Multiple bull signals are firing. A reversal is building momentum — historically this configuration has preceded sustained rallies."
        default:
            return "All bull reversal signals are active. The trend has shifted bullish with confirmed momentum, trend, and sentiment alignment."
        }
    }

    private var bearStatusDescription: String {
        switch activeBearCount {
        case 0:
            return "No bear reversal signals are active. The current trend remains intact with no signs of distribution or overheating."
        case 1...2:
            return "Multiple bear signals are flashing. The market is likely near or past a cycle top. Smart money is distributing. Reduce exposure and protect profits — this configuration has preceded every major crash."
        case 3...4:
            return "Significant bear signals active. Risk of a major trend reversal is high. Historically this has marked the transition into extended drawdowns."
        default:
            return "All bear reversal signals confirmed. Maximum caution — every prior instance of this configuration preceded a 70%+ drawdown."
        }
    }
}

// MARK: - Supporting Types

nonisolated enum ReversalTab: String, Sendable {
    case bull = "Bull"
    case bear = "Bear"
}

nonisolated enum ReversalStatus: Sendable {
    case preReversal
    case earlySignals
    case building
    case confirmed
    case lowRisk
    case elevatedRisk
    case highRisk

    var label: String {
        switch self {
        case .preReversal: return "PRE REVERSAL"
        case .earlySignals: return "EARLY SIGNALS"
        case .building: return "BUILDING"
        case .confirmed: return "CONFIRMED"
        case .lowRisk: return "LOW RISK"
        case .elevatedRisk: return "ELEVATED RISK"
        case .highRisk: return "HIGH RISK"
        }
    }

    var color: Color {
        switch self {
        case .preReversal: return .blue
        case .earlySignals: return .orange
        case .building: return Color(red: 0.2, green: 0.85, blue: 0.5)
        case .confirmed: return Color(red: 0.2, green: 0.85, blue: 0.5)
        case .lowRisk: return Color(red: 0.2, green: 0.85, blue: 0.5)
        case .elevatedRisk: return .orange
        case .highRisk: return Color(red: 0.95, green: 0.3, blue: 0.3)
        }
    }
}

struct ReversalSignal: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let categoryColor: Color
    let currentValue: String
    let trigger: String
    let isActive: Bool
    let explanation: String
}

struct SequenceStep {
    let label: String
    let isActive: Bool
}
