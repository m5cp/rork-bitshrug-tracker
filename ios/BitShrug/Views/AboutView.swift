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
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                        .padding(.bottom, 32)

                    whatIsBitShrug
                        .padding(.bottom, 24)

                    environmentScoreSection
                        .padding(.bottom, 24)

                    howToReadSection
                        .padding(.bottom, 24)

                    dataSourcesSection
                        .padding(.bottom, 24)

                    disclaimerSection
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

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("BitShrug")
                .font(.system(.title2, design: .monospaced, weight: .bold))
                .foregroundStyle(.primary)

            Text("¯\\_(ツ)_/¯")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    // MARK: - What is BitShrug

    private var whatIsBitShrug: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("What is BitShrug")

            Text("BitShrug helps you understand the current Bitcoin environment — without the noise.")
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Text("Instead of charts and predictions, it focuses on what matters: where we are in the cycle, how conditions are shifting, and whether the environment supports long-term positioning.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Environment Score

    private var environmentScoreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Environment Score")

            Text("A single score from 0 to 100 that reflects current Bitcoin market conditions across four components:")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 0) {
                componentRow(name: "Trend", range: "0 – 30", description: "Overall price direction relative to long-term averages", isLast: false)
                componentRow(name: "Momentum", range: "0 – 25", description: "Recent short-term and medium-term price movement", isLast: false)
                componentRow(name: "Positioning", range: "0 – 25", description: "Where price sits within the broader cycle range", isLast: false)
                componentRow(name: "Volatility", range: "0 – 20", description: "Stability of recent price action", isLast: true)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 14))

            Text("The score reflects conditions — not outcomes.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .italic()
        }
    }

    // MARK: - How to Read

    private var howToReadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("How to Read It")

            VStack(spacing: 0) {
                readRow(range: "75 – 100", label: "Strong", isLast: false)
                readRow(range: "55 – 74", label: "Moderate", isLast: false)
                readRow(range: "35 – 54", label: "Weak", isLast: false)
                readRow(range: "0 – 34", label: "High Risk", isLast: true)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 14))

            Text("This is for long-term positioning, not short-term trading.")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Data Sources

    private var dataSourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Data Sources")

            Text("Price and market data from CoinGecko. All indicators — including trend, momentum, positioning, and volatility — are calculated locally from historical price data.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Disclaimer

    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .padding(.bottom, 20)

            Text("BitShrug provides general market context for informational purposes only. It does not provide financial advice or predict future price movements.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.tertiary)
            .tracking(1)
    }

    private func componentRow(name: String, range: String, description: String, isLast: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Spacer()
                Text(range)
                    .font(.system(.caption, design: .monospaced, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)

            if !isLast {
                Divider()
                    .padding(.top, 8)
                    .padding(.bottom, 4)
            }
        }
        .padding(.vertical, 4)
    }

    private func readRow(range: String, label: String, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(range)
                    .font(.system(.footnote, design: .monospaced, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 72, alignment: .leading)

                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)

                Spacer()
            }
            .padding(.vertical, 8)

            if !isLast {
                Divider()
            }
        }
    }
}
