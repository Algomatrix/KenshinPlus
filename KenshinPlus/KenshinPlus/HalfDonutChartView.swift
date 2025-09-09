//
//  HalfDonutChartView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/09.
//

import SwiftUI

struct HalfDonutChartView: View {
    var value: Double
    var maxValue: Double
    var lineWidth: CGFloat = 20
    
    // Thresholds for coloring
    var lowThreshold: Double = 0.3   // 30% of max
    var highThreshold: Double = 0.7  // 70% of max
    
    
    private var progress: Double {
        value / maxValue
    }
    
    private var color: Color {
        switch progress {
        case ..<lowThreshold: return .red      // low values
        case ..<highThreshold: return .yellow  // mid values
        default: return .green                 // good values
        }
    }
    
    var body: some View {
        ZStack {
            // Background arc
            Circle()
                .trim(from: 0.0, to: 0.5)
                .rotation(Angle(degrees: 180))
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            
            // Foreground arc
            Circle()
                .trim(from: 0.0, to: CGFloat(progress) * 0.5)
                .rotation(Angle(degrees: 180))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            
            // Value label
            VStack {
                Spacer()
                Text("\(Int(value)) / \(Int(maxValue))")
                    .font(.headline)
                    .padding()
            }
        }
        .frame(width: 200, height: 120)
        .aspectRatio(2, contentMode: .fit)   // 2:1 for a half-donut
    }
}

#Preview {
    VStack(spacing: 30) {
        DataHoldingContainer(title: "Data") {
            HalfDonutChartView(value: 4, maxValue: 20)   // red
        }
        HalfDonutChartView(value: 12, maxValue: 20)  // yellow
        HalfDonutChartView(value: 18, maxValue: 20)  // green
    }
    .padding()
}
