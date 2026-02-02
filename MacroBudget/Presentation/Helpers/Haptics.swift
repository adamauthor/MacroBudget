import UIKit

enum Haptics {
    private static var lastFire: CFTimeInterval = 0
    private static var pendingWorkItem: DispatchWorkItem?
    private static let minimumInterval: CFTimeInterval = 0.15
    private static let debounceDelay: CFTimeInterval = 0.03

    static func lightTick() {
        pendingWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            let now = CACurrentMediaTime()
            guard now - lastFire >= minimumInterval else { return }
            lastFire = now
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        pendingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceDelay, execute: workItem)
    }
}
