import SwiftUI

struct ShoppingListTab: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                if app.currentList.items.isEmpty {
                    // Tom-tilstand
                    VStack(spacing: 12) {
                        Image(systemName: "cart")
                            .font(.system(size: 36, weight: .regular))
                            .foregroundStyle(Theme.text2)
                        Text("Din indkøbsliste er tom")
                            .font(.headline)
                            .foregroundStyle(Theme.text1)
                        Text("Søg efter varer og tilføj dem til listen.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.text2)
                    }
                    .padding()
                } else {
                    List {
                        Section("Indkøbsliste") {
                            ForEach(app.currentList.items) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.product.name)
                                            .foregroundStyle(Theme.text1)
                                        if let v = item.variant {
                                            Text(v.displayName)
                                                .font(.footnote)
                                                .foregroundStyle(Theme.text2)
                                        }
                                    }
                                    Spacer()
                                    Text("×\(item.qty)")
                                        .foregroundStyle(Theme.text2)
                                }
                                .listRowBackground(Theme.card)
                            }
                            .onDelete { idx in
                                app.removeItems(at: idx)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .themedListBackground()
                }
            }
            .navigationTitle("Indkøb")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
        }
    }
}
