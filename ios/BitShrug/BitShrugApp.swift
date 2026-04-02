import SwiftUI
import WidgetKit
import AppIntents
import RevenueCat

@main
struct BitShrugApp: App {
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "bitshrug_onboarded")

    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY)
        #else
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY)
        #endif
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
