import SwiftUI

struct PremiumCard: ViewModifier {
    var style: CardVariant = .standard

    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(cardBackground)
            .clipShape(.rect(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(borderGradient, lineWidth: 1)
            )
    }

    private var cardBackground: some ShapeStyle {
        switch style {
        case .standard:
            return AnyShapeStyle(Color.primary.opacity(0.05))
        case .highlighted:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.primary.opacity(0.07), Color.primary.opacity(0.03)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .accent:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.orange.opacity(0.08), Color.orange.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    private var borderGradient: some ShapeStyle {
        switch style {
        case .standard:
            return AnyShapeStyle(Color.primary.opacity(0.06))
        case .highlighted:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.primary.opacity(0.1), Color.primary.opacity(0.03)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .accent:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    nonisolated enum CardVariant: Sendable {
        case standard
        case highlighted
        case accent
    }
}

extension View {
    func premiumCard(_ style: PremiumCard.CardVariant = .standard) -> some View {
        modifier(PremiumCard(style: style))
    }
}

struct SectionHeader: View {
    let icon: String
    let iconColor: Color
    let title: String
    var trailing: AnyView?

    init(icon: String, iconColor: Color = .orange, title: String) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.trailing = nil
    }

    init(icon: String, iconColor: Color = .orange, title: String, @ViewBuilder trailing: () -> some View) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.trailing = AnyView(trailing())
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(iconColor)

            Text(title)
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(.primary)
                .tracking(1.5)

            Spacer()

            if let trailing {
                trailing
            }
        }
    }
}
