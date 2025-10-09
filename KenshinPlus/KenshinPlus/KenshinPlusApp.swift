//
//  KenshinPlusApp.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/05.
//

import SwiftUI
import SwiftData

@main
struct KenshinPlusApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabsView()
        }
        .modelContainer(Self.sharedContainer)
    }
}

extension KenshinPlusApp {
    static let sharedContainer: ModelContainer = {
        let schema = Schema([CheckupRecord.self])
        
        // Use the user's private iCloud database for sync
        let cloud = ModelConfiguration(schema: schema, cloudKitDatabase: .private("iCloud.com.Shubham.KenshinPlus"))
        
        // For now we only use the CloudKit-mirrored config
        do {
            return try ModelContainer(for: schema, configurations: [cloud])
        } catch {
            // Log error then fall back to local persistent store
            assertionFailure("Cloud sync disable due to error: \(error)")
            return try! ModelContainer(for: schema) // Local disk store, non-iCloud
        }
    }()
}
