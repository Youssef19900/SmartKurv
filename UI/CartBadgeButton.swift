import SwiftUI

struct CartBadgeButton: View {
    @EnvironmentObject var app: AppState
    var size: CGFloat = 30                   // total cirkel-diameter (ændr her)
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
                // Ikon + baggrund
                Image(systemName: "cart.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Theme.accent)
                    .font(.system(size: size * 0.56, weight: .semibold))   // skaler ikon
                    .frame(width: size, height: size)
                    .background(
                        Circle()
                            .fill(Theme.card.opacity(0.65))
                            .shadow(color: .black.opacity(0.25), radius: size * 0.15, y: size * 0.06)
                    )

                // Badge
                if count > 0 {
                    Text(badgeText)
                        .font(.system(size: max(10, size * 0.36), weight: .bold, design: .rounded))
                        .padding(.horizontal, max(5, size * 0.18))
                        .padding(.vertical, max(2, size * 0.08))
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.35), radius: size * 0.12, x: 1, y: 1)
                        .offset(x: size * 0.33, y: -size * 0.28)             // skaler offset
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: count)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Indkøbskurv med \(badgeText) varer")
    }
}