//
//  BloodPressureView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/06.
//

import SwiftUI
import Charts

struct BloodPressureSample: Identifiable {
    let id = UUID()
    let date: Date
    let systolic: Double
    let diastolic: Double
}

struct BloodPressureView: View {
    var title: String
    var subtitle: String
    var symbol: String
    var color: Color
    var frameHeight: Double
    let records: [CheckupRecord]

    private var samples: [BloodPressureSample] { records.bpSamples() }

//    let mockBloodPressureSamples: [BloodPressureSample] // MockData for future use

// MARK: Main body
    var body: some View {
        VStack {
            mainLabelView
                .frame(width: 150)

            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                
                systolicChart
            }
            .frame(height: frameHeight)
            
            
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))

                diastolicChart
            }
            .frame(height: frameHeight) // Adjust height as needed
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
        Chart {
            ForEach(samples) { bloodPressure in
                LineMark (
                    x: .value("Date", bloodPressure.date, unit: .day),
                    y: .value("Systolic BP", bloodPressure.systolic)
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
            if samples.isEmpty {
                NoChartDataView(systemImageName: "drop.degreesign.slash", title: "No Data", description: "There is no blood pressure data from App.")
            }
        }
    }
    
    var diastolicChart: some View {
        Chart {
            ForEach(samples) { bloodPressure in
                // Create two bars for each blood pressure sample
                LineMark (
                    x: .value("Date", bloodPressure.date, unit: .day),
                    y: .value("Systolic BP", bloodPressure.diastolic)
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
            if samples.isEmpty {
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
        frameHeight: 150,
        records: recs
    )
}

// MARK: For mockdata
//#Preview {
//    let mockData = MockDataForPreview()
//    let bloodPressureSamples = mockData.mockSystolicBloodPressure()
//    BloodPressureView(title: "Blood Pressure", subtitle: "systolic and daistolic", symbol: "blood.pressure.cuff.badge.gauge.with.needle.fill", color: .red, frameHeight: 150, mockBloodPressureSamples: bloodPressureSamples)
//        .frame(height: 50)
//}
