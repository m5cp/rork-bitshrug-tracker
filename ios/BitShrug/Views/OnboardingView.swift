import SwiftUI

struct OnboardingView: View {
    var onContinue: () -> Void

    @State private var phase: OnboardingPhase = .fogRising
    @State private var fogLayers: [FogLayer] = []
    @State private var badgeScale: Double = 0.15
    @State private var badgeOpacity: Double = 0
    @State private var badgeY: Double = 40
    @State private var textOpacity: Double = 0
    @State private var textY: Double = 30
    @State private var disclaimerOpacity: Double = 0
    @State private var fogDrift: Double = 0
    @State private var fogPulse: Double = 0
    @State private var screenFadeOut: Double = 0
    @State private var fogWhiteout: Double = 0

    private let fogGreen = Color(red: 0.3, green: 0.75, blue: 0.45)

    nonisolated enum OnboardingPhase: Sendable {
        case fogRising
        case badgeEmerging
        case revealed
        case fadingOut
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            denseRisingFog

            radialGlow

            VStack(spacing: 0) {
                Spacer()

                BitcoinFogBadge(size: .hero, fogIntensity: phase == .revealed ? 1.2 : 0.6)
                    .scaleEffect(badgeScale)
                    .opacity(badgeOpacity)
                    .offset(y: badgeY)

                Spacer()
                    .frame(height: 40)

                VStack(spacing: 14) {
                    Text("Fog of Bitcoin")
                        .font(.system(size: 42, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.75)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Text("Where signal meets uncertainty.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .opacity(textOpacity)
                .offset(y: textY)

                Spacer()

                Text("Not financial advice.\nEducational information only.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40)
                    .opacity(disclaimerOpacity)
            }

            driftingFogOverlay

            Color.black
                .opacity(screenFadeOut)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .task {
            generateFogLayers()
            await runSequence()
        }
    }

    private var radialGlow: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height * 0.36)
            let glowAmount = min(badgeOpacity, 1.0)

            let outerGlow = Path(ellipseIn: CGRect(
                x: center.x - size.width * 0.6,
                y: center.y - size.height * 0.2,
                width: size.width * 1.2,
                height: size.height * 0.4
            ))
            context.fill(outerGlow, with: .color(fogGreen.opacity(0.08 * glowAmount)))

            let innerGlow = Path(ellipseIn: CGRect(
                x: center.x - size.width * 0.35,
                y: center.y - size.height * 0.12,
                width: size.width * 0.7,
                height: size.height * 0.24
            ))
            context.fill(innerGlow, with: .color(fogGreen.opacity(0.14 * glowAmount)))
        }
        .blur(radius: 55)
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private var denseRisingFog: some View {
        Canvas { context, size in
            let rise = min(badgeOpacity + 0.3, 1.0)
            let pulse = fogPulse

            let baseY = size.height * (1.1 - rise * 0.85)

            let groundFog = Path(ellipseIn: CGRect(
                x: -size.width * 0.4,
                y: baseY + size.height * 0.05 + pulse * 6,
                width: size.width * 1.8,
                height: size.height * 0.35
            ))
            context.fill(groundFog, with: .color(fogGreen.opacity(0.18 * rise)))

            let midFog1 = Path(ellipseIn: CGRect(
                x: -size.width * 0.15,
                y: baseY - size.height * 0.08 - pulse * 10,
                width: size.width * 1.4,
                height: size.height * 0.28
            ))
            context.fill(midFog1, with: .color(fogGreen.opacity(0.14 * rise)))

            let midFog2 = Path(ellipseIn: CGRect(
                x: size.width * 0.15,
                y: baseY - size.height * 0.15 + pulse * 8,
                width: size.width * 1.1,
                height: size.height * 0.25
            ))
            context.fill(midFog2, with: .color(fogGreen.opacity(0.10 * rise)))

            let upperFog = Path(ellipseIn: CGRect(
                x: -size.width * 0.05,
                y: baseY - size.height * 0.28 - pulse * 6,
                width: size.width * 0.9,
                height: size.height * 0.18
            ))
            context.fill(upperFog, with: .color(fogGreen.opacity(0.07 * rise)))

            let wisp1 = Path(ellipseIn: CGRect(
                x: size.width * 0.3,
                y: baseY - size.height * 0.38 + pulse * 12,
                width: size.width * 0.55,
                height: size.height * 0.12
            ))
            context.fill(wisp1, with: .color(fogGreen.opacity(0.04 * rise)))

            let wisp2 = Path(ellipseIn: CGRect(
                x: -size.width * 0.1,
                y: baseY - size.height * 0.42 - pulse * 5,
                width: size.width * 0.6,
                height: size.height * 0.1
            ))
            context.fill(wisp2, with: .color(fogGreen.opacity(0.03 * rise)))

            let topHaze = Path(ellipseIn: CGRect(
                x: size.width * 0.1,
                y: baseY - size.height * 0.55 + pulse * 7,
                width: size.width * 0.7,
                height: size.height * 0.15
            ))
            context.fill(topHaze, with: .color(fogGreen.opacity(0.025 * rise)))
        }
        .blur(radius: 50)
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private var driftingFogOverlay: some View {
        Canvas { context, size in
            let drift = fogDrift
            let pulse = fogPulse

            let tendril1 = Path(ellipseIn: CGRect(
                x: -size.width * 0.3 + drift * size.width * 0.15,
                y: size.height * 0.25 + pulse * 20,
                width: size.width * 0.8,
                height: size.height * 0.08
            ))
            context.fill(tendril1, with: .color(fogGreen.opacity(0.06)))

            let tendril2 = Path(ellipseIn: CGRect(
                x: size.width * 0.4 - drift * size.width * 0.1,
                y: size.height * 0.55 - pulse * 15,
                width: size.width * 0.7,
                height: size.height * 0.06
            ))
            context.fill(tendril2, with: .color(fogGreen.opacity(0.04)))

            let tendril3 = Path(ellipseIn: CGRect(
                x: size.width * 0.1 + drift * size.width * 0.08,
                y: size.height * 0.4 + pulse * 12,
                width: size.width * 0.5,
                height: size.height * 0.05
            ))
            context.fill(tendril3, with: .color(fogGreen.opacity(0.035)))
        }
        .blur(radius: 40)
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func generateFogLayers() {
        fogLayers = (0..<8).map { i in
            FogLayer(
                xOffset: Double.random(in: -0.3...0.3),
                yOffset: Double.random(in: -0.2...0.2),
                width: Double.random(in: 0.5...1.4),
                height: Double.random(in: 0.1...0.3),
                opacity: Double.random(in: 0.03...0.12),
                blur: Double.random(in: 30...60)
            )
        }
    }

    private func runSequence() async {
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            fogPulse = 1
        }
        withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
            fogDrift = 1
        }

        try? await Task.sleep(for: .milliseconds(300))

        withAnimation(.spring(duration: 2.0, bounce: 0.15)) {
            badgeScale = 0.6
            badgeOpacity = 0.4
            badgeY = 20
        }

        try? await Task.sleep(for: .milliseconds(800))

        withAnimation(.spring(duration: 1.6, bounce: 0.2)) {
            badgeScale = 1.0
            badgeOpacity = 1.0
            badgeY = 0
            phase = .badgeEmerging
        }

        try? await Task.sleep(for: .milliseconds(600))

        withAnimation(.spring(duration: 1.0, bounce: 0.12)) {
            textOpacity = 1.0
            textY = 0
            phase = .revealed
        }

        try? await Task.sleep(for: .milliseconds(400))

        withAnimation(.easeIn(duration: 0.6)) {
            disclaimerOpacity = 1.0
        }

        try? await Task.sleep(for: .milliseconds(2200))

        phase = .fadingOut

        withAnimation(.easeIn(duration: 0.4)) {
            disclaimerOpacity = 0
        }

        withAnimation(.easeInOut(duration: 1.2)) {
            badgeScale = 1.15
            textOpacity = 0
            textY = -10
        }

        try? await Task.sleep(for: .milliseconds(400))

        withAnimation(.easeInOut(duration: 1.0)) {
            badgeScale = 1.5
            badgeOpacity = 0
            badgeY = -30
        }

        withAnimation(.easeIn(duration: 1.2)) {
            screenFadeOut = 1
        }

        try? await Task.sleep(for: .milliseconds(1300))

        onContinue()
    }
}

private struct FogLayer {
    let xOffset: Double
    let yOffset: Double
    let width: Double
    let height: Double
    let opacity: Double
    let blur: Double
}
