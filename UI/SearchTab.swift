import SwiftUI

struct SearchTab: View {
    @EnvironmentObject var app: AppState
    @State private var suggestions: [String] = []
    @State private var showDropdown = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Theme.bg.ignoresSafeArea()

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
                                ForEach(suggestions, id: \.self) { s in
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

                                    if s != suggestions.last {
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
                // Fallback så det virker på iOS < 17
                if #available(iOS 17.0, *) {
                    ToolbarItem(placement: .topBarTrailing) {
                        CartBadgeButton()
                    }
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        CartBadgeButton()
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Theme.bg, for: .navigationBar)
        }
    }

    private func updateSuggestions(for text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { suggestions = []; showDropdown = false; return }
        let names = CatalogService.shared.all().map(\.name)
        suggestions = names.filter { $0.localizedCaseInsensitiveContains(t) }
                           .prefix(6).map { $0 }
        showDropdown = !suggestions.isEmpty
    }
}