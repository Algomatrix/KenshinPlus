//
//  NoChartDataView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/17.
//

import SwiftUI

struct NoChartDataView: View {
    let systemImageName: String
    let title: LocalizedStringResource
    let description: LocalizedStringResource

    var body: some View {
        ContentUnavailableView {
            Image(systemName: systemImageName)
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.bottom, 8)
            
            Text(title)
                .font(.callout.bold())
            
            Text(description)
                .font(.footnote)

        }
        .foregroundStyle(.secondary)
        .offset(y: -12)
    }
}

#Preview {
    NoChartDataView(systemImageName: "chart.bar", title: "No Data", description: "There is no data from app.")
}
