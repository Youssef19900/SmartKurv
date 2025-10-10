import SwiftUI

struct ShoppingListTab: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            Group {
                if app.currentList.items.isEmpty {
                    // TOM-STATE
                    VStack(spacing: 12) {
                        Image(systemName: "cart")
                            .font(.system(size: 44, weight: .regular))
                            .foregroundStyle(Theme.text2)
                        Text("Din indkøbsliste er tom")
                            .font(.headline)
                            .foregroundStyle(Theme.text2)
                        Text("Søg efter varer og tilføj dem til listen.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.text2.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // LISTE
                    List {
                        Section {
                            ForEach(app.currentList.items) { item in
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.product.name)
                                            .font(.headline)
                                            .foregroundStyle(Theme.text1)
                                        // evt. ekstra info (variant mm.)
                                        // Text(item.product.variants.first?.displayName ?? "")
                                        //     .font(.subheadline)
                                        //     .foregroundStyle(Theme.text2)
                                    }
                                    Spacer()
                                    Text("x\(item.qty)")
                                        .font(.headline)
                                        .foregroundStyle(Theme.text2)
                                }
                                .listRowBackground(Theme.card)
                                // Swipe-to-delete (afkommentér, hvis du har denne metode)
                                //.swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                //    Button(role: .destructive) {
                                //        app.remove(item)
                                //    } label: {
                                //        Label("Slet", systemImage: "trash")
                                //    }
                                //}
                            }
                        } header: {
                            HStack {
                                Text("Din liste")
                                Spacer()
                                Text("\(app.currentList.items.count) varer")
                            }
                            .foregroundStyle(Theme.text2)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .appBackground()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Indkøb")
                        .font(.title2.bold())
                        .foregroundStyle(Theme.text1)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
