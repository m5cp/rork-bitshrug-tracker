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
    var isRenderMode: Bool = false

    private var scale: CGFloat { isRenderMode ? 3.0 : 1.0 }

    var body: some View {
        ZStack {
            backgroundLayer
            decorativeOrbs
            noiseOverlay

            VStack(spacing: 0) {
                Spacer(minLength: isRenderMode ? 80 : 24)

                Text(topText.uppercased())
                    .font(.system(size: (isRenderMode ? 48 : 32) , weight: .black))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.8), radius: isRenderMode ? 8 : 4, y: 2)
                    .padding(.horizontal, isRenderMode ? 48 : 20)
                    .minimumScaleFactor(0.6)

                Spacer()

                if showLiveData {
                    liveDataStrip
                        .padding(.bottom, isRenderMode ? 24 : 10)
                }

                Text(bottomText.uppercased())
                    .font(.system(size: (isRenderMode ? 48 : 32), weight: .black))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.8), radius: isRenderMode ? 8 : 4, y: 2)
                    .padding(.horizontal, isRenderMode ? 48 : 20)
                    .minimumScaleFactor(0.6)

                Spacer(minLength: isRenderMode ? 56 : 16)

                brandWatermark
                    .padding(.bottom, isRenderMode ? 32 : 12)
            }

            accentLine
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(.rect(cornerRadius: isRenderMode ? 0 : 24))
    }

    private var backgroundLayer: some View {
        ZStack {
            switch template.background {
            case .gradient(let colors):
                if colors.count >= 3 {
                    LinearGradient(
                        stops: [
                            .init(color: colors[0].color, location: 0),
                            .init(color: colors[1].color, location: 0.5),
                            .init(color: colors[2].color, location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    LinearGradient(
                        colors: colors.map(\.color),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            case .mesh(let a, let b, let c, let d):
                LinearGradient(
                    colors: [a.color, b.color, c.color, d.color],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    private var decorativeOrbs: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            Circle()
                .fill(
                    RadialGradient(
                        colors: [template.background.primaryColor.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: w * 0.4
                    )
                )
                .frame(width: w * 0.7, height: w * 0.7)
                .position(x: w * 0.15, y: h * 0.2)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.orange.opacity(0.08), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: w * 0.3
                    )
                )
                .frame(width: w * 0.5, height: w * 0.5)
                .position(x: w * 0.85, y: h * 0.75)
        }
        .allowsHitTesting(false)
    }

    private var noiseOverlay: some View {
        Canvas { context, size in
            for _ in 0..<300 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let opacity = Double.random(in: 0.015...0.05)
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: 1.5, height: 1.5)),
                    with: .color(.white.opacity(opacity))
                )
            }
        }
        .allowsHitTesting(false)
    }

    private var accentLine: some View {
        VStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .orange.opacity(0.6), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: isRenderMode ? 3 : 1.5)
            Spacer()
        }
        .allowsHitTesting(false)
    }

    private var liveDataStrip: some View {
        HStack(spacing: isRenderMode ? 20 : 12) {
            HStack(spacing: isRenderMode ? 6 : 4) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: isRenderMode ? 20 : 16, weight: .bold))
                    .foregroundStyle(.orange)
                Text(price)
                    .font(.system(size: isRenderMode ? 22 : 16, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.white)
            }

            Rectangle()
                .fill(.white.opacity(0.2))
                .frame(width: 1, height: isRenderMode ? 22 : 18)

            Text(change)
                .font(.system(size: isRenderMode ? 18 : 14, weight: .bold, design: .monospaced))
                .foregroundStyle(isPositive ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color(red: 0.95, green: 0.3, blue: 0.3))

            Rectangle()
                .fill(.white.opacity(0.2))
                .frame(width: 1, height: isRenderMode ? 22 : 18)

            HStack(spacing: isRenderMode ? 5 : 3) {
                Text("Score")
                    .font(.system(size: isRenderMode ? 14 : 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
                Text("\(score)")
                    .font(.system(size: isRenderMode ? 22 : 16, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, isRenderMode ? 24 : 14)
        .padding(.vertical, isRenderMode ? 14 : 10)
        .background(
            RoundedRectangle(cornerRadius: 100)
                .fill(.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var brandWatermark: some View {
        HStack(spacing: isRenderMode ? 8 : 5) {
            Circle()
                .fill(.orange.opacity(0.6))
                .frame(width: isRenderMode ? 8 : 5, height: isRenderMode ? 8 : 5)
            Text("TouchGrass BTC")
                .font(.system(size: isRenderMode ? 14 : 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
            Text("·")
                .foregroundStyle(.white.opacity(0.2))
            Text("¯\\_(ツ)_/¯")
                .font(.system(size: isRenderMode ? 12 : 9, weight: .bold, design: .monospaced))
                .foregroundStyle(.orange.opacity(0.35))
        }
    }
}
