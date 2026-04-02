import SwiftUI
import Charts

struct HomeTab: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var showAbout: Bool = false
    @State private var showSettings: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var appeared: Bool = false
    @State private var animatedScore: Int = 0
    @State private var shareImage: UIImage?
    @State private var scoreHistory = ScoreHistoryManager.shared

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 720 : .infinity }
    private var horizontalPadding: CGFloat { isRegular ? 32 : 20 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.isLoading && viewModel.price == 0 {
                        loadingView
                    } else {
                        heroSection
                            .padding(.bottom, 24)

                        if viewModel.historicalPrices.count > 30 {
                            chartSection
                                .padding(.bottom, 24)
                        }

                        if scoreHistory.entries.count >= 2 {
                            ScoreHistoryChartView(entries: scoreHistory.entries)
                                .padding(.bottom, 20)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 16)
                        }

                        insightSection
                            .padding(.bottom, 20)

                        driversSection
                            .padding(.bottom, 20)

                        weeklySummarySection
                            .padding(.bottom, 20)

                        contextSection
                            .padding(.bottom, 20)

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
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { shareEnvironmentScore() } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    Button { showAbout = true } label: {
                        Image(systemName: "info.circle")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showAbout) { AboutView() }
            .sheet(isPresented: $showSettings) { ProfileView() }
            .sheet(isPresented: $showShareSheet) {
                if let image = shareImage {
                    ShareSheetView(image: image)
                }
            }
        }
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

    private func shareEnvironmentScore() {
        shareImage = ShareCardRenderer.render(
            score: viewModel.environmentScore,
            label: viewModel.environmentScoreLabel,
            price: viewModel.formattedPrice,
            change: viewModel.formattedChange,
            isPositive: viewModel.change24h >= 0
        )
        if shareImage != nil {
            showShareSheet = true
        }
    }

    private var brandMark: some View {
        HStack(spacing: 6) {
            Text("BitShrug")
                .font(.system(.subheadline, design: .monospaced, weight: .bold))
                .foregroundStyle(.primary)
            Text("\u{00AF}\\_(ツ)_/\u{00AF}")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.1)
                .tint(.orange.opacity(0.5))
            Text("Loading")
                .font(.caption)
                .foregroundStyle(.quaternary)
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
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                if viewModel.price > 0 {
                    Text(viewModel.formattedPrice)
                        .font(.system(size: isRegular ? 52 : 42, weight: .bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                } else {
                    Text("\u{2014}")
                        .font(.system(size: isRegular ? 52 : 42, weight: .bold))
                        .foregroundStyle(.quaternary)
                }

                if viewModel.price > 0 {
                    Text(viewModel.formattedChange)
                        .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                        .foregroundStyle(viewModel.change24h >= 0 ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            (viewModel.change24h >= 0 ? Color.green : Color.red).opacity(0.1)
                        )
                        .clipShape(Capsule())
                }

                Spacer()
            }

            HStack(spacing: 16) {
                metricPill(label: "MCap", value: viewModel.formattedMarketCap)
                metricPill(label: "Vol", value: viewModel.formattedVolume)
                if let c7 = viewModel.change7d {
                    metricPill(label: "7d", value: String(format: "%+.1f%%", c7))
                }
                Spacer()
            }
        }
        .padding(.top, 8)
    }

    private func metricPill(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    private var environmentScoreBlock: some View {
        let signal = viewModel.compositeSignal

        return HStack(spacing: 18) {
            ScoreRingView(
                progress: Double(animatedScore) / 100.0,
                label: viewModel.environmentScoreLabel,
                color: signal.color,
                size: 88
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("ENVIRONMENT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .tracking(1.2)

                Text(signal.label)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(signal.color)

                Text(viewModel.environmentMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(signal.color.opacity(0.15), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Environment Score \(viewModel.environmentScore), \(viewModel.environmentScoreLabel)")
    }

    // MARK: - Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PRICE")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.tertiary)
                .tracking(1)

            PriceChartView(
                prices: viewModel.historicalPrices,
                movingAverages: viewModel.movingAverages
            )
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    // MARK: - Insight ("What Changed")

    private var insightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkle")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.orange)
                Text("WHAT CHANGED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .tracking(1)
                Spacer()

                if let change = viewModel.signalChangeText {
                    Text(change)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }

            Text(viewModel.insightHeadline)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.insightExpansion)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    // MARK: - Score Drivers

    private var driversSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SCORE BREAKDOWN")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.tertiary)
                .tracking(1)

            VStack(spacing: 0) {
                driverRow(name: "Trend", score: viewModel.trendScore, maxScore: 30, status: viewModel.trendStatus, explanation: viewModel.trendExplanation, isLast: false)
                driverRow(name: "Momentum", score: viewModel.momentumScore, maxScore: 25, status: viewModel.momentumStatus, explanation: viewModel.momentumExplanation, isLast: false)
                driverRow(name: "Positioning", score: viewModel.positioningScore, maxScore: 25, status: viewModel.positioningStatus, explanation: viewModel.positioningExplanation, isLast: false)
                driverRow(name: "Volatility", score: viewModel.volatilityScore, maxScore: 20, status: viewModel.volatilityStatus, explanation: viewModel.volatilityExplanation, isLast: true)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private func driverRow(name: String, score: Int, maxScore: Int, status: DriverStatus, explanation: String, isLast: Bool) -> some View {
        let progress = Double(score) / Double(maxScore)
        let color: Color = {
            switch status {
            case .bullish: return Color(red: 0.2, green: 0.85, blue: 0.5)
            case .neutral: return .orange
            case .bearish: return Color(red: 0.95, green: 0.3, blue: 0.3)
            }
        }()

        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        Text(status.label)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(color.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    Text(explanation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Text("\(score)/\(maxScore)")
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 10)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.06))

                    Capsule()
                        .fill(color.opacity(0.7))
                        .frame(width: max(0, geo.size.width * progress))
                        .animation(.spring(duration: 0.6), value: progress)
                }
            }
            .frame(height: 4)
            .padding(.bottom, isLast ? 0 : 8)

            if !isLast {
                Divider()
                    .overlay(Color.white.opacity(0.04))
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Weekly Summary

    private var weeklySummarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.orange)
                Text("THIS WEEK")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .tracking(1)
                Spacer()

                let dir = viewModel.weeklyDirection
                Text(dir)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(dir == "Improving" ? Color(red: 0.2, green: 0.85, blue: 0.5) : dir == "Weakening" ? Color(red: 0.95, green: 0.3, blue: 0.3) : .secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        (dir == "Improving" ? Color.green : dir == "Weakening" ? Color.red : Color.white).opacity(0.08)
                    )
                    .clipShape(Capsule())
            }

            if let change = viewModel.weeklyScoreChange {
                Text(change)
                    .font(.system(.subheadline, design: .monospaced, weight: .bold))
                    .foregroundStyle(.primary)
            }

            Text(viewModel.weeklyExplanation)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    // MARK: - Market Context

    private var contextSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "globe")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.orange)
                Text("MARKET CONTEXT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .tracking(1)
                Spacer()
            }

            Text(viewModel.marketContext)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            if let phase = viewModel.halvingInfo?.currentPhase {
                HStack(spacing: 8) {
                    Image(systemName: phase.icon)
                        .font(.system(size: 11))
                        .foregroundStyle(phase.color)
                    Text("Cycle Phase: \(phase.label)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(viewModel.rainbowBand.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(viewModel.rainbowBand.color)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var disclaimer: some View {
        Text("BitShrug provides general market context for informational purposes only. It does not provide financial advice or predict future price movements.")
            .font(.caption2)
            .foregroundStyle(.quaternary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
