import SwiftUI
import CoreLocation

struct ShoppingListTab: View {
    @EnvironmentObject var app: AppState
    @StateObject private var loc = LocationManager()

    var body: some View {
        NavigationView {
            VStack {
                if app.currentList.items.isEmpty {
                    ContentUnavailableView(
                        "Tom indkøbsliste",
                        systemImage: "cart",
                        description: Text("Tilføj varer fra Søg-fanen")
                    )
                    .padding()
                } else {
                    List {
                        ForEach(app.currentList.items) { item in
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.product.name)
                                        .font(.headline)
                                    Text(item.variant.displayName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    if let ean = item.variant.ean {
                                        Label("EAN \(ean)", systemImage: "bolt.fill")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("Estimeret pris")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Stepper(value: binding(for: item).qty, in: 1...99) {
                                    Text("\(binding(for: item).wrappedValue.qty)")
                                        .monospacedDigit()
                                }
                                .labelsHidden()
                            }
                            .padding(.vertical, 2)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.insetGrouped)
                }

                // Find billigst-knap + resultater
                VStack(spacing: 10) {
                    Button {
                        Task { await app.findCheapest(location: loc.lastLocation) }
                    } label: {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text("Find billigst i nærheden")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(app.currentList.items.isEmpty)

                    if app.isFindingCheapest {
                        ProgressView().padding(.bottom, 4)
                    }

                    if !app.cheapest.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Billigste butikker").font(.headline)
                            ForEach(app.cheapest) { t in
                                HStack {
                                    Text(t.storeName)
                                    Spacer()
                                    Text(String(format: "kr. %.2f", t.total))
                                        .monospacedDigit()
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 6)
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Indkøb")
            .navigationBarTitleDisplayMode(.inline) // mindre titel
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CartBadgeButton()
                        .environmentObject(app) // badge med antal varer
                }
            }
        }
    }

    // MARK: - Helpers

    private func binding(for item: ShoppingItem) -> Binding<ShoppingItem> {
        guard let idx = app.currentList.items.firstIndex(of: item) else {
            return .constant(item)
        }
        return $app.currentList.items[idx]
    }

    private func delete(at offsets: IndexSet) {
        app.currentList.items.remove(atOffsets: offsets)
    }
}

#if DEBUG
struct ShoppingListTab_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListTab().environmentObject(AppState())
    }
}
#endif
