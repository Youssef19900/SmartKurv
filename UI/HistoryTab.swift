import SwiftUI

private let historyKey = "smartkurv.history"

struct HistoryTab: View {
    @EnvironmentObject var app: AppState
    @State private var history: [ShoppingList] = []

    var body: some View {
        NavigationView {
            VStack {
                if history.isEmpty {
                    ContentUnavailableView(
                        "Ingen historik endnu",
                        systemImage: "clock",
                        description: Text("Gem din nuværende liste for at se den her.")
                    )
                    .padding()
                } else {
                    List {
                        ForEach(history) { list in
                            NavigationLink {
                                HistoryDetailView(list: list)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(list.createdAt, style: .date).font(.headline)
                                    Text("\(list.items.count) varer")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.insetGrouped)
                }

                HStack(spacing: 12) {
                    Button {
                        saveCurrentList()
                    } label: {
                        Label("Gem aktuel liste", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(app.currentList.items.isEmpty)

                    if let last = history.first {
                        Button {
                            restore(list: last)
                        } label: {
                            Label("Hent seneste", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle("Historik")
            .navigationBarTitleDisplayMode(.inline) // mindre titel
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton() // kurv-ikon med badge
                        .environmentObject(app)
                }
            }
        }
        .onAppear(perform: loadHistory)
    }

    // MARK: - Actions

    private func saveCurrentList() {
        var copy = app.currentList
        copy = ShoppingList(items: copy.items, createdAt: Date())
        history.insert(copy, at: 0)
        persist()
    }

    private func restore(list: ShoppingList) {
        app.currentList = list
    }

    private func delete(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        persist()
    }

    // MARK: - Persistence (UserDefaults)

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return }
        if let decoded = try? JSONDecoder().decode([ShoppingList].self, from: data) {
            history = decoded
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
}

struct HistoryDetailView: View {
    let list: ShoppingList

    var body: some View {
        List {
            ForEach(list.items) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.product.name).font(.headline)
                    Text(item.variant.displayName).font(.subheadline).foregroundColor(.secondary)
                    Text("Antal: \(item.qty)").font(.caption)
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle(Text(list.createdAt, style: .date))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct HistoryTab_Previews: PreviewProvider {
    static var previews: some View {
        HistoryTab().environmentObject(AppState())
    }
}
#endif
