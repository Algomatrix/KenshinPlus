//
//  FutureUpdates.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/09.
//

import SwiftUI

struct FutureUpdates: View {
    var body: some View {
        PutBarChartInContainer(title: "Developer Message") {
            Text("You can see future updates for app here. I plan to add new tests in the future so you can have more data of tests at all times in your pocket.")
                .font(.subheadline)
            
            Text("Please be aware that update release date is not fixed. I am doing my best to make your experience as better as possible.")
                .font(.subheadline)
        }
        
        List {
            Section(header: Text("Upcoming update list")) {
                DisclosureGroup("Checkup Test") {
                    VStack(alignment: .leading) {
                        Text("Version 1.2.0")
                            .font(.headline)
                        Divider()
                        Text("• Eye Test")
                        Text("• Hearing Test")
                    }
                }
                
                DisclosureGroup("Data Management") {
                    VStack(alignment: .leading) {
                        Text("Version 2.0")
                            .font(.headline)
                        Divider()
                        Text("• Sign-in with Google")
                        Text("• Export test result as CDAs file")
                    }
                }
            }
        }
        .navigationTitle("Future Updates")
    }
}

#Preview {
    FutureUpdates()
}
