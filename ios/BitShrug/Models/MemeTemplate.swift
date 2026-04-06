import SwiftUI

struct MemeTemplate: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let topText: String
    let bottomText: String
    let background: MemeBackground
    let icon: String

    nonisolated enum MemeBackground: Hashable, Sendable {
        case gradient([MemeColor])
        case solid(MemeColor)

        var colors: [Color] {
            switch self {
            case .gradient(let mc): return mc.map(\.color)
            case .solid(let mc): return [mc.color, mc.color]
            }
        }
    }

    nonisolated struct MemeColor: Hashable, Sendable {
        let r: Double, g: Double, b: Double
        var color: Color { Color(red: r, green: g, blue: b) }
    }

    static let templates: [MemeTemplate] = [
        MemeTemplate(
            id: "hodl",
            name: "HODL",
            topText: "WHEN BITCOIN DIPS 5%",
            bottomText: "AND YOU ALREADY KNEW\n¯\\_(ツ)_/¯",
            background: .gradient([MemeColor(r: 0.1, g: 0.1, b: 0.15), MemeColor(r: 0.2, g: 0.1, b: 0.0)]),
            icon: "hand.raised.fill"
        ),
        MemeTemplate(
            id: "laser_eyes",
            name: "Laser Eyes",
            topText: "THEY SAID BITCOIN IS DEAD",
            bottomText: "FOR THE 477TH TIME",
            background: .gradient([MemeColor(r: 0.0, g: 0.0, b: 0.0), MemeColor(r: 0.3, g: 0.05, b: 0.0)]),
            icon: "eyes"
        ),
        MemeTemplate(
            id: "zoom_out",
            name: "Zoom Out",
            topText: "YOU THINK THIS IS A CRASH?",
            bottomText: "ZOOM OUT\n¯\\_(ツ)_/¯",
            background: .gradient([MemeColor(r: 0.05, g: 0.1, b: 0.2), MemeColor(r: 0.0, g: 0.0, b: 0.1)]),
            icon: "magnifyingglass"
        ),
        MemeTemplate(
            id: "stacking",
            name: "Stack Sats",
            topText: "KEEP CALM",
            bottomText: "AND STACK SATS",
            background: .gradient([MemeColor(r: 0.15, g: 0.08, b: 0.0), MemeColor(r: 0.1, g: 0.05, b: 0.0)]),
            icon: "bitcoinsign.circle.fill"
        ),
        MemeTemplate(
            id: "nocoiners",
            name: "Nocoiners",
            topText: "MY FRIENDS STILL DON'T\nOWN BITCOIN",
            bottomText: "I'VE BEEN TELLING THEM\nSINCE $3,000",
            background: .gradient([MemeColor(r: 0.08, g: 0.08, b: 0.12), MemeColor(r: 0.15, g: 0.05, b: 0.1)]),
            icon: "person.2.slash"
        ),
        MemeTemplate(
            id: "cycle",
            name: "4-Year Cycle",
            topText: "THEY DON'T KNOW",
            bottomText: "THE HALVING IS PRICED IN\n¯\\_(ツ)_/¯",
            background: .gradient([MemeColor(r: 0.0, g: 0.1, b: 0.05), MemeColor(r: 0.05, g: 0.15, b: 0.1)]),
            icon: "arrow.triangle.2.circlepath"
        ),
        MemeTemplate(
            id: "fiat",
            name: "Fiat",
            topText: "YOUR SAVINGS ACCOUNT\nYIELDS 0.5%",
            bottomText: "BITCOIN DOESN'T CARE\n¯\\_(ツ)_/¯",
            background: .gradient([MemeColor(r: 0.1, g: 0.0, b: 0.0), MemeColor(r: 0.2, g: 0.05, b: 0.05)]),
            icon: "dollarsign.circle"
        ),
        MemeTemplate(
            id: "dip",
            name: "Buy The Dip",
            topText: "EVERYONE: PANIC SELL",
            bottomText: "ME: ADDING MORE\n¯\\_(ツ)_/¯",
            background: .gradient([MemeColor(r: 0.0, g: 0.0, b: 0.0), MemeColor(r: 0.1, g: 0.1, b: 0.0)]),
            icon: "cart.fill"
        ),
    ]
}
