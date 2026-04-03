import SwiftUI

struct IndicatorCardView: View {
    let icon: String
    let title: String
    let value: String
    let status: String
    let statusColor: Color
    let detail: String

    @State private var isExpanded: Bool = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .bold))
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

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)

                        Text(value)
                            .font(.system(.subheadline, design: .monospaced, weight: .bold))
                            .foregroundStyle(.primary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(status)
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(statusColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor.opacity(0.12))
                            .clipShape(Capsule())

                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.tertiary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }

                if isExpanded {
                    Divider()
                        .overlay(Color.primary.opacity(0.06))
                        .padding(.vertical, 12)

                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.primary.opacity(0.06), Color.primary.opacity(0.03)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(.rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.primary.opacity(0.07), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isExpanded)
    }
}

struct WideIndicatorCard: View {
    let icon: String
    let title: String
    let value: String
    let status: String
    let statusColor: Color
    let detail: String

    @State private var isExpanded: Bool = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
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

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(isExpanded ? nil : 1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(value)
                            .font(.system(.subheadline, design: .monospaced, weight: .bold))
                            .foregroundStyle(.primary)

                        Text(status)
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(statusColor)
                    }
                }

                if isExpanded {
                    Divider()
                        .padding(.vertical, 10)

                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.primary.opacity(0.06), Color.primary.opacity(0.03)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(.rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.primary.opacity(0.07), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isExpanded)
    }
}
