import SwiftUI

struct AnalysisTab: View {
    let viewModel: BitcoinViewModel
    @State private var selectedSegment: AnalysisSegment = .powerLaw

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                segmentPicker
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                TabView(selection: $selectedSegment) {
                    PowerLawContent(viewModel: viewModel)
                        .tag(AnalysisSegment.powerLaw)

                    CycleContent(viewModel: viewModel)
                        .tag(AnalysisSegment.cycle)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: selectedSegment)
            }
            .navigationTitle("Analysis")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fogBackground()
        .sensoryFeedback(.selection, trigger: selectedSegment)
    }

    private var segmentPicker: some View {
        HStack(spacing: 0) {
            ForEach(AnalysisSegment.allCases, id: \.self) { segment in
                Button {
                    selectedSegment = segment
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: segment.icon)
                            .font(.system(size: 11, weight: .bold))
                        Text(segment.title)
                            .font(.system(size: 12, weight: .heavy))
                    }
                    .foregroundStyle(selectedSegment == segment ? .white : .primary.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selectedSegment == segment
                            ? AnyShapeStyle(Color.orange.opacity(0.85))
                            : AnyShapeStyle(Color.clear)
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color.primary.opacity(0.06))
        .clipShape(Capsule())
    }

    nonisolated enum AnalysisSegment: CaseIterable, Hashable {
        case powerLaw
        case cycle

        var title: String {
            switch self {
            case .powerLaw: return "Power Law"
            case .cycle: return "4-Year Cycle"
            }
        }

        var icon: String {
            switch self {
            case .powerLaw: return "chart.line.uptrend.xyaxis"
            case .cycle: return "arrow.triangle.2.circlepath"
            }
        }
    }
}

// MARK: - Power Law Content

