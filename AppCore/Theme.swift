import SwiftUI

// MARK: - Theme

enum Theme {

    // Baggrund
    static let bgGradient = LinearGradient(
        colors: [
            Color(red: 0.08, green: 0.09, blue: 0.12),  // dyb mørkegrå
            Color(red: 0.05, green: 0.07, blue: 0.10)   // let blålig tone
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Nogle views forventer en Color – brug denne som “ren” baggrundsfarve.
    static let bgColor = Color(red: 0.07, green: 0.08, blue: 0.11)

    // Alias så ældre views der bruger `Theme.bg` stadig virker.
    static let bg: LinearGradient = Theme.bgGradient

    // Overflader & farver
    static let card      = Color(red: 0.11, green: 0.12, blue: 0.14)
    static let text1     = Color.white
    static let text2     = Color(red: 0.74, green: 0.75, blue: 0.77)
    static let accent    = Color(red: 0.05, green: 0.52, blue: 0.98)
    static let success   = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let warning   = Color(red: 1.00, green: 0.75, blue: 0.15)
    static let divider   = Color.white.opacity(0.06)

    enum Metrics {
        static let corner: CGFloat = 16
        static let pad: CGFloat = 16
        static let shadowRadius: CGFloat = 8
    }
}

// MARK: - Helpers

extension View {
    /// Læg app-baggrund på hele skærmen.
    func appBackground() -> some View {
        background(Theme.bgGradient.ignoresSafeArea())
    }

    /// Standard kort-stil for beholdere.
    func cardContainer(cornerRadius: CGFloat = Theme.Metrics.corner) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.30),
                        radius: Theme.Metrics.shadowRadius, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Theme.divider)
        )
    }
}

// MARK: - Components

/// Primær knap (håndterer også disabled state).
struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [
                        Theme.accent.opacity(configuration.isPressed ? 0.75 : 1.0),
                        Theme.accent.opacity(configuration.isPressed ? 0.65 : 0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.corner, style: .continuous))
            .shadow(color: Theme.accent.opacity(0.35),
                    radius: Theme.Metrics.shadowRadius, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Et kort med afrundede hjørner.
/// Brug: `Card { ... }` eller `Card(padding: 12) { ... }`
struct Card<Content: View>: View {
    let padding: CGFloat
    let content: Content

    init(padding: CGFloat = Theme.Metrics.pad, @ViewBuilder _ content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .cardContainer()
    }
}
