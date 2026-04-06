import SwiftUI

struct FunWithNumbersView: View {
    let viewModel: BitcoinViewModel
    @State private var portfolio = PortfolioManager.shared
    @State private var selectedYear: Double = 2030
    @State private var bandPosition: Double = 0.5
    @Environment(\.colorScheme) private var colorScheme

    private let minYear: Double = 2026
    private let maxYear: Double = 2040

    private var genesisDate: Date {
        var components = DateComponents()
        components.year = 2009
        components.month = 1
        components.day = 3
        return Calendar.current.date(from: components) ?? Date()
    }

    private var daysSinceGenesis: Double {
        var components = DateComponents()
        components.year = Int(selectedYear)
        components.month = 7
        components.day = 1
        let targetDate = Calendar.current.date(from: components) ?? Date()
        let days = Calendar.current.dateComponents([.day], from: genesisDate, to: targetDate).day ?? 1
        return Double(max(days, 1))
    }

    private var supportPrice: Double {
        let logDays = log10(daysSinceGenesis)
        return pow(10, 5.82 * logDays - 17.47)
    }

    private var resistancePrice: Double {
        let logDays = log10(daysSinceGenesis)
        return pow(10, 5.82 * logDays - 16.61)
    }

    private var estimatedPrice: Double {
        let logSupport = log10(max(supportPrice, 1))
        let logResistance = log10(max(resistancePrice, 1))
        let logPrice = logSupport + (logResistance - logSupport) * bandPosition
        return pow(10, logPrice)
    }

    private var portfolioValue: Double {
        portfolio.btcHoldings * estimatedPrice
    }

    private var currentBandColor: Color {
        rainbowColor(at: bandPosition)
    }

    private var currentBandLabel: String {
        let index = min(Int(bandPosition * 10), 9)
        return RainbowBand.allCases[index].label
    }

    private var subtleTextColor: Color {
        colorScheme == .light ? .black : Color.white.opacity(0.55)
    }

    private var faintTextColor: Color {
        colorScheme == .light ? Color.black.opacity(0.7) : Color.white.opacity(0.35)
    }

    private var boldTextColor: Color {
        colorScheme == .light ? .black : .white
    }

    private let rainbowStops: [(position: Double, color: Color)] = [
        (0.0, Color(red: 0.15, green: 0.0, blue: 0.85)),
        (0.11, Color(red: 0.0, green: 0.2, blue: 1.0)),
        (0.22, Color(red: 0.0, green: 0.75, blue: 0.65)),
        (0.33, Color(red: 0.0, green: 0.85, blue: 0.15)),
        (0.44, Color(red: 0.5, green: 0.95, blue: 0.0)),
        (0.55, Color(red: 1.0, green: 0.9, blue: 0.0)),
        (0.66, Color(red: 1.0, green: 0.55, blue: 0.0)),
        (0.77, Color(red: 1.0, green: 0.3, blue: 0.0)),
        (0.88, Color(red: 1.0, green: 0.1, blue: 0.0)),
        (1.0, Color(red: 0.9, green: 0.0, blue: 0.0)),
    ]

    private func rainbowColor(at position: Double) -> Color {
        let p = max(0, min(1, position))
        for i in 0..<(rainbowStops.count - 1) {
            let current = rainbowStops[i]
            let next = rainbowStops[i + 1]
            if p >= current.position && p <= next.position {
                let t = (p - current.position) / (next.position - current.position)
                return interpolateColor(from: current.color, to: next.color, t: t)
            }
        }
        return rainbowStops.last?.color ?? .red
    }

