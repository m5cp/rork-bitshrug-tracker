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
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Text("Mathematical observation, not a guarantee.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
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

            Text("Logarithmic regression divided into price bands corresponding to historical market conditions.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
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
            Text("THE FORMULA")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.tertiary)
                .tracking(1)

            Text("log\u{2081}\u{2080}(price) = 5.71 \u{00D7} log\u{2081}\u{2080}(days) \u{2212} k")
                .font(.system(.body, design: .monospaced, weight: .medium))
                .foregroundStyle(.orange)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.orange.opacity(0.08))
                .clipShape(.rect(cornerRadius: 10))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                mathTile(label: "price", value: "BTC price in USD")
                mathTile(label: "days", value: "Since genesis block")
                mathTile(label: "5.71", value: "Power law exponent")
                mathTile(label: "k", value: "Support/resistance offset")
            }

            let days = Calendar.current.dateComponents([.day], from: genesisDate(), to: Date()).day ?? 1
            let logDays = log10(Double(days))

            HStack(spacing: 0) {
                mathStat(label: "Days", value: "\(days)")
                Spacer()
                mathStat(label: "log\u{2081}\u{2080}(days)", value: String(format: "%.3f", logDays))
                Spacer()
                mathStat(label: "Slope", value: "5.71")
            }
            .padding(12)
            .background(Color.white.opacity(0.03))
            .clipShape(.rect(cornerRadius: 10))
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 18))
    }

    private func mathTile(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(.caption, design: .monospaced, weight: .bold))
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
        VStack(spacing: 10) {
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
                detail: "Price \u{221D} Time\u{2075}\u{22C5}\u{2077}\u{00B9} — fundamentally different from exponential growth. The rate of growth slows over time but never stops. Many natural phenomena follow power laws: earthquake magnitudes, city sizes, and network effects."
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

            Text("Based on historical patterns. Past behavior does not guarantee future results.")
                .font(.caption2)
                .foregroundStyle(.quaternary)
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
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
