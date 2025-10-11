import SwiftUI

enum Theme {
    static let bg      = Color(.systemBackground)
    static let card    = Color(.secondarySystemBackground)
    static let divider = Color(.separator)

    static let text1   = Color.primary
    static let text2   = Color.secondary

    static let accent  = Color.blue
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let warning = Color(red: 1.00, green: 0.75, blue: 0.15)
}

extension View {
    @ViewBuilder
    func themedListBackground() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
    }
}