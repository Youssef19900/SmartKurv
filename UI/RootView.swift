import SwiftUI

enum AppTab: Hashable {
    case search, shopping, history
}

struct RootView: View {
    @ObservedObject var app: AppState
    @State private var selection: AppTab = .search

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            TabView(selection: $selection) {
                SearchTab()
                    .environmentObject(app)
                    .tabItem {
                        Label("Søg", systemImage: "magnifyingglass")
                    }
                    .tag(AppTab.search)

                ShoppingListTab()
                    .environmentObject(app)
                    .tabItem {
                        Label("Indkøb", systemImage: "cart")
                    }
                    .tag(AppTab.shopping)

                HistoryTab()
                    .environmentObject(app)
                    .tabItem {
                        Label("Historik", systemImage: "clock.arrow.circlepath")
                    }
                    .tag(AppTab.history)
            }
            .tint(Theme.accent) // virker på iOS 16
        }
    }
}