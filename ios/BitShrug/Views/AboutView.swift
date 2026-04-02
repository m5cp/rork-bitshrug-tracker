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
        VStack(spacing: 8) {
            Text("BitShrug")
                .font(.system(.title2, design: .monospaced, weight: .bold))
                .foregroundStyle(.primary)

            Text("\u{00AF}\\_(ツ)_/\u{00AF}")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    private var purposeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "binoculars.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.orange)
                    .frame(width: 32, height: 32)
                    .background(.orange.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))

                Text("What is BitShrug?")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text("Understand the Bitcoin macro environment — without the noise. Focus on where we are in the cycle, how conditions are shifting, and whether the environment supports long-term positioning.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var scoreCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.orange)
                    .frame(width: 32, height: 32)
                    .background(.orange.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))

                Text("Environment Score")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text("A single 0\u{2013}100 score reflecting current conditions across four components:")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                componentChip(name: "Trend", range: "0\u{2013}30", icon: "chart.xyaxis.line")
                componentChip(name: "Momentum", range: "0\u{2013}25", icon: "bolt.fill")
                componentChip(name: "Positioning", range: "0\u{2013}25", icon: "scope")
                componentChip(name: "Volatility", range: "0\u{2013}20", icon: "waveform.path.ecg")
            }

            Text("Reflects conditions — not outcomes.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .italic()
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func componentChip(name: String, range: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 22)

            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)

            Spacer()

            Text(range)
                .font(.system(.caption, design: .monospaced, weight: .medium))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.03))
        .clipShape(.rect(cornerRadius: 8))
    }

    private var rangesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.orange)
                    .frame(width: 32, height: 32)
                    .background(.orange.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))

                Text("How to Read It")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            VStack(spacing: 6) {
                rangeRow(range: "75\u{2013}100", label: "Strong", color: Color(red: 0.2, green: 0.85, blue: 0.5))
                rangeRow(range: "55\u{2013}74", label: "Moderate", color: .blue)
                rangeRow(range: "35\u{2013}54", label: "Weak", color: .orange)
                rangeRow(range: "0\u{2013}34", label: "High Risk", color: Color(red: 0.95, green: 0.3, blue: 0.3))
            }

            Text("For long-term positioning, not short-term trading.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .italic()
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func rangeRow(range: String, label: String, color: Color) -> some View {
        HStack {
            Text(range)
                .font(.system(.caption, design: .monospaced, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)

            RoundedRectangle(cornerRadius: 3)
                .fill(color.opacity(0.6))
                .frame(width: 4, height: 18)

            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
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
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.06))
                    .clipShape(.rect(cornerRadius: 8))

                Text("Data Sources")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 8) {
                sourceRow(name: "CoinGecko", detail: "Price, market cap, volume, history")
                sourceRow(name: "Alternative.me", detail: "Fear & Greed Index")
                sourceRow(name: "Local Models", detail: "All indicators calculated from price data")
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func sourceRow(name: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(.orange.opacity(0.5))
                .frame(width: 5, height: 5)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var disclaimerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)
                Text("Disclaimer")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.tertiary)
            }

            Text("BitShrug provides general market context for informational purposes only. It does not provide financial advice or predict future price movements. Past performance does not guarantee future results.")
                .font(.caption)
                .foregroundStyle(.quaternary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .clipShape(.rect(cornerRadius: 14))
    }
}
