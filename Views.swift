import SwiftUI
import CoreLocation

// MARK: - EmptyState (beholdt – men tilpasset farver)
struct EmptyState: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 40, weight: .regular))
                .foregroundColor(Theme.text2)
            Text(title)
                .font(.headline)
                .foregroundColor(Theme.text1)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(Theme.text2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(Theme.bg.ignoresSafeArea())
    }
}

// MARK: - Root tabs
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
        .background(Theme.bg.ignoresSafeArea())
    }
}

// MARK: - Søg (med drop-down forslag)
struct SearchPage: View {
    @EnvironmentObject var app: AppState

    @State private var suggestions: [String] = []
    @State private var showSuggestions = false

    // En lille base til typeahead så der vises noget fra start
    private let seedNames = [
        "Banan", "Æbler Røde", "Æbler Grønne", "Pærer", "Appelsin",
        "Tomat", "Agurk", "Mælk", "Smør", "Brød", "Kaffe", "Ris", "Pasta", "Bulgur"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {

                        // Titel
                        Text("Søg")
                            .font(.system(size: 44, weight: .heavy))
                            .foregroundColor(Theme.text1)
                            .padding(.top, 8)

                        // Søg + forslag
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                TextField("Søg fx “banan”", text: $app.Query)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 14)
                                    .background(Theme.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .foregroundColor(Theme.text1)
                                    .onChange(of: app.Query) { newValue in
                                        updateSuggestions(for: newValue)
                                    }

                                Button("Søg") {
                                    app.performSearch()
                                    withAnimation { showSuggestions = false }
                                }
                                .buttonStyle(PrimaryButton())
                                .controlSize(.regular) // ← vigtig
                                .frame(width: 110)
                            }

                            if showSuggestions && !suggestions.isEmpty {
                                Card {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(suggestions, id: \.self) { name in
                                            Button {
                                                app.Query = name
                                                withAnimation { showSuggestions = false }
                                                app.performSearch()
                                            } label: {
                                                HStack(spacing: 10) {
                                                    Image(systemName: "magnifyingglass")
                                                        .foregroundColor(Theme.text2)
                                                    Text(name)
                                                        .foregroundColor(Theme.text1)
                                                    Spacer()
                                                }
                                                .contentShape(Rectangle())
                                            }
                                            .buttonStyle(.plain)

                                            if name != suggestions.last {
                                                Divider().background(Color.black.opacity(0.2))
                                            }
                                        }
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }

                        // Resultater
                        if app.searchResults.isEmpty {
                            Card {
                                EmptyState(
                                    title: "Ingen resultater endnu",
                                    subtitle: "Skriv en vare og tryk Søg.",
                                    systemImage: "text.magnifyingglass"
                                )
                                .frame(height: 180)
                            }
                            .background(Theme.bg)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        } else {
                            VStack(spacing: 12) {
                                ForEach(app.searchResults, id: \.id) { product in
                                    ProductRow(product: product)
                                }
                            }
                        }

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline) // ← vigtig
        }
    }

    // MARK: Typeahead
    func updateSuggestions(for text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else {
            withAnimation { showSuggestions = false }
            suggestions = []
            return
        }

        // Kandidater: seed + nuværende resultater + navne fra liste + historik
        var pool = seedNames
        pool.append(contentsOf: app.searchResults.map { $0.name })
        pool.append(contentsOf: app.currentList.items.map { $0.product.name })
        app.history.forEach { h in
            pool.append(contentsOf: h.items.map { $0.product.name })
        }

        let norm = normalize(t)
        let unique = Array(Set(pool))
        suggestions = unique
            .filter { normalize($0).hasPrefix(norm) }
            .sorted()
            .prefix(8)
            .map { $0 }

        withAnimation { showSuggestions = !suggestions.isEmpty }
    }

    func normalize(_ s: String) -> String {
        s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}

// MARK: - Produkt-række (stylet)
struct ProductRow: View {
    @EnvironmentObject var app: AppState
    let product: Product

    var units: [String] {
        Array(Set(product.variants.map { $0.unit })).sorted()
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(Theme.text1)

                HStack(spacing: 12) {
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
                    .controlSize(.regular) // ← vigtig

                    Toggle(isOn: Binding(
                        get: { app.isOrganic[product.id] ?? (app.defaultVariant(for: product).organic) },
                        set: { app.toggleOrganic(for: product, value: $0) }
                    )) {
                        Text("Øko").foregroundColor(Theme.text1)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Theme.accent))
                    .controlSize(.regular) // ← vigtig
                    .frame(maxWidth: 90)
                }

