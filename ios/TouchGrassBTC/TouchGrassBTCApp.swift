import SwiftUI
import WidgetKit
import AppIntents
import RevenueCat

@main
struct TouchGrassBTCApp: App {
    @AppStorage("bitshrug_onboarded") private var hasOnboarded: Bool = false
    @AppStorage("appColorScheme") private var appColorScheme: String = "dark"
    @State private var showOnboarding: Bool = false

    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY)
        #else
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY)
        #endif
        TouchGrassBTCShortcuts.updateAppShortcutParameters()
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
                    OnboardingView(onContinue: {
                        hasOnboarded = true
                        showOnboarding = false
                    })
                    .interactiveDismissDisabled()
                    .preferredColorScheme(colorScheme)
                }
                .onAppear {
                    if !hasOnboarded {
                        showOnboarding = true
                    }
                }
        }
    }
}
