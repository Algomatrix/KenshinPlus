//
//  PrivacyPolicyView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/09.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("At Our App (Kenshin Plus), we prioritize your privacy. This policy outlines how we handle your data.")
                        .font(.body)
                        .padding(.bottom, 20)

                    Group {
                        Text("1. No Data Collection")
                            .font(.headline)
                        Text("We do not collect any personal information from you. Your privacy is respected, and your data remains yours.")
                            .font(.body)
                            .padding(.bottom, 10)

                        Text("2. Your Data Management")
                            .font(.headline)
                        Text("You are solely responsible for managing your own data. We encourage you to keep your information secure.")
                            .font(.body)
                            .padding(.bottom, 10)

                        Text("3. iCloud Sync")
                            .font(.headline)
                        Text("You can save your own data on your iCloud using the iCloud sync function of the app. This allows you to access your data across your devices.")
                            .font(.body)
                            .padding(.bottom, 10)
                    }

                    Text("If you have any questions about our privacy policy, please feel free to contact us.")
                        .font(.body)
                        .padding(.top, 20)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
