import SwiftUI

struct OnboardingView: View {
    var onContinue: () -> Void
    @State private var opacity: Double = 0
    @State private var badgeScale: Double = 0.5
    @State private var titleOffset: Double = 20
    @State private var buttonOffset: Double = 30

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ShrugBadge(size: .hero, style: .hero)
                .scaleEffect(badgeScale)

            Text("Fog of Bitcoin")
                .font(.system(size: 36, weight: .heavy))
                .foregroundStyle(.primary)
                .offset(y: titleOffset)

            Text("Where signal meets uncertainty.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .offset(y: titleOffset)

            Spacer()

            Button {
                onContinue()
            } label: {
                Text("Click to Learn")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .clipShape(.rect(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .offset(y: buttonOffset)

            Text("Not financial advice.\nEducational information only.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)
                .offset(y: buttonOffset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
        .opacity(opacity)
        .sensoryFeedback(.impact(weight: .medium), trigger: opacity > 0.5)
        .task {
            withAnimation(.spring(duration: 0.8, bounce: 0.3)) {
                opacity = 1
                badgeScale = 1.0
            }
            withAnimation(.spring(duration: 0.7, bounce: 0.2).delay(0.2)) {
                titleOffset = 0
            }
            withAnimation(.spring(duration: 0.7, bounce: 0.2).delay(0.4)) {
                buttonOffset = 0
            }
        }
    }
}
