import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@main
struct SmartKurvApp: App {

    init() {
        // Mindre titler globalt (ingen kæmpe "Large Titles")
        #if canImport(UIKit)
        UINavigationBar.appearance().prefersLargeTitles = false

        // Fix for gennemsigtig tabbar ved scroll på iOS 15+
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        #endif

        // 🔐 Salling API-token (byt til rigtig eller læs fra Keychain)
        PricingService.shared.apiTokenProvider = { "DIN_SALLING_TOKEN" }
    }

    var body: some Scene {
        WindowGroup {
            RootView()  // TabView med Søg / Indkøb / Historik
        }
    }
}
