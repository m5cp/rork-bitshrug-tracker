import SwiftUI

struct ShrugBadge: View {
    var size: ShrugSize = .regular
    var style: ShrugStyle = .glowing

    var body: some View {
        switch style {
        case .glowing:
            glowingShrug
        case .inline:
            inlineShrug
        case .hero:
            heroShrug
        }
    }

    private var glowingShrug: some View {
        Text("¯\\_(ツ)_/¯")
            .font(.system(size: size.fontSize, weight: .bold, design: .monospaced))
            .foregroundStyle(
                LinearGradient(
                    colors: [.orange, Color(red: 1.0, green: 0.7, blue: 0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: .orange.opacity(0.5), radius: size.glowRadius)
            .shadow(color: .orange.opacity(0.2), radius: size.glowRadius * 2)
    }

    private var inlineShrug: some View {
        Text("¯\\_(ツ)_/¯")
            .font(.system(size: size.fontSize, weight: .heavy, design: .monospaced))
            .foregroundStyle(
                LinearGradient(
                    colors: [.orange, Color(red: 1.0, green: 0.6, blue: 0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var heroShrug: some View {
        Text("¯\\_(ツ)_/¯")
            .font(.system(size: size.fontSize, weight: .black, design: .monospaced))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.8, blue: 0.3),
                        .orange,
                        Color(red: 1.0, green: 0.5, blue: 0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: .orange.opacity(0.6), radius: size.glowRadius)
            .shadow(color: .orange.opacity(0.3), radius: size.glowRadius * 2.5)
    }

    nonisolated enum ShrugSize: Sendable {
        case small
        case regular
        case large
        case hero

        var fontSize: CGFloat {
            switch self {
            case .small: return 12
            case .regular: return 16
            case .large: return 22
            case .hero: return 28
            }
        }

        var glowRadius: CGFloat {
            switch self {
            case .small: return 3
            case .regular: return 5
            case .large: return 8
            case .hero: return 12
            }
        }
    }

    nonisolated enum ShrugStyle: Sendable {
        case glowing
        case inline
        case hero
    }
}
