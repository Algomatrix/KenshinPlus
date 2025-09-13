//
//  DataAtGlanceContainerSmall.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/06.
//

import SwiftUI

struct DataAtGlanceContainerSmall: View {
    
    var title: String
    var symbol: String
    var subtitle: String
    var color: Color

    var body: some View {
        VStack {
            mainLabelView
                .frame(width: 150)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12, style: .circular).fill(Color(.secondarySystemBackground)))
    }
    
    var mainLabelView: some View {
        VStack {
            Label(title, systemImage: symbol)
                .foregroundStyle(color)
                .frame(alignment: .leading)
            
            Text(subtitle)
                .font(.caption)
        }
    }
}

#Preview {
    DataAtGlanceContainerSmall(title: "Body Weight", symbol: "figure", subtitle: "80 Kg", color: .indigo)
    DataHoldingContainer(title: "RBC") {
        HalfDonutChartView(value: 40, maxValue: 120)
    }
}

/// A small container/card that hosts any content
struct DataHoldingContainer<Content: View>: View {
    let title: String
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
