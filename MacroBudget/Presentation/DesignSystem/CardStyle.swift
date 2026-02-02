import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

