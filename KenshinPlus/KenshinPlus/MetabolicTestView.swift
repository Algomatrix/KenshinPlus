//
//  MetabolicTestView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/09.
//

import SwiftUI
import Charts

struct MetabolicTestView: View {
    let samples: [MetabolismTestSample]

    var startDate: Date? { samples.map(\.date).min() }
    var endDate: Date? { samples.map(\.date).max() }

    var body: some View {
        VStack(spacing: 24) {
            // HbA1c
            PutBarChartInContainer(title: "HbA1c") {
                Text("Diabetes threshold is 6.5")
                    .font(.subheadline)
                Chart {
                    if let s = startDate, let e = endDate {
                        RectangleMark(
                            xStart: .value("Start", s),
                            xEnd: .value("End", e),
                            yStart: .value("HbA1c Min", 4.6),
                            yEnd: .value("HbA1c Max", 6.2)
                        )
                        .foregroundStyle(.blue.opacity(0.12))
                        
                        RuleMark(y: .value("Diabetes threshold", 6.5))
                            .lineStyle(.init(dash: [4,4]))
                            .annotation(position: .topTrailing) {
                                Text("6.5%")
                                    .offset(x: -50)
                            }
                    }
                    
                    ForEach(samples, id: \.date) { s in
                        LineMark(x: .value("Date", s.date), y: .value("HbA1c", s.hba1c))
                        PointMark(x: .value("Date", s.date), y: .value("HbA1c", s.hba1c))
                    }
                }
                .chartYAxisLabel("HbA1c (%)")
            }

            // Fasting glucose
            PutBarChartInContainer(title: "Glucose") {
                Text("Diabetes threshold is 126 mg/dL")
                    .font(.subheadline)
                Chart {
                    if let s = startDate, let e = endDate {
                        RectangleMark(
                            xStart: .value("Start", s),
                            xEnd: .value("End", e),
                            yStart: .value("Glucose Min", 70),
                            yEnd: .value("Glucose Max", 99)
                        )
                        .foregroundStyle(.green.opacity(0.12))
                        
                        RuleMark(y: .value("Diabetes threshold", 126))
                            .lineStyle(.init(dash: [4,4]))
                            .annotation(position: .topTrailing) {
                                Text("126 mg/dL")
                                    .offset(x: -50)
                            }
                    }
                    
                    ForEach(samples, id: \.date) { s in
                        LineMark(x: .value("Date", s.date), y: .value("Glucose", s.fastingGlucose))
                        PointMark(x: .value("Date", s.date), y: .value("Glucose", s.fastingGlucose))
                    }
                }
                .chartYAxisLabel("Fasting Glucose (mg/dL)")
            }
        }
        .padding()
    }
}

#Preview {
    let mockData = MockDataForPreview()
    MetabolicTestView(samples: mockData.mockMetabolismTestSeries(count: 6))
}
