//
//  BloodTestChartView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/09.
//

import SwiftUI
import Charts

struct BloodTestChartView: View {
    let data: [(date: Date, sample: BloodTestSample)]

    var body: some View {
        Chart(data, id: \.date) { entry in
            LineMark(
                x: .value("Date", entry.date),
                y: .value("WBC", entry.sample.wbc)
            )
        }
        .frame(height: 200)
    }
}

#Preview {
    let mock = MockDataForPreview()
    return BloodTestChartView(data: mock.mockBloodTestSeries())
}
