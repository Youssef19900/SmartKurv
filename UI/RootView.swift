import SwiftUI

struct RootView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        TabView {
            SearchTab()
                .tabItem { Label("Søg", systemImage: "magnifyingglass") }

            ShoppingListTab()
                .tabItem { Label("Indkøb", systemImage: "cart") }
                .badgeIfNeeded(app.cartItemCount)   // <- brug helperen herunder

            HistoryTab()
                .tabItem { Label("Historik", systemImage: "clock.arrow.circlepath") }
        }
        .background(Theme.bgGradient.ignoresSafeArea())
    }
}

// Gør badge betinget uden 'nil' (undgår overload-problemet)
private extension View {
    @ViewBuilder
    func badgeIfNeeded(_ count: Int) -> some View {
        if count > 0 {
            self.badge(count)   // Int-overload
        } else {
            self                 // ingen badge
        }
    }
}
