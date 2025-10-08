import SwiftUI

struct ShoppingListTab: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            // ... din liste/indhold ...

            // eksempel:
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
            .toolbar {       // Gør toolbaren entydig med ToolbarItem
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
        }
        .background(Theme.bgGradient.ignoresSafeArea())
    }
}
