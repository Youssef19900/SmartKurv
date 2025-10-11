import SwiftUI

struct HistoryTab: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                if app.history.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 64, weight: .regular))
                            .foregroundStyle(Theme.text2)
                        Text("Ingen historik endnu")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Theme.text1)
                        Text("Når du fuldfører en liste, dukker den op her.")
                            .foregroundStyle(Theme.text2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        Spacer()
                    }
                } else {
                    List {
                        Section("Fuldførte lister") {
                            ForEach(app.history) { entry in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.title)
                                        .font(.headline)
                                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.text2)
                                }
                                .listRowBackground(Theme.card)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Historik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Theme.bg, for: .navigationBar)
        }
    }
}