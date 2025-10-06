//
//  RootTabsView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/06.
//

import SwiftUI

enum MainTab: Hashable {
    case dashboard
    case settings
}

struct RootTabsView: View {
    @State private var tab: MainTab = .dashboard

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem { Label("Dashboard", systemImage: "speedometer") }
            .tag(MainTab.dashboard)

//            NavigationStack {
//                SettingsView() // make a simple placeholder if you don't have one yet
//                    .navigationTitle("Settings")
//            }
//            .tabItem { Label("Settings", systemImage: "gear") }
//            .tag(MainTab.settings)
        }
    }
}

#Preview {
    RootTabsView()
        .modelContainer(for: CheckupRecord.self, inMemory: true)
}
