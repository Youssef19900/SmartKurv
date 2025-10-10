import SwiftUI

enum Theme {
    static let bgGradient = LinearGradient(
        colors: [
            Color(red: 0.08, green: 0.09, blue: 0.12),
            Color(red: 0.05, green: 0.07, blue: 0.10)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let bg: LinearGradient = Theme.bgGradient

    static let card    = Color(red: 0.11, green: 0.12, blue: 0.14)
    static let text1   = Color.white
    static let text2   = Color(red: 0.74, green: 0.75, blue: 0.77)
    static let accent  = Color(red: 0.05, green: 0.52, blue: 0.98)
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let warning = Color(red: 1.00, green: 0.75, blue: 0.15)

    // ➕ ADD THIS:
    static let divider = Color.white.opacity(0.08)
}

// Small convenience used in screens
extension View {
    func appBackground() -> some View {
        background(Theme.bgGradient.ignoresSafeArea())
    }
}
