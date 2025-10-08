import SwiftUI

struct RootView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        TabView {
            SearchTab()
                .tabItem { Label("Søg", systemImage: "magnifyingglass") }

            ShoppingListTab()
                .tabItem { Label("Indkøb", systemImage: "cart") }
                .badge(app.cartItemCount > 0 ? app.cartItemCount : nil)

            HistoryTab()
                .tabItem { Label("Historik", systemImage: "clock.arrow.circlepath") }
        }
        .background(Theme.bg.ignoresSafeArea())
    }
}
