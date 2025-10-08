import SwiftUI

enum Theme {
    // Baggrund: mørk men med lidt farvespil
    static let bgGradient = LinearGradient(
        colors: [
            Color(red: 0.08, green: 0.09, blue: 0.12),  // dyb mørkegrå
            Color(red: 0.05, green: 0.07, blue: 0.10)   // let blålig tone
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Kort og elementer
    static let card    = Color(red: 0.11, green: 0.12, blue: 0.14)
    static let text1   = Color.white
    static let text2   = Color(red: 0.74, green: 0.75, blue: 0.77)
    static let accent  = Color(red: 0.05, green: 0.52, blue: 0.98)
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let warning = Color(red: 1.0, green: 0.75, blue: 0.15)
}

// MARK: - Genbrugelige komponenter

// Primær knap
struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Theme.accent.opacity(configuration.isPressed ? 0.7 : 1.0),
                        Theme.accent.opacity(configuration.isPressed ? 0.6 : 0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Theme.accent.opacity(0.4), radius: 8, y: 4)
    }
}

// Et “kort” med afrundede hjørner og blød skygge
struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.card)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
            )
    }
}