    private func interpolateColor(from: Color, to: Color, t: Double) -> Color {
        let fromResolved = UIColor(from)
        let toResolved = UIColor(to)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        fromResolved.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        toResolved.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: r1 + (r2 - r1) * t,
            green: g1 + (g2 - g1) * t,
            blue: b1 + (b2 - b1) * t
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                funDisclaimerBanner
                resultCard
                yearSliderSection
                bandSliderSection
                if portfolio.btcHoldings > 0 {
                    portfolioProjection
                }
                disclaimerFooter
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Fun with Numbers")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var resultCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(currentBandColor)
                Text("ESTIMATED PRICE")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(subtleTextColor)
                    .tracking(1.5)
                Spacer()
                Text(String(format: "%d", Int(selectedYear)))
                    .font(.system(.caption, design: .monospaced, weight: .heavy))
                    .foregroundStyle(currentBandColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(currentBandColor.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text(formatLargePrice(estimatedPrice))
                .font(.system(size: 42, weight: .black, design: .monospaced))
                .foregroundStyle(boldTextColor)
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.3), value: estimatedPrice)

            HStack(spacing: 16) {
                VStack(spacing: 3) {
                    Text("Band")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(boldTextColor)
                        .tracking(0.5)
                    Text(currentBandLabel)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(currentBandColor)
                }

                Rectangle()
                    .fill(colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.08))
                    .frame(width: 1, height: 28)

                VStack(spacing: 3) {
                    Text("Support")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(boldTextColor)
                        .tracking(0.5)
                    Text(formatCompactPrice(supportPrice))
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(boldTextColor)
                }

                Rectangle()
                    .fill(colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.08))
                    .frame(width: 1, height: 28)

