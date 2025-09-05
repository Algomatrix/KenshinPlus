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
        VStack {
            HStack(spacing: 20) {
                DataAtGlanceContainerSmall(title: "Body Weight", symbol: "figure", subtitle: "80 Kg", color: .indigo)
                DataAtGlanceContainerSmall(title: "Body Fat", symbol: "figure.walk", subtitle: "19", color: .indigo)
            }
            
            HStack(spacing: 20) {
                DataAtGlanceContainerSmall(title: "BMI", symbol: "figure", subtitle: "19", color: .mint)
                DataAtGlanceContainerSmall(title: "Height", symbol: "ruler", subtitle: "19", color: .mint)
            }
        }
//        .background(RoundedRectangle(cornerRadius: 12, style: .circular).fill(.tertiary.opacity(0.5)))
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Item.self, inMemory: true)
}
