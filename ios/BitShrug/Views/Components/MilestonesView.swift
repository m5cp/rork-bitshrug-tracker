import SwiftUI

struct MilestonesView: View {
    let btcHoldings: Double
    let currentPrice: Double

    private var satoshis: Int { Int(btcHoldings * 100_000_000) }
    private var currentValue: Double { btcHoldings * currentPrice }

    private let btcMilestones: [(threshold: Double, label: String, icon: String)] = [
        (0.001, "0.001 BTC", "star"),
        (0.005, "0.005 BTC", "star.fill"),
        (0.01, "0.01 BTC", "medal"),
        (0.05, "0.05 BTC", "medal.fill"),
        (0.1, "0.1 BTC", "trophy"),
        (0.25, "0.25 BTC", "trophy.fill"),
        (0.5, "0.5 BTC", "crown"),
        (1.0, "1 BTC — Whole Coiner", "crown.fill"),
        (2.1, "2.1 BTC — 1 in 10M", "sparkles"),
        (5.0, "5 BTC", "bolt.fill"),
        (10.0, "10 BTC", "flame.fill"),
        (21.0, "21 BTC — Magic Number", "bitcoinsign.circle.fill"),
    ]

    private var achievedMilestones: [(threshold: Double, label: String, icon: String)] {
        btcMilestones.filter { btcHoldings >= $0.threshold }
    }

    private var nextMilestone: (threshold: Double, label: String, icon: String)? {
        btcMilestones.first { btcHoldings < $0.threshold }
    }

    private var progressToNext: Double {
        guard let next = nextMilestone else { return 1.0 }
        let previous = btcMilestones.last { btcHoldings >= $0.threshold }?.threshold ?? 0
        let range = next.threshold - previous
        guard range > 0 else { return 0 }
        return (btcHoldings - previous) / range
    }

    private var worldRanking: String {
        if btcHoldings >= 21 { return "Top 0.0001%" }
        if btcHoldings >= 10 { return "Top 0.001%" }
        if btcHoldings >= 5 { return "Top 0.005%" }
        if btcHoldings >= 2.1 { return "Top 0.01%" }
        if btcHoldings >= 1.0 { return "Top 0.05%" }
        if btcHoldings >= 0.5 { return "Top 0.1%" }
        if btcHoldings >= 0.25 { return "Top 0.5%" }
        if btcHoldings >= 0.1 { return "Top 1%" }
        if btcHoldings >= 0.01 { return "Top 5%" }
        return "Top 10%"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "trophy.fill", title: "MILESTONES")

            rankBadge

            if let next = nextMilestone {
                nextMilestoneCard(next)
            }

            if !achievedMilestones.isEmpty {
                achievedGrid
            }
        }
        .premiumCard(.highlighted)
    }

    private var rankBadge: some View {
        HStack(spacing: 12) {
            Image(systemName: "globe")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.orange)
                .frame(width: 36, height: 36)
                .background(Color.orange.opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text("Global Holder Ranking")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                Text(worldRanking)
                    .font(.system(.subheadline, design: .monospaced, weight: .heavy))
                    .foregroundStyle(.orange)
            }

            Spacer()

            Text("\(achievedMilestones.count)/\(btcMilestones.count)")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    private func nextMilestoneCard(_ milestone: (threshold: Double, label: String, icon: String)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.cyan)
                Text("NEXT MILESTONE")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(.secondary)
                    .tracking(1)
            }

            HStack(spacing: 10) {
                Image(systemName: milestone.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.cyan)
                    .frame(width: 30, height: 30)
                    .background(Color.cyan.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(milestone.label)
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundStyle(.primary)

                    let remaining = milestone.threshold - btcHoldings
                    Text("\(formatBTC(remaining)) BTC to go")
                        .font(.system(.caption2, design: .monospaced, weight: .bold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(progressToNext * 100))%")
                    .font(.system(.caption, design: .monospaced, weight: .heavy))
                    .foregroundStyle(.cyan)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(0.06))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progressToNext, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .background(Color.cyan.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.cyan.opacity(0.12), lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 12))
    }

    private var achievedGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(achievedMilestones.reversed(), id: \.threshold) { milestone in
                HStack(spacing: 8) {
                    Image(systemName: milestone.icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)

                    Text(milestone.label)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.06))
                .clipShape(.rect(cornerRadius: 8))
            }
        }
    }

    private func formatBTC(_ value: Double) -> String {
        if value >= 1 { return String(format: "%.4f", value) }
        if value >= 0.01 { return String(format: "%.6f", value) }
        return String(format: "%.8f", value)
    }
}
