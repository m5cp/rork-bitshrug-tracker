import SwiftUI

struct CycleTab: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var showScrollToTop: Bool = false

    private let sections: [SectionAnchor] = [
        SectionAnchor(id: "verdict", icon: "hand.raised", label: "Verdict"),
        SectionAnchor(id: "status", icon: "waveform.path", label: "Status"),
        SectionAnchor(id: "history", icon: "clock.arrow.circlepath", label: "History"),
        SectionAnchor(id: "reversal", icon: "arrow.triangle.2.circlepath.circle", label: "Reversal"),
        SectionAnchor(id: "projected", icon: "chart.line.downtrend.xyaxis", label: "Bottom"),
    ]

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 720 : .infinity }
    private var horizontalPadding: CGFloat { isRegular ? 32 : 20 }


    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        Color.clear.frame(height: 0).id("top")

                        if viewModel.isLoading && viewModel.price == 0 {
                            loadingPlaceholder
                        } else {
                            SectionJumpBar(sections: sections) { id in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(id, anchor: .top)
                                }
                            }

                            shrugVerdict
                                .id("verdict")

                            cycleRing

                            halvingStats

                            CycleStatusView(
                                currentPrice: viewModel.price,
                                daysSinceHalving: viewModel.halvingInfo?.daysSinceLast ?? 0
                            )
                            .id("status")

                            HistoricalCycleComparisonView(currentPrice: viewModel.price)
                                .id("history")

                            historicalHalvings

                            historicalCycleReturns

                            ReversalTrackerView(viewModel: viewModel)
                                .id("reversal")

                            ProjectedCycleBottomView(currentPrice: viewModel.price)
                                .id("projected")

                            disclaimer
                        }
                    }
                    .frame(maxWidth: contentMaxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 40)
                    .onGeometryChange(for: CGFloat.self) { geo in
                        geo.frame(in: .global).minY
                    } action: { value in
                        showScrollToTop = value < -200
                    }
                }
                .scrollIndicators(.hidden)
                .refreshable { await viewModel.loadData() }
                .overlay(alignment: .bottomTrailing) {
                    FloatingScrollToTopButton(isVisible: showScrollToTop) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                }
            }
            .navigationTitle("4-Year Cycle Theory")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sensoryFeedback(.success, trigger: viewModel.lastUpdated)
    }

    private var loadingPlaceholder: some View {
        VStack(spacing: 20) {
            ShrugBadge(size: .regular, style: .glowing)
                .opacity(0.5)
            ProgressView()
                .tint(.orange.opacity(0.5))
            Text("Loading")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary.opacity(0.5))
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    // MARK: - Shrug Verdict

    private var shrugVerdict: some View {
        let info = viewModel.halvingInfo
        let progress = info?.cycleProgress ?? 0
        let phase = info?.currentPhase ?? .accumulation

        let verdict: String
        let explanation: String
        let verdictColor: Color

        switch phase {
        case .earlyBear, .capitulation:
            verdict = "The cycle has turned"
            explanation = "Bitcoin has pulled back significantly from the cycle high. Historical patterns suggest a cooling period is underway."
            verdictColor = Color(red: 0.95, green: 0.3, blue: 0.3)
        case .distribution:
            verdict = "Distribution phase"
            explanation = "Bitcoin has retreated from the cycle high. Long-term holders may be taking profits as the market digests prior gains."
            verdictColor = .orange
        case .euphoria:
            verdict = "The cycle is playing out"
            explanation = "Bitcoin is in the \(phase.label.lowercased()) phase, aligning with the post-halving pattern."
            verdictColor = Color(red: 0.2, green: 0.85, blue: 0.5)
        case .accumulation, .earlyBull, .acceleration:
            if progress > 0.1 {
                verdict = "The cycle is playing out"
                explanation = "Bitcoin is in the \(phase.label.lowercased()) phase, aligning with the post-halving pattern."
                verdictColor = Color(red: 0.2, green: 0.85, blue: 0.5)
            } else {
                verdict = "New cycle, fresh start"
                explanation = "Very early in this halving era. Not enough data yet to confirm or deny the theory."
                verdictColor = .blue
            }
        case .recovery:
            verdict = "Recovery underway"
            explanation = "Deep into the cycle timeline. The market is healing as the next halving approaches."
            verdictColor = .blue
        }

        return VStack(spacing: 16) {
            HStack(spacing: 10) {
                ShrugBadge(size: .large, style: .hero)

                Text("IS THE 4-YEAR CYCLE VALID?")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.primary)
                    .tracking(1.5)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(verdict)
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundStyle(verdictColor)

                Text(explanation)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 10))
                    .foregroundStyle(.primary.opacity(0.5))
                Text("Historical observation. Sample size: 4 halvings.")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .premiumCard(.accent)
    }

    // MARK: - Cycle Ring

    private var cycleRing: some View {
        let info = viewModel.halvingInfo

        return VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 12)

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
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .orange.opacity(0.3), radius: 8)
                    .animation(.spring(duration: 0.8), value: info?.cycleProgress)

                VStack(spacing: 4) {
                    Text(info?.currentPhase.label ?? "Loading")
                        .font(.system(.title3, weight: .heavy))
                        .foregroundStyle(.primary)

                    Text("\(Int((info?.cycleProgress ?? 0) * 100))% complete")
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(.primary)

                    if let info {
                        Text("Era \(info.currentEra)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .frame(width: isRegular ? 200 : 170, height: isRegular ? 200 : 170)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Cycle progress: \(info?.currentPhase.label ?? "Loading"), \(Int((info?.cycleProgress ?? 0) * 100)) percent complete, Era \(info?.currentEra ?? 0)")

            if let info {
                Text(info.currentPhase.description)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
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
                .premiumCard()
            }
        }
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.primary)
            Text(value)
                .font(.system(.footnote, design: .monospaced, weight: .bold))
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Historical Halvings

    private var historicalHalvings: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "clock.arrow.circlepath", title: "HALVING HISTORY")

            VStack(spacing: 0) {
                halvingRow(era: 1, date: "Nov 2012", reward: "50 → 25", peakApprox: "~$1,150", peakDate: "Nov 2013", isLast: false)
                halvingRow(era: 2, date: "Jul 2016", reward: "25 → 12.5", peakApprox: "~$19,700", peakDate: "Dec 2017", isLast: false)
                halvingRow(era: 3, date: "May 2020", reward: "12.5 → 6.25", peakApprox: "~$69,000", peakDate: "Nov 2021", isLast: false)
                halvingRow(era: 4, date: "Apr 2024", reward: "6.25 → 3.125", peakApprox: "TBD", peakDate: "", isLast: true)
            }

            Text("Peaks have formed ~12–18 months post-halving. Bear lows ~12 months after each peak.")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .premiumCard(.highlighted)
    }

    private func halvingRow(era: Int, date: String, reward: String, peakApprox: String, peakDate: String, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 10) {
                    Text("#\(era)")
                        .font(.system(.caption, design: .monospaced, weight: .heavy))
                        .foregroundStyle(.orange)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(date)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        Text(reward)
                            .font(.system(.caption, design: .monospaced, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Cycle Peak")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(peakApprox)
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(.primary)
                    if !peakDate.isEmpty {
                        Text(peakDate)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.primary.opacity(0.5))
                    }
                }
            }
            .padding(.vertical, 10)

            if !isLast {
                Divider()
                    .overlay(Color.primary.opacity(0.04))
            }
        }
    }

    // MARK: - Historical Cycle Returns

    private var historicalCycleReturns: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "arrow.up.right", iconColor: Color(red: 0.2, green: 0.85, blue: 0.5), title: "CYCLE-OVER-CYCLE RETURNS")

            VStack(spacing: 0) {
                returnRow(cycle: "Cycle 1", bottom: "$2", top: "$1,150", returnPct: "~57,400%", drawdown: "-87%", isLast: false)
                returnRow(cycle: "Cycle 2", bottom: "$152", top: "$19,700", returnPct: "~12,860%", drawdown: "-84%", isLast: false)
                returnRow(cycle: "Cycle 3", bottom: "$3,200", top: "$69,000", returnPct: "~2,056%", drawdown: "-77%", isLast: false)
                returnRow(cycle: "Cycle 4", bottom: "$15,500", top: "TBD", returnPct: "TBD", drawdown: "TBD", isLast: true)
            }

            Text("Diminishing peak returns but higher absolute prices. Bear drawdowns: 77–87%.")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .premiumCard()
    }

    private func returnRow(cycle: String, bottom: String, top: String, returnPct: String, drawdown: String, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(cycle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .frame(width: 64, alignment: .leading)

                Text("\(bottom) → \(top)")
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(returnPct)
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(returnPct == "TBD" ? Color.secondary : Color(red: 0.2, green: 0.85, blue: 0.5))
                    Text(drawdown)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(drawdown == "TBD" ? Color.secondary : Color(red: 0.95, green: 0.3, blue: 0.3))
                }
            }
            .padding(.vertical, 8)

            if !isLast {
                Divider()
                    .overlay(Color.primary.opacity(0.04))
            }
        }
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {
        VStack(spacing: 4) {
            if let updated = viewModel.lastUpdated {
                Text("Price updated \(updated.formatted(.relative(presentation: .named)))")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.primary.opacity(0.5))
            }
            Text("Numbers are not live. For educational purposes only.")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            Text("This is not financial advice. Do not make financial decisions based on this app.")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}


