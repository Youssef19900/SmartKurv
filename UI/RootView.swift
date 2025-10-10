import SwiftUI

struct RootView: View {
    @EnvironmentObject var app: AppState
    @State private var tab: Tab = .search

    enum Tab: Hashable { case search, shopping, history }

    var body: some View {
        TabView(selection: $tab) {

            // SØG
            NavigationStack { SearchTab() }
                .tabItem { Label("Søg", systemImage: "magnifyingglass") }
                .tag(Tab.search)

            // INDKØB
            NavigationStack { ShoppingListTab() }
                .tabItem { Label("Indkøb", systemImage: "cart") }
                .badgeIf(app.currentList.items.reduce(0) { $0 + $1.qty }) // ← kun badge hvis > 0
                .tag(Tab.shopping)

            // HISTORIK
            NavigationStack { HistoryTab() }
                .tabItem { Label("Historik", systemImage: "clock.arrow.circlepath") }
                .tag(Tab.history)
        }
        .tint(Theme.accent) // eller Color(.systemBlue)
        .background(Theme.bgGradient.ignoresSafeArea())
    }
}

// Kun vis badge når count > 0
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
