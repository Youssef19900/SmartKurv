enum Theme {
    static let bg = Color(.systemBackground)               // pure app background
    static let card = Color(.secondarySystemBackground)
    static let divider = Color(.separator)

    static let text1 = Color.black
    static let text2 = Color(.darkGray)                    // darker secondary

    static let accent  = Color(red: 0.05, green: 0.52, blue: 0.98)
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let warning = Color(red: 1.00, green: 0.75, blue: 0.15)
}

extension View {
    func appBackground() -> some View {
        background(Theme.bg) // solid white by default (adapts in dark mode if enabled)
    }
    func cardContainer(corner: CGFloat = 14) -> some View {
        padding(14)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: corner, style: .continuous))
    }
}
