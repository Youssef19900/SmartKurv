import SwiftUI

struct SearchTab: View {
    @EnvironmentObject var app: AppState
    @State private var suggestions: [String] = []
    @State private var showDropdown = false
    @State private var showCheapestSheet = false     // <- sheet til AI-resultater

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Theme.bg.ignoresSafeArea()
                    .onTapGesture { showDropdown = false }

                VStack(alignment: .leading, spacing: 16) {

                    // SØGEFELT
                    ZStack(alignment: .topLeading) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Theme.text2)

                            TextField("Søg fx “banan”", text: $app.query)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .font(.body)
                                .onChange(of: app.query) { updateSuggestions(for: $0) }
                                .onSubmit {
                                    showDropdown = false
                                    app.runSearch()
                                }
                                .onTapGesture { showDropdown = true }

                            if !app.query.isEmpty {
                                Button {
                                    app.query = ""
                                    app.searchResults = []
                                    suggestions = []
                                    showDropdown = false
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Theme.text2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(14)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Theme.divider, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                        // DROPDOWN
                        if showDropdown && !suggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(suggestions.indices, id: \.self) { i in
                                    let s = suggestions[i]
                                    Button {
                                        app.query = s
                                        showDropdown = false
                                        app.runSearch()
                                    } label: {
                                        HStack {
                                            Text(s)
                                                .foregroundStyle(Theme.text1)
                                                .padding(.vertical, 10)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 12)
                                    }
                                    .buttonStyle(.plain)

                                    if i < suggestions.count - 1 {
                                        Divider().background(Theme.divider)
                                    }
                                }
                            }
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Theme.divider, lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 72)
                            .shadow(radius: 6)
                            .zIndex(1)
                            .transition(.opacity.combined(with: .scale))
                        }
                    }

                    // RESULTATER
                    if app.searchResults.isEmpty {
                        Text("RESULTATER")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Theme.text2)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)

                        Spacer(minLength: 0)
                    } else {
                        List {
                            Section("Resultater") {
                                ForEach(app.searchResults, id: \.id) { product in
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(product.name)
                                                .font(.headline)
                                                .foregroundStyle(Theme.text1)
                                            Text(product.variants.first?.displayName ?? "")
                                                .font(.subheadline)
                                                .foregroundStyle(Theme.text2)
                                        }
                                        Spacer()
                                        Button {
                                            let v = app.defaultVariant(for: product)
                                            app.addToList(product: product, variant: v)
                                        } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.title3)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .listRowBackground(Theme.card)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Søg")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Begge knapper i højre side
                if #available(iOS 17.5, *) {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        aiButton
                        CartBadgeButton()
                    }
                } else {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        aiButton
                        CartBadgeButton()
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Theme.bg, for: .navigationBar)
        }
        // Sheet med AI-resultater/fejl
        .sheet(isPresented: $showCheapestSheet) {
            CheapestResultsSheet()
                .environmentObject(app)
        }
    }

    // MARK: - “Find billigst (AI)” knap
    private var aiButton: some View {
        Button {
            Task {
                await app.findCheapestNearby()
                showCheapestSheet = true
            }
        } label: {
            HStack(spacing: 6) {
                if app.isFindingCheapest { ProgressView() }
                Image(systemName: "bolt.badge.a")
                Text("Find billigst")
            }
        }
        .disabled(app.isFindingCheapest || app.currentList.items.isEmpty)
    }

    // MARK: - Hjælpere
    private func updateSuggestions(for text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { suggestions = []; showDropdown = false; return }
        let names = CatalogService.shared.all().map(\.name)
        suggestions = names
            .filter { $0.localizedCaseInsensitiveContains(t) }
            .prefix(6)
            .map { $0 }
        showDropdown = !suggestions.isEmpty
    }
}

// MARK: - Sheet der viser resultater fra AppState.cheapest
private struct CheapestResultsSheet: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            Group {
                if let msg = app.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 42))
                            .foregroundStyle(.orange)
                        Text(msg)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(Theme.bg)
                } else if app.cheapest.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bolt.slash")
                            .font(.system(size: 42))
                            .foregroundStyle(.secondary)
                        Text("Ingen priser fundet i nærheden.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(Theme.bg)
                } else {
                    List {
                        Section("Billigste butikker") {
                            ForEach(app.cheapest.indices, id: \.self) { i in
                                let row = app.cheapest[i]
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(storeName(row))
                                            .font(.headline)
                                        if let d = distance(row) {
                                            Text(String(format: "%.0f m væk", d))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Text(priceString(row))
                                        .font(.headline)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("AI – Find billigst")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Luk") { /* sheet lukkes udefra */ }
                }
            }
        }
    }

    // MARK: - Reflection: træk felter ud uden at kende præcis model
    private func storeName(_ any: Any) -> String {
        if let m = Mirror(reflecting: any).children.first(where: {
            ["storeName","name","chain","store","merchant"].contains($0.label ?? "")
        }), let s = m.value as? String {
            return s
        }
        return "Butik"
    }

    private func distance(_ any: Any) -> Double? {
        if let m = Mirror(reflecting: any).children.first(where: {
            ["distance","distanceMeters","meters"].contains($0.label ?? "")
        }), let v = m.value as? Double {
            return v
        }
        return nil
    }

    private func priceString(_ any: Any) -> String {
        if let m = Mirror(reflecting: any).children.first(where: {
            ["total","price","sum","totalPrice"].contains($0.label ?? "")
        }), let v = m.value as? Double {
            return String(format: "%.2f kr.", v)
        }
        return "–"
    }
}