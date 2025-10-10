import SwiftUI

enum Theme {
    // Lys baggrund
    static let bgGradient = LinearGradient(
        colors: [Color.white, Color(white: 0.98)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let bg: LinearGradient = bgGradient

    // Overflader
    static let card    = Color(white: 0.96)
    static let divider = Color(white: 0.88)

    // Tekst
    static let text1   = Color.black
    static let text2   = Color(white: 0.45)

    // Aksent
    static let accent  = Color(red: 0.05, green: 0.52, blue: 0.98)
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let warning = Color(red: 1.00, green: 0.75, blue: 0.15)
}

// Genbrugelige ting
extension View {
    func appBackground() -> some View {
        background(Theme.bgGradient.ignoresSafeArea())
    }
    func cardContainer(corner: CGFloat = 14) -> some View {
        padding(14)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous).stroke(Theme.divider)
            )
    }
}