//
//  LiverTestView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/09.
//

import SwiftUI
import Charts

struct LiverTestView: View {
    let data: [(date: Date, sample: LiverTestSample)]

    /// Get latest date and sample related to that date
    private var latest: LiverTestSample? {
        data.max(by: { $0.date < $1.date })?.sample
    }
    
    private func colorFor(value: Double, normal: ClosedRange<Double>) -> Color {
        if value < normal.lowerBound { return .orange }
        if value > normal.upperBound { return .red }
        return .green
    }

    var body: some View {
        ScrollView {
            VStack {
                PutBarChartInContainer(title: "AST(GOT)") {
                    Chart(data, id: \.date) { entry in
                        BarMark (
                            x: .value("Date", entry.date),
                            y: .value("AST(GOT)", entry.sample.ast)
                        )
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                }
                
                PutBarChartInContainer(title: "ALT(GPT)") {
                    Chart(data, id: \.date) { entry in
                        BarMark (
                            x: .value("Date", entry.date),
                            y: .value("ALT(GPT)", entry.sample.alt)
                        )
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                }
                
                PutBarChartInContainer(title: "GGT") {
                    Chart(data, id: \.date) { entry in
                        BarMark (
                            x: .value("Date", entry.date),
                            y: .value("GGT", entry.sample.ggt)
                        )
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                }
                
                PutBarChartInContainer(title: "Total Protein") {
                    Chart(data, id: \.date) { entry in
                        BarMark (
                            x: .value("Date", entry.date),
                            y: .value("Total Protein", entry.sample.totalProtein)
                        )
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                }
                
                PutBarChartInContainer(title: "Albumin") {
                    Chart(data, id: \.date) { entry in
                        BarMark (
                            x: .value("Date", entry.date),
                            y: .value("Albumin", entry.sample.albumin)
                        )
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    let mock = MockDataForPreview()
    LiverTestView(data: mock.mockLiverTestSeries())
}