                Button {
                    app.addToList(product: product)
                } label: {
                    Label("Læg i kurven", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButton())
                .controlSize(.regular) // ← vigtig
            }
        }
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
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 16) {
                    if app.currentList.items.isEmpty {
                        EmptyState(
                            title: "Tom indkøbsliste",
                            subtitle: "Tilføj varer fra Søg.",
                            systemImage: "cart"
                        )
                    } else {
                        // Liste
                        Card {
                            VStack(spacing: 10) {
                                ForEach(app.currentList.items) { item in
                                    HStack(alignment: .center) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.product.name)
                                                .font(.headline)
                                                .foregroundColor(Theme.text1)
                                            Text("\(item.variant.organic ? "Øko " : "")\(item.variant.unit)")
                                                .font(.subheadline)
                                                .foregroundColor(Theme.text2)
                                        }
                                        Spacer()
                                        HStack(spacing: 10) {
                                            Button {
                                                app.changeQty(itemID: item.id, delta: -1)
                                            } label: {
                                                Image(systemName: "minus.circle")
                                            }
                                            .tint(Theme.text1)

                                            Text("\(item.qty)")
                                                .frame(minWidth: 24)
                                                .foregroundColor(Theme.text1)
                                                .monospaced()

                                            Button {
                                                app.changeQty(itemID: item.id, delta: +1)
                                            } label: {
                                                Image(systemName: "plus.circle")
                                            }
                                            .tint(Theme.text1)
                                        }
                                    }

                                    if item.id != app.currentList.items.last?.id {
                                        Divider().background(Color.black.opacity(0.2))
                                    }
                                }
                            }
                        }

                        // Find billigst
                        Button {
                            handleFindCheapest()
                        } label: {
                            Label(isFinding ? "Søger…" : "Find billigst i nærheden",
                                  systemImage: "location.fill.viewfinder")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButton())
                        .controlSize(.regular) // ← vigtig
                        .disabled(isFinding)

                        // Resultat
                        if !results.isEmpty {
                            let cheapest = results[0]
                            let second   = results.count > 1 ? results[1] : nil
                            let savings  = second != nil ? max(0, second!.total - cheapest.total) : 0

                            Card {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("🏆 Billigst hos \(cheapest.storeName)")
                                        .font(.headline)
                                        .foregroundColor(Theme.text1)

                                    Text("Samlet pris: \(String(format: "DKK %.2f", cheapest.total))")
                                        .monospaced()
                                        .foregroundColor(Theme.text1)

                                    if let sec = second {
                                        Text("💸 Du sparer \(String(format: "DKK %.2f", savings)) i forhold til \(sec.storeName)")
                                            .font(.headline)
                                            .foregroundColor(Theme.success)
                                    }

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Butikker")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.text2)

                                        ForEach(results) { r in
                                            HStack {
                                                Text(r.storeName).foregroundColor(Theme.text1)
                                                Spacer()
                                                Text(String(format: "DKK %.2f", r.total))
                                                    .foregroundColor(Theme.text1)
                                                    .monospaced()
                                            }
                                        }
                                    }

                                    Button {
                                        app.commitCurrentListToHistory()
                                        results = []
                                    } label: {
                                        Label("Gem som handlet", systemImage: "archivebox")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.regular) // ← ens størrelse
                                    .tint(Theme.text1)
                                    .padding(.top, 4)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Indkøbsliste")
            .navigationBarTitleDisplayMode(.inline) // ← vigtig
            .alert("Lokation kræves", isPresented: $showLocationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Giv adgang til din lokation for at finde butikker i nærheden.")
            }
        }
    }

    // uændret logik
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
            ZStack {
                Theme.bg.ignoresSafeArea()

                if app.history.isEmpty {
                    EmptyState(
                        title: "Ingen historik endnu",
                        subtitle: "Når du markerer en liste som handlet, vises den her.",
                        systemImage: "clock"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(app.history) { list in
                                Card {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(list.createdAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(.subheadline)
                                            .foregroundColor(Theme.text2)

                                        ForEach(list.items) { item in
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(item.product.name)
                                                        .foregroundColor(Theme.text1)
                                                    Text("\(item.variant.organic ? "Øko " : "")\(item.variant.unit)")
                                                        .font(.caption)
                                                        .foregroundColor(Theme.text2)
                                                }
                                                Spacer()
                                                Text("x\(item.qty)")
                                                    .foregroundColor(Theme.text1)
                                            }

                                            if item.id != list.items.last?.id {
                                                Divider().background(Color.black.opacity(0.2))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Historik")
            .navigationBarTitleDisplayMode(.inline) // ← vigtig
        }
    }
}
