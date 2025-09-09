//
//  ContentView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/05.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    let mockData = MockDataForPreview()
    var body: some View {
        let mockBloodData = mockData.mockBloodTestSeries()
        let mockLiverData = mockData.mockLiverTestSeries()
        let mockKidneyData = mockData.mockKidneyTestSeries()
        let mockMetabolismData = mockData.mockMetabolismTestSeries()

        NavigationStack {
            ScrollView {
                VStack {
                    HStack(spacing: 20) {
                        DataAtGlanceContainerSmall(title: "Body Weight", symbol: "figure", subtitle: "80 Kg", color: .indigo)
                        DataAtGlanceContainerSmall(title: "Body Fat", symbol: "figure.walk", subtitle: "19", color: .indigo)
                    }
                    
                    HStack(spacing: 20) {
                        DataAtGlanceContainerSmall(title: "BMI", symbol: "figure", subtitle: "19", color: .mint)
                        DataAtGlanceContainerSmall(title: "Height", symbol: "ruler", subtitle: "19", color: .mint)
                    }
                    
                    HStack(spacing: 20) {
                        NavigationLink(
                            destination: BloodPressureView(title: "Blood Pressure", subtitle: "Systolic and Diastolic", symbol: "blood.pressure.cuff.badge.gauge.with.needle.fill", color: .red, frameHeight: 300, mockBloodPressureSamples: MockDataForPreview().mockSystolicBloodPressure())
                        ) {
                            DataAtGlanceContainerSmall(
                                title: "Blood Pressure",
                                symbol: "heart",
                                subtitle: "Systolic and Diastolic",
                                color: .red
                            )
                        }

                        NavigationLink(
                            destination: BloodTestChartView(data: mockBloodData)
                        ) {
                            DataAtGlanceContainerSmall(
                                title: "Blood Test",
                                symbol: "syringe.fill",
                                subtitle: "RBC, WBC, etc",
                                color: .red
                            )
                        }
                    }
                }
                
                // Liver and Uric Acid
                HStack(spacing: 20) {
                    NavigationLink(
                        destination: LiverTestView(data: mockLiverData)
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Liver Info",
                            symbol: "chart.line.text.clipboard.fill",
                            subtitle: "Systolic and Diastolic",
                            color: .red
                        )
                    }
                    
                    NavigationLink(
                        destination: KidneyTestView(data: mockKidneyData)
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Uric Acid",
                            symbol: "vial.viewfinder",
                            subtitle: "Creatine and Uric Acid",
                            color: .red
                        )
                    }
                }
                
                // Metabolism and Cholesterol
                HStack(spacing: 20) {
                    NavigationLink(
                        destination: MetabolicTestView(samples: mockMetabolismData)
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Metabolism",
                            symbol: "flame.fill",
                            subtitle: "HbA1c, Fasting Glucose",
                            color: .orange
                        )
                    }
                    
                    NavigationLink(
                        destination: EmptyView()
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Cholesterol",
                            symbol: "heart.circle",
                            subtitle: "Creatine and Uric Acid",
                            color: .orange
                        )
                    }
                }
                
                // Eyesight and Hearing
                HStack(spacing: 20) {
                    NavigationLink(
                        destination: EmptyView()
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Eyesight",
                            symbol: "eye",
                            subtitle: "Left and Right",
                            color: .green
                        )
                    }
                    
                    NavigationLink(
                        destination: EmptyView()
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Hearing",
                            symbol: "ear.badge.waveform",
                            subtitle: "Left and Right",
                            color: .green
                        )
                    }
                }
            }
            .navigationTitle("Health Dashboard")
            .padding()
        }
//        .background(RoundedRectangle(cornerRadius: 12, style: .circular).fill(.tertiary.opacity(0.5)))
    }
}

#Preview {
    DashboardView()
}

//#Preview {
//    DashboardView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
