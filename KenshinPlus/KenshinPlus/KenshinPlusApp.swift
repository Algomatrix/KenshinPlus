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
        let config = ModelConfiguration(schema: schema, cloudKitDatabase: .private("iCloud.com.Shubham.KenshinPlus"))
        
        // For now we only use the CloudKit-mirrored config
        return try! ModelContainer(for: schema, configurations: [config])
    }()
}
