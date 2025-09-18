//
//  MetabolicTestView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/09.
//

import SwiftUI
import Charts

struct MetabolicTestView: View {
    let records: [CheckupRecord]
    
    private var hba1cSeries: [MetricSample] {
        records.metricSamples(\.hba1cNgspPercent)
    }
    
    private var glucoseSeries: [MetricSample] {
        records.metricSamples(\.fastingGlucoseMgdl)
    }
    
    var startDate: Date? { (hba1cSeries + glucoseSeries).map(\.date).min() }
    var endDate: Date? { (hba1cSeries + glucoseSeries).map(\.date).max() }
    
    
    var body: some View {
        VStack {
            
            // --- HbA1c ---
            PutBarChartInContainer(title: "HbA1c") {
                Text("Diabetes threshold is 6.5%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Chart {
                    if let s = startDate, let e = endDate {
                        // Normal band ~4.0–5.6% (visual guide)
                        RectangleMark(
                            xStart: .value("Start", s),
                            xEnd: .value("End", e),
                            yStart: .value("Normal Min", 4.0),
                            yEnd: .value("Normal Max", 5.6)
                        )
                        .foregroundStyle(.blue.opacity(0.12))

                        
                        RuleMark(y: .value("Diabetes", 6.5))
                            .lineStyle(.init(dash: [4, 4]))
                            .annotation(position: .automatic, alignment: .leading) {
                                Text("6.5 %")
                                    .font(.caption)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
                            }
                    }
                    
                    ForEach(hba1cSeries) { s in
                        LineMark(x: .value("Date", s.date),
                                 y: .value("HbA1c", s.value)
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
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.year(.twoDigits).month(.twoDigits).day())
                    }
                }
                .chartYAxisLabel("HbA1c (%)")
                .overlay {
                    if hba1cSeries.isEmpty {
                        NoChartDataView(systemImageName: "flame.fill", title: "No Data", description: "There is no HbA1c data from App.")
                    }
                }
            }
            
            // --- Fasting Glucose ---
            PutBarChartInContainer(title: "Fasting Glucose") {
                Text("Diabetes threshold is 126 mg/dL")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Chart {
                    if let s = startDate, let e = endDate {
                        // Normal band 70–99 mg/dL (visual guide)
                        RectangleMark(
                            xStart: .value("Start", s),
                            xEnd: .value("End", e),
                            yStart: .value("Normal Min", 70),
                            yEnd: .value("Normal Max", 99)
                        )
                        .foregroundStyle(.green.opacity(0.12))
                        
                        RuleMark(y: .value("Diabetes", 126))
                            .lineStyle(.init(dash: [4,4]))
                            .annotation(position: .automatic, alignment: .leading) {
                                Text("126 mg/dL")
                                    .font(.caption)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
                            }
                    }
                    
                    ForEach(glucoseSeries) { s in
                        LineMark(x: .value("Date", s.date),
                                 y: .value("Glucose", s.value)
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
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.year(.twoDigits).month(.twoDigits).day())
                    }
                }
                .chartYAxisLabel("Fating Glucose (mg/dL)")
                .overlay {
                    if glucoseSeries.isEmpty {
                        NoChartDataView(systemImageName: "flame.fill", title: "No Data", description: "There is no Fasting Glucose data from App.")
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    let dates: [Date] = (0..<6).reversed().compactMap {
        Calendar.current.date(byAdding: .month, value: -$0, to: .now)
    }
    let recs: [CheckupRecord] = dates.map { d in
        let r = CheckupRecord(date: d, gender: .male, heightCm: 170, weightKg: 70)
        r.hba1cNgspPercent = Double.random(in: 5.2...7.2)
        r.fastingGlucoseMgdl = Double.random(in: 80...150)
        return r
    }
    MetabolicTestView(records: recs)
        .padding()
}
