import SwiftUI

struct ShoppingListTab: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 16) {
                    if app.list.isEmpty {
                        // Tom-tilstand
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Theme.card)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .overlay(
                                HStack {
                                    Text("Din liste er tom.")
                                        .foregroundStyle(Theme.text2)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                            )
                            .padding(.horizontal, 16)

                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Theme.card.opacity(0.7))
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .overlay(
                                Text("Sammenlign priser i nærheden")
                                    .foregroundStyle(Theme.text2)
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                            )
                            .padding(.horizontal, 16)

                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Theme.card.opacity(0.7))
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .overlay(
                                Text("Gem i historik")
                                    .foregroundStyle(Theme.text2)
                                    .font(.headline)
                            )
                            .padding(.horizontal, 16)

                        Spacer(minLength: 0)
                    } else {
                        // Din rigtige liste
                        List {
                            ForEach(app.list, id: \.id) { item in
                                HStack {
                                    Text(item.product.name)
                                    Spacer()
                                    Text(item.variant.displayName)
                                        .foregroundStyle(Theme.text2)
                                }
                                .listRowBackground(Theme.card)
                            }
                            .onDelete(perform: app.deleteFromList)
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Indkøb")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Theme.bg, for: .navigationBar)
        }
    }
}