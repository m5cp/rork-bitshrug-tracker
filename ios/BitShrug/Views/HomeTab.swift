import SwiftUI
import Charts

struct HomeTab: View {
    let viewModel: BitcoinViewModel
    @Binding var selectedTab: AppTab
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var showSettings: Bool = false
    @State private var appeared: Bool = false
    @State private var animatedScore: Int = 0
    @State private var scoreHistory = ScoreHistoryManager.shared
    @State private var showScrollToTop: Bool = false
    @State private var premium = PremiumManager.shared
    @State private var showPaywall: Bool = false

    private let sections: [SectionAnchor] = [
        SectionAnchor(id: "price", icon: "chart.xyaxis.line", label: "Price"),
        SectionAnchor(id: "insight", icon: "sparkle", label: "Insight"),
        SectionAnchor(id: "breakdown", icon: "gauge.with.dots.needle.bottom.50percent", label: "Breakdown"),
    ]

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 720 : .infinity }
    private var horizontalPadding: CGFloat { isRegular ? 32 : 20 }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 0).id("top")

                        if viewModel.isLoading && viewModel.price == 0 {
                            loadingView
                        } else if viewModel.price == 0 && viewModel.errorMessage != nil {
                            errorView
                        } else {
                            SectionJumpBar(sections: sections) { id in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(id, anchor: .top)
                                }
                            }
                            .padding(.bottom, 16)

                            heroSection
                                .padding(.bottom, 24)

                            if viewModel.historicalPrices.count > 30 {
                                chartSection
                                    .id("price")
                                    .padding(.bottom, 20)
                            }

                            if scoreHistory.entries.count >= 2 {
                                ScoreHistoryChartView(entries: scoreHistory.entries)
                                    .padding(.bottom, 20)
                                    .opacity(appeared ? 1 : 0)
                                    .offset(y: appeared ? 0 : 16)
                            }

                            insightSection
                                .id("insight")
                                .padding(.bottom, 20)

                            driversSection
                                .id("breakdown")
                                .padding(.bottom, 20)

                            if !premium.isPremium {
                                premiumUpsellCard
                                    .padding(.bottom, 20)
                            }

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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { brandMark }
                ToolbarItem(placement: .topBarLeading) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !premium.isPremium {
                        Button {
                            showPaywall = true
                        } label: {
                            Text("PRO")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettings) { ProfileView() }
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
        .fogBackground()
        .sensoryFeedback(.success, trigger: viewModel.lastUpdated)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appeared = true
            }
        }
        .onChange(of: viewModel.environmentScore) { _, newScore in
            animateScore(to: newScore)
        }
        .task {
            if viewModel.environmentScore > 0 {
                animateScore(to: viewModel.environmentScore)
            }
        }
    }

    private func animateScore(to target: Int) {
        let start = animatedScore
        let steps = 30
        let duration = 0.8
        for i in 0...steps {
            let delay = duration * Double(i) / Double(steps)
            let progress = Double(i) / Double(steps)
            let eased = 1 - pow(1 - progress, 3)
            let value = start + Int(Double(target - start) * eased)
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(Int(delay * 1000)))
                animatedScore = value
            }
        }
    }

    private var brandMark: some View {
        HStack(spacing: 8) {
            Text("TouchGrass BTC")
                .font(.system(.subheadline, design: .monospaced, weight: .bold))
                .foregroundStyle(.primary)
            ShrugBadge(size: .small, style: .inline)
        }
        .fixedSize()
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ShrugBadge(size: .large, style: .glowing)
                .opacity(0.6)
            ProgressView()
                .scaleEffect(1.1)
                .tint(.orange.opacity(0.5))
            Text("Loading market data...")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 400)
    }

    private var errorView: some View {
        VStack(spacing: 20) {
            ShrugBadge(size: .large, style: .hero)
                .opacity(0.5)

            VStack(spacing: 8) {
                Text("Unable to load data")
                    .font(.title3)
                    .fontWeight(.bold)

                Text(viewModel.errorMessage ?? "Check your internet connection and try again.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                Task { await viewModel.loadData() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Retry")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 400)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 20) {
            priceBlock
            environmentScoreBlock
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var priceBlock: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                if viewModel.price > 0 {
                    Text(viewModel.formattedPrice)
                        .font(.system(size: isRegular ? 52 : 44, weight: .heavy))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                } else {
                    Text("\u{2014}")
                        .font(.system(size: isRegular ? 52 : 44, weight: .heavy))
                        .foregroundStyle(.quaternary)
                }

                if viewModel.price > 0 {
                    Text(viewModel.formattedChange)
                        .font(.system(.subheadline, design: .monospaced, weight: .bold))
                        .foregroundStyle(AppColors.changeColor(positive: viewModel.change24h >= 0))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            (viewModel.change24h >= 0 ? Color.green : Color.red).opacity(0.12)
                        )
                        .clipShape(Capsule())
                }

                Spacer()

                Button {
                    selectedTab = .portfolio
                } label: {
                    Image(systemName: "wallet.bifold.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.orange)
                        .padding(10)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: selectedTab)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(viewModel.price > 0 ? "Bitcoin price \(viewModel.formattedPrice), \(viewModel.change24h >= 0 ? "up" : "down") \(viewModel.formattedChange) today" : "Price loading")

            HStack(spacing: 16) {
                metricPill(label: "MCap", value: viewModel.formattedMarketCap)
                metricPill(label: "Vol", value: viewModel.formattedVolume)
                if let c7 = viewModel.change7d {
                    metricPill(label: "7d", value: String(format: "%+.1f%%", c7))
                }
                Spacer()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Market cap \(viewModel.formattedMarketCap), volume \(viewModel.formattedVolume)")

            if let updated = viewModel.lastUpdated {
                Text("Updated \(updated.formatted(.relative(presentation: .named)))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.primary.opacity(0.5))
            }
        }
        .padding(.top, 8)
    }

    private func metricPill(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.primary.opacity(0.5))
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)
        }
    }

    private var environmentScoreBlock: some View {
        let signal = viewModel.compositeSignal

        return HStack(spacing: 18) {
            ScoreRingView(
                progress: Double(animatedScore) / 100.0,
                label: viewModel.environmentScoreLabel,
                color: signal.color,
                size: 96
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("ENVIRONMENT")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.primary)
                    .tracking(1.5)

                Text(signal.label)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundStyle(signal.color)

                Text(viewModel.environmentMessage)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .premiumCard(.accent)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Environment Score \(viewModel.environmentScore), \(viewModel.environmentScoreLabel)")
    }

    // MARK: - Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "chart.xyaxis.line", title: "PRICE")

            PriceChartView(
                prices: viewModel.historicalPrices,
                movingAverages: viewModel.movingAverages
            )
        }
        .premiumCard(.highlighted)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    // MARK: - Insight

    private var insightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "sparkle", iconColor: .orange, title: "WHAT CHANGED") {
                if let change = viewModel.signalChangeText {
                    Text(change)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }

            Text(viewModel.insightHeadline)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            if premium.isPremium {
                Text(viewModel.insightExpansion)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(viewModel.insightExpansion)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [.clear, Color(.systemBackground)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 20)
                    }

                Button { showPaywall = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("Unlock full insights")
                            .font(.caption)
                            .fontWeight(.bold)
                        proBadge
                    }
                    .foregroundStyle(.orange)
                }
                .buttonStyle(.plain)
            }
        }
        .premiumCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Daily insight: \(viewModel.insightHeadline). \(viewModel.insightExpansion)")
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    // MARK: - Score Drivers

    private var driversSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "gauge.with.dots.needle.bottom.50percent", title: "SCORE BREAKDOWN")

            VStack(spacing: 0) {
                driverRow(name: "Trend", score: viewModel.trendScore, maxScore: 30, status: viewModel.trendStatus, explanation: viewModel.trendExplanation, isLast: false)
                driverRow(name: "Momentum", score: viewModel.momentumScore, maxScore: 25, status: viewModel.momentumStatus, explanation: viewModel.momentumExplanation, isLast: false)
                driverRow(name: "Positioning", score: viewModel.positioningScore, maxScore: 25, status: viewModel.positioningStatus, explanation: viewModel.positioningExplanation, isLast: false)
                driverRow(name: "Volatility", score: viewModel.volatilityScore, maxScore: 20, status: viewModel.volatilityStatus, explanation: viewModel.volatilityExplanation, isLast: true)
            }
        }
        .premiumCard(.highlighted)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private func driverRow(name: String, score: Int, maxScore: Int, status: DriverStatus, explanation: String, isLast: Bool) -> some View {
        let progress = Double(score) / Double(maxScore)
        let color: Color = {
            switch status {
            case .bullish: return AppColors.bullish
            case .neutral: return .orange
            case .bearish: return AppColors.bearish
            }
        }()

        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(name)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Text(status.label)
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(color)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(color.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    Text(explanation)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Text("\(score)/\(maxScore)")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .padding(.vertical, 10)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.06))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.5), color.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geo.size.width * progress))
                        .animation(.spring(duration: 0.6), value: progress)
                }
            }
            .frame(height: 5)
            .clipShape(Capsule())
            .padding(.bottom, isLast ? 0 : 8)

            if !isLast {
                Divider()
                    .overlay(Color.primary.opacity(0.04))
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Premium Upsell

    private var premiumUpsellCard: some View {
        Button { showPaywall = true } label: {
            VStack(spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.orange)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("Unlock TouchGrass BTC Pro")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            proBadge
                        }
                        Text("All indicators, full insights, weekly summaries & more")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.orange)
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.03)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.4), Color.orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: showPaywall)
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
