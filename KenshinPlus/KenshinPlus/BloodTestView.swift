//
//  BloodTestChartView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/09.
//

import SwiftUI
import Charts

struct BloodTestView: View {
    let records: [CheckupRecord]
    
    private func colorFor(value: Double, normal: ClosedRange<Double>) -> Color {
        if value < normal.lowerBound { return .orange }
        if value > normal.upperBound { return .red }
        return .green
    }

    // Series per metric
    private var wbcSeries: [MetricSample] {
        records.metricSamples(\.wbcThousandPeruL)
    }

    private var rbcSeries: [MetricSample] {
        records.metricSamples(\.rbcMillionPeruL)
    }

    private var hgbSeries: [MetricSample] {
        records.metricSamples(\.hgbPerdL)
    }

    private var hctSeries: [MetricSample] {
        records.metricSamples(\.hctPercent)
    }

    private var pltSeries: [MetricSample] {
        records.metricSamples(\.pltThousandPeruL)
    }

    // Latest Values
    private var latestWBC: Double? { records.latestValue(\.wbcThousandPeruL) }
    private var latestRBC: Double? { records.latestValue(\.rbcMillionPeruL) }
    private var lastestHGB: Double? { records.latestValue(\.hgbPerdL) }
    private var lastestHCT: Double? { records.latestValue(\.hctPercent) }
    private var lastestPLT: Double? { records.latestValue(\.pltThousandPeruL) }

    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))

                    VStack {
                        HStack {
                            DataHoldingContainer(title: "Red blood cells (Latest)") {
                                if let rcbValue = latestRBC {
                                    HalfDonutChartView(
                                        value: rcbValue,
                                        maxValue: 8,
                                        lineWidth: 12
                                    )
                                    .tint(colorFor(value: rcbValue, normal: 4.5...5.5))
                                }
                            }
                            .overlay {
                                if rbcSeries.isEmpty {
                                    Text("No Data")
                                        .foregroundStyle(.secondary)
                                }
                            }

                            DataHoldingContainer(title: "White blood cells (Latest)") {
                                if let wbcValue = latestWBC {
                                    HalfDonutChartView(
                                        value: wbcValue,
                                        maxValue: 11.0,
                                        lineWidth: 12
                                    )
                                    .tint(colorFor(value: wbcValue, normal: 3...8))
                                }
                            }
                            .overlay {
                                if wbcSeries.isEmpty {
                                    Text("No Data")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        HStack {
                            DataHoldingContainer(title: "Hemoglobin (Latest)") {
                                if let hgbValue = lastestHGB {
                                    HalfDonutChartView(
                                        value: hgbValue,
                                        maxValue: 20,
                                        lineWidth: 12
                                    )
                                    .tint(colorFor(value: hgbValue, normal: 13.5...17.5))
                                }
                            }
                            .overlay {
                                if hgbSeries.isEmpty {
                                    Text("No Data")
                                        .foregroundStyle(.secondary)
                                }
                            }

                            DataHoldingContainer(title: "Hematocrit (Latest)") {
                                if let hctValue = lastestHCT {
                                    HalfDonutChartView(
                                        value: hctValue,
                                        maxValue: 50,
                                        lineWidth: 12
                                    )
                                    .tint(colorFor(value: hctValue, normal: 38.3...48.6))
                                }
                            }
                            .overlay {
                                if hctSeries.isEmpty {
                                    Text("No Data")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        HStack {
                            DataHoldingContainer(title: "Platelet (Latest)") {
                                if let pltValue = lastestPLT {
                                    HalfDonutChartView(
                                        value: pltValue,
                                        maxValue: 550,
                                        lineWidth: 12
                                    )
                                    .tint(colorFor(value: pltValue, normal: 150...450))
                                }
                            }
                            .overlay {
                                if pltSeries.isEmpty {
                                    Text("No Data")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                }

                PutBarChartInContainer(title: "Red Blood Cell (RBC)")  {
                    Chart(rbcSeries) { entry in
                        LineMark (
                            x: .value("Date", ChartAxis.startOfDay(entry.date)),
                            y: .value("RBC", entry.value)
                        )
                        .symbol(.circle)
                        .interpolationMethod(.monotone)
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                    .chartXAxis { ChartAxis.axisAtDataDates(rbcSeries, date: \.date) }
                    .chartScrollableAxes(.horizontal)
                    .overlay {
                        if rbcSeries.isEmpty {
                            NoChartDataView(systemImageName: "drop.degreesign.slash", title: "No Data", description: "There is no RBC data from App.")
                        }
                    }
                }

                PutBarChartInContainer(title: "White Blood Cell (WBC)")  {
                    Chart(wbcSeries) { entry in
                        LineMark (
                            x: .value("Date", ChartAxis.startOfDay(entry.date)),
                            y: .value("WBC", entry.value)
                        )
                        .symbol(.circle)
                        .interpolationMethod(.monotone)
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                    .chartXAxis { ChartAxis.axisAtDataDates(wbcSeries, date: \.date) }
                    .chartScrollableAxes(.horizontal)
                    .overlay {
                        if wbcSeries.isEmpty {
                            NoChartDataView(systemImageName: "drop.degreesign.slash", title: "No Data", description: "There is no WBC data from App.")
                        }
                    }
                }

                PutBarChartInContainer(title: "Hemoglobin")  {
                    Chart(hgbSeries) { entry in
                        LineMark (
                            x: .value("Date", ChartAxis.startOfDay(entry.date)),
                            y: .value("Hemoglobin", entry.value)
                        )
                        .symbol(.circle)
                        .interpolationMethod(.monotone)
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                    .chartXAxis { ChartAxis.axisAtDataDates(hgbSeries, date: \.date) }
                    .chartScrollableAxes(.horizontal)
                    .overlay {
                        if hgbSeries.isEmpty {
                            NoChartDataView(systemImageName: "drop.degreesign.slash", title: "No Data", description: "There is no Hemoglobin data from App.")
                        }
                    }
                }

                PutBarChartInContainer(title: "Hematocrit")  {
                    Chart(hctSeries) { entry in
                        LineMark (
                            x: .value("Date", ChartAxis.startOfDay(entry.date)),
                            y: .value("Hematocrit", entry.value)
                        )
                        .symbol(.circle)
                        .interpolationMethod(.monotone)
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                    .chartXAxis { ChartAxis.axisAtDataDates(hctSeries, date: \.date) }
                    .chartScrollableAxes(.horizontal)
                    .overlay {
                        if hctSeries.isEmpty {
                            NoChartDataView(systemImageName: "drop.degreesign.slash", title: "No Data", description: "There is no Hematocrit data from App.")
                        }
                    }
                }

                PutBarChartInContainer(title: "Platelet")  {
                    Chart(pltSeries) { entry in
                        LineMark (
                            x: .value("Date", ChartAxis.startOfDay(entry.date)),
                            y: .value("Platelet", entry.value)
                        )
                        .symbol(.circle)
                        .interpolationMethod(.monotone)
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .offset(x: 8)
                        }
                    }
                    .chartXAxis { ChartAxis.axisAtDataDates(pltSeries, date: \.date) }
                    .chartScrollableAxes(.horizontal)
                    .overlay {
                        if pltSeries.isEmpty {
                            NoChartDataView(systemImageName: "drop.degreesign.slash", title: "No Data", description: "There is no Platelet data from App.")
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
        r.wbcThousandPeruL = Double.random(in: 4.5...10.5)
        r.rbcMillionPeruL = Double.random(in: 4.2...5.8)
        r.hgbPerdL = Double.random(in: 12.5...17.0)
        r.hctPercent = Double.random(in: 36.0...50.0)
        r.pltThousandPeruL = Double.random(in: 180.0...420.0)
        return r
    }
    return BloodTestView(records: recs)
}
