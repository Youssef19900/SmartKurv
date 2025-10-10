import SwiftUI

struct HistoryTab: View {
    @EnvironmentObject var app: AppState

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
                                ForEach(list.items) { item in
                                    HStack(spacing: 12) {
                                        Text(item.product.name)
                                            .font(.headline)
                                            .foregroundStyle(Theme.text1)
                                        Spacer()
                                        Text("x\(item.qty)")
                                            .font(.headline)
                                            .foregroundStyle(Theme.text2)
                                    }
                                    .listRowBackground(Theme.card)
                                }
                            } header: {
                                HStack {
                                    Text(list.createdAt, style: .date)
                                    Spacer()
                                    Text("\(list.items.count) varer")
                                }
                                .foregroundStyle(Theme.text2)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .appBackground()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Historik")
                        .font(.title2.bold())
                        .foregroundStyle(Theme.text1)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
