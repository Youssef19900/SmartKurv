import SwiftUI

struct SearchTab: View {
    @EnvironmentObject var app: AppState
    @State private var suggestions: [String] = []
    @State private var showDropdown = false

    var body: some View {
        VStack(spacing: 12) {
            // SEARCH FIELD
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Theme.text2)

                    TextField("Søg fx “banan”", text: $app.query)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .onChange(of: app.query) { updateSuggestions(for:) }
                        .onSubmit { showDropdown = false; app.runSearch() }
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
                .padding(.horizontal, 14).frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(Theme.card)
                )

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
                                    Text(s).foregroundStyle(Theme.text1)
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                            }
                            .buttonStyle(.plain)

                            if s != suggestions.last { Divider() }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12).fill(Theme.card)
                            .shadow(radius: 4, y: 2)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8) // small, so the field hugs the nav bar

            // RESULTS (plain list, dark header)
            List {
                Section {
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
                } header: {
                    Text("RESULTATER")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.black)   // strong header
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
        }
        .navigationTitle("Søg")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CartBadgeButton()
            }
        }
        .appBackground()
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