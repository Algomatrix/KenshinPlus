//
//  CholesterolTestView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/10.
//

import SwiftUI
import Charts

struct CholesterolTestView: View {
    let records: [CheckupRecord]
    
    private var totalCholesterolSeries: [MetricSample] {
        records.metricSamples(\.totalChol)
    }
    
    private var ldlSeries: [MetricSample] {
        records.metricSamples(\.ldl)
    }
    
    private var hdlSeries: [MetricSample] {
        records.metricSamples(\.hdl)
    }
    
    private var triglyceridesSeries: [MetricSample] {
        records.metricSamples(\.triglycerides)
    }

    // MARK: Main Body
    var body: some View {
        ScrollView {
            VStack {
                totalCholesterol

                LDL
                
                HDL
                
                triglycerides
            }
            .padding()
        }
    }

    // MARK: View as Var
    // MARK: ------- Total Cholesterol -------
    var totalCholesterol: some View {
        PutBarChartInContainer(title: "Total Cholesterol") {
            Chart {
                if let (seriesStart, seriesEnd) = ChartAxis.bounds(totalCholesterolSeries, date: \.date),
                   !totalCholesterolSeries.isEmpty {
                    RectangleMark(
                        xStart: .value("Start", ChartAxis.startOfDay(seriesStart)),
                        xEnd:   .value("End",   ChartAxis.startOfDay(seriesEnd)),
                        yStart: .value("Cholesterol Min", 150),
                        yEnd:   .value("Cholesterol Max", 240)
                    )
                    .foregroundStyle(.green.opacity(0.12))
                }
                
                ForEach(totalCholesterolSeries) { entry in
                    LineMark(
                        x: .value("Date", ChartAxis.startOfDay(entry.date)),
                        y: .value("Total Cholesterol", entry.value)
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
            .chartXAxis { ChartAxis.axisAtDataDates(totalCholesterolSeries, date: \.date) }
            .chartScrollableAxes(.horizontal)
            .overlay {
                if totalCholesterolSeries.isEmpty {
                    NoChartDataView(systemImageName: "heart.circle", title: "No Data", description: "There is no Total Cholesterol data from App.")
                }
            }
        }
    }
    
    // MARK: ------- LDL -------
    var LDL: some View {
        PutBarChartInContainer(title: "LDL") {
            Chart {
                if let (seriesStart, seriesEnd) = ChartAxis.bounds(ldlSeries, date: \.date),
                   !ldlSeries.isEmpty {
                    RectangleMark(
                        xStart: .value("Start", ChartAxis.startOfDay(seriesStart)),
                        xEnd:   .value("End",   ChartAxis.startOfDay(seriesEnd)),
                        yStart: .value("LDL Min", 70),
                        yEnd:   .value("LDL Max", 160)
                    )
                    .foregroundStyle(.green.opacity(0.12))
                }

                // Line for Creatinine
                ForEach(ldlSeries) { entry in
                    LineMark(
                        x: .value("Date", ChartAxis.startOfDay(entry.date)),
                        y: .value("LDL", entry.value)
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
            .chartXAxis { ChartAxis.axisAtDataDates(ldlSeries, date: \.date) }
            .chartScrollableAxes(.horizontal)
            .overlay {
                if ldlSeries.isEmpty {
                    NoChartDataView(systemImageName: "heart.circle", title: "No Data", description: "There is no LDL data from App.")
                }
            }
        }
    }
    
    // MARK: ------- HDL -------
    var HDL: some View {
        PutBarChartInContainer(title: "HDL") {
            Chart {
                // Reference band for Creatinine (0.6–1.1 mg/dL)
                if let (seriesStart, seriesEnd) = ChartAxis.bounds(hdlSeries, date: \.date),
                   !hdlSeries.isEmpty {
                    RectangleMark(
                        xStart: .value("Start", ChartAxis.startOfDay(seriesStart)),
                        xEnd:   .value("End",   ChartAxis.startOfDay(seriesEnd)),
                        yStart: .value("HDL Min", 35),
                        yEnd:   .value("HDL Max", 70)
                    )
                    .foregroundStyle(.green.opacity(0.12))
                }

                // Line for Creatinine
                ForEach(hdlSeries) { entry in
                    LineMark(
                        x: .value("Date", ChartAxis.startOfDay(entry.date)),
                        y: .value("HDL", entry.value)
                    )
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
            .chartXAxis { ChartAxis.axisAtDataDates(hdlSeries, date: \.date) }
            .chartScrollableAxes(.horizontal)
            .overlay {
                if hdlSeries.isEmpty {
                    NoChartDataView(systemImageName: "heart.circle", title: "No Data", description: "There is no HDL data from App.")
                }
            }
        }
    }
    
    // MARK: ------- Triglyceride -------
    var triglycerides: some View {
        PutBarChartInContainer(title: "Triglycerides") {
            Chart {
                if let (seriesStart, seriesEnd) = ChartAxis.bounds(triglyceridesSeries, date: \.date),
                   !triglyceridesSeries.isEmpty {
                    RectangleMark(
                        xStart: .value("Start", ChartAxis.startOfDay(seriesStart)),
                        xEnd:   .value("End",   ChartAxis.startOfDay(seriesEnd)),
                        yStart: .value("Triglyceride Min", 80),
                        yEnd:   .value("Triglyceride Max", 200)
                    )
                    .foregroundStyle(.green.opacity(0.12))
                }

                ForEach(triglyceridesSeries) { entry in
                    LineMark(
                        x: .value("Date", ChartAxis.startOfDay(entry.date)),
                        y: .value("Triglycerides", entry.value)
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
            .chartXAxis { ChartAxis.axisAtDataDates(totalCholesterolSeries, date: \.date) }
            .chartScrollableAxes(.horizontal)
            .overlay {
                if triglyceridesSeries.isEmpty {
                    NoChartDataView(systemImageName: "heart.circle", title: "No Data", description: "There is no Triglyceride data from App.")
                }
            }
        }
    }
}

#Preview {
    let dates: [Date] = (0..<6).reversed().compactMap {
        Calendar.current.date(byAdding: .month, value: -$0, to: .now)
    }
    let recs: [CheckupRecord] = dates.map { d in
        let r = CheckupRecord(date: d, gender: .male, heightCm: 170, weightKg: 70)
        r.totalChol = Double.random(in: 150...240)     // mg/dL
        r.ldl = Double.random(in: 70...160)                   // mg/dL
        r.hdl = Double.random(in: 35...70)                    // mg/dL
        r.triglycerides = Double.random(in: 80...200)         // mg/dL
        return r
    }
    CholesterolTestView(records: recs)
}
