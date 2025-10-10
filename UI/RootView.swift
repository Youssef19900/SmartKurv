import SwiftUI

struct RootView: View {
    @EnvironmentObject var app: AppState
    @State private var tab: Tab = .search

    enum Tab: Hashable {
        case search
        case shopping
        case history
    }

    var body: some View {
        TabView(selection: $tab) {

            // MARK: - SØG
            NavigationStack {
                SearchTab()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Søg", systemImage: "magnifyingglass")
            }
            .tag(Tab.search)

            // MARK: - INDKØB
            NavigationStack {
                ShoppingListTab()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Indkøb", systemImage: "cart")
            }
            .badge(app.currentList.items.count > 0 ? app.currentList.items.count : nil) // badge på tab
            .tag(Tab.shopping)

            // MARK: - HISTORIK
            NavigationStack {
                HistoryTab()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Historik", systemImage: "clock.arrow.circlepath")
            }
            .tag(Tab.history)
        }
        .tint(Theme.accent)
        .background(Theme.bgGradient.ignoresSafeArea())
    }
}
