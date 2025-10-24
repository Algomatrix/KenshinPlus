//
//  ReachoutToDeveloper.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/24.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}

struct ReachoutToDeveloper: View {
    let openURLInSheet: (URL) -> Void
    
    private let feedbackFormURL = URL(string: "https://tally.so/r/wzpxyZ")!
    private let featureRequestURL = URL(string: "https://tally.so/r/mOpD4M")!
    private let bugReportURL = URL(string: "https://tally.so/r/nrNjaX")!

    var body: some View {
        List {
            Section("Forms") {
                Row(title: "General Feedback", systemImage: "text.bubble.fill") {
                    openURLInSheet(feedbackFormURL)
                }
                Row(title: "Feature Request", systemImage: "lightbulb.fill") {
                    openURLInSheet(featureRequestURL)
                }
                Row(title: "Report a Bug", systemImage: "ant.fill") {
                    openURLInSheet(bugReportURL)
                }
            }
            
            Section("Note") {
                Text("Forms open in a secure in-app browser. You will not leave the app to fill the form.")
            }
        }
        .navigationTitle("Reach Out to Developer")
    }
    
    private func Row(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage).frame(width: 22)
                Text(title)
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReachoutToDeveloper(openURLInSheet: {_ in })
    }
}
