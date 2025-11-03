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
                    Text("Last Updated: October 2025")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Group {
                        Text("1. Overview")
                            .font(.headline)
                        Text("""
                        Kenshin Plus (“the App”) is developed and maintained by the developer (“we”, “our”, or “us”). 
                        We respect your privacy and are committed to handling your personal information responsibly, securely, and in compliance with applicable privacy laws including Japan’s Act on the Protection of Personal Information (APPI) and, where applicable, the EU General Data Protection Regulation (GDPR).
                        """)
                            .font(.body)
                    }

                    Group {
                        Text("2. Information We Collect")
                            .font(.headline)
                        Text("""
                        The App only stores information that you voluntarily enter, such as:
                        - Health and checkup records (e.g., blood test results, blood pressure, height, weight)
                        - Date of checkup or related metadata
                        - App preferences and settings

                        The App does not automatically collect, share, or transmit your personal data to any external server or third party.
                        """)
                            .font(.body)
                            .padding(.bottom, 10)

                        Text("3. Data Storage and Security")
                            .font(.headline)
                        Text("""
                        All data is stored locally on your device using Apple’s secure sandbox environment. 
                        Optionally, you may enable iCloud Sync, which stores your data in your personal iCloud account. 
                        iCloud data is managed and protected by Apple’s infrastructure and is not accessible to us or anyone else. 
                        Data transmission between your device and iCloud is end-to-end encrypted by Apple.
                        """)
                            .font(.body)
                            .padding(.bottom, 10)

                        Text("4. Tip Jar and Payments")
                            .font(.headline)
                        Text("""
                        Kenshin Plus offers optional in-app tips to support development. 
                        All payments are securely processed by Apple through the App Store using your Apple ID. 
                        We do not collect, process, or store any payment, billing, or financial information. 
                        Any receipts or transaction details are managed exclusively by Apple.
                        """)
                            .font(.body)
                            .padding(.bottom, 10)
                    }

                    Group {
                        Text("5. Health Data and Sensitive Information")
                            .font(.headline)
                        Text("""
                        Because Kenshin Plus may store health-related metrics that you input manually, we treat all such data as sensitive. 
                        This data never leaves your device or your iCloud account without your explicit action. 
                        We do not analyze, aggregate, or share any health information with third parties.
                        """)
                            .font(.body)
                            .padding(.bottom, 10)

                        Text("6. Analytics and Tracking")
                            .font(.headline)
                        Text("""
                        Kenshin Plus does not include any third-party analytics, advertising networks, or tracking technologies. 
                        We do not collect personally identifiable information or usage analytics.
                        """)
                            .font(.body)
                            .padding(.bottom, 10)

                        Text("7. Data Retention and Deletion")
                            .font(.headline)
                        Text("""
                        You retain full control of your data. 
                        You may delete all local data at any time using the “Clear Local Data” option in Settings. 
                        To remove iCloud data, disable iCloud sync or delete the app’s iCloud container via your device’s Settings → Apple ID → iCloud → Manage Storage.
                        Once deleted, this data cannot be recovered by us.
                        """)
                            .font(.body)
                            .padding(.bottom, 10)

                        Text("8. Children’s Privacy")
                            .font(.headline)
                        Text("""
                        Kenshin Plus is intended for general audiences and is not designed for children under the age of 13. 
                        We do not knowingly collect or store any personal information from minors. 
                        If you believe a minor has provided information, please contact us to request deletion.
                        """)
                            .font(.body)
                            .padding(.bottom, 10)

                        Text("9. International Users")
                            .font(.headline)
                        Text("""
                        Your data may be processed and stored on your device or iCloud servers located in your region as managed by Apple. 
                        By using the App, you acknowledge that your data handling is governed by Apple’s iCloud policies and applicable data protection laws in your jurisdiction.
                        """)
                            .font(.body)
                            .padding(.bottom, 10)

                        Text("10. Policy Updates")
                            .font(.headline)
                        Text("""
                        We may update this Privacy Policy to reflect improvements in our practices or compliance requirements. 
                        Any changes will be reflected by the “Last Updated” date above. 
                        Continued use of the App after changes indicates your acceptance of the revised policy.
                        """)
                            .font(.body)
                            .padding(.bottom, 10)

                        Text("11. Contact Us")
                            .font(.headline)
                        Text("""
                        If you have any questions or concerns about this Privacy Policy, please contact us using **Reach out to Developer** option from Settings.
                        """)
                            .font(.body)
                    }

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
