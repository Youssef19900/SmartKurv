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
            .toolbar {                      // <— ingen tvivl for overloads
                shoppingToolbar
            }
        }
        .background(Theme.bgGradient.ignoresSafeArea())
    }

    // Gør det til en computed var i stedet for en func
    @ToolbarContentBuilder
    private var shoppingToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            CartBadgeButton()
        }
        // Eksempel på flere items:
        // ToolbarItem(placement: .topBarLeading) { EditButton() }
    }
}
