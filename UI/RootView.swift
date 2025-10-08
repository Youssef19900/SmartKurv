import SwiftUI

struct RootView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        TabView {
            SearchTab()
                .tabItem { Label("Søg", systemImage: "magnifyingglass") }

            // Tilføj badge kun når der er varer
            Group {
                if app.cartItemCount > 0 {
                    ShoppingListTab()
                        .tabItem { Label("Indkøb", systemImage: "cart") }
                        .badge(app.cartItemCount)
                } else {
                    ShoppingListTab()
                        .tabItem { Label("Indkøb", systemImage: "cart") }
                }
            }

            HistoryTab()
                .tabItem { Label("Historik", systemImage: "clock.arrow.circlepath") }
        }
        .background(Theme.bgGradient.ignoresSafeArea())
    }
}
