import SwiftUI

struct ShoppingListTab: View {
    @EnvironmentObject var app: AppState

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
        let items = app.currentList.items  // træk ud så type-checker har det nemt

        if items.isEmpty {
            EmptyStateView()
        } else {
            SimpleListView(items: items)
        }
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 36))
                .foregroundStyle(Theme.text2)
            Text("Din indkøbsliste er tom")
                .font(.headline)
                .foregroundStyle(Theme.text1)
            Text("Søg efter varer og tilføj dem til listen.")
                .font(.subheadline)
                .foregroundStyle(Theme.text2)
        }
        .padding()
    }
}

private struct SimpleListView: View {
    let items: [ShoppingListItem]   // Tilpas typen hvis din model hedder anderledes

    var body: some View {
        List {
            Section("Indkøbsliste") {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    Row(item: item)
                        .listRowBackground(Theme.card)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
    }
}

private struct Row: View {
    let item: ShoppingListItem      // Tilpas typen hvis din model hedder anderledes

    var body: some View {
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
    }
}