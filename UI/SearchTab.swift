import SwiftUI

struct SearchTab: View {
    @State private var query = ""
    @State private var results: [Product] = []
    @State private var selectedProduct: Product?
    @State private var selectedVariant: ProductVariant?
    @State private var isOrganic = false

    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Theme.bgGradient.ignoresSafeArea()   // 👈 Baggrundsfarve

            VStack(spacing: 20) {

                // MARK: - Header med titel + kurv badge
                HStack {
                    Text("Søg")
                        .font(.largeTitle.bold())
                        .foregroundColor(Theme.text1)

                    Spacer()

                    // Kurv med antal varer
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.accent)

                        if appState.currentList.items.count > 0 {
                            Text("\(appState.currentList.items.count)")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Circle().fill(Theme.accent))
                                .offset(x: 8, y: -8)
                        }
                    }
                }
                .padding(.horizontal)

                // MARK: - Søgning
                HStack {
                    TextField("Søg efter vare...", text: $query)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .onSubmit { performSearch() }

                    Button("Søg") { performSearch() }
                        .buttonStyle(PrimaryButton())
                        .frame(width: 80)
                }

                // MARK: - Resultater
                if let product = selectedProduct {
                    VStack(spacing: 12) {
                        Text(product.name)
                            .font(.title3.bold())
                            .foregroundColor(Theme.text1)

                        Picker("Enhed", selection: Binding(
                            get: { selectedVariant?.unit ?? "" },
                            set: { unit in
                                selectedVariant = product.variants.first { $0.unit == unit && $0.organic == isOrganic }
                            }
                        )) {
                            ForEach(product.variants.filter { $0.organic == isOrganic }, id: \.unit) { variant in
                                Text(variant.unit.uppercased()).tag(variant.unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        Toggle("Øko", isOn: $isOrganic)
                            .toggleStyle(SwitchToggleStyle(tint: Theme.accent))
                            .padding(.horizontal)
                            .onChange(of: isOrganic) { _ in
                                if let p = selectedProduct {
                                    selectedVariant = p.variants.first { $0.unit == selectedVariant?.unit && $0.organic == isOrganic }
                                }
                            }

                        Button {
                            if let product = selectedProduct, let variant = selectedVariant {
                                appState.addToList(product: product, variant: variant)
                            }
                        } label: {
                            Label("Læg i kurven", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(PrimaryButton())
                        .padding(.horizontal)
                    }
                    .transition(.opacity)
                } else {
                    Spacer()
                }

                Spacer()
            }
            .padding(.top, 20)
        }
    }

    // MARK: - Handling
    private func performSearch() {
        let matches = CatalogService.shared.search(query)
        results = matches
        selectedProduct = matches.first
        selectedVariant = matches.first?.variants.first
    }
}
