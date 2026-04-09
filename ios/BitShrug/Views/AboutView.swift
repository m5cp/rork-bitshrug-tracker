import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 620 : .infinity }
    private var horizontalPadding: CGFloat { isRegular ? 32 : 24 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    purposeCard

                    scoreCard

                    rangesCard

                    sourcesCard

                    disclaimerCard
                }
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.tertiary)
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("TouchGrass BTC")
                .font(.system(.title2, design: .monospaced, weight: .heavy))
                .foregroundStyle(.primary)

            ShrugBadge(size: .large, style: .hero)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    private var purposeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "binoculars.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.orange)
                    .frame(width: 34, height: 34)
                    .background(
                        LinearGradient(
                            colors: [.orange.opacity(0.15), .orange.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 9))

                Text("What is TouchGrass BTC?")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }

            Text("Understand the Bitcoin macro environment — without the noise. This is an educational tool to help you learn about Bitcoin's cycle, conditions, and historical patterns. Not financial advice.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .premiumCard(.accent)
    }

    private var scoreCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.orange)
                    .frame(width: 34, height: 34)
                    .background(
                        LinearGradient(
                            colors: [.orange.opacity(0.15), .orange.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 9))

                Text("Environment Score")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }

            Text("A single 0–100 score reflecting current conditions across four components:")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                componentChip(name: "Trend", range: "0–30", icon: "chart.xyaxis.line")
                componentChip(name: "Momentum", range: "0–25", icon: "bolt.fill")
                componentChip(name: "Positioning", range: "0–25", icon: "scope")
                componentChip(name: "Volatility", range: "0–20", icon: "waveform.path.ecg")
            }

            Text("Reflects conditions — not outcomes.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .italic()
        }
        .premiumCard(.highlighted)
    }

    private func componentChip(name: String, range: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.orange)
                .frame(width: 22)

            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Spacer()

            Text(range)
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 8))
    }

    private var rangesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.orange)
                    .frame(width: 34, height: 34)
                    .background(
                        LinearGradient(
                            colors: [.orange.opacity(0.15), .orange.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 9))

                Text("How to Read It")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }

            VStack(spacing: 6) {
                rangeRow(range: "75–100", label: "Strong", color: Color(red: 0.2, green: 0.85, blue: 0.5))
                rangeRow(range: "55–74", label: "Moderate", color: .blue)
                rangeRow(range: "35–54", label: "Weak", color: .orange)
                rangeRow(range: "0–34", label: "High Risk", color: Color(red: 0.95, green: 0.3, blue: 0.3))
            }

            Text("For educational context only. Where signal meets uncertainty.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .italic()
        }
        .premiumCard()
    }

    private func rangeRow(range: String, label: String, color: Color) -> some View {
        HStack {
            Text(range)
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)

            RoundedRectangle(cornerRadius: 3)
                .fill(color.opacity(0.7))
                .frame(width: 4, height: 20)

            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)

            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }

    private var sourcesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "server.rack")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 34, height: 34)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(.rect(cornerRadius: 9))

                Text("Data Sources")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }

            VStack(alignment: .leading, spacing: 10) {
                sourceRow(name: "Finnhub", detail: "BTC price & 24h change")
                sourceRow(name: "CryptoCompare", detail: "Market cap, volume, supply, price history")
                sourceRow(name: "Alternative.me", detail: "Fear & Greed Index")
                sourceRow(name: "Network Stats API", detail: "Hash rate, block height")
                sourceRow(name: "Calculated Locally", detail: "MVRV, Puell, Power Law, Rainbow, Cycles")
            }

            HStack(spacing: 6) {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
                Text("Data is not real-time. Fetched on launch and pull-to-refresh.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 4)
        }
        .premiumCard()
    }

    private func sourceRow(name: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(.orange.opacity(0.5))
                .frame(width: 5, height: 5)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var disclaimerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.red)
                Text("Disclaimer")
                    .font(.caption)
                    .fontWeight(.heavy)
                    .foregroundStyle(.secondary)
            }

            Text("Numbers are not live. Prices and indicators are delayed estimates, not real-time market data.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Text("This is not financial advice. TouchGrass BTC is for educational purposes only. Nobody should make financial decisions based on this app. We do not recommend purchasing Bitcoin or any cryptocurrency. Bitcoin is a volatile asset and you could lose all of your money. Past performance does not guarantee future results.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.red.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.red.opacity(0.15), lineWidth: 1)
        )
    }
}
