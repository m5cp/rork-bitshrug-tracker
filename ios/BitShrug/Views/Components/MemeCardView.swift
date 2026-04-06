import SwiftUI

struct MemeCardView: View {
    let template: MemeTemplate
    let topText: String
    let bottomText: String
    let showLiveData: Bool
    let price: String
    let score: Int
    let scoreLabel: String
    let change: String
    let isPositive: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: template.background.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            noiseOverlay

            VStack(spacing: 0) {
                Spacer(minLength: 24)

                Text(topText)
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.6), radius: 4, y: 2)
                    .padding(.horizontal, 24)

                Spacer()

                if showLiveData {
                    liveDataStrip
                        .padding(.bottom, 16)
                }

                Text(bottomText)
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.6), radius: 4, y: 2)
                    .padding(.horizontal, 24)

                Spacer(minLength: 16)

                brandWatermark
                    .padding(.bottom, 20)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var noiseOverlay: some View {
        Canvas { context, size in
            for _ in 0..<200 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let opacity = Double.random(in: 0.02...0.06)
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)),
                    with: .color(.white.opacity(opacity))
                )
            }
        }
        .allowsHitTesting(false)
    }

    private var liveDataStrip: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.orange)
                Text(price)
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.white)
            }

            HStack(spacing: 4) {
                Text(change)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(isPositive ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3))
            }

            HStack(spacing: 4) {
                Text("Score")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                Text("\(score)")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial.opacity(0.3))
        .background(Color.black.opacity(0.4))
        .clipShape(Capsule())
    }

    private var brandWatermark: some View {
        HStack(spacing: 6) {
            Text("Fog of Bitcoin")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))
            Text("¯\\_(ツ)_/¯")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.orange.opacity(0.5))
        }
    }
}
