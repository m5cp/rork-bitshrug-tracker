import SwiftUI

struct PowerLawTab: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var showScrollToTop: Bool = false

    private let sections: [SectionAnchor] = [
        SectionAnchor(id: "verdict", icon: "hand.raised", label: "Verdict"),
        SectionAnchor(id: "corridor", icon: "chart.line.uptrend.xyaxis", label: "Corridor"),
        SectionAnchor(id: "rainbow", icon: "rainbow", label: "Rainbow"),
        SectionAnchor(id: "math", icon: "function", label: "Formula"),
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

                            if viewModel.historicalPrices.count > 30 {
                                corridorChart
                                    .id("corridor")
                            }

                            corridorCard

                            priceRange

                            projectionsTable

                            rainbowCard
                                .id("rainbow")

                            mathSection
                                .id("math")

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
            .navigationTitle("Power Law")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fogBackground()
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

    // MARK: - Power Law Chart

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

    // MARK: - Corridor Status

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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Power Law position: \(zoneName), \(Int(viewModel.powerLawPercent * 100)) percent through corridor")
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

    // MARK: - Price Range

    private var priceRange: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                priceBox(label: "CURRENT PRICE", price: viewModel.price, color: .primary)
                priceBox(label: "FAIR VALUE", price: viewModel.powerLawFairValue, color: .yellow)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Current price \(formatPrice(viewModel.price)), Fair value \(formatPrice(viewModel.powerLawFairValue))")

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
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Support \(formatPrice(viewModel.powerLawSupport)), Fair value \(formatPrice(viewModel.powerLawFairValue)), Resistance \(formatPrice(viewModel.powerLawResistance))")
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

    // MARK: - Projections Table

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

                Text("These values are theoretical estimates derived from a mathematical model. Bitcoin is a volatile asset and could decline significantly, including to zero. Past patterns do not guarantee future results. Do not make investment decisions based on these projections.")
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

    // MARK: - Rainbow Chart

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

    // MARK: - The Math

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

    // MARK: - Helpers

    private func signalTypeColor(_ type: String) -> Color {
        switch type {
        case "Bullish": return Color(red: 0.2, green: 0.85, blue: 0.5)
        case "Bearish": return Color(red: 0.95, green: 0.3, blue: 0.3)
        default: return .orange
        }
    }

    private var disclaimer: some View {
        StyledDisclaimer()
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
