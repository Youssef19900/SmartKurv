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
            .badge(tabBadge)  // <— brug explicit optional
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

    // MARK: - Badge helper
    private var tabBadge: Int? {
        let c = app.currentList.items.count
        return c == 0 ? nil : c
    }
}
