import SwiftUI

struct MemeTemplate: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let topText: String
    let bottomText: String
    let background: MemeBackground
    let icon: String
    let emoji: String
    let category: MemeCategory

    nonisolated enum MemeCategory: String, CaseIterable, Sendable {
        case hodl = "HODL"
        case culture = "Culture"
        case market = "Market"
        case fiat = "Fiat"
    }

    nonisolated enum MemeBackground: Hashable, Sendable {
        case gradient([MemeColor])
        case mesh(MemeColor, MemeColor, MemeColor, MemeColor)

        var colors: [Color] {
            switch self {
            case .gradient(let mc): return mc.map(\.color)
            case .mesh(let a, let b, let c, let d): return [a.color, b.color, c.color, d.color]
            }
        }

        var primaryColor: Color {
            colors.first ?? .black
        }
    }

    nonisolated struct MemeColor: Hashable, Sendable {
        let r: Double, g: Double, b: Double
        var color: Color { Color(red: r, green: g, blue: b) }
    }

    static let templates: [MemeTemplate] = [
        MemeTemplate(
            id: "diamond_hands",
            name: "Diamond Hands",
            topText: "THEY PANIC SOLD\nAT THE DIP",
            bottomText: "I BOUGHT MORE",
            background: .gradient([
                MemeColor(r: 0.0, g: 0.0, b: 0.0),
                MemeColor(r: 0.05, g: 0.02, b: 0.15),
                MemeColor(r: 0.0, g: 0.0, b: 0.0)
            ]),
            icon: "diamond.fill",
            emoji: "💎",
            category: .hodl
        ),
        MemeTemplate(
            id: "laser_eyes",
            name: "Laser Eyes",
            topText: "BITCOIN OBITUARY\n#478",
            bottomText: "NEW ALL-TIME HIGH\nINCOMING",
            background: .gradient([
                MemeColor(r: 0.0, g: 0.0, b: 0.0),
                MemeColor(r: 0.4, g: 0.05, b: 0.0),
                MemeColor(r: 0.0, g: 0.0, b: 0.0)
            ]),
            icon: "eyes",
            emoji: "🔥",
            category: .culture
        ),
        MemeTemplate(
            id: "zoom_out",
            name: "Zoom Out",
            topText: "\"BITCOIN IS CRASHING\"",
            bottomText: "SIR, ZOOM OUT\nTO THE YEARLY CHART",
            background: .gradient([
                MemeColor(r: 0.0, g: 0.04, b: 0.12),
                MemeColor(r: 0.0, g: 0.08, b: 0.2),
                MemeColor(r: 0.0, g: 0.02, b: 0.08)
            ]),
            icon: "magnifyingglass",
            emoji: "🔭",
            category: .market
        ),
        MemeTemplate(
            id: "stacking",
            name: "Stack Sats",
            topText: "EVERY PAYCHECK.\nEVERY DIP.\nEVERY DAY.",
            bottomText: "STACK SATS\nSTAY HUMBLE",
            background: .gradient([
                MemeColor(r: 0.12, g: 0.06, b: 0.0),
                MemeColor(r: 0.2, g: 0.1, b: 0.0),
                MemeColor(r: 0.08, g: 0.04, b: 0.0)
            ]),
            icon: "bitcoinsign.circle.fill",
            emoji: "⚡",
            category: .hodl
        ),
        MemeTemplate(
            id: "nocoiners",
            name: "Nocoiners",
            topText: "MY FRIEND:\n\"I'LL BUY WHEN IT DIPS\"",
            bottomText: "BITCOIN:\nDIPS FROM $100K TO $95K\nFRIEND: \"TOO RISKY\"",
            background: .gradient([
                MemeColor(r: 0.06, g: 0.06, b: 0.1),
                MemeColor(r: 0.1, g: 0.04, b: 0.12),
                MemeColor(r: 0.04, g: 0.04, b: 0.06)
            ]),
            icon: "person.slash.fill",
            emoji: "🤡",
            category: .culture
        ),
        MemeTemplate(
            id: "halving",
            name: "The Halving",
            topText: "SUPPLY CUT IN HALF",
            bottomText: "DEMAND STAYS THE SAME\nDO THE MATH",
            background: .gradient([
                MemeColor(r: 0.0, g: 0.08, b: 0.04),
                MemeColor(r: 0.0, g: 0.15, b: 0.08),
                MemeColor(r: 0.0, g: 0.05, b: 0.02)
            ]),
            icon: "scissors",
            emoji: "✂️",
            category: .market
        ),
        MemeTemplate(
            id: "fiat",
            name: "Fiat is Fine",
            topText: "INFLATION: 7%\nSAVINGS RATE: 0.5%",
            bottomText: "\"BITCOIN IS\nTHE RISKY ONE\"",
            background: .gradient([
                MemeColor(r: 0.12, g: 0.02, b: 0.02),
                MemeColor(r: 0.2, g: 0.04, b: 0.04),
                MemeColor(r: 0.08, g: 0.0, b: 0.0)
            ]),
            icon: "dollarsign.circle",
            emoji: "🏦",
            category: .fiat
        ),
        MemeTemplate(
            id: "shrug",
            name: "The Shrug",
            topText: "HAVE FUN\nSTAYING POOR",
            bottomText: "¯\\_(ツ)_/¯",
            background: .gradient([
                MemeColor(r: 0.0, g: 0.0, b: 0.0),
                MemeColor(r: 0.08, g: 0.06, b: 0.0),
                MemeColor(r: 0.0, g: 0.0, b: 0.0)
            ]),
            icon: "face.smiling",
            emoji: "¯\\_(ツ)_/¯",
            category: .culture
        ),
        MemeTemplate(
            id: "whale",
            name: "Whale Alert",
            topText: "JUST BOUGHT ANOTHER\n0.001 BTC",
            bottomText: "EVERY SAT COUNTS\n🐋",
            background: .gradient([
                MemeColor(r: 0.0, g: 0.02, b: 0.1),
                MemeColor(r: 0.0, g: 0.06, b: 0.2),
                MemeColor(r: 0.0, g: 0.01, b: 0.06)
            ]),
            icon: "water.waves",
            emoji: "🐋",
            category: .hodl
        ),
        MemeTemplate(
            id: "power_law",
            name: "Power Law",
            topText: "\"WHERE WILL BTC BE\nIN 10 YEARS?\"",
            bottomText: "THE MATH HAS\nALREADY ANSWERED",
            background: .gradient([
                MemeColor(r: 0.04, g: 0.0, b: 0.08),
                MemeColor(r: 0.1, g: 0.02, b: 0.16),
                MemeColor(r: 0.02, g: 0.0, b: 0.04)
            ]),
            icon: "function",
            emoji: "📐",
            category: .market
        ),
        MemeTemplate(
            id: "printer",
            name: "Money Printer",
            topText: "FED: MONEY PRINTER\nGOES BRRR",
            bottomText: "BITCOIN:\nFIXED SUPPLY GOES 📈",
            background: .gradient([
                MemeColor(r: 0.0, g: 0.06, b: 0.0),
                MemeColor(r: 0.02, g: 0.12, b: 0.02),
                MemeColor(r: 0.0, g: 0.04, b: 0.0)
            ]),
            icon: "printer.fill",
            emoji: "🖨️",
            category: .fiat
        ),
        MemeTemplate(
            id: "cycle_top",
            name: "Cycle Veteran",
            topText: "SURVIVED:\n2014, 2018, 2022",
            bottomText: "THIS DIP?\nTHAT'S CALLED TUESDAY",
            background: .gradient([
                MemeColor(r: 0.08, g: 0.08, b: 0.0),
                MemeColor(r: 0.15, g: 0.12, b: 0.0),
                MemeColor(r: 0.05, g: 0.05, b: 0.0)
            ]),
            icon: "medal.fill",
            emoji: "🎖️",
            category: .hodl
        ),
    ]
}
