import SwiftUI
import WidgetKit
import AppIntents
import RevenueCat

@main
struct BitShrugApp: App {
    @AppStorage("bitshrug_onboarded_v2") private var hasOnboarded: Bool = false
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
                .fullScreenCover(isPresented: Binding(
                    get: { !hasOnboarded },
                    set: { newValue in
                        if !newValue { hasOnboarded = true }
                    }
                )) {
                    OnboardingView(onContinue: {
                        hasOnboarded = true
                    })
                    .interactiveDismissDisabled()
                    .preferredColorScheme(colorScheme)
                }
        }
    }
}
