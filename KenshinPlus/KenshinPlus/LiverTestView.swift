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
    private let citation = HealthCitationLibrary.liver
    
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
                    Chart {
                        if !astSeries.isEmpty {
                            RectangleMark(
                                yStart: .value("AST Min", 10.0),
                                yEnd:   .value("AST Max", 40.0)
                            )
                            .foregroundStyle(.green.opacity(0.12))
                        }

                        ForEach(astSeries) { entry in
                            LineMark(
                                x: .value("Date", ChartAxis.startOfDay(entry.date)),
                                y: .value("AST(GOT)", entry.value)
                            )
                            .symbol(.circle)
                            .interpolationMethod(.monotone)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                    .chartXAxis { ChartAxis.axisAtDataDates(astSeries, date: \.date) }
                    .chartScrollableAxes(.horizontal)
                    .scrolledToLatest(in: astSeries, date: \.date)
                    .overlay {
                        if astSeries.isEmpty {
                            NoChartDataView(systemImageName: "chart.line.text.clipboard.fill", title: "No Data", description: "There is no AST(GOT) data from App.")
                        }
                    }
                }
                
                PutBarChartInContainer(title: "ALT(GPT)") {
                    Chart {
                        if !altSeries.isEmpty {
                            RectangleMark(
                                yStart: .value("ALT Min", 7.0),
                                yEnd:   .value("ALT Max", 56.0)
                            )
                            .foregroundStyle(.green.opacity(0.12))
                        }

                        ForEach(altSeries) { entry in
                            LineMark(
                                x: .value("Date", ChartAxis.startOfDay(entry.date)),
                                y: .value("ALT(GPT)", entry.value)
                            )
                            .symbol(.circle)
                            .interpolationMethod(.monotone)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                    .chartXAxis { ChartAxis.axisAtDataDates(altSeries, date: \.date) }
                    .chartScrollableAxes(.horizontal)
                    .scrolledToLatest(in: altSeries, date: \.date)
                    .overlay {
                        if altSeries.isEmpty {
                            NoChartDataView(systemImageName: "chart.line.text.clipboard.fill", title: "No Data", description: "There is no ALT(GPT) data from App.")
                        }
                    }
                }
                
                PutBarChartInContainer(title: "GGT") {
                    Chart {
                        if !ggtSeries.isEmpty {
                            RectangleMark(
                                yStart: .value("GGT Min", 9.0),
                                yEnd:   .value("GGT Max", 48.0)
                            )
                            .foregroundStyle(.green.opacity(0.12))
                        }

                        ForEach(ggtSeries) { entry in
                            LineMark(
                                x: .value("Date", ChartAxis.startOfDay(entry.date)),
                                y: .value("GGT", entry.value)
                            )
                            .symbol(.circle)
                            .interpolationMethod(.monotone)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                    .chartXAxis { ChartAxis.axisAtDataDates(ggtSeries, date: \.date) }
                    .chartScrollableAxes(.horizontal)
                    .scrolledToLatest(in: ggtSeries, date: \.date)
                    .overlay {
                        if ggtSeries.isEmpty {
                            NoChartDataView(systemImageName: "chart.line.text.clipboard.fill", title: "No Data", description: "There is no GGT data from App.")
                        }
                    }
                }
                
                PutBarChartInContainer(title: "Total Protein") {
                    Chart {
                        if !totalProteinSeries.isEmpty {
                            RectangleMark(
                                yStart: .value("TP Min", 6.0),
                                yEnd:   .value("TP Max", 8.3)
                            )
                            .foregroundStyle(.green.opacity(0.12))
                        }

                        ForEach(totalProteinSeries) { entry in
                            LineMark(
                                x: .value("Date", ChartAxis.startOfDay(entry.date)),
                                y: .value("Total Protein", entry.value)
                            )
                            .symbol(.circle)
                            .interpolationMethod(.monotone)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                    .chartXAxis { ChartAxis.axisAtDataDates(totalProteinSeries, date: \.date) }
                    .chartScrollableAxes(.horizontal)
                    .scrolledToLatest(in: totalProteinSeries, date: \.date)
                    .overlay {
                        if totalProteinSeries.isEmpty {
                            NoChartDataView(systemImageName: "chart.line.text.clipboard.fill", title: "No Data", description: "There is no Total Protein data from App.")
                        }
                    }
                }
                
                PutBarChartInContainer(title: "Albumin") {
                    Chart {
                        if !albuminSeries.isEmpty {
                            RectangleMark(
                                yStart: .value("Alb Min", 3.5),
                                yEnd:   .value("Alb Max", 5.0)
                            )
                            .foregroundStyle(.green.opacity(0.12))
                        }

                        ForEach(albuminSeries) { entry in
                            LineMark(
                                x: .value("Date", ChartAxis.startOfDay(entry.date)),
                                y: .value("Albumin", entry.value)
                            )
                            .symbol(.circle)
                            .interpolationMethod(.monotone)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                    .chartXAxis { ChartAxis.axisAtDataDates(albuminSeries, date: \.date) }
                    .chartScrollableAxes(.horizontal)
                    .scrolledToLatest(in: albuminSeries, date: \.date)
                    .overlay {
                        if albuminSeries.isEmpty {
                            NoChartDataView(systemImageName: "chart.line.text.clipboard.fill", title: "No Data", description: "There is no Albumin data from App.")
                        }
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CitationInfoButton(citation: citation)
            }
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
