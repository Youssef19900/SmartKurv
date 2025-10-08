import SwiftUI

struct ShoppingListTab: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            List {
                ForEach(app.currentList.items) { item in
                    HStack {
                        Text(item.product.name)
                        Spacer()
                        Text("x\(item.qty)")
                            .foregroundStyle(Theme.text2)
                    }
                }
            }
            .navigationTitle("Indkøb")
            .toolbar(content: shoppingToolbar)  // <- eksplicit content-funktion
        }
        .background(Theme.bgGradient.ignoresSafeArea())
    }

    @ToolbarContentBuilder
    private func shoppingToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            CartBadgeButton()
        }
    }
}
