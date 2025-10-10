import SwiftUI

struct RootView: View {
    @EnvironmentObject var app: AppState
    @State private var tab: Tab = .search

    enum Tab: Hashable { case search, shopping, history }

    var body: some View {
        TabView(selection: $tab) {

            // SØG
            NavigationStack {
                SearchTab()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Søg", systemImage: "magnifyingglass") }
            .tag(Tab.search)

            // INDKØB
            NavigationStack {
                ShoppingListTab()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Indkøb", systemImage: "cart") }
            .badgeIf(app.currentList.items.count)   // <- kun badge når > 0
            .tag(Tab.shopping)

            // HISTORIK
            NavigationStack {
                HistoryTab()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Historik", systemImage: "clock.arrow.circlepath") }
            .tag(Tab.history)
        }
        .tint(Theme.accent)
        .background(Theme.bgGradient.ignoresSafeArea())
    }
}

// Viser kun badge hvis count > 0
private extension View {
    @ViewBuilder
    func badgeIf(_ count: Int) -> some View {
        if count > 0 {
            self.badge(count)
        } else {
            self
        }
    }
}
