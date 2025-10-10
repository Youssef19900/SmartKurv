import SwiftUI

struct SearchTab: View {
    @EnvironmentObject var app: AppState
    @State private var suggestions: [String] = []

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {

                // Søgefelt
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Theme.text2)

                    TextField("Søg fx “banan”", text: $app.query)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .font(.body)
                        .onChange(of: app.query) { newValue in   // <- brug denne signatur
                            updateSuggestions(for: newValue)
                        }
                        .onSubmit { app.runSearch() }

                    if !app.query.isEmpty {
                        Button {
                            app.query = ""
                            app.searchResults = []
                            suggestions = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Theme.text2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(14)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Find billigst (kalder AppState)
                Button {
                    Task { await app.findCheapestNearby() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkle.magnifyingglass")
                        Text("Sammenlign priser i nærheden")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(app.isFindingCheapest || app.currentList.items.isEmpty)
                .padding(.horizontal, 16)
                .padding(.top, 4)

                // Resultater / billigst / forslag
                List {
                    if app.isFindingCheapest {
                        Section {
                            HStack {
                                ProgressView("Beregner…")
                                Spacer()
                            }
                        } header: {
                            Text("Billigst i nærheden").foregroundStyle(Theme.text2)
                        }
                    } else if !app.cheapest.isEmpty {
                        Section {
                            ForEach(app.cheapest, id: \.storeName) { t in
                                HStack {
                                    Text(t.storeName)
                                    Spacer()
                                    Text(String(format: "%.2f kr", t.total)).font(.headline)
                                }
                                .padding(.vertical, 4)
                            }
                        } header: {
                            Text("Billigst i nærheden").foregroundStyle(Theme.text2)
                        }
                    } else if let msg = app.errorMessage {
                        Section {
                            Text(msg).foregroundStyle(Theme.text2)
                        } header: {
                            Text("Billigst i nærheden").foregroundStyle(Theme.text2)
                        }
                    }

                    if !suggestions.isEmpty && app.searchResults.isEmpty {
                        Section("Forslag") {
                            ForEach(suggestions, id: \.self) { s in
                                Button {
                                    app.query = s
                                    app.runSearch()
                                } label: { Text(s) }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Section("Resultater") {
                        ForEach(app.searchResults, id: \.id) { product in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(product.name).font(.headline)
                                    Text(product.variants.first?.displayName ?? "")
                                        .font(.subheadline).foregroundStyle(Theme.text2)
                                }
                                Spacer()
                                Button {
                                    let v = app.defaultVariant(for: product)
                                    app.addToList(product: product, variant: v)
                                } label: {
                                    Image(systemName: "plus.circle.fill").font(.title3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .listStyle(.plain)                   // mere kompakt
                .scrollContentBackground(.hidden)
            }
            .appBackground()
            .navigationTitle("Søg")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
        }
    }

    private func updateSuggestions(for text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { suggestions = []; return }
        let names = CatalogService.shared.all().map(\.name)
        suggestions = names.filter { $0.localizedCaseInsensitiveContains(t) }
                           .prefix(5).map { $0 }
    }
}