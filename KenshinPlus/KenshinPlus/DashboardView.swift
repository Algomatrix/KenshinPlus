//
//  ContentView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/05.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    var body: some View {
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
                        let mockData = MockDataForPreview()
                        let mockBloodData = mockData.mockBloodTestSeries()

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
