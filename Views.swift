import SwiftUI
import CoreLocation

// En simpel tom-tilstand der virker på iOS 16+
struct EmptyState: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            SearchPage()
                .tabItem { Label("Søg", systemImage: "magnifyingglass") }
            ListPage()
                .tabItem { Label("Indkøb", systemImage: "cart") }
            HistoryPage()
                .tabItem { Label("Historik", systemImage: "clock.arrow.circlepath") }
        }
    }
}

// MARK: - Søg

struct SearchPage: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    TextField("Søg fx “banan”", text: $app.searchQuery)
                        .textFieldStyle(.roundedBorder)
                    Button("Søg") { app.performSearch() }
                        .buttonStyle(.borderedProminent)
                }

                if app.searchResults.isEmpty {
                    EmptyState(
                        title: "Ingen resultater endnu",
                        subtitle: "Skriv en vare og tryk Søg.",
                        systemImage: "text.magnifyingglass"
                    )
                } else {
                    List(app.searchResults, id: \.id) { product in
                        ProductRow(product: product)
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
            .navigationTitle("Søg")
        }
    }
}

struct ProductRow: View {
    @EnvironmentObject var app: AppState
    let product: Product

    var units: [String] {
        Array(Set(product.variants.map { $0.unit })).sorted()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.name).font(.headline)

            HStack(spacing: 12) {
                // Enhed (stk/bundt/ltr/…)
                Picker("Enhed", selection: Binding<String>(
                    get: {
                        (app.selectedVariant[product.id]?.unit)
                        ?? app.defaultVariant(for: product).unit
                    },
                    set: { app.setUnit(for: product, unit: $0) }
                )) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
                .pickerStyle(.segmented)

                // Øko-toggle
                Toggle(isOn: Binding(
                    get: { app.isOrganic[product.id] ?? (app.defaultVariant(for: product).organic) },
                    set: { app.toggleOrganic(for: product, value: $0) }
                )) {
                    Text("Øko")
                }
                .toggleStyle(.switch)
                .frame(maxWidth: 90)
            }

            Button {
                app.addToList(product: product)
            } label: {
                Label("Læg i kurven", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Indkøbsliste

struct ListPage: View {
    @EnvironmentObject var app: AppState
    @State private var isFinding = false
    @State private var results: [StoreTotal] = []
    @State private var showLocationAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                if app.currentList.items.isEmpty {
                    EmptyState(
                        title: "Tom indkøbsliste",
                        subtitle: "Tilføj varer fra Søg.",
                        systemImage: "cart"
                    )
                } else {
                    List {
                        ForEach(app.currentList.items) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.product.name).font(.headline)
                                    Text("\(item.variant.organic ? "Øko " : "")\(item.variant.unit)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                HStack(spacing: 8) {
                                    Button {
                                        app.changeQty(itemID: item.id, delta: -1)
                                    } label: {
                                        Image(systemName: "minus.circle")
                                    }
                                    Text("\(item.qty)")
                                        .frame(minWidth: 24)
                                    Button {
                                        app.changeQty(itemID: item.id, delta: +1)
                                    } label: {
                                        Image(systemName: "plus.circle")
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)

                    Button {
                        handleFindCheapest()
                    } label: {
                        Label("Find billigst i nærheden", systemImage: "location.fill.viewfinder")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isFinding)

                    // RESULTAT + "Du sparer X kr."
                    if !results.isEmpty {
                        let cheapest = results[0]
                        let second   = results.count > 1 ? results[1] : nil
                        let savings  = second != nil ? max(0, second!.total - cheapest.total) : 0

                        VStack(alignment: .leading, spacing: 10) {
                            // Konklusion
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🏆 Billigst hos \(cheapest.storeName)")
                                    .font(.headline)
                                Text("Samlet pris: \(String(format: "DKK %.2f", cheapest.total))")
                                    .monospaced()
                                if let sec = second {
                                    Text("💸 Du sparer \(String(format: "DKK %.2f", savings)) i forhold til \(sec.storeName)")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                            }

                            // Begge butikker med total
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Butikker")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                ForEach(results) { r in
                                    HStack {
                                        Text(r.storeName)
                                        Spacer()
                                        Text(String(format: "DKK %.2f", r.total)).monospaced()
                                    }
                                }
                            }

                            Button {
                                app.commitCurrentListToHistory()
                                results = []
                            } label: {
                                Label("Gem som handlet", systemImage: "archivebox")
                            }
                            .buttonStyle(.bordered)
                            .padding(.top, 4)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding()
            .navigationTitle("Indkøbsliste")
            .alert("Lokation kræves", isPresented: $showLocationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Giv adgang til din lokation for at finde butikker i nærheden.")
            }
        }
    }

    func handleFindCheapest() {
        let status = app.locationManager.status
        if status == .notDetermined {
            app.locationManager.requestWhenInUse()
        }
        if status == .denied || status == .restricted {
            showLocationAlert = true
            return
        }

        isFinding = true
        Task {
            if app.locationManager.lastLocation == nil {
                app.locationManager.refreshLocation()
                try? await Task.sleep(nanoseconds: 600_000_000) // 0.6s
            }
            let res = await PricingService.shared.findCheapest(
                list: app.currentList,
                location: app.locationManager.lastLocation
            )
            results = res
            isFinding = false
        }
    }
}

// MARK: - Historik

struct HistoryPage: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            if app.history.isEmpty {
                EmptyState(
                    title: "Ingen historik endnu",
                    subtitle: "Når du markerer en liste som handlet, vises den her.",
                    systemImage: "clock"
                )
                .navigationTitle("Historik")
            } else {
                List {
                    ForEach(app.history) { list in
                        Section(list.createdAt.formatted(date: .abbreviated, time: .shortened)) {
                            ForEach(list.items) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.product.name).font(.body)
                                        Text("\(item.variant.organic ? "Øko " : "")\(item.variant.unit)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("x\(item.qty)")
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Historik")
            }
        }
    }
}
