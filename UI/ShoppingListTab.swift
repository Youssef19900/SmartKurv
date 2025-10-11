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
        // Træk ud i en lokal variabel for at gøre type-checkeren glad
        let items = app.currentList.items

        // Vi antager kun at 'items' er en Collection med count + subscript
        if itemsCount(items) == 0 {
            EmptyStateView()
        } else {
            List {
                Section("Indkøbsliste") {
                    ForEach(0..<itemsCount(items), id: \.self) { i in
                        let anyItem = itemAt(items, i)
                        Row(title: titleFor(anyItem),
                            subtitle: subtitleFor(anyItem),
                            qtyText: qtyFor(anyItem))
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

// MARK: - Hjælpere (type-agnostiske)

/// Antal elementer i en hvilken som helst Array-lignende collection.
private func itemsCount(_ items: Any) -> Int {
    if let a = items as? [Any] { return a.count }
    // fallback via Mirror (langsommere, men kompilerer)
    let mirror = Mirror(reflecting: items)
    if mirror.displayStyle == .collection { return mirror.children.count }
    return 0
}

/// Hent element ved indeks fra en Array-lignende collection.
private func itemAt(_ items: Any, _ index: Int) -> Any {
    if let a = items as? [Any] { return a[index] }
    // fallback via iteration
    let mirror = Mirror(reflecting: items)
    if mirror.displayStyle == .collection {
        let idx = mirror.children.index(mirror.children.startIndex, offsetBy: index)
        return mirror.children[idx].value
    }
    return items
}

/// Prøv at udlede en titel (product.name / name / title), ellers brug beskrivelse.
private func titleFor(_ item: Any) -> String {
    // Direkte forsøg via key-path-lignende casts
    if let named = item as? CustomStringConvertible { return String(describing: named) }

    // Reflection: product.name -> String
    let m = Mirror(reflecting: item)
    for child in m.children {
        if child.label == "product" {
            let pm = Mirror(reflecting: child.value)
            for p in pm.children where p.label == "name", let s = p.value as? String {
                return s
            }
        }
        if (child.label == "name" || child.label == "title"), let s = child.value as? String {
            return s
        }
    }
    return String(describing: item)
}

/// Prøv at lave en lille undertekst (variant.displayName / variant / brand).
private func subtitleFor(_ item: Any) -> String? {
    let m = Mirror(reflecting: item)
    for child in m.children {
        if child.label == "variant" {
            let vm = Mirror(reflecting: child.value)
            for p in vm.children where p.label == "displayName", let s = p.value as? String {
                return s
            }
            if let s = child.value as? String { return s }
        }
        if child.label == "brand", let s = child.value as? String { return s }
    }
    return nil
}

/// Prøv at finde qty og formattere det.
private func qtyFor(_ item: Any) -> String {
    let m = Mirror(reflecting: item)
    for child in m.children where child.label == "qty" {
        if let q = child.value as? Int { return "×\(q)" }
        if let q = child.value as? Double { return "×\(Int(q))" }
        if let q = child.value as? String { return "×\(q)" }
    }
    return ""
}

// MARK: - Små visninger

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

private struct Row: View {
    let title: String
    let subtitle: String?
    let qtyText: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).foregroundStyle(Theme.text1)
                if let subtitle {
                    Text(subtitle).font(.footnote).foregroundStyle(Theme.text2)
                }
            }
            Spacer()
            if !qtyText.isEmpty {
                Text(qtyText).foregroundStyle(Theme.text2)
            }
        }
    }
}