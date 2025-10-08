import SwiftUI

struct HistoryTab: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            List {
                ForEach(app.history) { list in
                    Section(header: Text(list.createdAt, style: .date)) {
                        ForEach(list.items) { item in
                            HStack {
                                Text(item.product.name)
                                Spacer()
                                Text("x\(item.qty)")
                                    .foregroundStyle(Theme.text2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Historik")
            .toolbar(content: historyToolbar)   // <- eksplicit content-funktion
        }
        .background(Theme.bgGradient.ignoresSafeArea())
    }

    // Gør det tydeligt for compileren at dette er ToolbarContent
    @ToolbarContentBuilder
    private func historyToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            CartBadgeButton()
        }
    }
}
