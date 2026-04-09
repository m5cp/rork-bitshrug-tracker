import SwiftUI

struct SignalsTab: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var appeared: Bool = false
    @State private var showScrollToTop: Bool = false
    @State private var premium = PremiumManager.shared
    @State private var showPaywall: Bool = false

    private let sections: [SectionAnchor] = [
        SectionAnchor(id: "sentiment", icon: "heart.text.square", label: "Sentiment"),
        SectionAnchor(id: "indicators", icon: "gauge.with.dots.needle.bottom.50percent", label: "Indicators"),
        SectionAnchor(id: "macro", icon: "building.columns", label: "Macro"),
        SectionAnchor(id: "context", icon: "globe", label: "Context"),
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

                            sentimentCard
                                .id("sentiment")

                            indicatorsSection
                                .id("indicators")

                            if viewModel.macroData.isLoaded {
                                MacroIntelligenceView(macroData: viewModel.macroData)
                                    .id("macro")
                                    .opacity(appeared ? 1 : 0)
                                    .offset(y: appeared ? 0 : 16)
                            }

                            contextSection
                                .id("context")

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
            .navigationTitle("Signals")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
        .fogBackground()
        .sensoryFeedback(.success, trigger: viewModel.lastUpdated)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appeared = true
            }
        }
    }

    private var loadingPlaceholder: some View {
        VStack(spacing: 20) {
            ShrugBadge(size: .regular, style: .glowing)
                .opacity(0.5)
            ProgressView()
                .tint(.orange.opacity(0.5))
            Text("Loading signals...")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary.opacity(0.5))
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    // MARK: - Sentiment

    private var sentimentCard: some View {
        let level = viewModel.fearGreedLevel

        return VStack(spacing: 16) {
            SectionHeader(icon: "heart.text.square", title: "MARKET SENTIMENT")

            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(level.color.opacity(0.12), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: Double(viewModel.fearGreedValue) / 100.0)
                        .stroke(
                            AngularGradient(
                                colors: [level.color.opacity(0.5), level.color],
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(-90 + 360 * Double(viewModel.fearGreedValue) / 100.0)
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(duration: 0.6), value: viewModel.fearGreedValue)

                    Text("\(viewModel.fearGreedValue)")
                        .font(.system(.title3, design: .monospaced, weight: .heavy))
                        .foregroundStyle(.primary)
                }
                .frame(width: 68, height: 68)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Fear & Greed Index")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(level.label)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(level.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(level.color.opacity(0.12))
                        .clipShape(Capsule())

                    Text(level.signalDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                }

                Spacer()
            }
        }
        .premiumCard(.accent)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    // MARK: - Indicators

    private var allIndicators: [(icon: String, title: String, value: String, status: String, statusColor: Color, detail: String)] {
        var items: [(String, String, String, String, Color, String)] = []

        if let ma = viewModel.movingAverages {
            items.append((
                "chart.xyaxis.line",
                "200-Day EMA",
                formatIndicatorPrice(ma.ema200Day),
                ma.isAboveEMA ? "Bull" : "Bear",
                ma.isAboveEMA ? AppColors.bullish : AppColors.bearish,
                "Price is \(String(format: "%.1f%%", abs(ma.priceVsEMA))) \(ma.isAboveEMA ? "above" : "below") the 200-day exponential moving average."
            ))

            items.append((
                "chart.line.flattrend.xyaxis",
                "200-Week MA",
                formatIndicatorPrice(ma.estimated200WMA),
                ma.isAbove200WMA ? "Above" : "Below",
                ma.isAbove200WMA ? AppColors.bullish : AppColors.bearish,
                "Price is \(String(format: "%.1f%%", abs(ma.priceVs200WMA))) \(ma.isAbove200WMA ? "above" : "below") the estimated 200-week moving average."
            ))
        }

        items.append((
            "waveform.path.ecg",
            "MVRV Z-Score",
            String(format: "%.2f", viewModel.mvrvZScore),
            viewModel.mvrvZone.label,
            viewModel.mvrvZone.color,
            viewModel.mvrvZone.description
        ))

        items.append((
            "pickaxe",
            "Puell Multiple",
            String(format: "%.2f", viewModel.puellMultiple),
            viewModel.puellZone.label,
            viewModel.puellZone.color,
            viewModel.puellZone.description
        ))

        let s2f = s2fStatus
        items.append((
            "cube.box",
            "Stock-to-Flow",
            String(format: "%.2fx", viewModel.stockToFlowRatio),
            s2f.label,
            s2f.color,
            s2f.detail
        ))

        if let sp = viewModel.supplyInProfit {
            items.append((
                "chart.pie",
                "Supply in Profit",
                String(format: "%.0f%%", sp.estimatedPercent),
                sp.zone.label,
                sp.zone.color,
                sp.zone.description
            ))
        }

        return items
    }

    private var indicatorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "gauge.with.dots.needle.bottom.50percent", title: "ON-CHAIN INDICATORS")

            let freeCount = 3
            let indicators = allIndicators
            let freeIndicators = Array(indicators.prefix(freeCount))
            let lockedIndicators = premium.isPremium ? Array(indicators.dropFirst(freeCount)) : []

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(Array(freeIndicators.enumerated()), id: \.offset) { _, indicator in
                    indicatorCell(
                        icon: indicator.icon,
                        title: indicator.title,
                        value: indicator.value,
                        status: indicator.status,
                        statusColor: indicator.statusColor,
                        detail: indicator.detail
                    )
                }
                ForEach(Array(lockedIndicators.enumerated()), id: \.offset) { _, indicator in
                    indicatorCell(
                        icon: indicator.icon,
                        title: indicator.title,
                        value: indicator.value,
                        status: indicator.status,
                        statusColor: indicator.statusColor,
                        detail: indicator.detail
                    )
                }
            }

            if !premium.isPremium {
                lockedIndicatorsTeaser(count: indicators.count - freeCount)
            }

            if let dir = viewModel.weeklyScoreChange {
                Divider().overlay(Color.primary.opacity(0.04)).padding(.top, 4)

                if premium.isPremium {
                    HStack(spacing: 8) {
                        Text("THIS WEEK")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.primary)
                            .tracking(1)
                        Text(dir)
                            .font(.system(.caption, design: .monospaced, weight: .bold))
                            .foregroundStyle(.primary)

                        let weekDir = viewModel.weeklyDirection
                        Text(weekDir)
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(weekDir == "Improving" ? AppColors.bullish : weekDir == "Weakening" ? AppColors.bearish : .secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background((weekDir == "Improving" ? Color.green : weekDir == "Weakening" ? Color.red : Color.primary).opacity(0.1))
                            .clipShape(Capsule())

                        Spacer()
                    }
                } else {
                    Button { showPaywall = true } label: {
                        HStack(spacing: 8) {
                            Text("THIS WEEK")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(.primary)
                                .tracking(1)

                            Image(systemName: "lock.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.tertiary)

                            proBadge

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .premiumCard(.highlighted)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private func indicatorCell(icon: String, title: String, value: String, status: String, statusColor: Color, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.orange)
                Text(title)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Text(value)
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(status)
                .font(.system(size: 8, weight: .heavy))
                .foregroundStyle(statusColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(statusColor.opacity(0.12))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.primary.opacity(0.04))
        .clipShape(.rect(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value), \(status)")
    }

    // MARK: - Context

    private var contextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "globe", title: "MARKET CONTEXT")

            Text(viewModel.marketContext)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            if let phase = viewModel.halvingInfo?.currentPhase {
                HStack(spacing: 10) {
                    Image(systemName: phase.icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(phase.color)
                        .frame(width: 24, height: 24)
                        .background(phase.color.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 6))

                    Text("Cycle: \(phase.label)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(viewModel.rainbowBand.label)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(viewModel.rainbowBand.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(viewModel.rainbowBand.color.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
        }
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    // MARK: - Helpers

    private var s2fStatus: (label: String, color: Color, detail: String) {
        let ratio = viewModel.stockToFlowRatio
        if ratio < 0.5 {
            return ("Undervalued", AppColors.bullish, "Price is significantly below the Stock-to-Flow model price.")
        } else if ratio < 1.5 {
            return ("Fair Value", .blue, "Price is near the Stock-to-Flow model estimate.")
        } else {
            return ("Extended", .orange, "Price is above the Stock-to-Flow model estimate.")
        }
    }

    private func formatIndicatorPrice(_ value: Double) -> String {
        "$\(Int(value).formatted(.number))"
    }

    private func lockedIndicatorsTeaser(count: Int) -> some View {
        Button { showPaywall = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("+\(count) more indicators")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        proBadge
                    }
                    Text("Puell Multiple, Stock-to-Flow, Supply in Profit")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(Color.orange.opacity(0.06))
            .clipShape(.rect(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.orange.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var proBadge: some View {
        Text("PRO")
            .font(.system(size: 8, weight: .heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                LinearGradient(
                    colors: [.orange, .orange.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
    }

    private var disclaimer: some View {
        StyledDisclaimer()
    }
}
