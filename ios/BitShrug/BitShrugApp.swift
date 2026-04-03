import SwiftUI
import WidgetKit
import AppIntents
import RevenueCat

@main
struct BitShrugApp: App {
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "bitshrug_onboarded")
    @AppStorage("appColorScheme") private var appColorScheme: String = "dark"

    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY)
        #else
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY)
        #endif
        BitShrugShortcuts.updateAppShortcutParameters()
    }

    private var colorScheme: ColorScheme? {
        switch appColorScheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme)
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView(isPresented: $showOnboarding)
                        .preferredColorScheme(colorScheme)
                }
        }
    }
}