private struct PowerLawContent: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var showScrollToTop: Bool = false

    private let sections: [SectionAnchor] = [
        SectionAnchor(id: "pl-verdict", icon: "hand.raised", label: "Verdict"),
        SectionAnchor(id: "pl-corridor", icon: "chart.line.uptrend.xyaxis", label: "Corridor"),
        SectionAnchor(id: "pl-rainbow", icon: "rainbow", label: "Rainbow"),
        SectionAnchor(id: "pl-math", icon: "function", label: "Formula"),
    ]

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 720 : .infinity }
    private var horizontalPadding: CGFloat { isRegular ? 32 : 20 }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    Color.clear.frame(height: 0).id("pl-top")

                    if viewModel.isLoading && viewModel.price == 0 {
                        loadingPlaceholder
                    } else {
                        SectionJumpBar(sections: sections) { id in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(id, anchor: .top)
                            }
                        }

                        shrugVerdict
                            .id("pl-verdict")

                        if viewModel.historicalPrices.count > 30 {
                            corridorChart
                                .id("pl-corridor")
                        }

                        corridorCard
                        priceRange
                        projectionsTable

                        rainbowCard
                            .id("pl-rainbow")

                        mathSection
                            .id("pl-math")

                        StyledDisclaimer()
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
                        proxy.scrollTo("pl-top", anchor: .top)
                    }
                }
            }
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
                .fontWeight(.semibold)
                .foregroundStyle(.primary.opacity(0.5))
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    private var shrugVerdict: some View {
        let position = viewModel.powerLawPosition
        let percent = viewModel.powerLawPercent

        let verdict: String
        let explanation: String
        let verdictColor: Color

        switch position {
        case .belowSupport:
            verdict = "The Power Law is holding"
            explanation = "Price is below the model's support floor — historically the strongest long-term value zone."
            verdictColor = Color(red: 0.2, green: 0.85, blue: 0.5)
        case .withinCorridor:
            if percent < 0.35 {
                verdict = "The Power Law is holding"
                explanation = "Price is near the lower corridor. The long-term growth trajectory appears intact."
                verdictColor = Color(red: 0.2, green: 0.85, blue: 0.5)
            } else if percent > 0.75 {
                verdict = "Getting stretched"
                explanation = "Price is approaching the upper boundary. Extended periods above 75% have preceded cooling phases."
                verdictColor = .orange
            } else {
                verdict = "On track"
                explanation = "Price is within the expected corridor. Long-term logarithmic growth appears consistent."
                verdictColor = .blue
            }
        case .aboveResistance:
            verdict = "Beyond the model"
            explanation = "Price has exceeded the upper boundary. Either the model needs recalibrating, or price will revert."
            verdictColor = Color(red: 0.95, green: 0.3, blue: 0.3)
        }

        return VStack(spacing: 16) {
            HStack(spacing: 10) {
                ShrugBadge(size: .large, style: .hero)

                Text("IS THE POWER LAW VALID?")
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
                Text("Mathematical observation, not a guarantee.")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .premiumCard(.accent)
    }

    private var corridorChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "chart.line.uptrend.xyaxis", title: "POWER LAW CORRIDOR") {
                HStack(spacing: 10) {
                    legendDot(color: .orange, label: "Price")
                    legendDot(color: .green.opacity(0.5), label: "Support")
                    legendDot(color: .yellow.opacity(0.5), label: "Fair Value")
                    legendDot(color: .red.opacity(0.5), label: "Resistance")
                }
            }

            PowerLawChartView(
                prices: viewModel.historicalPrices,
                supportPrice: viewModel.powerLawSupport,
                resistancePrice: viewModel.powerLawResistance,
                currentPrice: viewModel.price
            )
        }
        .premiumCard(.highlighted)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.primary)
        }
    }

    private var corridorCard: some View {
        let zoneName: String = {
            switch viewModel.powerLawPosition {
            case .belowSupport: return "Below Support"
            case .withinCorridor: return "Within Corridor"
            case .aboveResistance: return "Above Resistance"
            }
        }()

        let zoneColor: Color = {
            switch viewModel.powerLawPosition {
            case .belowSupport: return Color(red: 0.2, green: 0.85, blue: 0.5)
            case .withinCorridor: return .blue
            case .aboveResistance: return Color(red: 0.95, green: 0.3, blue: 0.3)
            }
        }()

        return VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("POSITION")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.primary)
                        .tracking(1.5)

                    Text(zoneName)
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundStyle(zoneColor)
                }

                Spacer()

                Text("\(Int(viewModel.powerLawPercent * 100))%")
                    .font(.system(.title2, design: .monospaced, weight: .heavy))
                    .foregroundStyle(.primary)
            }

            corridorBar(position: viewModel.powerLawPercent)

            HStack {
                VStack(spacing: 2) {
                    Text("Support")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.green)
                    Text("0%")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("Midpoint")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.secondary)
                    Text("50%")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("Resistance")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.red)
                    Text("100%")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .premiumCard(.highlighted)
    }

    private func corridorBar(position: Double) -> some View {
        GeometryReader { geo in
            let width = geo.size.width

            ZStack(alignment: .leading) {
                LinearGradient(
                    colors: [.green.opacity(0.3), .blue.opacity(0.3), .red.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(Capsule())

                Circle()
                    .fill(.white)
                    .frame(width: 18, height: 18)
                    .shadow(color: .white.opacity(0.4), radius: 8)
                    .shadow(color: .white.opacity(0.2), radius: 16)
                    .offset(x: max(0, min(width - 18, width * position - 9)))
                    .animation(.spring(duration: 0.5), value: position)
            }
        }
        .frame(height: 18)
    }

    private var priceRange: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                priceBox(label: "CURRENT PRICE", price: viewModel.price, color: .primary)
                priceBox(label: "FAIR VALUE", price: viewModel.powerLawFairValue, color: .yellow)
            }

            if let updated = viewModel.lastUpdated {
                Text("Price updated \(updated.formatted(.relative(presentation: .named)))")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.primary.opacity(0.5))
            }

            HStack(spacing: 12) {
                statBox(label: "DAYS SINCE GENESIS", value: "\(daysSinceGenesis)", color: .primary)
                statBox(label: "MODEL R²", value: "0.952", color: Color(red: 0.2, green: 0.85, blue: 0.5))
            }

            HStack {
                priceColumn(label: "Support", price: viewModel.powerLawSupport, color: Color(red: 0.2, green: 0.85, blue: 0.5))
                Spacer()
                priceColumn(label: "Fair Value", price: viewModel.powerLawFairValue, color: .yellow)
                Spacer()
                priceColumn(label: "Resistance", price: viewModel.powerLawResistance, color: Color(red: 0.95, green: 0.3, blue: 0.3))
            }
            .padding(.top, 4)
        }
        .premiumCard()
    }

    private func priceBox(label: String, price: Double, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(.primary)
                .tracking(1)
            Text(formatPrice(price))
                .font(.system(.body, design: .monospaced, weight: .heavy))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func statBox(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(.primary)
                .tracking(1)
            Text(value)
                .font(.system(.body, design: .monospaced, weight: .heavy))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func priceColumn(label: String, price: Double, color: Color) -> some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(.primary)
            Text(formatPrice(price))
                .font(.system(.footnote, design: .monospaced, weight: .bold))
                .foregroundStyle(color)
        }
    }

    private var daysSinceGenesis: Int {
        Calendar.current.dateComponents([.day], from: genesisDate(), to: Date()).day ?? 0
    }

    private var projectionsTable: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "chart.bar.xaxis", title: "POWER LAW PROJECTIONS")

            VStack(spacing: 0) {
                HStack {
                    Text("YEAR")
                        .frame(width: 50, alignment: .leading)
                    Spacer()
                    Text("SUPPORT")
                        .frame(width: 80, alignment: .trailing)
                    Spacer()
                    Text("FAIR VALUE")
                        .frame(width: 90, alignment: .trailing)
                    Spacer()
                    Text("RESISTANCE")
                        .frame(width: 90, alignment: .trailing)
                }
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.vertical, 10)
                .padding(.horizontal, 4)
                .background(Color.primary.opacity(0.03))
                .clipShape(.rect(cornerRadius: 8))
                .padding(.bottom, 6)

                ForEach(projectionYears, id: \.year) { row in
                    HStack {
                        Text("\(row.year)")
                            .font(.system(.footnote, design: .monospaced, weight: .heavy))
                            .foregroundStyle(.primary)
                            .frame(width: 50, alignment: .leading)
                        Spacer()
                        Text(formatPrice(row.support))
                            .font(.system(.caption, design: .monospaced, weight: .bold))
                            .foregroundStyle(Color(red: 0.2, green: 0.85, blue: 0.5))
                            .frame(width: 80, alignment: .trailing)
                        Spacer()
                        Text(formatPrice(row.fairValue))
                            .font(.system(.caption, design: .monospaced, weight: .bold))
                            .foregroundStyle(.yellow)
                            .frame(width: 90, alignment: .trailing)
                        Spacer()
                        Text(formatPrice(row.resistance))
                            .font(.system(.caption, design: .monospaced, weight: .bold))
                            .foregroundStyle(.red)
                            .frame(width: 90, alignment: .trailing)
                    }
                    .padding(.vertical, 8)

                    if row.year != projectionYears.last?.year {
                        Divider().opacity(0.15)
                    }
                }
            }

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.orange.opacity(0.6))
                    Text("Projections based on power law regression. Not financial advice.")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }

                Text("These values are theoretical estimates derived from a mathematical model. Bitcoin is a volatile asset and could decline significantly, including to zero. Past patterns do not guarantee future results.")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.primary.opacity(0.6))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .premiumCard(.highlighted)
    }

    private var projectionYears: [(year: Int, support: Double, fairValue: Double, resistance: Double)] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let genesis = genesisDate()
        return (currentYear...(currentYear + 5)).map { year in
            var components = DateComponents()
            components.year = year
            components.month = 7
            components.day = 1
            let midYear = Calendar.current.date(from: components) ?? Date()
            let days = Double(max(Calendar.current.dateComponents([.day], from: genesis, to: midYear).day ?? 1, 1))
            let logDays = log10(days)
            let support = pow(10, 5.82 * logDays - 17.47)
            let fairValue = pow(10, 5.82 * logDays - 17.01)
            let resistance = pow(10, 5.82 * logDays - 16.61)
            return (year, support, fairValue, resistance)
        }
    }

    private var rainbowCard: some View {
        let band = viewModel.rainbowBand

        return VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    SectionHeader(icon: "rainbow", iconColor: .purple, title: "RAINBOW CHART")

                    Text(band.label)
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundStyle(band.color)
                        .padding(.top, 4)
                }

                Spacer()

                Text(band.signalType)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(signalTypeColor(band.signalType))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(signalTypeColor(band.signalType).opacity(0.12))
                    .clipShape(Capsule())
            }

            rainbowBands(currentBand: band)

            Text("Logarithmic regression divided into price bands corresponding to historical market conditions.")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .premiumCard(.highlighted)
    }

    private func rainbowBands(currentBand: RainbowBand) -> some View {
        VStack(spacing: 2) {
            ForEach(RainbowBand.allCases.reversed(), id: \.rawValue) { band in
                let isCurrent = band == currentBand

                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(band.color.opacity(isCurrent ? 1.0 : 0.3))
                        .frame(height: isCurrent ? 26 : 10)

                    if isCurrent {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 8))
                            Text("You are here")
                                .font(.system(size: 10, weight: .heavy))
                        }
                        .foregroundStyle(band.color)
                        .frame(width: 90, alignment: .leading)
                    } else {
                        Color.clear
                            .frame(width: 90)
                    }
                }
                .animation(.spring(duration: 0.3), value: isCurrent)
            }
        }
    }

    private var mathSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "function", title: "THE FORMULA")

            Text("log₁₀(price) = 5.82 × log₁₀(days) − k")
                .font(.system(.body, design: .monospaced, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, Color(red: 1.0, green: 0.6, blue: 0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.orange.opacity(0.15), lineWidth: 1)
                )
                .clipShape(.rect(cornerRadius: 12))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                mathTile(label: "price", value: "BTC price in USD")
                mathTile(label: "days", value: "Since genesis block")
                mathTile(label: "5.82", value: "Power law exponent")
                mathTile(label: "k", value: "Support/resistance offset")
            }

            let days = Calendar.current.dateComponents([.day], from: genesisDate(), to: Date()).day ?? 1
            let logDays = log10(Double(days))

            HStack(spacing: 0) {
                mathStat(label: "Days", value: "\(days)")
                Spacer()
                mathStat(label: "log₁₀(days)", value: String(format: "%.3f", logDays))
                Spacer()
                mathStat(label: "Slope", value: "5.82")
            }
            .padding(12)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
        }
        .premiumCard(.highlighted)
    }

    private func mathTile(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(.caption, design: .monospaced, weight: .heavy))
                .foregroundStyle(.orange)
            Text(value)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
    }

    private func mathStat(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.primary)
            Text(value)
                .font(.system(.footnote, design: .monospaced, weight: .bold))
                .foregroundStyle(.primary)
        }
    }

    private func signalTypeColor(_ type: String) -> Color {
        switch type {
        case "Bullish": return Color(red: 0.2, green: 0.85, blue: 0.5)
        case "Bearish": return Color(red: 0.95, green: 0.3, blue: 0.3)
        default: return .orange
        }
    }

    private func formatPrice(_ value: Double) -> String {
        "$\(Int(value).formatted(.number))"
    }

    private func genesisDate() -> Date {
        var components = DateComponents()
        components.year = 2009
        components.month = 1
        components.day = 3
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - Cycle Content

private struct CycleContent: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var showScrollToTop: Bool = false
    @State private var showTimeMachine: Bool = false

    private let sections: [SectionAnchor] = [
        SectionAnchor(id: "cy-verdict", icon: "hand.raised", label: "Verdict"),
        SectionAnchor(id: "cy-history", icon: "clock.arrow.circlepath", label: "History"),
        SectionAnchor(id: "cy-reversal", icon: "arrow.triangle.2.circlepath.circle", label: "Reversal"),
        SectionAnchor(id: "cy-projected", icon: "chart.line.downtrend.xyaxis", label: "Bottom"),
    ]

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 720 : .infinity }
    private var horizontalPadding: CGFloat { isRegular ? 32 : 20 }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    Color.clear.frame(height: 0).id("cy-top")

                    if viewModel.isLoading && viewModel.price == 0 {
                        loadingPlaceholder
                    } else {
                        SectionJumpBar(sections: sections) { id in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(id, anchor: .top)
                            }
                        }

                        shrugVerdict
                            .id("cy-verdict")

                        cycleRing
                        halvingStats

                        HistoricalCycleComparisonView(currentPrice: viewModel.price)
                            .id("cy-history")

                        historicalHalvings
                        historicalCycleReturns

                        ReversalTrackerView(viewModel: viewModel)
                            .id("cy-reversal")

                        ProjectedCycleBottomView(currentPrice: viewModel.price)
                            .id("cy-projected")

                        timeMachineCard

                        StyledDisclaimer(showLastUpdated: viewModel.lastUpdated)
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
                        proxy.scrollTo("cy-top", anchor: .top)
                    }
                }
            }
        }
        .sheet(isPresented: $showTimeMachine) {
            CycleTimeMachineView(viewModel: viewModel)
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
                .fontWeight(.semibold)
                .foregroundStyle(.primary.opacity(0.5))
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

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
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: isRegular ? 200 : 170, height: isRegular ? 200 : 170)

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
        .padding(.vertical, 12)
        .premiumCard(.highlighted)
    }

    private var halvingStats: some View {
        Group {
            if let info = viewModel.halvingInfo {
                HStack(spacing: 0) {
                    statCell(label: "Since Halving", value: "\(info.daysSinceLast)d", icon: "calendar.badge.clock")
                    Spacer()
                    Rectangle()
                        .fill(Color.primary.opacity(0.06))
                        .frame(width: 1, height: 36)
                    Spacer()
                    statCell(label: "Next Halving", value: "~\(info.daysUntilNext)d", icon: "hourglass")
                    Spacer()
                    Rectangle()
                        .fill(Color.primary.opacity(0.06))
                        .frame(width: 1, height: 36)
                    Spacer()
                    statCell(label: "Block Reward", value: "\(String(format: "%.3f", info.blockReward)) BTC", icon: "cube")
                }
                .premiumCard(.accent)
            }
        }
    }

    private func statCell(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.orange.opacity(0.7))
            Text(label)
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(.secondary)
                .tracking(0.5)
            Text(value)
                .font(.system(.footnote, design: .monospaced, weight: .bold))
                .foregroundStyle(.primary)
        }
    }

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

    private var timeMachineCard: some View {
        Button { showTimeMachine = true } label: {
            HStack(spacing: 14) {
                Image(systemName: "clock.arrow.2.circlepath")
                    .font(.system(size: 22))
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Cycle Time Machine")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text("Scrub through past cycles and see estimated scores")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
        .premiumCard(.highlighted)
    }
}
