import SwiftUI

@main
struct SmartKurvApp: App {
    @StateObject private var app = AppState()   // <-- OPRET én delt AppState

    var body: some Scene {
        WindowGroup {
            RootView()                          // <-- din tab-view
                .environmentObject(app)         // <-- INJICÉR den til alle under-views
                .tint(Theme.accent)             // global knap/link-farve
                .background(Theme.bg.ignoresSafeArea())
        }
    }
}
