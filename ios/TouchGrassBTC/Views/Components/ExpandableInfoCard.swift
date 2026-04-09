import SwiftUI

struct ExpandableInfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let summary: String
    let detail: String

    @State private var isExpanded: Bool = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(iconColor)
                        .frame(width: 34, height: 34)
                        .background(
                            LinearGradient(
                                colors: [iconColor.opacity(0.15), iconColor.opacity(0.06)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 9))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.heavy)
                            .foregroundStyle(.primary)

                        Text(summary)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(isExpanded ? nil : 2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }

                if isExpanded {
                    Divider()
                        .overlay(Color.primary.opacity(0.06))
                        .padding(.vertical, 12)

                    Text(detail)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 46)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isExpanded)
    }
}

struct KeyPointRow: View {
    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(iconColor)
                .frame(width: 26, height: 26)
                .background(
                    LinearGradient(
                        colors: [iconColor.opacity(0.12), iconColor.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(.rect(cornerRadius: 7))

            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct CompactFactCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(iconColor)
                    .frame(width: 30, height: 30)
                    .background(
                        LinearGradient(
                            colors: [iconColor.opacity(0.15), iconColor.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 8))

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
            }

            Text(content)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
