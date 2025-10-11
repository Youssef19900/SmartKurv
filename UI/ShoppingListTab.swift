struct ShoppingListTab: View {
    @EnvironmentObject var app: AppState
    
    // Træk items ud her—så undgår du let-binding inde i ViewBuilder
    private var itemsAny: Any { app.currentList.items }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                content
            }
            .navigationTitle("Indkøb")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if itemsCount(itemsAny) == 0 {
            EmptyStateView()
        } else {
            List {
                Section("Indkøbsliste") {
                    ForEach(0..<itemsCount(itemsAny), id: \.self) { i in
                        let anyItem = itemAt(itemsAny, i)
                        Row(
                            title: titleFor(anyItem),
                            subtitle: subtitleFor(anyItem),
                            qtyText: qtyFor(anyItem)
                        )
                        .listRowBackground(Theme.card)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
        }
    }
}