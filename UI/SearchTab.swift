import SwiftUI

struct SearchTab: View {
    @EnvironmentObject var app: AppState
    @State private var suggestions: [String] = []
    @State private var showDropdown = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {

                // Lys baggrund – sikker for iOS 16
                Color.white.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {

                    // MARK: Søgefelt helt i toppen
                    ZStack(alignment: .topLeading) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)

                            TextField("Søg fx “banan”", text: $app.query)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .font(.body)
                                .foregroundColor(.black)
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
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(14)
                        // iOS 16-kompatibel "card" + kant
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(white: 0.96))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color(white: 0.88), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                        // MARK: Dropdown med forslag
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
                                                .foregroundColor(.black)
                                                .padding(.vertical, 10)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 12)
                                    }
                                    .buttonStyle(.plain)

                                    if s != suggestions.last {
                                        Divider()
                                            .background(Color(white: 0.88))
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(white: 0.96))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color(white: 0.88), lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 72) // Lige under søgefeltet
                            .shadow(radius: 6)
                        }
                    }

                    // MARK: Resultater
                    List {
                        Section(header:
                            Text("Resultater")
                                .foregroundColor(.gray)
                        ) {
                            ForEach(app.searchResults, id: \.id) { product in
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.name)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        Text(product.variants.first?.displayName ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
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
                                .listRowBackground(Color(white: 0.96))
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden) // bevar hvid baggrund
                }
            }
            .navigationTitle("Søg")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {                           // Entydig toolbar – ingen ambiguitet
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
        }
        .tint(.blue) // iOS16-sikker (undgå .systemBlue)
    }

    // MARK: - Hjælpere
    private func updateSuggestions(for text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else {
            suggestions = []
            showDropdown = false
            return
        }

        // Enkel autocomplete: top 6 der matcher
        let names = CatalogService.shared.all().map(\.name)
        suggestions = names
            .filter { $0.localizedCaseInsensitiveContains(t) }
            .prefix(6)
            .map { $0 }

        showDropdown = !suggestions.isEmpty
    }
}