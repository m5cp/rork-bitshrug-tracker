import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var opacity: Double = 0
    @State private var dismissed: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ShrugBadge(size: .hero, style: .hero)

            Text("BitShrug")
                .font(.system(size: 36, weight: .heavy))
                .foregroundStyle(.primary)

            Text("Rise or fall, we DCA and hold.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
        .opacity(opacity)
        .task {
            withAnimation(.easeIn(duration: 1.0)) {
                opacity = 1
            }
            try? await Task.sleep(for: .seconds(3.0))
            guard !dismissed else { return }
            withAnimation(.easeOut(duration: 2.0)) {
                opacity = 0
            }
            try? await Task.sleep(for: .seconds(2.0))
            UserDefaults.standard.set(true, forKey: "bitshrug_onboarded")
            isPresented = false
        }
        .onDisappear {
            dismissed = true
        }
    }
}
