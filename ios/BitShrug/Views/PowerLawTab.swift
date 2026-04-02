import SwiftUI

struct PowerLawTab: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 720 : .infinity }
    private var horizontalPadding: CGFloat { isRegular ? 32 : 20 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading && viewModel.price == 0 {
                        loadingPlaceholder
                    } else {
                        shrugVerdict
                            .padding(.top, 8)

                        if viewModel.historicalPrices.count > 30 {
                            corridorChart
                        }

                        corridorCard

                        priceRange

                        rainbowCard

                        mathSection

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
            .navigationTitle("Power Law")
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
        let position = viewModel.powerLawPosition
        let percent = viewModel.powerLawPercent

        let verdict: String
        let explanation: String
        let verdictColor: Color

        switch position {
        case .belowSupport:
            verdict = "The Power Law is holding"
            explanation = "Price is below the model's support floor \u{2014} a zone that has historically represented the strongest long-term value. If Bitcoin follows the Power Law, this is where the model says to pay attention."
            verdictColor = Color(red: 0.2, green: 0.85, blue: 0.5)
        case .withinCorridor:
            if percent < 0.35 {
                verdict = "The Power Law is holding"
                explanation = "Price is near the lower end of the Power Law corridor. The model's long-term growth trajectory appears intact, with price tracking the expected path."
                verdictColor = Color(red: 0.2, green: 0.85, blue: 0.5)
            } else if percent > 0.75 {
                verdict = "Getting stretched"
                explanation = "Price is approaching the upper boundary of the Power Law corridor. Historically, extended periods above 75% have preceded cooling phases. The model isn't broken \u{2014} but it's being tested."
                verdictColor = .orange
            } else {
                verdict = "On track"
                explanation = "Price is within the expected Power Law corridor. The mathematical model's prediction of long-term logarithmic growth appears consistent with current price action."
                verdictColor = .blue
            }
        case .aboveResistance:
            verdict = "Beyond the model"
            explanation = "Price has exceeded the Power Law's upper boundary. This has happened before during euphoric phases, but it challenges the model's predictive accuracy. Either the model needs recalibrating, or price will revert."
            verdictColor = Color(red: 0.95, green: 0.3, blue: 0.3)
        }

        return VStack(spacing: 14) {
            HStack(spacing: 8) {
                Text("\u{00AF}\\_(ツ)_/\u{00AF}")
                    .font(.system(.title3, design: .monospaced))
                    .foregroundStyle(.orange)
                Text("IS THE POWER LAW VALID?")
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
                Text("The Power Law is a mathematical observation, not a guarantee. It could break at any time.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
    }

    // MARK: - Power Law Chart

    private var corridorChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("POWER LAW CORRIDOR")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .tracking(1)
                Spacer()

                HStack(spacing: 12) {
                    legendDot(color: .orange, label: "Price")
                    legendDot(color: .green.opacity(0.5), label: "Support")
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
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.tertiary)
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
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.tertiary)
                        .tracking(1)

                    Text(zoneName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(zoneColor)
                }

                Spacer()

                Text("\(Int(viewModel.powerLawPercent * 100))%")
                    .font(.system(.title2, design: .monospaced, weight: .bold))
                    .foregroundStyle(.primary)
            }

            corridorBar(position: viewModel.powerLawPercent)

            HStack {
                Text("Support")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.green.opacity(0.7))
                Spacer()
                Text("Midpoint")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Resistance")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.red.opacity(0.7))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
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
                    .frame(width: 16, height: 16)
                    .shadow(color: .white.opacity(0.3), radius: 6)
                    .offset(x: max(0, min(width - 16, width * position - 8)))
                    .animation(.spring(duration: 0.5), value: position)
            }
        }
        .frame(height: 16)
    }

    // MARK: - Price Range

    private var priceRange: some View {
        HStack {
            priceColumn(label: "Support", price: viewModel.powerLawSupport, color: Color(red: 0.2, green: 0.85, blue: 0.5))
            Spacer()
            priceColumn(label: "Current", price: viewModel.price, color: .primary)
            Spacer()
            priceColumn(label: "Resistance", price: viewModel.powerLawResistance, color: Color(red: 0.95, green: 0.3, blue: 0.3))
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
    }

    private func priceColumn(label: String, price: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.tertiary)
            Text(formatPrice(price))
                .font(.system(.footnote, design: .monospaced, weight: .semibold))
                .foregroundStyle(color)
        }
    }

    // MARK: - Rainbow Chart

    private var rainbowCard: some View {
        let band = viewModel.rainbowBand

        return VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RAINBOW CHART")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.tertiary)
                        .tracking(1)

                    Text(band.label)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(band.color)
                }

                Spacer()

                Text(band.signalType)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(signalTypeColor(band.signalType))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(signalTypeColor(band.signalType).opacity(0.12))
                    .clipShape(Capsule())
            }

            rainbowBands(currentBand: band)

            Text("Based on logarithmic regression of Bitcoin's price over time, divided into price bands that historically correspond to different market conditions.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
    }

    private func rainbowBands(currentBand: RainbowBand) -> some View {
        VStack(spacing: 2) {
            ForEach(RainbowBand.allCases.reversed(), id: \.rawValue) { band in
                let isCurrent = band == currentBand

                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(band.color.opacity(isCurrent ? 1.0 : 0.3))
                        .frame(height: isCurrent ? 24 : 10)

                    if isCurrent {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 8))
                            Text("You are here")
                                .font(.system(size: 10, weight: .bold))
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
            Text("THE MATH BEHIND IT")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.tertiary)
                .tracking(1)

            VStack(alignment: .leading, spacing: 8) {
                Text("The Power Law Formula")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Text("log\u{2081}\u{2080}(price) = 5.71 \u{00D7} log\u{2081}\u{2080}(days) \u{2212} k")
                    .font(.system(.body, design: .monospaced, weight: .medium))
                    .foregroundStyle(.orange)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(.orange.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 10))

                Text("Where:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 6) {
                    mathRow(variable: "price", meaning: "Bitcoin's price in USD")
                    mathRow(variable: "days", meaning: "Days since Bitcoin's genesis block (Jan 3, 2009)")
                    mathRow(variable: "5.71", meaning: "The power law exponent (slope on log-log scale)")
                    mathRow(variable: "k", meaning: "Constant that shifts the line up/down (support \u{2248} 17.01, resistance \u{2248} 15.51)")
                }

                Text("In plain English: when you plot Bitcoin's price on a log-log chart (log of price vs log of time), it follows a remarkably straight line. The slope of 5.71 means price scales as time\u{2075}\u{22C5}\u{2077}\u{00B9} \u{2014} a power law relationship, not exponential growth.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }

            Divider()
                .overlay(Color.white.opacity(0.06))

            VStack(alignment: .leading, spacing: 8) {
                Text("Current Values")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                let days = Calendar.current.dateComponents([.day], from: genesisDate(), to: Date()).day ?? 1
                let logDays = log10(Double(days))

                HStack(spacing: 0) {
                    mathStat(label: "Days Since Genesis", value: "\(days)")
                    Spacer()
                    mathStat(label: "log\u{2081}\u{2080}(days)", value: String(format: "%.3f", logDays))
                    Spacer()
                    mathStat(label: "Slope", value: "5.71")
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
    }

    private func mathRow(variable: String, meaning: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(variable)
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(.orange)
                .frame(width: 50, alignment: .leading)
            Text(meaning)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func mathStat(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.system(.footnote, design: .monospaced, weight: .semibold))
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Education

    private var educationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("UNDERSTANDING THE POWER LAW")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.tertiary)
                .tracking(1)

            educationBlock(
                title: "Who Created It?",
                body: "The Bitcoin Power Law model is most closely associated with Harold Christopher Burger, who published his research in 2019. He observed that Bitcoin's price, when plotted on a log-log chart against time, follows a remarkably linear relationship \u{2014} a power law.\n\nGiovanni Santostasi further developed the concept, applying power law analysis to Bitcoin's price, hash rate, and number of addresses, showing the relationship holds across multiple network metrics."
            )

            educationBlock(
                title: "What is a Power Law?",
                body: "A power law is a mathematical relationship where one quantity varies as a power of another. In Bitcoin's case:\n\nPrice \u{221D} Time\u{2075}\u{22C5}\u{2077}\u{00B9}\n\nThis is fundamentally different from exponential growth (which compounds at a constant rate). Power law growth decelerates over time but never stops \u{2014} the rate of growth slows, but the growth continues.\n\nMany natural and social phenomena follow power laws: earthquake magnitudes, city sizes, wealth distribution, and network effects."
            )

            educationBlock(
                title: "How to Read the Corridor",
                body: "\u{2022} Below Support \u{2014} Price is historically cheap. In past cycles, this has been the best long-term accumulation zone.\n\n\u{2022} Within Corridor \u{2014} Price is tracking the expected long-term growth path. Most of Bitcoin's life is spent here.\n\n\u{2022} Above Resistance \u{2014} Price has exceeded the upper boundary. This has historically coincided with cycle tops and euphoria."
            )

            educationBlock(
                title: "What is the Rainbow Chart?",
                body: "The Rainbow Chart overlays colored bands on the power law model, dividing it into zones from 'Fire Sale' (deep blue) to 'Maximum Bubble' (deep red).\n\nEach band represents a standard deviation from the fair value regression line. It's a visual heuristic \u{2014} not a prediction \u{2014} that shows where price sits relative to its long-term trend."
            )

            Text("Based on historical patterns. Past behavior does not guarantee future results.")
                .font(.caption2)
                .foregroundStyle(.quaternary)
                .italic()
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

    // MARK: - Helpers

    private func signalTypeColor(_ type: String) -> Color {
        switch type {
        case "Bullish": return Color(red: 0.2, green: 0.85, blue: 0.5)
        case "Bearish": return Color(red: 0.95, green: 0.3, blue: 0.3)
        default: return .orange
        }
    }

    private var disclaimer: some View {
        Text("BitShrug provides general market context for informational purposes only. It does not provide financial advice or predict future price movements.")
            .font(.caption2)
            .foregroundStyle(.quaternary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
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
