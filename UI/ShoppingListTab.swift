import SwiftUI

struct ShoppingListTab: View {
    @EnvironmentObject var app: AppState
    @State private var showCheapest = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                // Find billigst-knap
                Button {
                    Task {
                        await app.findCheapestNearby()
                        // Vis resultat kort, og flyt derefter listen til historik
                        showCheapest = true
                        app.commitCurrentListToHistory()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkle.magnifyingglass")
                        Text("Find billigst inden for 2 km")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(app.isFindingCheapest || app.currentList.items.isEmpty)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Resultatvisning (når vi lige har beregnet)
                if app.isFindingCheapest {
                    ProgressView("Beregner…")
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if showCheapest && !app.cheapest.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Billigst i nærheden")
                            .font(.headline)
                            .foregroundStyle(Theme.text2)
                        ForEach(app.cheapest, id: \.storeName) { t in
                            HStack {
                                Text(t.storeName).foregroundStyle(Theme.text1)
                                Spacer()
                                Text(String(format: "%.2f kr", t.total))
                                    .font(.headline)
                            }
                            .cardContainer()
                        }
                    }
                    .padding(.horizontal, 16)
                } else if let msg = app.errorMessage {
                    Text(msg).foregroundStyle(Theme.text2)
                        .padding(.horizontal, 16)
                }

                // Selve listen
                List {
                    Section {
                        ForEach(app.currentList.items) { item in
                            HStack {
                                Text(item.product.name).foregroundStyle(Theme.text1)
                                Spacer()
                                Text("x\(item.qty)").foregroundStyle(Theme.text2)
                            }
                            .listRowBackground(Theme.card)
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
                .listStyle(.plain) // tættere layout
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Indkøb")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { CartBadgeButton() }
            }
            .appBackground()
        }
    }
}