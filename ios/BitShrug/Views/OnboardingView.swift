import SwiftUI

struct OnboardingView: View {
    var onContinue: () -> Void
    @State private var opacity: Double = 0
    @State private var badgeScale: Double = 0.3
    @State private var badgeOffset: Double = 80
    @State private var titleOffset: Double = 40
    @State private var buttonOffset: Double = 50
    @State private var fogRise: Double = 0
    @State private var fogPulse: Double = 0
    @State private var glowIntensity: Double = 0

    private let fogGreen = Color(red: 0.3, green: 0.75, blue: 0.45)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            risingFogLayer

            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height * 0.38)
                let radius = size.width * 0.5
                let radialGlow = Path(ellipseIn: CGRect(
                    x: center.x - radius,
                    y: center.y - radius * 0.7,
                    width: radius * 2,
                    height: radius * 1.4
                ))
                context.fill(radialGlow, with: .color(fogGreen.opacity(0.08 * glowIntensity)))
            }
            .blur(radius: 50)
            .allowsHitTesting(false)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                BitcoinFogBadge(size: .hero)
                    .scaleEffect(badgeScale)
                    .offset(y: badgeOffset)
                    .opacity(opacity)

                Spacer()
                    .frame(height: 28)

                VStack(spacing: 12) {
                    Text("Fog of Bitcoin")
                        .font(.system(size: 38, weight: .heavy))
                        .foregroundStyle(.white)

                    Text("Where signal meets uncertainty.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                }
                .offset(y: titleOffset)
                .opacity(opacity)

                Spacer()

                VStack(spacing: 16) {
                    Button {
                        onContinue()
                    } label: {
                        Text("Click to Learn")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.orange, Color(red: 1.0, green: 0.6, blue: 0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(.rect(cornerRadius: 14))
                            .shadow(color: .orange.opacity(0.3), radius: 12, y: 4)
                    }
                    .padding(.horizontal, 32)

                    Text("Not financial advice.\nEducational information only.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.35))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 32)
                }
                .offset(y: buttonOffset)
                .opacity(opacity)
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: opacity > 0.5)
        .task {
            withAnimation(.easeOut(duration: 1.2)) {
                fogRise = 1
            }
            withAnimation(.spring(duration: 1.0, bounce: 0.25).delay(0.2)) {
                opacity = 1
                badgeScale = 1.0
                badgeOffset = 0
                glowIntensity = 1
            }
            withAnimation(.spring(duration: 0.8, bounce: 0.2).delay(0.5)) {
                titleOffset = 0
            }
            withAnimation(.spring(duration: 0.8, bounce: 0.2).delay(0.7)) {
                buttonOffset = 0
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(1.2)) {
                fogPulse = 1
            }
        }
    }

    private var risingFogLayer: some View {
        Canvas { context, size in
            let progress = fogRise
            let pulse = fogPulse

            let fogBottom = size.height * (1.0 - progress * 0.7)

            let fog1 = Path(ellipseIn: CGRect(
                x: -size.width * 0.2,
                y: fogBottom - size.height * 0.08 - pulse * 12,
                width: size.width * 1.4,
                height: size.height * 0.25
            ))
            context.fill(fog1, with: .color(fogGreen.opacity(0.12 * progress)))

            let fog2 = Path(ellipseIn: CGRect(
                x: -size.width * 0.1,
                y: fogBottom + size.height * 0.06 + pulse * 8,
                width: size.width * 1.2,
                height: size.height * 0.2
            ))
            context.fill(fog2, with: .color(fogGreen.opacity(0.08 * progress)))

            let fog3 = Path(ellipseIn: CGRect(
                x: size.width * 0.15,
                y: fogBottom + size.height * 0.15 - pulse * 6,
                width: size.width * 0.9,
                height: size.height * 0.18
            ))
            context.fill(fog3, with: .color(fogGreen.opacity(0.06 * progress)))

            let topWisp = Path(ellipseIn: CGRect(
                x: size.width * 0.1,
                y: fogBottom - size.height * 0.2 + pulse * 10,
                width: size.width * 0.6,
                height: size.height * 0.12
            ))
            context.fill(topWisp, with: .color(fogGreen.opacity(0.05 * progress)))
        }
        .blur(radius: 40)
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
