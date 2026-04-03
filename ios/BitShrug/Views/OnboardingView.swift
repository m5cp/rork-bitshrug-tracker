import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ShrugBadge(size: .hero, style: .hero)

            Text("BitShrug")
                .font(.system(size: 36, weight: .heavy))
                .foregroundStyle(.primary)

            Text("Rise or fall, we don't know. We hold.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                UserDefaults.standard.set(true, forKey: "bitshrug_onboarded")
                isPresented = false
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

            Text("Not financial advice.\nEducational information only.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
        .opacity(opacity)
        .task {
            withAnimation(.easeIn(duration: 0.8)) {
                opacity = 1
            }
        }
    }
}
