//
//  KidneyTestView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/09.
//

import SwiftUI
import Charts

struct KidneyTestView: View {
    let data: [(date: Date, sample: KidneyTestSample)]

    // Helpers for shaded band extent on X
    private var startDate: Date? { data.map { $0.date }.min() }
    private var endDate: Date? { data.map { $0.date }.max() }

    var body: some View {
        ScrollView {
            VStack {
                // ------- Uric Acid -------
                PutBarChartInContainer(title: "Uric Acid") {
                    Chart {
                        // Reference band for Uric Acid (3.6–7.0 mg/dL)
                        if let start = startDate, let end = endDate {
                            RectangleMark(
                                xStart: .value("Start", start),
                                xEnd: .value("End", end),
                                yStart: .value("Uric Acid Min", 3.6),
                                yEnd: .value("Uric Acid Max", 7.0)
                            )
                            .foregroundStyle(.blue.opacity(0.12))
                        }

                        // Line for Uric Acid
                        ForEach(data, id: \.date) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Uric Acid", entry.sample.uricAcid)
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

                // ------- Creatinine -------
                PutBarChartInContainer(title: "Creatinine") {
                    Chart {
                        // Reference band for Creatinine (0.6–1.1 mg/dL)
                        if let start = startDate, let end = endDate {
                            RectangleMark(
                                xStart: .value("Start", start),
                                xEnd: .value("End", end),
                                yStart: .value("Creatinine Min", 0.6),
                                yEnd: .value("Creatinine Max", 1.1)
                            )
                            .foregroundStyle(.green.opacity(0.12))
                        }

                        // Line for Creatinine
                        ForEach(data, id: \.date) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Creatinine", entry.sample.creatinine)
                            )
                            .foregroundStyle(.green)
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
    KidneyTestView(data: mock.mockKidneyTestSeries())
}
