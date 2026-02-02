import SwiftUI

struct MacroProgressBar: View {
    let progress: Double
    @AppStorage("accentColor") private var accentColorName = AccentColorOption.default.rawValue

    var body: some View {
        let accent = AccentColorOption(rawValue: accentColorName)?.color ?? AccentColorOption.default.color
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DSColor.divider)
                Capsule()
                    .fill(accent)
                    .frame(width: proxy.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: 6)
        .accessibilityLabel("Progress")
    }
}
