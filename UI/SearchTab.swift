import SwiftUI

struct SearchTab: View {
    @EnvironmentObject var app: AppState
    @State private var suggestions: [String] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // SØGEFELT I TOPPEN
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                    TextField("Søg fx “banan”", text: $app.query)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .onChange(of: app.query) { newValue in
                            updateSuggestions(for: newValue)
                        }
                        .onSubmit {
                            app.runSearch()
                        }
                    if !app.query.isEmpty {
                        Button {
                            app.query = ""
                            app.searchResults = []
                            suggestions = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding([.horizontal, .top])

                // RESULTATER / SUGGESTIONS
                List {
                    if suggestions.count > 0 && app.searchResults.isEmpty {
                        Section("Forslag") {
                            ForEach(suggestions, id: \.self) { s in
                                Button(s) {
                                    app.query = s
                                    app.runSearch()
                                }
                            }
                        }
                    }

                    Section("Resultater") {
                        ForEach(app.searchResults, id: \.id) { product in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(product.name)
                                        .font(.headline)
                                    Text(product.variants.first?.displayName ?? "")
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.text2)
                                }
                                Spacer()
                                Button {
                                    let variant = app.defaultVariant(for: product)
                                    app.addToList(product: product, variant: variant)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .imageScale(.large)
                                }
                                .buttonStyle(.plain)
                            }
                            .contentShape(Rectangle())
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Søg")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
        }
        .background(Theme.bgGradient.ignoresSafeArea())
    }

    private func updateSuggestions(for text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { suggestions = []; return }
        // Meget simpel “autocomplete”: tag de første 5 fra katalog der matcher
        let names = CatalogService.shared.all().map(\.name)
        suggestions = names
            .filter { $0.localizedCaseInsensitiveContains(t) }
            .prefix(5)
            .map { $0 }
    }
}
