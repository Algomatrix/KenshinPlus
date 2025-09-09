//
//  BloodTestChartView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/09.
//

import SwiftUI
import Charts

struct BloodTestChartView: View {
    let data: [(date: Date, sample: BloodTestSample)]
    
    /// Get latest date and sample related to that date
    private var latest: BloodTestSample? {
        data.max(by: { $0.date < $1.date })?.sample
    }
    
    private func colorFor(value: Double, normal: ClosedRange<Double>) -> Color {
        if value < normal.lowerBound { return .orange }
        if value > normal.upperBound { return .red }
        return .green
    }

    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.black).opacity(0.8))
                    
                    VStack {
                        HStack {
                            DataHoldingContainer(title: "Red blood cells") {
                                if let healthData = latest {
                                    HalfDonutChartView(
                                        value: healthData.rbc,
                                        maxValue: 8,
                                        lineWidth: 12
                                    )
                                    .tint(colorFor(value: healthData.hemoglobin, normal: 4.5...5.5))
                                }
                            }
                            DataHoldingContainer(title: "White blood cells") {
                                if let healthData = latest {
                                    HalfDonutChartView(
                                        value: healthData.wbc,
                                        maxValue: 11.0,
                                        lineWidth: 12
                                    )
                                    .tint(colorFor(value: healthData.wbc, normal: 3...8))
                                }
                            }
                        }
                        
                        HStack {
                            DataHoldingContainer(title: "Hemoglobin") {
                                if let healthData = latest {
                                    HalfDonutChartView(
                                        value: healthData.rbc,
                                        maxValue: 20,
                                        lineWidth: 12
                                    )
                                    .tint(colorFor(value: healthData.hemoglobin, normal: 13.5...17.5))
                                }
                            }
                            DataHoldingContainer(title: "Hematocrit") {
                                if let healthData = latest {
                                    HalfDonutChartView(
                                        value: healthData.hematocrit,
                                        maxValue: 50,
                                        lineWidth: 12
                                    )
                                    .tint(colorFor(value: healthData.hemoglobin, normal: 38.3...48.6))
                                }
                            }
                        }
                        
                        HStack {
                            DataHoldingContainer(title: "Platelet") {
                                if let healthData = latest {
                                    HalfDonutChartView(
                                        value: healthData.platelet,
                                        maxValue: 550,
                                        lineWidth: 12
                                    )
                                    .tint(colorFor(value: healthData.hemoglobin, normal: 150...450))
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                PutBarChartInContainer {
                    Chart(data, id: \.date) { entry in
                        BarMark (
                            x: .value("Date", entry.date),
                            y: .value("WBC", entry.sample.wbc)
                        )
                    }
                }
                
                PutBarChartInContainer {
                    Chart(data, id: \.date) { entry in
                        BarMark (
                            x: .value("Date", entry.date),
                            y: .value("RBC", entry.sample.rbc)
                        )
                    }
                }
                
                PutBarChartInContainer {
                    Chart(data, id: \.date) { entry in
                        BarMark (
                            x: .value("Date", entry.date),
                            y: .value("Hemoglobin", entry.sample.hemoglobin)
                        )
                    }
                }
                
                PutBarChartInContainer {
                    Chart(data, id: \.date) { entry in
                        BarMark (
                            x: .value("Date", entry.date),
                            y: .value("Hematocrit", entry.sample.hematocrit)
                        )
                    }
                }
            }
        }
    }
}

struct PutBarChartInContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
            
            content()
                .padding()
        }
    }
}

#Preview {
    let mock = MockDataForPreview()
    return BloodTestChartView(data: mock.mockBloodTestSeries())
}
