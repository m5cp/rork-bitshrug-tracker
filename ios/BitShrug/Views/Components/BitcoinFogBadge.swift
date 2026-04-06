import SwiftUI

struct BitcoinFogBadge: View {
    var size: BadgeSize = .regular
    var fogIntensity: Double = 1.0

    private let fogGreen = Color(red: 0.3, green: 0.75, blue: 0.45)

    var body: some View {
        ZStack {
            Circle()
                .fill(fogGreen.opacity(0.08 * fogIntensity))
                .frame(width: size.dimension * 2.2, height: size.dimension * 2.2)
                .blur(radius: size.dimension * 0.5)

            Circle()
                .fill(fogGreen.opacity(0.12 * fogIntensity))
                .frame(width: size.dimension * 1.6, height: size.dimension * 1.6)
                .blur(radius: size.dimension * 0.35)

            Circle()
                .fill(fogGreen.opacity(0.06 * fogIntensity))
                .frame(width: size.dimension * 1.8, height: size.dimension * 1.4)
                .offset(x: -size.dimension * 0.15, y: size.dimension * 0.1)
                .blur(radius: size.dimension * 0.4)

            Circle()
                .fill(fogGreen.opacity(0.05 * fogIntensity))
                .frame(width: size.dimension * 1.5, height: size.dimension * 1.3)
                .offset(x: size.dimension * 0.2, y: -size.dimension * 0.08)
                .blur(radius: size.dimension * 0.3)

            Image("bitcoinfog_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.dimension, height: size.dimension)
                .shadow(color: fogGreen.opacity(0.5), radius: size.glowRadius)
                .shadow(color: fogGreen.opacity(0.2), radius: size.glowRadius * 2.5)
        }
    }

    nonisolated enum BadgeSize: Sendable {
        case small
        case regular
        case large
        case hero

        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .regular: return 48
            case .large: return 80
            case .hero: return 180
            }
        }

        var glowRadius: CGFloat {
            switch self {
            case .small: return 4
            case .regular: return 8
            case .large: return 16
            case .hero: return 35
            }
        }
    }
}
