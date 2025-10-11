import SwiftUI

enum Theme {
    // Baggrunde
    static let bg       = Color(.systemBackground)
    static let card     = Color(.secondarySystemBackground)

    // Linjer/tekst
    static let divider  = Color(.separator)
    static let text1    = Color.primary
    static let text2    = Color.secondary

    // Accent
    static let accent   = Color.blue

    // Bruges nogle steder som "bgGradient"
    static let bgGradient = LinearGradient(
        colors: [Color(.systemBackground), Color(.systemBackground)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// iOS-16 sikker kort-stil (kan bruges i stedet for .fill/.stroke fra iOS 17)
extension View {
    func themedCard(cornerRadius: CGFloat = 14, lineWidth: CGFloat = 1) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .foregroundColor(Theme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Theme.divider, lineWidth: lineWidth)
        )
    }
}