import SwiftUI

struct OnboardingView: View {
    var onContinue: () -> Void
    @State private var opacity: Double = 0
    @State private var badgeScale: Double = 0.3
    @State private var badgeOffset: Double = 100
    @State private var titleOffset: Double = 50
    @State private var buttonOffset: Double = 60
    @State private var fogRise: Double = 0
    @State private var fogPulse: Double = 0
    @State private var glowIntensity: Double = 0
    @State private var badgeGlow: Double = 0

    private let fogGreen = Color(red: 0.3, green: 0.75, blue: 0.45)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            risingFogLayer

            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height * 0.35)
                let radius = size.width * 0.55
                let radialGlow = Path(ellipseIn: CGRect(
                    x: center.x - radius,
                    y: center.y - radius * 0.6,
                    width: radius * 2,
                    height: radius * 1.2
                ))
                context.fill(radialGlow, with: .color(fogGreen.opacity(0.1 * glowIntensity)))
            }
            .blur(radius: 60)
            .allowsHitTesting(false)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(maxHeight: .infinity)

                ZStack {
                    Circle()
                        .fill(fogGreen.opacity(0.06 * badgeGlow))
                        .frame(width: 260, height: 260)
                        .blur(radius: 50)

                    Circle()
                        .fill(fogGreen.opacity(0.03 * badgeGlow))
                        .frame(width: 340, height: 340)
                        .blur(radius: 70)

                    BitcoinFogBadge(size: .hero)
                }
                .scaleEffect(badgeScale)
                .offset(y: badgeOffset)
                .opacity(opacity)

                Spacer()
                    .frame(height: 32)

                VStack(spacing: 14) {
                    Text("Fog of Bitcoin")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Text("Where signal meets uncertainty.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .offset(y: titleOffset)
                .opacity(opacity)

                Spacer()
                    .frame(maxHeight: .infinity)

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
            withAnimation(.easeOut(duration: 1.4)) {
                fogRise = 1
            }
            withAnimation(.spring(duration: 1.2, bounce: 0.2).delay(0.15)) {
                opacity = 1
                badgeScale = 1.0
                badgeOffset = 0
                glowIntensity = 1
            }
            withAnimation(.spring(duration: 0.9, bounce: 0.15).delay(0.5)) {
                titleOffset = 0
            }
            withAnimation(.spring(duration: 0.8, bounce: 0.15).delay(0.75)) {
                buttonOffset = 0
            }
            withAnimation(.easeIn(duration: 1.5).delay(0.3)) {
                badgeGlow = 1
            }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true).delay(1.5)) {
                fogPulse = 1
            }
        }
    }

    private var risingFogLayer: some View {
        Canvas { context, size in
            let progress = fogRise
            let pulse = fogPulse

            let fogBottom = size.height * (1.0 - progress * 0.75)

            let fog1 = Path(ellipseIn: CGRect(
                x: -size.width * 0.25,
                y: fogBottom - size.height * 0.1 - pulse * 14,
                width: size.width * 1.5,
                height: size.height * 0.28
            ))
            context.fill(fog1, with: .color(fogGreen.opacity(0.14 * progress)))

            let fog2 = Path(ellipseIn: CGRect(
                x: -size.width * 0.1,
                y: fogBottom + size.height * 0.05 + pulse * 10,
                width: size.width * 1.2,
                height: size.height * 0.22
            ))
            context.fill(fog2, with: .color(fogGreen.opacity(0.09 * progress)))

            let fog3 = Path(ellipseIn: CGRect(
                x: size.width * 0.1,
                y: fogBottom + size.height * 0.14 - pulse * 8,
                width: size.width * 0.95,
                height: size.height * 0.2
            ))
            context.fill(fog3, with: .color(fogGreen.opacity(0.07 * progress)))

            let topWisp = Path(ellipseIn: CGRect(
                x: size.width * 0.05,
                y: fogBottom - size.height * 0.22 + pulse * 12,
                width: size.width * 0.7,
                height: size.height * 0.14
            ))
            context.fill(topWisp, with: .color(fogGreen.opacity(0.05 * progress)))

            let highWisp = Path(ellipseIn: CGRect(
                x: size.width * 0.2,
                y: fogBottom - size.height * 0.35 + pulse * 8,
                width: size.width * 0.5,
                height: size.height * 0.1
            ))
            context.fill(highWisp, with: .color(fogGreen.opacity(0.03 * progress)))
        }
        .blur(radius: 45)
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
