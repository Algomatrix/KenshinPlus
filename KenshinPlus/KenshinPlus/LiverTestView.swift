//
//  LiverTestView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/09.
//

import SwiftUI
import Charts

struct LiverTestView: View {
    let records: [CheckupRecord]
    
    private func colorFor(value: Double, normal: ClosedRange<Double>) -> Color {
        if value < normal.lowerBound { return .orange }
        if value > normal.upperBound { return .red }
        return .green
    }

    private var astSeries: [MetricSample] {
        records.metricSamples(\.ast)
    }

    private var altSeries: [MetricSample] {
        records.metricSamples(\.alt)
    }

    private var ggtSeries: [MetricSample] {
        records.metricSamples(\.ggt)
    }

    private var totalProteinSeries: [MetricSample] {
        records.metricSamples(\.totalProtein)
    }

    private var albuminSeries: [MetricSample] {
        records.metricSamples(\.albumin)
    }

    var body: some View {
        ScrollView {
            VStack {
                PutBarChartInContainer(title: "AST(GOT)") {
                    Chart(astSeries) { entry in
                        LineMark (
                            x: .value("Date", entry.date),
                            y: .value("AST(GOT)", entry.value)
                        )
                        .symbol(.circle)
                        .interpolationMethod(.catmullRom)
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
                        if astSeries.isEmpty {
                            NoChartDataView(systemImageName: "chart.line.text.clipboard.fill", title: "No Data", description: "There is no AST(GOT) data from App.")
                        }
                    }
                }
                
                PutBarChartInContainer(title: "ALT(GPT)") {
                    Chart(altSeries) { entry in
                        LineMark (
                            x: .value("Date", entry.date),
                            y: .value("ALT(GPT)", entry.value)
                        )
                        .symbol(.circle)
                        .interpolationMethod(.catmullRom)
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
                        if altSeries.isEmpty {
                            NoChartDataView(systemImageName: "chart.line.text.clipboard.fill", title: "No Data", description: "There is no ALT(GPT) data from App.")
                        }
                    }
                }
                
                PutBarChartInContainer(title: "GGT") {
                    Chart(ggtSeries) { entry in
                        LineMark (
                            x: .value("Date", entry.date),
                            y: .value("GGT", entry.value)
                        )
                        .symbol(.circle)
                        .interpolationMethod(.catmullRom)
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
                        if ggtSeries.isEmpty {
                            NoChartDataView(systemImageName: "chart.line.text.clipboard.fill", title: "No Data", description: "There is no GGT data from App.")
                        }
                    }
                }
                
                PutBarChartInContainer(title: "Total Protein") {
                    Chart(totalProteinSeries) { entry in
                        LineMark (
                            x: .value("Date", entry.date),
                            y: .value("Total Protein", entry.value)
                        )
                        .symbol(.circle)
                        .interpolationMethod(.catmullRom)
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
                        if totalProteinSeries.isEmpty {
                            NoChartDataView(systemImageName: "chart.line.text.clipboard.fill", title: "No Data", description: "There is no Total Protein data from App.")
                        }
                    }
                }
                
                PutBarChartInContainer(title: "Albumin") {
                    Chart(albuminSeries) { entry in
                        LineMark (
                            x: .value("Date", entry.date),
                            y: .value("Albumin", entry.value)
                        )
                        .symbol(.circle)
                        .interpolationMethod(.catmullRom)
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
                        if albuminSeries.isEmpty {
                            NoChartDataView(systemImageName: "chart.line.text.clipboard.fill", title: "No Data", description: "There is no Albumin data from App.")
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
        r.ast = Double.random(in: 10...40)              // U/L
        r.alt = Double.random(in: 7...56)               // U/L
        r.ggt = Double.random(in: 9...48)               // U/L
        r.totalProtein = Double.random(in: 6.0...8.3)   // g/dL
        r.albumin = Double.random(in: 3.5...5.0)        // g/dL
        return r
    }
    return LiverTestView(records: recs)
}
