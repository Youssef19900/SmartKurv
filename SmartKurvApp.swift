import SwiftUI

@main
struct SmartKurvApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(Theme.accent)
                .background(Theme.bg.ignoresSafeArea())
                // 👇 Begræns hvor stort teksten må blive (stadig fleksibel)
                .dynamicTypeSize(.xSmall ... .xxLarge)
        }
    }
}
