import SwiftUI

struct MacroIntelligenceView: View {
    let macroData: MacroIntelligenceData

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "building.columns", title: "MACRO INTELLIGENCE") {
                backdropBadge
            }

            if macroData.hasError || macroData.indicators.allSatisfy({ !$0.isAvailable }) {
                unavailableState
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(macroData.indicators) { indicator in
                        macroCell(indicator)
                    }
                }

                if let fetched = macroData.lastFetched {
                    Text("FRED data updated \(fetched.formatted(.relative(presentation: .named)))")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.quaternary)
                        .padding(.top, 2)
                }
            }
        }
        .premiumCard()
    }

    private var backdropBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: macroData.backdrop.icon)
                .font(.system(size: 9, weight: .bold))
            Text(macroData.backdrop.rawValue)
                .font(.system(size: 9, weight: .heavy))
        }
        .foregroundStyle(macroData.backdrop.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(macroData.backdrop.color.opacity(0.12))
        .clipShape(Capsule())
    }

    private var unavailableState: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.icloud")
                .font(.system(size: 18))
                .foregroundStyle(.tertiary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Macro data unavailable")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Text("FRED data could not be loaded. Pull to refresh.")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func macroCell(_ indicator: MacroIndicator) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(indicator.title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            if indicator.isAvailable {
                Text(indicator.formattedValue)
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 3) {
                    Image(systemName: indicator.direction.icon)
                        .font(.system(size: 8, weight: .bold))
                    Text(indicator.direction.rawValue.capitalized)
                        .font(.system(size: 8, weight: .heavy))
                }
                .foregroundStyle(indicator.direction.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(indicator.direction.color.opacity(0.12))
                .clipShape(Capsule())
            } else {
                Text("Unavailable")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(.tertiary)

                Text("—")
                    .font(.system(size: 8, weight: .heavy))
                    .foregroundStyle(.quaternary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.primary.opacity(0.04))
        .clipShape(.rect(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(indicator.title): \(indicator.formattedValue), \(indicator.direction.rawValue)")
    }
}
