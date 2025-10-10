import SwiftUI

struct RootView: View {
    @EnvironmentObject var app: AppState
    @State private var tab: Tab = .search

    enum Tab: Hashable { case search, shopping, history }

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { SearchTab() }
                .tabItem { Label("Søg", systemImage: "magnifyingglass") }
                .tag(Tab.search)

            NavigationStack { ShoppingListTab() }
                .tabItem { Label("Indkøb", systemImage: "cart") }
                .tabBadge(app.cartItemCount)          // ✅ only shows when > 0
                .tag(Tab.shopping)

            NavigationStack { HistoryTab() }
                .tabItem { Label("Historik", systemImage: "clock.arrow.circlepath") }
                .tag(Tab.history)
        }
        .tint(Color(.systemBlue))                    // ✅ avoid .systemBlue directly
        .appBackground()
    }
}

// ✅ helper so we don’t pass nil into .badge
private extension View {
    @ViewBuilder
    func tabBadge(_ count: Int) -> some View {
        if count > 0 { self.badge(count) } else { self }
    }
}
