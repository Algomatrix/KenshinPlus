//
//  CholesterolTestView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/10.
//

import SwiftUI
import Charts

struct CholesterolTestView: View {
    let sample: [CholesterolTestSample]

    // Helpers for shaded band extent on X
    private var startDate: Date? { sample.map { $0.date }.min() }
    private var endDate: Date? { sample.map { $0.date }.max() }

    var body: some View {
        ScrollView {
            VStack {
                // ------- Total Cholesterol -------
                PutBarChartInContainer(title: "Total Cholesterol") {
                    Chart {
                        if let start = startDate, let end = endDate {
                            RectangleMark(
                                xStart: .value("Start", start),
                                xEnd: .value("End", end),
                                yStart: .value("Cholesterol Min", 150),
                                yEnd: .value("Cholesterol Max", 240)
                            )
                            .foregroundStyle(.green.opacity(0.12))
                        }

                        ForEach(sample, id: \.date) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Total Cholesterol", entry.totalCholesterol)
                            )
                            .foregroundStyle(.blue)
                            .symbol(Circle())
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { _ in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                }

                // ------- LDL -------
                PutBarChartInContainer(title: "LDL") {
                    Chart {
                        if let start = startDate, let end = endDate {
                            RectangleMark(
                                xStart: .value("Start", start),
                                xEnd: .value("End", end),
                                yStart: .value("LDL Min", 70),
                                yEnd: .value("LDL Max", 160)
                            )
                            .foregroundStyle(.green.opacity(0.12))
                        }

                        // Line for Creatinine
                        ForEach(sample, id: \.date) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("LDL", entry.ldl)
                            )
                            .foregroundStyle(.blue)
                            .symbol(Circle())
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { _ in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                }
                
                // ------- HDL -------
                PutBarChartInContainer(title: "HDL") {
                    Chart {
                        // Reference band for Creatinine (0.6–1.1 mg/dL)
                        if let start = startDate, let end = endDate {
                            RectangleMark(
                                xStart: .value("Start", start),
                                xEnd: .value("End", end),
                                yStart: .value("HDL Min", 35),
                                yEnd: .value("HDL Max", 70)
                            )
                            .foregroundStyle(.green.opacity(0.12))
                        }

                        // Line for Creatinine
                        ForEach(sample, id: \.date) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("HDL", entry.hdl)
                            )
                            .foregroundStyle(.blue)
                            .symbol(Circle())
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { _ in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                }
                
                // ------- Triglyceride -------
                PutBarChartInContainer(title: "Triglyceride") {
                    Chart {
                        if let start = startDate, let end = endDate {
                            RectangleMark(
                                xStart: .value("Start", start),
                                xEnd: .value("End", end),
                                yStart: .value("Triglyceride Min", 80),
                                yEnd: .value("Triglyceride Max", 200)
                            )
                            .foregroundStyle(.green.opacity(0.12))
                        }

                        ForEach(sample, id: \.date) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Triglyceride", entry.triglycerides)
                            )
                            .foregroundStyle(.blue)
                            .symbol(Circle())
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { _ in
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
    CholesterolTestView(sample: mock.mockCholesterolTestSeries(count: 6))
}