                VStack(spacing: 3) {
                    Text("Resistance")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(boldTextColor)
                        .tracking(0.5)
                    Text(formatCompactPrice(resistancePrice))
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(boldTextColor)
                }
            }
        }
        .premiumCard(.accent)
    }

    private var yearSliderSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader(icon: "calendar", title: "YEAR")
                Spacer()
                Text(String(format: "%d", Int(selectedYear)))
                    .font(.system(.title3, design: .monospaced, weight: .black))
                    .foregroundStyle(boldTextColor)
            }

            Slider(value: $selectedYear, in: minYear...maxYear, step: 1)
                .tint(.orange)
                .sensoryFeedback(.selection, trigger: Int(selectedYear))

            HStack {
                Text(String(format: "%d", Int(minYear)))
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundStyle(boldTextColor)
                Spacer()
                Text(String(format: "%d", Int(maxYear)))
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundStyle(boldTextColor)
            }
        }
        .premiumCard(.highlighted)
    }

    private var bandSliderSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader(icon: "rainbow", iconColor: currentBandColor, title: "POWER LAW BAND")
                Spacer()
                Text(currentBandLabel)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(currentBandColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(currentBandColor.opacity(0.15))
                    .clipShape(Capsule())
            }

            GeometryReader { geo in
                let width = geo.size.width
                let thumbSize: CGFloat = 30
                let trackHeight: CGFloat = 22
                let thumbX = max(0, min(width - thumbSize, width * bandPosition - thumbSize / 2))

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(
                            LinearGradient(
                                stops: rainbowStops.map { Gradient.Stop(color: $0.color, location: $0.position) },
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: trackHeight)

                    Circle()
                        .fill(currentBandColor)
                        .frame(width: thumbSize, height: thumbSize)
                        .overlay(
                            Circle()
                                .strokeBorder(.white, lineWidth: 3)
                        )
                        .shadow(color: currentBandColor.opacity(0.6), radius: 8)
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                        .offset(x: thumbX)
                        .animation(.spring(duration: 0.2), value: bandPosition)
                }
                .frame(height: max(trackHeight, thumbSize))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newPosition = value.location.x / width
                            bandPosition = max(0, min(1, newPosition))
                        }
                )
            }
            .frame(height: 30)

            HStack {
                Text("Fire Sale")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(red: 0.15, green: 0.0, blue: 0.85))
                Spacer()
                Text("Max Bubble")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(red: 0.9, green: 0.0, blue: 0.0))
            }

            rainbowBandPreview
        }
        .premiumCard(.highlighted)
    }

    private var rainbowBandPreview: some View {
        VStack(spacing: 2) {
            ForEach(RainbowBand.allCases.reversed(), id: \.rawValue) { band in
                let bandIndex = Double(band.rawValue)
                let bandStart = bandIndex / 10.0
                let bandEnd = (bandIndex + 1.0) / 10.0
                let isCurrent = bandPosition >= bandStart && bandPosition < bandEnd
                    || (band == .maxBubble && bandPosition >= 0.9)

                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(band.color)
                        .frame(height: isCurrent ? 22 : 8)
                        .opacity(isCurrent ? 1.0 : 0.4)

                    if isCurrent {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 8))
                            Text(band.label)
                                .font(.system(size: 10, weight: .heavy))
                        }
                        .foregroundStyle(band.color)
                        .frame(width: 120, alignment: .leading)
                    } else {
                        Color.clear.frame(width: 120)
                    }
                }
                .animation(.spring(duration: 0.3), value: isCurrent)
            }
        }
    }

    private var portfolioProjection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "bitcoinsign.circle.fill", title: "YOUR HOLDINGS AT THIS PRICE")

            HStack(alignment: .firstTextBaseline) {
                Text(formatLargePrice(portfolioValue))
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundStyle(boldTextColor)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.3), value: portfolioValue)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatBTC(portfolio.btcHoldings))
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(.orange)
                    Text("BTC")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(boldTextColor)
                        .tracking(1)
                }
            }

            if portfolio.hasCostBasis {
                let totalInvested = portfolio.totalCost()
                let pl = portfolioValue - totalInvested
                let plPct = totalInvested > 0 ? ((portfolioValue - totalInvested) / totalInvested) * 100 : 0
                let isPositive = pl >= 0

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Projected P&L")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(boldTextColor)
                            .tracking(0.5)
                        Text("\(isPositive ? "+" : "")\(formatLargePrice(pl))")
                            .font(.system(.caption, design: .monospaced, weight: .bold))
                            .foregroundStyle(AppColors.changeColor(positive: isPositive))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Return")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(boldTextColor)
                            .tracking(0.5)
                        Text("\(isPositive ? "+" : "")\(formatPercent(plPct))")
                            .font(.system(.caption, design: .monospaced, weight: .bold))
                            .foregroundStyle(AppColors.changeColor(positive: isPositive))
                    }

                    Spacer()
                }
            }
        }
        .premiumCard(.accent)
    }

    private var funDisclaimerBanner: some View {
        VStack(spacing: 8) {
            ShrugBadge(size: .large, style: .hero)
                .padding(.bottom, 2)

            HStack(spacing: 6) {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.orange)
                Text("JUST FOR FUN")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(boldTextColor)
                    .tracking(1.2)
            }

            Text("This is all playing with theory numbers and should not be confused with any financial advice. No financial decision should be made based on this and it is no indication that the price will go up or down.")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(faintTextColor)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("Where signal meets uncertainty.")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(.orange)
                .padding(.top, 2)
        }
        .multilineTextAlignment(.center)
        .padding(16)
        .background(Color.orange.opacity(0.06))
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.orange.opacity(0.15), lineWidth: 1)
        )
    }

    private var disclaimerFooter: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange.opacity(0.7))
                Text("For entertainment only. Not financial advice.")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(boldTextColor)
            }

            Text("These projections are based on a theoretical mathematical model (Power Law regression). Bitcoin is extremely volatile and could decline to zero. Past patterns do not guarantee future results. Do not make investment decisions based on these numbers.")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(faintTextColor)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)
        .padding(.top, 4)
    }

    private func formatLargePrice(_ value: Double) -> String {
        if value >= 1_000_000_000_000 {
            return String(format: "$%.2fT", value / 1_000_000_000_000)
        } else if value >= 1_000_000_000 {
            return String(format: "$%.2fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return "$\(Int(value).formatted(.number))"
        }
        return String(format: "$%.2f", value)
    }

    private func formatCompactPrice(_ value: Double) -> String {
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return "$\(Int(value / 1000))k"
        }
        return "$\(Int(value))"
    }

    private func formatBTC(_ value: Double) -> String {
        if value >= 1 { return String(format: "%.4f", value) }
        if value >= 0.01 { return String(format: "%.6f", value) }
        return String(format: "%.8f", value)
    }

    private func formatPercent(_ value: Double) -> String {
        if abs(value) >= 1_000_000 {
            return String(format: "%.1fM%%", value / 1_000_000)
        } else if abs(value) >= 10_000 {
            return String(format: "%.0f%%", value)
        }
        return String(format: "%.1f%%", value)
    }
}
