//
//  WhatsNewGuideSheet.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/22.
//

import SwiftUI

enum AppVersion {
    static var current: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }
}

enum OnboardingKeys {
    static let hasShownOnFirstLaunch = "hasShownOnFirstLaunch"
    static let lastShownWhatsNewVersion = "lastShownWhatsNewVersion"
}

struct WhatsNewFeature: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color?
}

/// Sheet to tell users whats new about this app. Apple style info sheet.
struct WhatsNewSheet: View {
    let features: [WhatsNewFeature]
    let primaryButtonTitle: String
    let onPrimary: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 44, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.yellow)
                    Text("Welcome!")
                        .font(.title.bold())
                    Text("Thanks for installing Kenshin Plus! Here are few highlights of the App.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Feature List
                VStack(spacing: 16) {
                    ForEach(features) { feature in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: feature.systemImage)
                                .font(.title3)
                                .frame(width: 32, height: 32)
                                .padding(10)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(feature.color!)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(feature.title).font(.headline)
                                Text(feature.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Primary CTA
                Button(action: onPrimary) {
                    Text(primaryButtonTitle)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .padding(.bottom)
            }
            .presentationDetents([.large]) // Nice on iPhone & iPad
            .presentationDragIndicator(.automatic)
        }
    }
}

extension WhatsNewSheet {
    static var sampleFeatures: [WhatsNewFeature] {
        [
            .init(title: "Quick Health Input",
                  subtitle: "Enter checkup values quickly.",
                  systemImage: "figure", color: .indigo),
            .init(title: "Clean Trends",
                  subtitle: "Beautiful charts to track progress over time.",
                  systemImage: "chart.line.uptrend.xyaxis", color: .blue),
            .init(title: "Private by Design",
                  subtitle: "Your data stays on device and automatically syncs with iCloud.",
                  systemImage: "lock.shield", color: .green),
            .init(title: "Scan and Fill",
                  subtitle: "You can quickly input test fields automatically just from an Image.",
                  systemImage: "photo.on.rectangle", color: .primary),
        ]
    }
}

#Preview {
    WhatsNewSheet(features: WhatsNewSheet.sampleFeatures, primaryButtonTitle: "Awesome! Let's Try!!", onPrimary: {})
}
