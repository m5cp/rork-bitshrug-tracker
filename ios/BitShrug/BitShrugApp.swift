import SwiftUI
import WidgetKit

@main
struct BitShrugApp: App {
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "bitshrug_onboarded")

    init() {
        BitShrugShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView(isPresented: $showOnboarding)
                        .preferredColorScheme(.dark)
                }
        }
    }
}
