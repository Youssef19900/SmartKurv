import SwiftUI

struct SearchTab: View {
    @EnvironmentObject var app: AppState
    @State private var suggestions: [String] = []
    @State private var showSuggestions = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Baggrund
                Color.clear.appBackground()

                VStack(alignment: .leading, spacing: 10) {

                    // Søgefelt
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Theme.text2)

                        TextField("Søg fx “banan”", text: $app.query)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .font(.body)
                            .onChange(of: app.query) { newValue in
                                updateSuggestions(for: newValue)
                            }
                            .onTapGesture { showSuggestions = !suggestions.isEmpty }
                            .onSubmit {
                                showSuggestions = false
                                app.runSearch()
                            }

                        if !app.query.isEmpty {
                            Button {
                                app.query = ""
                                app.searchResults = []
                                suggestions = []
                                showSuggestions = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Theme.text2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Theme.divider)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 6)

                    // Resultater
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
                                        Image(systemName: "plus.circle.fill").font(.title3)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .listRowBackground(Theme.card)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
                .padding(.bottom, 8)

                // DROPDOWN – suggestions under feltet
                if showSuggestions && !suggestions.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(suggestions, id: \.self) { s in
                            Button {
                                app.query = s
                                showSuggestions = false
                                app.runSearch()
                            } label: {
                                HStack {
                                    Text(s).foregroundStyle(Theme.text1)
                                    Spacer()
                                }
                                .padding(.horizontal, 14).padding(.vertical, 10)
                            }
                            Divider().background(Theme.divider)
                        }
                    }
                    .background(.white) // dropdowns er typisk helt hvide
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.top, 66) // lige under søgefeltet
                    .onTapGesture { } // så taps ikke går videre
                }
            }
            .navigationTitle("Søg")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { CartBadgeButton() }
            }
        }
    }

    private func updateSuggestions(for text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { suggestions = []; showSuggestions = false; return }

        let names = CatalogService.shared.all().map(\.name)
        let list = names.filter { $0.localizedCaseInsensitiveContains(t) }
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            .prefix(8)

        suggestions = Array(list)
        showSuggestions = !suggestions.isEmpty
    }
}