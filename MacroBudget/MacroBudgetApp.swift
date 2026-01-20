//
//  MacroBudgetApp.swift
//  MacroBudget
//
//  Created by Akhmediyar Olzhassov on 20.01.2026.
//

import SwiftUI
import SwiftData

@main
struct MacroBudgetApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(container: AppContainer.shared)
        }
        .modelContainer(AppContainer.shared.modelContainer)
    }
}
