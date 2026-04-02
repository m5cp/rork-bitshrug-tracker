import SwiftUI

struct ShareCardView: View {
    let score: Int
    let label: String
    let price: String
    let change: String
    let isPositive: Bool

    private var scoreColor: Color {
        if score >= 75 { return Color(red: 0.2, green: 0.85, blue: 0.5) }
        if score >= 55 { return .orange }
        if score >= 35 { return Color(red: 0.95, green: 0.6, blue: 0.2) }
        return Color(red: 0.95, green: 0.3, blue: 0.3)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                HStack {
                    Text("BitShrug")
                        .font(.system(.subheadline, design: .monospaced, weight: .bold))
                        .foregroundStyle(.white)
                    Text("¯\\_(ツ)_/¯")
                        .font(.system(.caption, design: .monospaced, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.8, blue: 0.3), .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Spacer()
                }

                HStack(alignment: .bottom, spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(scoreColor.opacity(0.2), lineWidth: 6)
                        Circle()
                            .trim(from: 0, to: Double(score) / 100.0)
                            .stroke(scoreColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .shadow(color: scoreColor.opacity(0.4), radius: 6)

                        VStack(spacing: 0) {
                            Text("\(score)")
                                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                                .foregroundStyle(.white)
                            Text(label.uppercased())
                                .font(.system(size: 8, weight: .heavy))
                                .foregroundStyle(scoreColor)
                                .tracking(0.5)
                        }
                    }
                    .frame(width: 80, height: 80)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("ENVIRONMENT SCORE")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.white.opacity(0.4))
                            .tracking(1)

                        Text(price)
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundStyle(.white)

                        Text(change)
                            .font(.system(.caption, design: .monospaced, weight: .bold))
                            .foregroundStyle(isPositive ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3))
                    }

                    Spacer()
                }
            }
            .padding(24)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.08, green: 0.08, blue: 0.12), Color(red: 0.04, green: 0.04, blue: 0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            HStack {
                Text("bitshrug.app")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
                Spacer()
                Text(Date().formatted(.dateTime.month(.abbreviated).day().year()))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color(red: 0.03, green: 0.03, blue: 0.06))
        }
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct ShareCardRenderer {
    @MainActor
    static func render(score: Int, label: String, price: String, change: String, isPositive: Bool) -> UIImage? {
        let view = ShareCardView(
            score: score,
            label: label,
            price: price,
            change: change,
            isPositive: isPositive
        )
        .frame(width: 360)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}
