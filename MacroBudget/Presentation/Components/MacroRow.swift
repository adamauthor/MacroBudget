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
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(consumed)/\(limit)")
                    .font(.subheadline)
                    .foregroundStyle(DSColor.mutedText)
            }
            MacroProgressBar(progress: progress)
            HStack {
                Text("Remaining: \(remaining)")
                    .font(.caption)
                    .foregroundStyle(DSColor.mutedText)
                Spacer()
                if overBy > 0 {
                    Text("Over by \(overBy)")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}
