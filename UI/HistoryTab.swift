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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
        }
        .background(Theme.bgGradient.ignoresSafeArea())
    }
}
