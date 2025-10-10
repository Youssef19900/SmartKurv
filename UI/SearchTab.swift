import SwiftUI

struct SearchTab: View {
    @EnvironmentObject var app: AppState
    @State private var suggestions: [String] = []

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {

                // SØGEFELT HELT I TOPPEN
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Theme.text2)

                    TextField("Søg fx “banan”", text: $app.query)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .font(.body)
                        .onChange(of: app.query) { updateSuggestions(for:) }
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
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Theme.divider)
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // KNAP: FIND BILLIGST INDEN FOR 2 KM
                Button {
                    Task { await app.findCheapestNearby() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkle.magnifyingglass")
                        Text("Find billigst inden for 2 km")
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

                // RESULTATER / SUGGESTIONS / BILLIGST
                List {
                    // BILLIGST-SEKTION (progress / resultater / fejl)
                    if app.isFindingCheapest {
                        Section {
                            HStack {
                                ProgressView("Beregner…")
                                Spacer()
                            }
                            .listRowBackground(Theme.card)
                        } header: {
                            Text("Billigst i nærheden")
                                .foregroundStyle(Theme.text2)
                        }
                    } else if !app.cheapest.isEmpty {
                        Section {
                            ForEach(app.cheapest, id: \.storeName) { t in
                                HStack {
                                    Text(t.storeName)
                                        .foregroundStyle(Theme.text1)
                                    Spacer()
                                    Text(String(format: "%.2f kr", t.total))
                                        .font(.headline)
                                        .foregroundStyle(Theme.text1)
                                }
                                .padding(.vertical, 4)
                                .listRowBackground(Theme.card)
                            }
                        } header: {
                            Text("Billigst i nærheden")
                                .foregroundStyle(Theme.text2)
                        }
                    } else if let msg = app.errorMessage {
                        Section {
                            Text(msg)
                                .foregroundStyle(Theme.text2)
                                .listRowBackground(Theme.card)
                        } header: {
                            Text("Billigst i nærheden")
                                .foregroundStyle(Theme.text2)
                        }
                    }

                    // FORSLAG (kun når der ingen søgningeresultater er)
                    if !suggestions.isEmpty && app.searchResults.isEmpty {
                        Section("Forslag") {
                            ForEach(suggestions, id: \.self) { s in
                                Button {
                                    app.query = s
                                    app.runSearch()
                                } label: {
                                    Text(s).foregroundStyle(Theme.text1)
                                }
                                .listRowBackground(Theme.card)
                            }
                        }
                    }

                    // SØGERESULTATER
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
                .scrollContentBackground(.hidden) // mørk baggrund
            }
            .appBackground()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Søg")
                        .font(.title2.bold())             // mindre end default kæmpe-titel
                        .foregroundStyle(Theme.text1)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()                    // badge-knap
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func updateSuggestions(for text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { suggestions = []; return }

        // enkel autocomplete: top 5 der matcher
        let names = CatalogService.shared.all().map(\.name)
        suggestions = names
            .filter { $0.localizedCaseInsensitiveContains(t) }
            .prefix(5)
            .map { $0 }
    }
}
