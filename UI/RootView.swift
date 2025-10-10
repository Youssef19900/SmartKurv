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
                .badge(app.cartItemCount == 0 ? nil : app.cartItemCount)
                .tag(Tab.shopping)

            NavigationStack { HistoryTab() }
                .tabItem { Label("Historik", systemImage: "clock.arrow.circlepath") }
                .tag(Tab.history)
        }
        .tint(.systemBlue)
        .appBackground()              // solid white, respects safe areas
    }
}
