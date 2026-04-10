import SwiftUI

struct SplashOverlayView: View {
    @State private var opacity: Double = 1.0
    @State private var logoScale: Double = 0.85
    @State private var logoOpacity: Double = 0.0

    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 72, weight: .thin))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                Text("TouchGrass BTC")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .opacity(logoOpacity)

                Text("Macro clarity, not noise.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .opacity(logoOpacity)
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            withAnimation(.easeInOut(duration: 1.0).delay(1.8)) {
                opacity = 0.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                onDismiss()
            }
        }
        .allowsHitTesting(false)
    }
}
