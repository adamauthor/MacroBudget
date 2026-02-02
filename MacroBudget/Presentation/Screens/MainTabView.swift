import SwiftUI

struct MainTabView: View {
    let container: AppContainer
    @State private var selection: Tab = .today
    @State private var showAdd = false
    @AppStorage("accentColor") private var accentColorName = AccentColorOption.default.rawValue

    var body: some View {
        let accent = AccentColorOption(rawValue: accentColorName)?.color ?? AccentColorOption.default.color
        TabView(selection: $selection) {
            TodayView(container: container)
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
                .tag(Tab.today)

            Color.clear
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32, weight: .bold))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(accent, DSColor.divider)
                    Text("Add")
                }
                .tag(Tab.add)

            AnalyticsView(container: container)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .tag(Tab.analytics)
        }
        .tint(accent)
        .onChange(of: selection) { _, newValue in
            if newValue == .add {
                showAdd = true
            }
        }
        .sheet(isPresented: $showAdd, onDismiss: { selection = .today }) {
            AddTransactionView(container: container) {}
        }
    }
}

private enum Tab {
    case today
    case add
    case analytics
}
