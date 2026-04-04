import SwiftUI

struct DCACalculatorView: View {
    let viewModel: BitcoinViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var weeklyAmount: Double = 50
    @State private var selectedYears: Double = 5
    @State private var bandPosition: Double = 0.5

    private let minAmount: Double = 10
    private let maxAmount: Double = 500
    private let minYears: Double = 1
    private let maxYears: Double = 15

    private var genesisDate: Date {
        var components = DateComponents()
        components.year = 2009
        components.month = 1
        components.day = 3
        return Calendar.current.date(from: components) ?? Date()
    }

    private var targetYear: Int {
        Calendar.current.component(.year, from: Date()) + Int(selectedYears)
    }

    private var daysSinceGenesis: Double {
        var components = DateComponents()
        components.year = targetYear
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

    private var estimatedFuturePrice: Double {
        let logSupport = log10(max(supportPrice, 1))
        let logResistance = log10(max(resistancePrice, 1))
        let logPrice = logSupport + (logResistance - logSupport) * bandPosition
        return pow(10, logPrice)
    }

    private var totalWeeks: Int {
        Int(selectedYears * 52)
    }

    private var totalInvested: Double {
        weeklyAmount * Double(totalWeeks)
    }

    private var estimatedBTC: Double {
        guard viewModel.price > 0 else { return 0 }
        let currentPrice = viewModel.price
        let futurePrice = estimatedFuturePrice
        let avgPrice = (currentPrice + futurePrice) / 2
        return totalInvested / avgPrice
    }

    private var estimatedValue: Double {
        estimatedBTC * estimatedFuturePrice
    }

    private var estimatedReturn: Double {
        guard totalInvested > 0 else { return 0 }
        return ((estimatedValue - totalInvested) / totalInvested) * 100
    }

    private var boldTextColor: Color {
        colorScheme == .light ? .black : .white
    }

    private var faintTextColor: Color {
        colorScheme == .light ? Color.black.opacity(0.7) : Color.white.opacity(0.35)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                disclaimerBanner
                resultCard
                amountSlider
                yearsSlider
                bandSlider
                breakdownCard
                disclaimerFooter
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("DCA Calculator")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var disclaimerBanner: some View {
        VStack(spacing: 8) {
            ShrugBadge(size: .large, style: .hero)
                .padding(.bottom, 2)

            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.orange)
                Text("DCA SIMULATOR")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(boldTextColor)
                    .tracking(1.2)
            }

            Text("See what consistent weekly investing could look like over time based on Power Law projections. This is purely hypothetical.")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(faintTextColor)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("Rise or Fall, we hold.")
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

    private var resultCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.orange)
                Text("ESTIMATED VALUE IN \(targetYear)")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(boldTextColor)
                    .tracking(1.5)
                Spacer()
            }

            Text(formatLargePrice(estimatedValue))
                .font(.system(size: 38, weight: .black, design: .monospaced))
                .foregroundStyle(boldTextColor)
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.3), value: estimatedValue)

            HStack(spacing: 16) {
                VStack(spacing: 3) {
                    Text("Invested")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(boldTextColor)
                        .tracking(0.5)
                    Text(formatLargePrice(totalInvested))
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(boldTextColor)
                }

                Rectangle()
                    .fill(colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.08))
                    .frame(width: 1, height: 28)

                VStack(spacing: 3) {
                    Text("Est. BTC")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(boldTextColor)
                        .tracking(0.5)
                    Text(formatBTC(estimatedBTC))
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(.orange)
                }

                Rectangle()
                    .fill(colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.08))
                    .frame(width: 1, height: 28)

                VStack(spacing: 3) {
                    Text("Return")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(boldTextColor)
                        .tracking(0.5)
                    Text("\(estimatedReturn >= 0 ? "+" : "")\(formatPercent(estimatedReturn))")
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(AppColors.changeColor(positive: estimatedReturn >= 0))
                }
            }
        }
        .premiumCard(.accent)
    }

    private var amountSlider: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader(icon: "dollarsign.circle", title: "WEEKLY AMOUNT")
                Spacer()
                Text("$\(Int(weeklyAmount))/wk")
                    .font(.system(.title3, design: .monospaced, weight: .black))
                    .foregroundStyle(boldTextColor)
            }

            Slider(value: $weeklyAmount, in: minAmount...maxAmount, step: 10)
                .tint(.orange)
                .sensoryFeedback(.selection, trigger: Int(weeklyAmount))

            HStack {
                Text("$\(Int(minAmount))")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundStyle(boldTextColor)
                Spacer()
                Text("$\(Int(maxAmount))")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundStyle(boldTextColor)
            }
        }
        .premiumCard(.highlighted)
    }

    private var yearsSlider: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader(icon: "calendar", title: "TIME HORIZON")
                Spacer()
                Text("\(Int(selectedYears)) yr\(Int(selectedYears) == 1 ? "" : "s")")
                    .font(.system(.title3, design: .monospaced, weight: .black))
                    .foregroundStyle(boldTextColor)
            }

            Slider(value: $selectedYears, in: minYears...maxYears, step: 1)
                .tint(.orange)
                .sensoryFeedback(.selection, trigger: Int(selectedYears))

            HStack {
                Text("\(Int(minYears)) yr")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundStyle(boldTextColor)
                Spacer()
                Text("\(Int(maxYears)) yrs")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundStyle(boldTextColor)
            }
        }
        .premiumCard(.highlighted)
    }

    private var bandSlider: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader(icon: "rainbow", title: "POWER LAW BAND")
                Spacer()
                Text(currentBandLabel)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(currentBandColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(currentBandColor.opacity(0.15))
                    .clipShape(Capsule())
            }

            Slider(value: $bandPosition, in: 0...1)
                .tint(currentBandColor)
                .sensoryFeedback(.selection, trigger: Int(bandPosition * 10))

            HStack {
                Text("Support")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.blue)
                Spacer()
                Text("Resistance")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.red)
            }
        }
        .premiumCard(.highlighted)
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "list.bullet", title: "BREAKDOWN")

            VStack(spacing: 10) {
                breakdownRow(label: "Weekly investment", value: "$\(Int(weeklyAmount))")
                breakdownRow(label: "Duration", value: "\(Int(selectedYears)) year\(Int(selectedYears) == 1 ? "" : "s") (\(totalWeeks) weeks)")
                breakdownRow(label: "Total invested", value: formatLargePrice(totalInvested))
                breakdownRow(label: "Current BTC price", value: viewModel.formattedPrice)
                breakdownRow(label: "Projected \(targetYear) price", value: formatLargePrice(estimatedFuturePrice))
                breakdownRow(label: "Est. BTC accumulated", value: formatBTC(estimatedBTC))
                breakdownRow(label: "Est. satoshis", value: Int(estimatedBTC * 100_000_000).formatted(.number))
            }
        }
        .premiumCard()
    }

    private func breakdownRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(boldTextColor)
        }
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

            Text("DCA projections use Power Law regression estimates. Bitcoin is extremely volatile and could decline to zero. Past patterns do not guarantee future results.")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(faintTextColor)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)
        .padding(.top, 4)
    }

    private var currentBandColor: Color {
        let index = min(Int(bandPosition * 10), 9)
        return RainbowBand.allCases[index].color
    }

    private var currentBandLabel: String {
        let index = min(Int(bandPosition * 10), 9)
        return RainbowBand.allCases[index].label
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
