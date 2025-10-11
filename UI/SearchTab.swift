import SwiftUI

struct SearchTab: View {
    @EnvironmentObject var app: AppState
    @State private var suggestions: [String] = []
    @State private var showDropdown = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Theme.bg.ignoresSafeArea()
                    .onTapGesture { showDropdown = false } // luk ved tryk i baggrunden

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
                // Saml knapper i en gruppe, så begge vises
                if #available(iOS 17.5, *) {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        AIFindCheapestButton()
                        CartBadgeButton()
                    }
                } else {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        AIFindCheapestButton()
                        CartBadgeButton()
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Theme.bg, for: .navigationBar)
        }
        // Sheet til AI-resultater
        .sheet(isPresented: $app.aiSheetOpen) {
            AISuggestionsSheet().environmentObject(app)
        }
    }

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

// MARK: - “Find billigst (AI)” knap
private struct AIFindCheapestButton: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        Button {
            Task { await app.findCheapest(query: app.query) }
        } label: {
            HStack(spacing: 6) {
                if app.isFindingCheapest {
                    ProgressView()
                }
                Image(systemName: "bolt.badge.a")
                Text("Find billigst")
            }
        }
        .disabled(app.isFindingCheapest || app.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
}

// MARK: - Sheet til AI-forslag
private struct AISuggestionsSheet: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            List {
                if app.aiSuggestions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bolt.slash")
                            .imageScale(.large)
                            .font(.system(size: 36))
                            .foregroundStyle(.secondary)
                        Text("Ingen forslag")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .listRowSeparator(.hidden)
                } else {
                    Section("Billigste fundet") {
                        ForEach(app.aiSuggestions) { s in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(s.itemName)
                                        .font(.headline)
                                    Text(s.bestStore)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    if let note = s.note, !note.isEmpty {
                                        Text(note)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Text(String(format: "%.2f kr.", s.price))
                                    .font(.headline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("AI – Find billigst")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Luk") { app.aiSheetOpen = false }
                }
            }
        }
    }
}