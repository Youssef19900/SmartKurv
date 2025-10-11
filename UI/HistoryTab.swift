import SwiftUI

struct HistoryTab: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                // Vis noget enkelt for nu (for at passere compile):
                VStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 36))
                        .foregroundStyle(Theme.text2)
                    Text("Historik")
                        .font(.headline)
                        .foregroundStyle(Theme.text1)
                    Text("Dine tidligere indkøb vises her.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.text2)
                }
                .padding()
            }
            .navigationTitle("Historik")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartBadgeButton()
                }
            }
        }
    }
}