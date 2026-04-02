import SwiftUI

struct CycleTab: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 720 : .infinity }
    private var horizontalPadding: CGFloat { isRegular ? 32 : 20 }

    private let phases: [SimpleCyclePhase] = [
        SimpleCyclePhase(name: "Accumulation", keys: [.accumulation]),
        SimpleCyclePhase(name: "Early Bull", keys: [.earlyBull]),
        SimpleCyclePhase(name: "Acceleration", keys: [.acceleration]),
        SimpleCyclePhase(name: "Euphoria", keys: [.euphoria]),
        SimpleCyclePhase(name: "Distribution", keys: [.distribution]),
        SimpleCyclePhase(name: "Bear", keys: [.earlyBear, .capitulation]),
        SimpleCyclePhase(name: "Recovery", keys: [.recovery])
    ]

    private var currentSimpleIndex: Int {
        guard let info = viewModel.halvingInfo else { return 0 }
        return phases.firstIndex { $0.keys.contains(info.currentPhase) } ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading && viewModel.price == 0 {
                        loadingPlaceholder
                    } else {
                        shrugVerdict
                            .padding(.top, 8)

                        cycleRing

                        phaseTimeline

                        halvingStats

                        historicalHalvings

                        educationSection

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
            .navigationTitle("4-Year Cycle Theory")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var loadingPlaceholder: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.orange.opacity(0.5))
            Text("Loading")
                .font(.caption)
                .foregroundStyle(.quaternary)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    // MARK: - Shrug Verdict

    private var shrugVerdict: some View {
        let info = viewModel.halvingInfo
        let phase = info?.currentPhase ?? .accumulation
        let progress = info?.cycleProgress ?? 0

        let verdict: String
        let explanation: String
        let verdictColor: Color

        if progress > 0.1 && progress < 0.55 {
            verdict = "The cycle is playing out"
            explanation = "Bitcoin is in the \(phase.label.lowercased()) phase, which historically aligns with the post-halving pattern. The 4-year cycle appears to be on track so far."
            verdictColor = Color(red: 0.2, green: 0.85, blue: 0.5)
        } else if progress >= 0.55 && progress < 0.78 {
            verdict = "Too early to tell"
            explanation = "Bitcoin is past the typical peak zone. Whether this cycle follows the historical pattern or breaks it remains to be seen. The theory is being tested."
            verdictColor = .orange
        } else if progress >= 0.78 {
            verdict = "The cycle is stretched"
            explanation = "We're deep into the cycle timeline. Previous cycles had already completed their bear phases by now. This cycle may be different, or the theory may need updating."
            verdictColor = Color(red: 0.95, green: 0.3, blue: 0.3)
        } else {
            verdict = "New cycle, fresh start"
            explanation = "We're very early in this halving era. There isn't enough data yet to confirm or deny the cycle theory. Time will tell."
            verdictColor = .blue
        }

        return VStack(spacing: 14) {
            HStack(spacing: 8) {
                Text("\u{00AF}\\_(ツ)_/\u{00AF}")
                    .font(.system(.title3, design: .monospaced))
                    .foregroundStyle(.orange)
                Text("IS THE 4-YEAR CYCLE VALID?")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .tracking(1)
                Spacer()
            }

            Text(verdict)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(verdictColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                Text("The 4-year cycle is a historical observation, not a guarantee. Sample size: 4 halvings.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
    }

    // MARK: - Cycle Ring

    private var cycleRing: some View {
        let info = viewModel.halvingInfo

        return VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: info?.cycleProgress ?? 0)
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(red: 0.2, green: 0.85, blue: 0.5),
                                .orange,
                                Color(red: 0.95, green: 0.3, blue: 0.3),
                                .purple,
                                .blue,
                                Color(red: 0.2, green: 0.85, blue: 0.5)
                            ],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.8), value: info?.cycleProgress)

                VStack(spacing: 4) {
                    Text(info?.currentPhase.label ?? "Loading")
                        .font(.system(.title3, weight: .bold))
                        .foregroundStyle(.primary)

                    Text("\(Int((info?.cycleProgress ?? 0) * 100))% complete")
                        .font(.system(.caption, design: .monospaced, weight: .medium))
                        .foregroundStyle(.secondary)

                    if let info {
                        Text("Era \(info.currentEra)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .frame(width: isRegular ? 200 : 160, height: isRegular ? 200 : 160)

            if let info {
                Text(info.currentPhase.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Phase Timeline

    private var phaseTimeline: some View {
        VStack(spacing: 14) {
            Text("CYCLE PHASES")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.tertiary)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                ForEach(Array(phases.enumerated()), id: \.element.name) { index, phase in
                    let isCurrent = index == currentSimpleIndex
                    let isPast = index < currentSimpleIndex

                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(isCurrent ? .orange : isPast ? .orange.opacity(0.3) : Color.white.opacity(0.08))
                                .frame(width: 28, height: 28)

                            if isCurrent {
                                Circle()
                                    .fill(.orange)
                                    .frame(width: 10, height: 10)
                            } else if isPast {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.orange.opacity(0.6))
                            }
                        }

                        if index < phases.count - 1 {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(phase.name)
                                    .font(.subheadline)
                                    .fontWeight(isCurrent ? .bold : .medium)
                                    .foregroundStyle(isCurrent ? .primary : isPast ? .secondary : .tertiary)

                                if isCurrent {
                                    Text("Current phase")
                                        .font(.caption2)
                                        .foregroundStyle(.orange)
                                        .padding(.top, 1)
                                }
                            }
                        } else {
                            Text(phase.name)
                                .font(.subheadline)
                                .fontWeight(isCurrent ? .bold : .medium)
                                .foregroundStyle(isCurrent ? .primary : isPast ? .secondary : .tertiary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 6)

                    if index < phases.count - 1 {
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(isPast ? .orange.opacity(0.3) : Color.white.opacity(0.06))
                                .frame(width: 2, height: 12)
                                .padding(.leading, 13)
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
    }

    // MARK: - Halving Stats

    private var halvingStats: some View {
        Group {
            if let info = viewModel.halvingInfo {
                HStack(spacing: 0) {
                    statCell(label: "Since Halving", value: "\(info.daysSinceLast)d")
                    Spacer()
                    statCell(label: "Next Halving", value: "~\(info.daysUntilNext)d")
                    Spacer()
                    statCell(label: "Block Reward", value: "\(String(format: "%.3f", info.blockReward)) BTC")
                }
                .padding(16)
                .background(Color.white.opacity(0.04))
                .clipShape(.rect(cornerRadius: 18))
            }
        }
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.system(.footnote, design: .monospaced, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Historical Halvings

    private var historicalHalvings: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("HALVING HISTORY")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.tertiary)
                .tracking(1)

            VStack(spacing: 0) {
                halvingRow(era: 1, date: "Nov 2012", reward: "50 \u{2192} 25", peakApprox: "~$1,150", isLast: false)
                halvingRow(era: 2, date: "Jul 2016", reward: "25 \u{2192} 12.5", peakApprox: "~$19,700", isLast: false)
                halvingRow(era: 3, date: "May 2020", reward: "12.5 \u{2192} 6.25", peakApprox: "~$69,000", isLast: false)
                halvingRow(era: 4, date: "Apr 2024", reward: "6.25 \u{2192} 3.125", peakApprox: "TBD", isLast: true)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
    }

    private func halvingRow(era: Int, date: String, reward: String, peakApprox: String, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Text("#\(era)")
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(.orange)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(date)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        Text(reward)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Cycle Peak")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                    Text(peakApprox)
                        .font(.system(.caption, design: .monospaced, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 10)

            if !isLast {
                Divider()
                    .overlay(Color.white.opacity(0.04))
            }
        }
    }

    // MARK: - Education

    private var educationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("UNDERSTANDING THE 4-YEAR CYCLE THEORY")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.tertiary)
                .tracking(1)

            educationBlock(
                title: "What is the Halving?",
                body: "Every 210,000 blocks (approximately every 4 years), the Bitcoin block reward is cut in half. This reduces the rate of new BTC entering circulation \u{2014} a programmatic supply shock.\n\nThe first halving in 2012 reduced the reward from 50 to 25 BTC per block. Each subsequent halving halves it again: 12.5, 6.25, 3.125, and so on until all 21 million BTC are mined (estimated ~2140)."
            )

            educationBlock(
                title: "Why Does a Cycle Form?",
                body: "The theory suggests that each halving triggers a multi-year cycle:\n\n1. Accumulation \u{2014} After the bear market bottom, smart money begins buying at depressed prices while public interest is low.\n\n2. Bull Market \u{2014} Reduced supply meets growing demand. Price accelerates, media attention builds, and retail interest surges.\n\n3. Euphoria & Peak \u{2014} Parabolic price action, maximum FOMO. Historically occurs 12\u{2013}18 months after the halving.\n\n4. Bear Market \u{2014} Overextended prices correct. Long-term holders distribute to late buyers. Price typically falls 70\u{2013}85% from the peak.\n\n5. Recovery \u{2014} Market heals, weak hands capitulate, and the cycle begins again as the next halving approaches."
            )

            educationBlock(
                title: "Is the Cycle Guaranteed?",
                body: "No. The 4-year cycle is an observed historical pattern across four halving events \u{2014} a small sample size. As Bitcoin matures, factors like institutional adoption, regulation, macro conditions, and diminishing supply shocks may alter or dampen the cycle.\n\nIt's a useful framework for understanding Bitcoin's rhythms, but past patterns do not guarantee future behavior."
            )

            educationBlock(
                title: "How BitShrug Uses It",
                body: "BitShrug uses the halving cycle as one lens for understanding where we are. The cycle phase is combined with on-chain indicators, momentum, and positioning to provide a more complete picture of the current environment.\n\nIt's a context tool \u{2014} not a timing tool."
            )
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
    }

    private func educationBlock(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text(body)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {
        Text("BitShrug provides general market context for informational purposes only. It does not provide financial advice or predict future price movements.")
            .font(.caption2)
            .foregroundStyle(.quaternary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }
}

struct SimpleCyclePhase: Sendable {
    let name: String
    let keys: [CyclePhase]
}
