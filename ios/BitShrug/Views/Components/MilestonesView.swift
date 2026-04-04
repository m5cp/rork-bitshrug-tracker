import SwiftUI

struct MilestonesView: View {
    let btcHoldings: Double
    let currentPrice: Double

    @State private var showMethodology: Bool = false

    private static let holderTiers: [(minBTC: Double, maxBTC: Double?, label: String, addresses: Int, icon: String, color: Color)] = [
        (100_000, nil, "100,000+ BTC", 4, "building.columns.fill", .purple),
        (10_000, 100_000, "10K – 100K BTC", 98, "building.2.fill", .indigo),
        (1_000, 10_000, "1K – 10K BTC", 1_922, "crown.fill", .orange),
        (100, 1_000, "100 – 1K BTC", 18_014, "medal.fill", .yellow),
        (10, 100, "10 – 100 BTC", 130_388, "star.fill", .cyan),
        (1, 10, "1 – 10 BTC", 824_460, "star", .teal),
        (0.1, 1, "0.1 – 1 BTC", 3_510_000, "circle.hexagongrid.fill", .blue),
        (0.01, 0.1, "0.01 – 0.1 BTC", 8_250_000, "circle.grid.3x3.fill", .mint),
        (0.001, 0.01, "0.001 – 0.01 BTC", 11_990_000, "circle.grid.2x2.fill", .green),
        (0, 0.001, "< 0.001 BTC", 33_840_000, "circle.dotted", Color.primary.opacity(0.4)),
    ]

    private static let totalHolderAddresses: Int = 58_560_000

    private var currentTierIndex: Int {
        Self.holderTiers.firstIndex { tier in
            if let max = tier.maxBTC {
                return btcHoldings >= tier.minBTC && btcHoldings < max
            }
            return btcHoldings >= tier.minBTC
        } ?? Self.holderTiers.count - 1
    }

    private var currentTier: (minBTC: Double, maxBTC: Double?, label: String, addresses: Int, icon: String, color: Color) {
        Self.holderTiers[currentTierIndex]
    }

    private var addressesAboveOrEqual: Int {
        var total = 0
        for i in 0...currentTierIndex {
            total += Self.holderTiers[i].addresses
        }
        return total
    }

    private var holderPercentile: Double {
        let aboveCount = Self.holderTiers.prefix(currentTierIndex).reduce(0) { $0 + $1.addresses }
        return (Double(aboveCount) / Double(Self.totalHolderAddresses)) * 100
    }

    private var holderRankLabel: String {
        let pct = holderPercentile
        if pct < 0.001 { return "Top 0.001%" }
        if pct < 0.01 { return "Top 0.01%" }
        if pct < 0.1 { return "Top \(String(format: "%.2f", pct))%" }
        if pct < 1 { return "Top \(String(format: "%.1f", pct))%" }
        return "Top \(Int(ceil(pct)))%"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "mappin.and.ellipse", title: "WHERE AM I?")

            yourPosition

            Divider().opacity(0.3)

            tierBreakdown

            methodologyButton
        }
        .premiumCard(.highlighted)
        .sheet(isPresented: $showMethodology) {
            methodologySheet
        }
    }

    private var yourPosition: some View {
        HStack(spacing: 12) {
            Image(systemName: currentTier.icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(currentTier.color)
                .frame(width: 42, height: 42)
                .background(currentTier.color.opacity(0.12))
                .clipShape(.rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(holderRankLabel)
                    .font(.system(.subheadline, design: .monospaced, weight: .heavy))
                    .foregroundStyle(.orange)

                Text("of all Bitcoin holder addresses")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)

                Text(currentTier.label)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(currentTier.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(currentTier.color.opacity(0.1))
                    .clipShape(Capsule())
            }

            Spacer()
        }
    }

    private var tierBreakdown: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                Text("HOLDER DISTRIBUTION")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(.secondary)
                    .tracking(1)
            }
            .padding(.bottom, 2)

            ForEach(Array(Self.holderTiers.enumerated()), id: \.offset) { index, tier in
                let isCurrentTier = index == currentTierIndex
                let barWidth = barFraction(for: tier.addresses)

                HStack(spacing: 8) {
                    Text(tier.label)
                        .font(.system(size: 9, weight: isCurrentTier ? .heavy : .bold, design: .monospaced))
                        .foregroundStyle(isCurrentTier ? tier.color : .secondary)
                        .frame(width: 110, alignment: .leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.primary.opacity(0.04))

                            RoundedRectangle(cornerRadius: 3)
                                .fill(isCurrentTier ? tier.color : Color.primary.opacity(0.15))
                                .frame(width: max(4, geo.size.width * barWidth))
                        }
                    }
                    .frame(height: 10)

                    Text(formatCount(tier.addresses))
                        .font(.system(size: 9, weight: isCurrentTier ? .heavy : .bold, design: .monospaced))
                        .foregroundStyle(isCurrentTier ? .primary : .tertiary)
                        .frame(width: 40, alignment: .trailing)
                }
                .padding(.vertical, isCurrentTier ? 4 : 1)
                .padding(.horizontal, isCurrentTier ? 6 : 0)
                .background(isCurrentTier ? tier.color.opacity(0.06) : .clear)
                .clipShape(.rect(cornerRadius: 6))
            }
        }
    }

    private var methodologyButton: some View {
        Button {
            showMethodology = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 11, weight: .semibold))
                Text("How is this calculated?")
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(.secondary)
            .padding(10)
            .background(Color.primary.opacity(0.03))
            .clipShape(.rect(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private var methodologySheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Data Source", systemImage: "server.rack")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)

                        Text("Address counts come from on-chain data aggregated by BitInfoCharts, which tracks every Bitcoin address with a non-zero balance on the public blockchain.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("What These Numbers Mean", systemImage: "number.circle")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.cyan)

                        Text("Each \"address\" is a unique Bitcoin wallet address with a balance. One person can own multiple addresses, and some addresses belong to exchanges holding coins for many people. This means:")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        bulletPoint("The real number of individual holders is likely lower than ~58.5M addresses")
                        bulletPoint("Your true ranking among individuals may be higher (better) than shown")
                        bulletPoint("Exchange addresses with large balances are counted as single entries")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("How Your Tier Is Determined", systemImage: "arrow.up.right.circle")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.teal)

                        Text("Your BTC amount is compared against the distribution of all addresses. The \"Top X%\" represents how many addresses hold the same or more BTC than you, out of all ~58.5 million addresses with any balance.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Important Caveats", systemImage: "exclamationmark.triangle")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.yellow)

                        bulletPoint("This is an estimate, not a precise rank")
                        bulletPoint("Address counts shift daily as people transact")
                        bulletPoint("Figures shown are approximate snapshots, updated periodically")
                        bulletPoint("This is not financial advice or encouragement to buy")
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last data reference: BitInfoCharts.com")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.tertiary)
                        Text("Approximate address counts as of early 2025")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.top, 8)
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Methodology")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showMethodology = false }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func barFraction(for count: Int) -> Double {
        let maxCount = Self.holderTiers.map(\.addresses).max() ?? 1
        let logVal = log10(Double(max(count, 1)))
        let logMax = log10(Double(max(maxCount, 1)))
        guard logMax > 0 else { return 0 }
        return logVal / logMax
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.0fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
}
