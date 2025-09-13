//
//  BloodPressureView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/06.
//

import SwiftUI
import Charts

struct BloodPressureView: View {
    var title: String
    var subtitle: String
    var symbol: String
    var color: Color
    var frameHeight: Double

    let mockBloodPressureSamples: [BloodPressureSample]

    var body: some View {
        VStack {
            mainLabelView
                .frame(width: 150)

            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                
                Chart {
                    ForEach(mockBloodPressureSamples) { bloodPressure in
                        BarMark(
                            x: .value("Date", bloodPressure.date, unit: .day),
                            y: .value("Systolic BP", bloodPressure.systolic)
                        )
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
            }
            .frame(height: frameHeight)
            
            
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))

                Chart {
                    ForEach(mockBloodPressureSamples) { bloodPressure in
                        // Create two bars for each blood pressure sample
                        BarMark(
                            x: .value("Date", bloodPressure.date, unit: .day),
                            y: .value("Systolic BP", bloodPressure.diastolic)
                        )
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
            }
            .frame(height: frameHeight) // Adjust height as needed
        }
        .padding()
    }
    
    var mainLabelView: some View {
        VStack {
            Label(title, systemImage: symbol)
                .foregroundStyle(color)
                .frame(alignment: .leading)
            
            Text(subtitle)
                .font(.caption)
        }
    }
}

#Preview {
    let mockData = MockDataForPreview()
    let bloodPressureSamples = mockData.mockSystolicBloodPressure()
    BloodPressureView(title: "Blood Pressure", subtitle: "systolic and daistolic", symbol: "blood.pressure.cuff.badge.gauge.with.needle.fill", color: .red, frameHeight: 150, mockBloodPressureSamples: bloodPressureSamples)
        .frame(height: 50)
}
