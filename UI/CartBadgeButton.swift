import SwiftUI

struct CartBadgeButton: View {
    @EnvironmentObject var app: AppState
    var action: () -> Void = {}

    private var count: Int {
        min(app.currentList.items.reduce(0) { $0 + $1.qty }, 100)
    }
    private var badgeText: String {
        let total = app.currentList.items.reduce(0) { $0 + $1.qty }
        return total > 100 ? "100+" : "\(total)"
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "cart")
                    .imageScale(.large)

                if count > 0 {
                    Text(badgeText)
                        .font(.caption2).bold()
                        .padding(4)
                        .background(.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .offset(x: 8, y: -8)
                }
            }
        }
        .accessibilityLabel("Indkøbskurv \(badgeText) varer")
    }
}
