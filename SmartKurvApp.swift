import SwiftUI

@main
struct SmartKurvApp: App {
    @StateObject private var appState = AppState()   // ← opret én delt instans

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)         // ← injicer til hele view-hierarkiet
                .tint(Theme.accent)
                .background(Theme.bg.ignoresSafeArea())
                .dynamicTypeSize(.xSmall ... .xxLarge)
        }
    }
}
