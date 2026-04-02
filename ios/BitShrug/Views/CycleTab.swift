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

                        conceptsExplainer

                        historicalHalvings

                        historicalCycleReturns

                        whyCyclesSection

                        couldCyclesEndSection

                        strategySection

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
        VStack(spacing: 20) {
            ShrugBadge(size: .regular, style: .glowing)
                .opacity(0.5)
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
        let progress = info?.cycleProgress ?? 0

        let verdict: String
        let explanation: String
        let verdictColor: Color

        if progress > 0.1 && progress < 0.55 {
            verdict = "The cycle is playing out"
            explanation = "Bitcoin is in the \(info?.currentPhase.label.lowercased() ?? "early") phase, aligning with the post-halving pattern."
            verdictColor = Color(red: 0.2, green: 0.85, blue: 0.5)
        } else if progress >= 0.55 && progress < 0.78 {
            verdict = "Too early to tell"
            explanation = "Past the typical peak zone. Whether the historical pattern holds remains to be seen."
            verdictColor = .orange
        } else if progress >= 0.78 {
            verdict = "The cycle is stretched"
            explanation = "Deep into the cycle timeline. Previous cycles had completed their bear phases by now."
            verdictColor = Color(red: 0.95, green: 0.3, blue: 0.3)
        } else {
            verdict = "New cycle, fresh start"
            explanation = "Very early in this halving era. Not enough data yet to confirm or deny the theory."
            verdictColor = .blue
        }

        return VStack(spacing: 16) {
            HStack(spacing: 10) {
                ShrugBadge(size: .large, style: .hero)

                Text("IS THE 4-YEAR CYCLE VALID?")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.secondary)
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
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Text("Historical observation. Sample size: 4 halvings.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
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
                        .foregroundStyle(.secondary)

                    if let info {
                        Text("Era \(info.currentEra)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .frame(width: isRegular ? 200 : 170, height: isRegular ? 200 : 170)

            if let info {
                Text(info.currentPhase.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
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
            SectionHeader(icon: "list.bullet", title: "CYCLE PHASES")

            VStack(spacing: 0) {
                ForEach(Array(phases.enumerated()), id: \.element.name) { index, phase in
                    let isCurrent = index == currentSimpleIndex
                    let isPast = index < currentSimpleIndex

                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(isCurrent ? .orange : isPast ? .orange.opacity(0.3) : Color.white.opacity(0.08))
                                .frame(width: 30, height: 30)

                            if isCurrent {
                                Circle()
                                    .fill(.orange)
                                    .frame(width: 10, height: 10)
                                    .shadow(color: .orange.opacity(0.5), radius: 4)
                            } else if isPast {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.orange.opacity(0.6))
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(phase.name)
                                .font(.subheadline)
                                .fontWeight(isCurrent ? .heavy : .medium)
                                .foregroundStyle(isCurrent ? .primary : isPast ? .secondary : .tertiary)

                            if isCurrent {
                                Text("Current phase")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.orange)
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 6)

                    if index < phases.count - 1 {
                        HStack(spacing: 14) {
                            Rectangle()
                                .fill(isPast ? .orange.opacity(0.3) : Color.white.opacity(0.06))
                                .frame(width: 2, height: 14)
                                .padding(.leading, 14)
                            Spacer()
                        }
                    }
                }
            }
        }
        .premiumCard(.highlighted)
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
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.system(.footnote, design: .monospaced, weight: .bold))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Concepts Explainer

    private var conceptsExplainer: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "book.closed", title: "KNOW THE DIFFERENCE")

            Text("These three terms are often used interchangeably, but they describe distinct concepts.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)

            conceptCard(
                number: "1",
                color: .orange,
                term: "The Halving",
                icon: "scissors",
                definition: "A hard-coded event in Bitcoin's protocol",
                details: [
                    "Every 210,000 blocks (~4 years), the mining reward is cut in half",
                    "Reduces the rate of new BTC entering circulation",
                    "Completely predictable — next one is ~April 2028",
                    "4 halvings so far: 2012, 2016, 2020, 2024"
                ],
                takeaway: "A supply-side event. It's mechanical, not theoretical."
            )

            conceptCard(
                number: "2",
                color: .cyan,
                term: "The Epoch (Era)",
                icon: "square.stack.3d.up",
                definition: "The period between two consecutive halvings",
                details: [
                    "Epoch 1: Genesis → Nov 2012 (50 BTC reward)",
                    "Epoch 2: Nov 2012 → Jul 2016 (25 BTC reward)",
                    "Epoch 3: Jul 2016 → May 2020 (12.5 BTC reward)",
                    "Epoch 4: May 2020 → Apr 2024 (6.25 BTC reward)",
                    "Epoch 5: Apr 2024 → ~2028 (3.125 BTC reward)"
                ],
                takeaway: "A time period defined by a fixed block reward. We're in Epoch 5."
            )

            conceptCard(
                number: "3",
                color: .purple,
                term: "The 4-Year Cycle",
                icon: "arrow.triangle.2.circlepath",
                definition: "An observed market pattern, not a protocol rule",
                details: [
                    "Bull tops and bear bottoms have formed ~4 years apart",
                    "Driven by halvings, monetary policy, and psychology",
                    "Each cycle: accumulation → bull → euphoria → bear",
                    "Only 4 complete cycles observed — small sample size",
                    "May weaken or end as Bitcoin matures"
                ],
                takeaway: "A theory based on historical observation. Correlation, not causation."
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.orange)
                    Text("How They Connect")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundStyle(.primary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    connectionRow(
                        left: "Halving",
                        right: "triggers the start of each Epoch"
                    )
                    connectionRow(
                        left: "Epoch",
                        right: "provides the timeframe for each cycle"
                    )
                    connectionRow(
                        left: "4-Year Cycle",
                        right: "is the market behavior observed within epochs"
                    )
                }

                Text("The halving is a fact. The epoch is a measurement. The cycle is a theory.")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                    .padding(.top, 4)
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.08), Color.orange.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.orange.opacity(0.15), lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: 14))
        }
        .premiumCard(.highlighted)
    }

    private func conceptCard(number: String, color: Color, term: String, icon: String, definition: String, details: [String], takeaway: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(number)
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(color)
                    .clipShape(.rect(cornerRadius: 6))

                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(color)

                Text(term)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)

                Spacer()
            }

            Text(definition)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(color.opacity(0.9))

            VStack(alignment: .leading, spacing: 6) {
                ForEach(details, id: \.self) { detail in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(color.opacity(0.4))
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "arrow.turn.down.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.tertiary)
                Text(takeaway)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
            .padding(.top, 2)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [color.opacity(0.06), color.opacity(0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(color.opacity(0.1), lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 14))
    }

    private func connectionRow(left: String, right: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(left)
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(.orange)
                .frame(width: 90, alignment: .leading)
            Text(right)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
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
                .foregroundStyle(.tertiary)
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
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Cycle Peak")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.tertiary)
                    Text(peakApprox)
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(.secondary)
                    if !peakDate.isEmpty {
                        Text(peakDate)
                            .font(.system(size: 9))
                            .foregroundStyle(.quaternary)
                    }
                }
            }
            .padding(.vertical, 10)

            if !isLast {
                Divider()
                    .overlay(Color.white.opacity(0.04))
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
                .foregroundStyle(.tertiary)
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
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)

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
                    .overlay(Color.white.opacity(0.04))
            }
        }
    }

    // MARK: - Why Do Cycles Happen

    private var whyCyclesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "questionmark.circle", title: "WHY DO 4-YEAR CYCLES HAPPEN?")

            CompactFactCard(
                icon: "hammer.fill",
                iconColor: .orange,
                title: "Bitcoin Halvings",
                content: "Every ~4 years, mining rewards are cut in half — a programmatic supply shock. Each halving has coincided with the early stages of a new bull market. Next halving: ~2028."
            )

            CompactFactCard(
                icon: "building.columns.fill",
                iconColor: .blue,
                title: "Monetary Policy",
                content: "Crypto prices have tended to rise when the Fed cuts rates or injects liquidity. However, this correlation doesn't always hold — Bitcoin didn't rally on the Dec 2025 rate cut."
            )

            CompactFactCard(
                icon: "brain.head.profile",
                iconColor: .purple,
                title: "Investor Psychology",
                content: "The same boom-bust dynamics that drive most markets: optimism and greed push prices up, panic and fear push them down — playing out over roughly 4-year intervals."
            )
        }
        .premiumCard(.highlighted)
    }

    // MARK: - Could Cycles End

    private var couldCyclesEndSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "exclamationmark.triangle", title: "COULD THE CYCLES BE OVER?")

            HStack(spacing: 10) {
                verdictPill(
                    color: Color(red: 0.2, green: 0.85, blue: 0.5),
                    title: "Bull Case",
                    points: [
                        "Institutional adoption changes dynamics",
                        "Spot ETFs absorb selling pressure",
                        "Possible \"supercycle\" scenario"
                    ]
                )

                verdictPill(
                    color: Color(red: 0.95, green: 0.3, blue: 0.3),
                    title: "Bear Case",
                    points: [
                        "Oct 2025 ATH followed by bear-like action",
                        "Pattern matches historical cycle behavior",
                        "Psychology hasn't changed"
                    ]
                )
            }

            HStack(spacing: 8) {
                ShrugBadge(size: .small, style: .inline)
                Text("The honest answer: we don't know yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
        .premiumCard()
    }

    private func verdictPill(color: Color, title: String, points: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 6) {
                        Circle()
                            .fill(color.opacity(0.5))
                            .frame(width: 4, height: 4)
                            .padding(.top, 5)
                        Text(point)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(0.12), lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 12))
    }

    // MARK: - Strategy

    private var strategySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "lightbulb", title: "USING CYCLES AS A REFERENCE")

            VStack(alignment: .leading, spacing: 10) {
                KeyPointRow(icon: "clock", iconColor: .orange, text: "Cycles are not precisely 4 years — they've varied each time")
                KeyPointRow(icon: "exclamationmark.triangle", iconColor: .orange, text: "Selling exactly 4 years from last peak would have missed the top")
                KeyPointRow(icon: "chart.line.downtrend.xyaxis", iconColor: .orange, text: "No guarantee cycles will continue as before")
                KeyPointRow(icon: "lightbulb", iconColor: .orange, text: "Use as context for positioning, not as a timing tool")
            }

            Text("Crypto is high-risk. Only invest what you can afford to lose.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .italic()
        }
        .premiumCard()
    }

    // MARK: - Education

    private var educationSection: some View {
        VStack(spacing: 10) {
            ExpandableInfoCard(
                icon: "arrow.triangle.2.circlepath",
                iconColor: .orange,
                title: "What is the Halving?",
                summary: "Block reward cut in half every 210,000 blocks (~4 years)",
                detail: "Started at 50 BTC per block in 2009. Now 3.125 BTC. Halvings reduce new supply entering circulation — a programmatic scarcity mechanism that continues until all 21M BTC are mined (~2140)."
            )

            ExpandableInfoCard(
                icon: "chart.line.uptrend.xyaxis",
                iconColor: Color(red: 0.2, green: 0.85, blue: 0.5),
                title: "The Cycle Pattern",
                summary: "Tops and bottoms ~4 years apart since 2011",
                detail: "Bull tops: Nov 2013, Dec 2017, Nov 2021. Bear lows: Jan 2015, Dec 2018, Nov 2022. A repeating cycle of accumulation, expansion, euphoria, and correction — driven by supply shocks and human psychology."
            )

            ExpandableInfoCard(
                icon: "questionmark.diamond",
                iconColor: .purple,
                title: "Is It Guaranteed?",
                summary: "No — only 4 halving events observed so far",
                detail: "As Bitcoin matures, institutional adoption, regulation, macro conditions, and diminishing supply shocks may alter or dampen the cycle. Useful framework, but past patterns don't guarantee future behavior."
            )

            ExpandableInfoCard(
                icon: "app.badge",
                iconColor: .blue,
                title: "How BitShrug Uses It",
                summary: "One lens among many for understanding conditions",
                detail: "The cycle phase is combined with momentum, trend, positioning, and volatility to create a composite picture. It's a context tool — not a timing tool."
            )
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
