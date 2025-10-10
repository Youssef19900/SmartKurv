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
                // Ikon
                Image(systemName: "cart.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Theme.accent)
                    .imageScale(.large)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(Theme.card.opacity(0.6))
                            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                    )

                // Badge
                if count > 0 {
                    Text(badgeText)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.4), radius: 3, x: 1, y: 1)
                        .offset(x: 10, y: -8)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: count)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Indkøbskurv med \(badgeText) varer")
    }
}
