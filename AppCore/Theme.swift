import SwiftUI

enum Theme {
    // Baggrund (lys)
    static let bgGradient = LinearGradient(
        colors: [
            Color(.systemBackground),
            Color(.secondarySystemBackground)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Overflader
    static let card    = Color(.secondarySystemBackground)
    static let divider = Color(.separator)

    // Tekst
    static let text1   = Color.primary
    static let text2   = Color.secondary

    // Farver
    static let accent  = Color.blue
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let warning = Color(red: 1.00, green: 0.75, blue: 0.15)
}

// Genbrugelige modifiers
extension View {
    func appBackground() -> some View {
        background(Theme.bgGradient.ignoresSafeArea())
    }

    func cardContainer(corner: CGFloat = 14) -> some View {
        padding(14)
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(Theme.divider)
            )
    }
}
