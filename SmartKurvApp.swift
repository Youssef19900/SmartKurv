import SwiftUI

@main
struct SmartKurvApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()            // <— dit eksisterende tab-view
                .tint(Theme.accent)  // global knap/link-farve
                .background(Theme.bg.ignoresSafeArea())
        }
    }
}
