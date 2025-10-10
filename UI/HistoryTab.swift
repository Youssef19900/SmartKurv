import SwiftUI

struct HistoryTab: View {
    @EnvironmentObject var app: AppState
    @State private var expanded: Set<UUID> = []   // hvilke lister er foldet ud

    var body: some View {
        NavigationStack {
            Group {
                if app.history.isEmpty {
                    // TOM-STATE
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 44))
                            .foregroundStyle(Theme.text2)
                        Text("Ingen historik endnu")
                            .font(.headline)
                            .foregroundStyle(Theme.text2)
                        Text("Når du fuldfører en liste, dukker den op her.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.text2.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // LISTE
                    List {
                        ForEach(app.history) { list in
                            Section {
                                // "Forside" på historik-kortet
                                Button {
                                    toggle(list.id)
                                } label: {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(list.createdAt, style: .date)
                                                .font(.subheadline)
                                                .foregroundStyle(Theme.text2)

                                            HStack(spacing: 10) {
                                                // Estimeret total
                                                Text(formatKr(app.totalForHistory(list)))
                                                    .font(.headline)
                                                    .foregroundStyle(Theme.text1)

                                                // Estimeret besparelse
                                                let saving = app.savingsForHistory(list)
                                                if saving > 0.0 {
                                                    Text("− \(formatKr(saving))")
                                                        .font(.subheadline.weight(.semibold))
                                                        .foregroundStyle(Theme.success)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .fill(Theme.card)
                                                        )
                                                }
                                            }
                                        }
                                        Spacer()

                                        // Pil op/ned
                                        Image(systemName: expanded.contains(list.id) ? "chevron.up" : "chevron.down")
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(Theme.text2)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Theme.card)

                                // Detaljer (foldes ud)
                                if expanded.contains(list.id) {
                                    ForEach(list.items) { item in
                                        HStack(spacing: 12) {
                                            Text(item.product.name)
                                                .foregroundStyle(Theme.text1)
                                            Spacer()
                                            Text("x\(item.qty)")
                                                .foregroundStyle(Theme.text2)
                                        }
                                        .listRowBackground(Theme.card)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .appBackground()
            .navigationTitle("Historik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
        }
    }

    private func toggle(_ id: UUID) {
        if expanded.contains(id) { expanded.remove(id) } else { expanded.insert(id) }
    }

    private func formatKr(_ value: Double) -> String {
        String(format: "%.2f kr", value)
    }
}