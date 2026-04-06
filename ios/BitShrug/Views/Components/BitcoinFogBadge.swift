import SwiftUI

struct BitcoinFogBadge: View {
    var size: BadgeSize = .regular

    var body: some View {
        Image("bitcoinfog_logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.dimension, height: size.dimension)
            .shadow(color: Color(red: 0.3, green: 0.8, blue: 0.4).opacity(0.4), radius: size.glowRadius)
            .shadow(color: Color(red: 0.3, green: 0.8, blue: 0.4).opacity(0.15), radius: size.glowRadius * 2.5)
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
            case .hero: return 160
            }
        }

        var glowRadius: CGFloat {
            switch self {
            case .small: return 4
            case .regular: return 8
            case .large: return 16
            case .hero: return 30
            }
        }
    }
}
