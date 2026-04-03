import SwiftUI

struct LearnTab: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var showScrollToTop: Bool = false
    @State private var selectedCategory: LearnCategory = .powerLaw

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 720 : .infinity }
    private var horizontalPadding: CGFloat { isRegular ? 32 : 20 }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        Color.clear.frame(height: 0).id("top")

                        categoryPicker

                        switch selectedCategory {
                        case .powerLaw:
                            powerLawEducation
                        case .cycles:
                            cycleEducation
                        case .indicators:
                            indicatorEducation
                        }

                        disclaimer
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
                .overlay(alignment: .bottomTrailing) {
                    FloatingScrollToTopButton(isVisible: showScrollToTop) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                }
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var categoryPicker: some View {
        HStack(spacing: 8) {
            ForEach(LearnCategory.allCases, id: \.self) { category in
                let isSelected = selectedCategory == category
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        selectedCategory = category
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon)
                            .font(.system(size: 11, weight: .bold))
                        Text(category.label)
                            .font(.system(size: 12, weight: .heavy))
                    }
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isSelected ? Color.orange : Color.white.opacity(0.06))
                    .clipShape(Capsule())
                }
                .sensoryFeedback(.selection, trigger: selectedCategory)
            }
            Spacer()
        }
    }

    // MARK: - Power Law Education

    private var powerLawEducation: some View {
        VStack(spacing: 12) {
            ExpandableInfoCard(
                icon: "person.fill",
                iconColor: .orange,
                title: "Who Created It?",
                summary: "Harold Christopher Burger (2019) and Giovanni Santostasi",
                detail: "Burger observed Bitcoin's price follows a linear relationship on a log-log chart. Santostasi extended this to hash rate and addresses, showing the power law holds across multiple network metrics."
            )

            ExpandableInfoCard(
                icon: "function",
                iconColor: .blue,
                title: "What is a Power Law?",
                summary: "A relationship where one quantity scales as a power of another",
                detail: "Price ∝ Time⁵·⁸² — fundamentally different from exponential growth. The rate of growth slows over time but never stops. Many natural phenomena follow power laws: earthquake magnitudes, city sizes, and network effects."
            )

            ExpandableInfoCard(
                icon: "chart.bar.fill",
                iconColor: Color(red: 0.2, green: 0.85, blue: 0.5),
                title: "Reading the Corridor",
                summary: "Below support, within corridor, or above resistance",
                detail: "Below Support — historically the best long-term accumulation zone. Within Corridor — tracking the expected growth path. Above Resistance — historically coincides with cycle tops and euphoria."
            )

            ExpandableInfoCard(
                icon: "rainbow",
                iconColor: .purple,
                title: "Rainbow Chart",
                summary: "Colored bands from 'Fire Sale' to 'Maximum Bubble'",
                detail: "Each band represents a standard deviation from the fair value regression line. It's a visual heuristic showing where price sits relative to its long-term trend — not a prediction."
            )

            formulaCard

            Text("Based on historical patterns. Past behavior does not guarantee future results. Honest answer, we don't know. We hold.")
                .font(.caption2)
                .foregroundStyle(.quaternary)
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
        }
    }

    private var formulaCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "function")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.orange)
                Text("The Formula")
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
            }

            Text("log₁₀(price) = 5.82 × log₁₀(days) − k")
                .font(.system(.callout, design: .monospaced, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, Color(red: 1.0, green: 0.6, blue: 0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.orange.opacity(0.15), lineWidth: 1)
                )
                .clipShape(.rect(cornerRadius: 10))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                formulaTile(label: "price", value: "BTC price in USD")
                formulaTile(label: "days", value: "Since genesis block")
                formulaTile(label: "5.82", value: "Power law exponent")
                formulaTile(label: "k", value: "Support/resistance offset")
            }
        }
        .premiumCard(.highlighted)
    }

    private func formulaTile(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(.caption, design: .monospaced, weight: .heavy))
                .foregroundStyle(.orange)
            Text(value)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.03))
        .clipShape(.rect(cornerRadius: 10))
    }

    // MARK: - Cycle Education

    private var cycleEducation: some View {
        VStack(spacing: 12) {
            conceptsExplainer

            whyCyclesSection

            couldCyclesEndSection

            strategySection

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
                    connectionRow(left: "Halving", right: "triggers the start of each Epoch")
                    connectionRow(left: "Epoch", right: "provides the timeframe for each cycle")
                    connectionRow(left: "4-Year Cycle", right: "is the market behavior observed within epochs")
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
                Text("Honest answer, we don't know. We hold.")
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

    private var strategySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "lightbulb", title: "USING CYCLES AS A REFERENCE")

            VStack(alignment: .leading, spacing: 10) {
                KeyPointRow(icon: "clock", iconColor: .orange, text: "Cycles are not precisely 4 years — they've varied each time")
                KeyPointRow(icon: "exclamationmark.triangle", iconColor: .orange, text: "No guarantee cycles will continue as before")
                KeyPointRow(icon: "chart.line.downtrend.xyaxis", iconColor: .orange, text: "Past patterns don't predict future behavior")
                KeyPointRow(icon: "lightbulb", iconColor: .orange, text: "Use as educational context, not as a timing tool")
            }

            Text("Crypto is high-risk. This is educational context, not a recommendation.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .italic()
        }
        .premiumCard()
    }

    // MARK: - Indicator Education

    private var indicatorEducation: some View {
        VStack(spacing: 12) {
            ExpandableInfoCard(
                icon: "heart.text.square",
                iconColor: .orange,
                title: "Fear & Greed Index",
                summary: "Measures market sentiment from 0 (Extreme Fear) to 100 (Extreme Greed)",
                detail: "Aggregates volatility, market volume, social media, dominance, and trends. Extreme fear can signal buying opportunities; extreme greed can signal overextension. It's a contrarian indicator — be fearful when others are greedy."
            )

            ExpandableInfoCard(
                icon: "chart.xyaxis.line",
                iconColor: .blue,
                title: "200-Day EMA",
                summary: "Exponential moving average of the last 200 days",
                detail: "Gives more weight to recent prices than a simple moving average. When price is above the 200-Day EMA, the trend is considered bullish. Below it, bearish. It's the most widely watched long-term trend indicator."
            )

            ExpandableInfoCard(
                icon: "chart.line.flattrend.xyaxis",
                iconColor: Color(red: 0.2, green: 0.85, blue: 0.5),
                title: "200-Week MA",
                summary: "The long-term price floor Bitcoin has never closed below",
                detail: "Calculated from ~1,400 days of price history. Historically, Bitcoin has bounced off this level during every bear market. It represents the deepest value zone for long-term holders."
            )

            ExpandableInfoCard(
                icon: "waveform.path.ecg",
                iconColor: .purple,
                title: "MVRV Z-Score",
                summary: "Market Value to Realized Value ratio",
                detail: "Compares Bitcoin's market cap to its 'realized cap' (average cost basis of all coins). Z-Score above 7 has historically marked cycle tops. Below 0.1 has marked generational bottoms. Currently used to gauge overvaluation or undervaluation."
            )

            ExpandableInfoCard(
                icon: "pickaxe",
                iconColor: .cyan,
                title: "Puell Multiple",
                summary: "Daily miner revenue vs 365-day average",
                detail: "When miners earn much more than usual (Puell > 4), it often signals a top — miners sell to lock in profits. When miners earn much less (Puell < 0.5), it signals capitulation and potential bottoms."
            )

            ExpandableInfoCard(
                icon: "cube.box",
                iconColor: .yellow,
                title: "Stock-to-Flow",
                summary: "Scarcity model comparing existing supply to new production",
                detail: "S2F = Existing Supply / Annual Production. Higher ratio = more scarce. After each halving, S2F doubles as production is cut in half. The model predicts higher prices with increasing scarcity, though it has faced criticism for oversimplification."
            )

            ExpandableInfoCard(
                icon: "chart.pie",
                iconColor: Color(red: 0.2, green: 0.85, blue: 0.5),
                title: "Supply in Profit",
                summary: "Percentage of Bitcoin supply currently worth more than when last moved",
                detail: "When >95% of supply is in profit, it historically signals overheated conditions. When <50% is in profit, it signals deep bear territory and potential accumulation zones. Estimated from MVRV ratio."
            )
        }
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {
        VStack(spacing: 4) {
            Text("For educational purposes only.")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
            Text("This is not financial advice. Do not make financial decisions based on this app.")
                .font(.caption2)
                .foregroundStyle(.quaternary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

enum LearnCategory: CaseIterable {
    case powerLaw
    case cycles
    case indicators

    var label: String {
        switch self {
        case .powerLaw: return "Power Law"
        case .cycles: return "Cycles"
        case .indicators: return "Indicators"
        }
    }

    var icon: String {
        switch self {
        case .powerLaw: return "chart.line.uptrend.xyaxis"
        case .cycles: return "arrow.triangle.2.circlepath"
        case .indicators: return "gauge.with.dots.needle.bottom.50percent"
        }
    }
}
