import SwiftUI

struct RootView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        TabView {
            SearchTab()
                .tabItem { Label("Søg", systemImage: "magnifyingglass") }

            // Badge må ikke være nil – tilføj den kun når > 0
            shoppingTab

            HistoryTab()
                .tabItem { Label("Historik", systemImage: "clock.arrow.circlepath") }
        }
        .background(Theme.bgGradient.ignoresSafeArea()) // brug bgGradient fra Theme
    }

    @ViewBuilder
    private var shoppingTab: some View {
        if app.cartItemCount > 0 {
            ShoppingListTab()
                .tabItem { Label("Indkøb", systemImage: "cart") }
                .badge(app.cartItemCount)  // kun her
        } else {
            ShoppingListTab()
                .tabItem { Label("Indkøb", systemImage: "cart") }
        }
    }
}
