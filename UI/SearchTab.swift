import SwiftUI

struct SearchTab: View {
    @EnvironmentObject var app: AppState
    @State private var suggestions: [String] = []
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                // Indholdet
                List {
                    // RESULTATER
                    if !app.searchResults.isEmpty {
                        Section("Resultater") {
                            ForEach(app.searchResults, id: \.id) { product in
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(product.name)
                                            .font(.body.weight(.medium))
                                            .foregroundColor(.primary)
                                        Text(product.variants.first?.displayName ?? "")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
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
                                .contentShape(Rectangle())
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .contentMargins(.top, 64)   // plads til søgefeltet
                .scrollDismissesKeyboard(.immediately)

                // SØGEFELT + DROPDOWN
                VStack(spacing: 6) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)

                        TextField("Søg fx “banan”", text: $app.query)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .focused($isFocused)
                            .onChange(of: app.query) { updateSuggestions(for: $0) }
                            .onSubmit { app.runSearch() }

                        if !app.query.isEmpty {
                            Button {
                                app.query = ""
                                app.searchResults = []
                                suggestions = []
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6))
                            .strokeBorder(Color(.separator), lineWidth: 0.5)
                    )

                    // DROPDOWN – vis kun når der er tekst og ingen resultater endnu
                    if !suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(suggestions, id: \.self) { s in
                                Button {
                                    app.query = s
                                    isFocused = false
                                    app.runSearch()
                                    suggestions = []
                                } label: {
                                    HStack {
                                        Text(s)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                }
                                .buttonStyle(.plain)

                                if s != suggestions.last {
                                    Divider()
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 6, y: 2)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Søg")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
            .background(Color(.systemBackground))
        }
    }

    private func updateSuggestions(for text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { suggestions = []; return }
        let names = CatalogService.shared.all().map(\.name)
        suggestions = Array(
            names.filter { $0.localizedCaseInsensitiveContains(t) }
                 .prefix(8)
        )
    }
}