import SwiftUI

enum Theme {
    // Mørkt tema – simple faste farver (ingen Assets nødvendig)
    static let bg      = Color(red: 0.043, green: 0.043, blue: 0.051)  // #0B0B0D
    static let card    = Color(red: 0.066, green: 0.067, blue: 0.071)  // #111114
    static let text1   = Color.white
    static let text2   = Color(red: 0.72, green: 0.73, blue: 0.75)     // grå tekst
    static let accent  = Color(red: 0.039, green: 0.518, blue: 1.0)    // #0A84FF
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)     // #34C759
}

// Genbrugelig primær knap
struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Theme.accent.opacity(configuration.isPressed ? 0.85 : 1))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
    }
}

// Et “kort” med afrundede hjørner
struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(16)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
