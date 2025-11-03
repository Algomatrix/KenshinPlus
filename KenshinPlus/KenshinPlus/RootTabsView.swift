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
    
    // persisted flags
    @AppStorage(OnboardingKeys.hasShownOnFirstLaunch)
    private var hasShownOnFirstLaunch: Bool = false
    
    @AppStorage(OnboardingKeys.lastShownWhatsNewVersion)
    private var lastShownWhatsNewVersion: String = ""
    
    // presentaition state
    @State private var showWhatsNew = false

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem { Label("Health Dashboard", systemImage: "speedometer") }
            .tag(MainTab.dashboard)

            NavigationStack {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem { Label("Settings", systemImage: "gear") }
            .tag(MainTab.settings)
        }
        .sheet(isPresented: $showWhatsNew) {
            WhatsNewSheet(
                features: WhatsNewSheet.sampleFeatures,
                primaryButtonTitle: hasShownOnFirstLaunch ? "Got it" : "Get Started",
                onPrimary: {
                    hasShownOnFirstLaunch = true
                    lastShownWhatsNewVersion = AppVersion.current
                    showWhatsNew = false
                }
            )
            .interactiveDismissDisabled() // Force a tap on the button
        }
        .task {
            // Detect when to show
            if !hasShownOnFirstLaunch {
                // first install
                showWhatsNew = true
            } else if lastShownWhatsNewVersion != AppVersion.current {
                // optional: re-show after an update
                showWhatsNew = true
            }
        }
    }
}

#Preview {
    RootTabsView()
        .modelContainer(for: CheckupRecord.self, inMemory: true)
}
