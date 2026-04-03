import SwiftUI

struct CycleStatusView: View {
    let currentPrice: Double
    let daysSinceHalving: Int

    private var cycleHigh: Double {
        CycleHistoryData.currentEpoch?.cycleHighPrice ?? 126279
    }

    private var peakDate: Date {
        CycleHistoryData.currentEpoch?.cycleHighDate ?? Date()
    }

    private var checks: [CycleHistoryData.RhymeCheck] {
        CycleHistoryData.rhymeChecks(
            currentPrice: currentPrice,
            daysSinceHalving: daysSinceHalving,
            cycleHigh: cycleHigh,
            cycleHighDate: peakDate
        )
    }

    private var score: (matching: Int, total: Int) {
        CycleHistoryData.rhymeScore(checks: checks)
    }

    private var isOnTrack: Bool { score.matching >= 3 }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            cycleStatusCard
            rhymeSection
        }
    }

    private var cycleStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("4-YEAR CYCLE STATUS")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.secondary)
                    .tracking(1.5)

                Spacer()

                Text(isOnTrack ? "ON TRACK" : "DIVERGING")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(isOnTrack ? Color(red: 0.2, green: 0.85, blue: 0.5) : .orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        (isOnTrack ? Color(red: 0.2, green: 0.85, blue: 0.5) : .orange).opacity(0.12)
                    )
                    .clipShape(Capsule())
            }

            HStack(spacing: 6) {
                ForEach(0..<score.total, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(i < score.matching
                            ? Color(red: 0.2, green: 0.85, blue: 0.5)
                            : Color.primary.opacity(0.1)
                        )
                        .frame(height: 6)
                }
            }

            Text("\(score.matching)/\(score.total) historical patterns matching · Cycle theory remains \(isOnTrack ? "valid" : "uncertain")")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    (isOnTrack ? Color(red: 0.2, green: 0.85, blue: 0.5) : .orange).opacity(0.08),
                    (isOnTrack ? Color(red: 0.2, green: 0.85, blue: 0.5) : .orange).opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    (isOnTrack ? Color(red: 0.2, green: 0.85, blue: 0.5) : .orange).opacity(0.15),
                    lineWidth: 1
                )
        )
        .clipShape(.rect(cornerRadius: 16))
    }

    private var rhymeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "waveform.path", iconColor: .purple, title: "DOES THIS CYCLE RHYME?")

            VStack(spacing: 10) {
                ForEach(checks) { check in
                    rhymeCheckRow(check)
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Text("Pattern matching is observational, not predictive. Sample size: 4 cycles.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .premiumCard(.highlighted)
    }

    private func rhymeCheckRow(_ check: CycleHistoryData.RhymeCheck) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(check.matches
                        ? Color(red: 0.2, green: 0.85, blue: 0.5)
                        : Color(red: 0.95, green: 0.3, blue: 0.3).opacity(0.6)
                    )
                    .frame(width: 8, height: 8)

                Text(check.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text(check.matches ? "MATCHES" : "PENDING")
                    .font(.system(size: 8, weight: .heavy))
                    .foregroundStyle(check.matches
                        ? Color(red: 0.2, green: 0.85, blue: 0.5)
                        : .secondary
                    )
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        (check.matches
                            ? Color(red: 0.2, green: 0.85, blue: 0.5)
                            : Color.white
                        ).opacity(0.1)
                    )
                    .clipShape(Capsule())

                Spacer()
            }

            Text(check.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 16)
        }
        .padding(12)
        .background(
            check.matches
                ? Color(red: 0.2, green: 0.85, blue: 0.5).opacity(0.04)
                : Color.primary.opacity(0.02)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    (check.matches
                        ? Color(red: 0.2, green: 0.85, blue: 0.5)
                        : Color.white
                    ).opacity(0.06),
                    lineWidth: 1
                )
        )
        .clipShape(.rect(cornerRadius: 12))
    }
}
