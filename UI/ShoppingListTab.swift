import SwiftUI

@MainActor
struct ShoppingListTab: View {
    @EnvironmentObject var app: AppState
    
    // Vi holder os til Any + spejling, så den virker uanset din item-models navn/felter
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
                    CartBadgeButton()   // arver @EnvironmentObject fra denne view-hierarki
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if itemsCount(itemsAny) == 0 {
            // Lille tom-tilstand uden afhængighed til andre Views
            VStack(spacing: 12) {
                Image(systemName: "cart")
                    .imageScale(.large)
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("Din indkøbsliste er tom")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.bg)
        } else {
            List {
                Section("Indkøbsliste") {
                    ForEach(0..<itemsCount(itemsAny), id: \.self) { i in
                        let anyItem = itemAt(itemsAny, i)
                        ItemRow(
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

// MARK: - Hjælpe-Views

private struct ItemRow: View {
    let title: String
    let subtitle: String?
    let qtyText: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checklist")
                .imageScale(.large)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color(.systemGray6))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                if let s = subtitle, !s.isEmpty {
                    Text(s)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if !qtyText.isEmpty {
                Text(qtyText)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(Color(.systemGray5))
                    )
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Spejl-baserede helpers (robuste mod forskellige modelnavne)

/// Antal elementer i en Collection uden at kende typen
private func itemsCount(_ collection: Any) -> Int {
    let m = Mirror(reflecting: collection)
    guard m.displayStyle == .collection else { return 0 }
    return m.children.count
}

/// Element ved indeks i en Collection via Mirror
private func itemAt(_ collection: Any, _ index: Int) -> Any {
    let m = Mirror(reflecting: collection)
    guard m.displayStyle == .collection else { return collection }
    for (i, child) in m.children.enumerated() where i == index {
        return child.value
    }
    return collection
}

/// Find en streng-værdi for feltnavne som kunne være titel
private func titleFor(_ item: Any) -> String {
    // Mulige feltnavne som kan fungere som primær titel
    let candidates = ["name", "title", "displayName", "productName", "text"]
    return firstStringField(in: item, names: candidates) ?? "Vare"
}

/// Find en sekundær linje (fx brand/beskrivelse)
private func subtitleFor(_ item: Any) -> String? {
    let candidates = ["brand", "subtitle", "description", "details", "note"]
    return firstStringField(in: item, names: candidates)
}

/// Byg mængde/qty tekst – accepterer både Int, Double og String-felter
private func qtyFor(_ item: Any) -> String {
    // mest almindelige felter
    let qtyInt = firstIntField(in: item, names: ["qty", "quantity", "count", "amount"])
    let unit = firstStringField(in: item, names: ["unit", "unitName", "uom"])
    
    if let q = qtyInt {
        if let u = unit, !u.isEmpty {
            return "\(q) \(u)"
        } else {
            return "\(q)"
        }
    }
    
    // fallback: prøv string-baserede felter
    if let qStr = firstStringField(in: item, names: ["qtyText", "quantityText"]) {
        return qStr
    }
    
    return ""
}

// MARK: - Feltopslag via Mirror

private func firstStringField(in value: Any, names: [String]) -> String? {
    let m = Mirror(reflecting: value)
    for child in m.children {
        guard let label = child.label else { continue }
        if names.contains(label), let s = child.value as? String {
            return s
        }
    }
    // Gå evt. et niveau ned, hvis item wrapper andre data
    for child in m.children {
        if let s: String = firstStringField(in: child.value, names: names) {
            return s
        }
    }
    return nil
}

private func firstIntField(in value: Any, names: [String]) -> Int? {
    let m = Mirror(reflecting: value)
    for child in m.children {
        guard let label = child.label else { continue }
        if names.contains(label) {
            if let i = child.value as? Int { return i }
            if let d = child.value as? Double { return Int(d) }
            if let s = child.value as? String, let i = Int(s) { return i }
        }
    }
    // Gå evt. et niveau ned
    for child in m.children {
        if let i: Int = firstIntField(in: child.value, names: names) {
            return i
        }
    }
    return nil
}