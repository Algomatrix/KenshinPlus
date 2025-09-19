//
//  KidneyTestView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/09.
//

import SwiftUI
import Charts

struct KidneyTestView: View {
    let records: [CheckupRecord]

    // Helpers for shaded band extent on X
    private var startDate: Date? { records.map { $0.date }.min() }
    private var endDate: Date? { records.map { $0.date }.max() }
    
    private var uricAcid: [MetricSample] {
        records.metricSamples(\.uricAcid)
    }

    private var creatinine: [MetricSample] {
        records.metricSamples(\.creatinine)
    }

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
                        ForEach(uricAcid) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Uric Acid", entry.value)
                            )
                            .foregroundStyle(.blue)
                            .symbol(.circle)
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                    .chartXAxis {
                        AxisMarks {
                            AxisValueLabel(format: .dateTime.year(.twoDigits).month(.twoDigits).day())
                        }
                    }
                    .overlay {
                        if uricAcid.isEmpty {
                            NoChartDataView(systemImageName: "vial.viewfinder", title: "No Data", description: "There is no Albumin data from App.")
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
                        ForEach(creatinine) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Creatinine", entry.value)
                            )
                            .foregroundStyle(.green)
                            .symbol(.circle)
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                    .chartXAxis {
                        AxisMarks {
                            AxisValueLabel(format: .dateTime.year(.twoDigits).month(.twoDigits).day())
                        }
                    }
                    .overlay {
                        if creatinine.isEmpty {
                            NoChartDataView(systemImageName: "vial.viewfinder", title: "No Data", description: "There is no Creatinine data from App.")
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    // Build a few preview records (no SwiftData container needed here)
    let dates: [Date] = (0..<7).reversed().compactMap {
        Calendar.current.date(byAdding: .day, value: -$0, to: .now)
    }
    let recs: [CheckupRecord] = dates.map { d in
        let r = CheckupRecord(date: d, gender: .male, heightCm: 170, weightKg: 70)
        r.uricAcid = Double.random(in: 3.6...7.0)       // reference range mg/dL
        r.creatinine = Double.random(in: 0.6...1.1)     // reference range mg/dL
        return r
    }
    return KidneyTestView(records: recs)
}
