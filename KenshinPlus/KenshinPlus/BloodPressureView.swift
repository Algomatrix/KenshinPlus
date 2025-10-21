//
//  BloodPressureView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/06.
//

import SwiftUI
import Charts

struct BloodPressureView: View {
    var title: LocalizedStringResource
    var subtitle: LocalizedStringResource
    var symbol: String
    var color: Color
    let records: [CheckupRecord]

// MARK: Main body
    var body: some View {
        VStack {
            mainLabelView
                .frame(width: 150)

                PutBarChartInContainer(title: "Systolic") {
                    systolicChart
                }

                PutBarChartInContainer(title: "Diastolic") {
                    diastolicChart
                }
        }
        .padding()
    }

// MARK: Views of Main Body
    private var mainLabelView: some View {
        VStack {
            Label(title, systemImage: symbol).foregroundStyle(color)
            Text(subtitle).font(.caption)
        }
    }
    
    var systolicChart: some View {
        let systolic = records.metricSamples(\.systolic)

        return Chart {
            ForEach(systolic) { bloodPressure in
                LineMark (
                    x: .value("Date", bloodPressure.date, unit: .day),
                    y: .value("Systolic BP", bloodPressure.value)
                )
                .symbol(.circle)
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.red)
            }
        }
        .chartXAxis {
            AxisMarks {
                AxisValueLabel(format: .dateTime.month(.twoDigits).day())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                    .foregroundStyle(Color.secondary.opacity(0.3))
                AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
            }
        }
        .padding() // So the chart doesn't touch the edges of the background
        .overlay {
            if systolic.isEmpty {
                NoChartDataView(systemImageName: "drop.degreesign.slash", title: "No Data", description: "There is no blood pressure data from App.")
            }
        }
    }
    
    var diastolicChart: some View {
        let diastolic = records.metricSamples(\.diastolic)

        return Chart {
            ForEach(diastolic) { bloodPressure in
                // Create two bars for each blood pressure sample
                LineMark (
                    x: .value("Date", bloodPressure.date, unit: .day),
                    y: .value("Systolic BP", bloodPressure.value)
                )
                .symbol(.circle)
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.blue) // Systolic bar color
            }
        }
        .chartXAxis {
            AxisMarks {
                AxisValueLabel(format: .dateTime.month(.twoDigits).day())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                    .foregroundStyle(Color.secondary.opacity(0.3))
                AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
            }
        }
        .padding()
        .overlay {
            if diastolic.isEmpty {
                NoChartDataView(systemImageName: "drop.degreesign.slash", title: "No Data", description: "There is no blood pressure data from App.")
            }
        }
    }
}

#Preview {
    let dates: [Date] = (0..<7).reversed().compactMap {
        Calendar.current.date(byAdding: .day, value: -$0, to: .now)
    }
    let recs: [CheckupRecord] = dates.map { d in
        let r = CheckupRecord(date: d, gender: .male, heightCm: 170, weightKg: 70)
        r.systolic = Double(118 + Int.random(in: -8...8))
        r.diastolic = Double(76 + Int.random(in: -6...6))
        return r
    }

    BloodPressureView(
        title: "Blood Pressure",
        subtitle: "Systolic and Diastolic",
        symbol: "blood.pressure.cuff.badge.gauge.with.needle.fill",
        color: .red,
        records: recs
    )
}
