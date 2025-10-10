import SwiftUI

@main
struct SmartKurvApp: App {
    init() {
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = .white
        nav.titleTextAttributes = [.foregroundColor: UIColor.black]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = .blue     // bar button/tint

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = .white
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        UITabBar.appearance().tintColor = .blue            // active tab color
        UITabBar.appearance().unselectedItemTintColor = .gray
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(AppState())
        }
    }
}
