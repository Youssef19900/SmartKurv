import SwiftUI

struct RootView: View {
    @StateObject private var app = AppState()

    var body: some View {
        TabView {
            SearchTab()
                .environmentObject(app)
                .tabItem { Label("Søg", systemImage: "magnifyingglass") }

            ShoppingListTab()
                .environmentObject(app)
                .tabItem { Label("Indkøbsliste", systemImage: "cart") }

            HistoryTab()
                .environmentObject(app)
                .tabItem { Label("Tidligere lister", systemImage: "clock") }
        }
        .onAppear {
            // TODO: byt til rigtig token (eller hent fra Keychain)
            PricingService.shared.apiTokenProvider = { "DIN_SALLING_TOKEN" }
        }
    }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
#endif
