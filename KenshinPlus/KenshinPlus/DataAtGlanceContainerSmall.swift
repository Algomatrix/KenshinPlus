//
//  DataAtGlanceContainerSmall.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/06.
//

import SwiftUI

struct DataAtGlanceContainerSmall: View {
    var title: LocalizedStringResource
    var symbol: String
    var subtitle: String
    var color: Color

    var body: some View {
        VStack {
            VStack(spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    HStack(alignment: .center, spacing: 6) {
                        Image(systemName: symbol)
                            .foregroundStyle(color)

                        Text(title)
                            .foregroundStyle(color)
                            .font(.subheadline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }

                    Spacer(minLength: 4)
                }

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 150)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .circular)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    DataAtGlanceContainerSmall(title: "Body Weight", symbol: "figure", subtitle: "80 Kg", color: .indigo)
    DataHoldingContainer(title: "RBC") {
        HalfDonutChartView(value: 40, maxValue: 120)
    }
    CitedDashboardCard(citation: HealthCitationLibrary.cholesterol) {
        NavigationLink(
            destination: CholesterolTestView(records: [])
                .navigationTitle("Cholesterol Test Data")
        ) {
            DataAtGlanceContainerSmall(
                title: "Cholesterol",
                symbol: "heart.circle",
                subtitle: String(localized: "HDL, LDL, etc"),
                color: .orange
            )
        }
        .buttonStyle(.plain)
    }
}

/// A small container/card that hosts any content
struct DataHoldingContainer<Content: View>: View {
    let title: LocalizedStringResource
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 10)

            // Content area with fixed height
            ZStack { content() }
                .frame(height: 90)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
                .strokeBorder(style: .init(lineWidth: 0.2))
        )
    }
}
