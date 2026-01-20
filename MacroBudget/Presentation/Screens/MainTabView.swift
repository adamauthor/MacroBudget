import SwiftUI

struct MainTabView: View {
    let container: AppContainer

    var body: some View {
        TabView {
            TodayView(container: container)
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
            AnalyticsView(container: container)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
            SettingsView(container: container)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
