import SwiftUI

struct SearchTab: View {
    @EnvironmentObject var app: AppState
    @State private var suggestions: [String] = []
    @State private var showDropdown = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Theme.bgGradient.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {

                    // SØGEFELT HELT I TOPPEN
                    ZStack(alignment: .topLeading) {
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
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Theme.card)
                                .stroke(Theme.divider)
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                        // DROPDOWN (autocomplete)
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
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Theme.card)
                                    .stroke(Theme.divider)
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 72) // lige under søgefeltet
                            .shadow(radius: 6)
                        }
                    }

                    // RESULTATER
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
            .navigationTitle("Søg")
            .navigationBarTitleDisplayMode(.inline)
            // 🔧 iOS16-safe: undgår .toolbar-ambiguity
            .navigationBarItems(trailing: CartBadgeButton())
        }
    }

    private func updateSuggestions(for text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { suggestions = []; showDropdown = false; return }

        // enkel autocomplete: top 6 der matcher – vis med det samme
        let names = CatalogService.shared.all().map(\.name)
        suggestions = names
            .filter { $0.localizedCaseInsensitiveContains(t) }
            .prefix(6)
            .map { $0 }
        showDropdown = !suggestions.isEmpty
    }
}