import SwiftUI

enum AppColors {
    static let bullish = Color(red: 0.2, green: 0.85, blue: 0.5)
    static let bearish = Color(red: 0.95, green: 0.3, blue: 0.3)
    static let cautionOrange = Color(red: 0.95, green: 0.6, blue: 0.2)
    static let accent = Color.orange

    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let subtleBorder = Color(.separator)
    static let subtleBackground = Color(.tertiarySystemGroupedBackground)

    static func scoreColor(for score: Int) -> Color {
        if score >= 75 { return bullish }
        if score >= 55 { return .orange }
        if score >= 35 { return cautionOrange }
        return bearish
    }

    static func changeColor(positive: Bool) -> Color {
        positive ? bullish : bearish
    }
}
