import SwiftUI

struct ShoppingListTab: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                // LISTE
                List {
                    if app.currentList.items.isEmpty {
                        Text("Din liste er tom.")
                            .foregroundColor(.secondary)
                    } else {
                        Section {
                            ForEach(app.currentList.items) { item in
                                HStack {
                                    Text(item.product.name)
                                    Spacer()
                                    Text("x\(item.qty)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        } header: {
                            HStack {
                                Text("Din liste")
                                Spacer()
                                Text("\(app.currentList.items.reduce(0) { $0 + $1.qty }) varer")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // BILLIGST I NÆRHEDEN (vises efter du trykker “Sammenlign priser”)
                    if app.isFindingCheapest {
                        Section("Prissammenligning") {
                            HStack {
                                ProgressView()
                                Text("Finder priser i nærheden…")
                            }
                        }
                    } else if !app.cheapest.isEmpty {
                        Section("Prissammenligning") {
                            ForEach(app.cheapest, id: \.storeName) { t in
                                HStack {
                                    Text(t.storeName)
                                    Spacer()
                                    Text(String(format: "%.2f kr", t.total))
                                        .font(.headline)
                                }
                            }
                        }
                    } else if let msg = app.errorMessage {
                        Section("Prissammenligning") {
                            Text(msg).foregroundColor(.secondary)
                        }
                    }
                }
                .listStyle(.insetGrouped)

                // HANDLING-KNAPPER
                VStack(spacing: 10) {
                    Button {
                        Task { await app.findCheapestNearby() }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "chart.bar.xaxis")
                            Text("Sammenlign priser i nærheden")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .disabled(app.currentList.items.isEmpty || app.isFindingCheapest)

                    Button {
                        app.commitCurrentListToHistory()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "tray.and.arrow.down.fill")
                            Text("Gem i historik")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .disabled(app.currentList.items.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .navigationTitle("Indkøb")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
            .background(Color(.systemBackground))
        }
    }
}