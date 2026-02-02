import SwiftUI

struct MacroRow: View {
    let title: String
    let consumed: Int
    let limit: Int
    let remaining: Int
    let overBy: Int

    var progress: Double {
        guard limit > 0 else { return 0 }
        return Double(consumed) / Double(limit)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Text("\(consumed)/\(limit)")
                .font(.subheadline)
                .foregroundStyle(DSColor.mutedText)
            MacroProgressBar(progress: progress)
            if overBy > 0 {
                Text("Over by \(overBy)")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                Text("Remaining: \(remaining)")
                    .font(.caption)
                    .foregroundStyle(DSColor.mutedText)
            }
        }
    }
}
