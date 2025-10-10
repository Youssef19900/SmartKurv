import SwiftUI

struct RootView: View {
    @EnvironmentObject var app: AppState
    @State private var tab: Tab = .search
    enum Tab: Hashable { case search, shopping, history }

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { SearchTab().navigationBarTitleDisplayMode(.inline) }
                .tabItem { Label("Søg", systemImage: "magnifyingglass") }
                .tag(Tab.search)

            NavigationStack { ShoppingListTab().navigationBarTitleDisplayMode(.inline) }
                .tabItem { Label("Indkøb", systemImage: "cart") }
                .badgeIf(app.currentList.items.count)
                .tag(Tab.shopping)

            NavigationStack { HistoryTab().navigationBarTitleDisplayMode(.inline) }
                .tabItem { Label("Historik", systemImage: "clock.arrow.circlepath") }
                .tag(Tab.history)
        }
        .tint(Theme.accent)
        .appBackground()
    }
}

private extension View {
    @ViewBuilder func badgeIf(_ count: Int) -> some View {
        if count > 0 { self.badge(count) } else { self }
    }
}
