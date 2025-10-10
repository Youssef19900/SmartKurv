import SwiftUI

enum Theme {
    // Baggrund (lys)
    static let bgColor = Color(.systemBackground)
    static let bgGradient = LinearGradient(
        colors: [bgColor, bgColor.opacity(0.98)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let bg: LinearGradient = bgGradient

    // Overflader
    static let card    = Color(.secondarySystemBackground)
    static let divider = Color(.separator)

    // Tekst
    static let text1   = Color.primary
    static let text2   = Color.secondary

    // Aksent
    static let accent  = Color.systemBlue
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let warning = Color(red: 1.00, green: 0.75, blue: 0.15)
}

extension View {
    @ViewBuilder
    func appBackground() -> some View {
        background(Theme.bgGradient.ignoresSafeArea())
    }

    @ViewBuilder
    func cardContainer(corner: CGFloat = 14) -> some View {
        padding(14)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(Theme.divider)
            )
    }
}