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
    var lineWidth: CGFloat = 16

    // Thresholds for coloring (percent of max)
    var lowThreshold: Double = 0.3
    var highThreshold: Double = 0.7
    var showLabel: Bool = true

    private var progress: Double {
        guard maxValue > 0 else { return 0 }
        return max(0, min(1, value / maxValue))   // clamp 0...1
    }

    private var color: Color {
        switch progress {
        case ..<lowThreshold: return .red
        case ..<highThreshold: return .yellow
        default: return .green
        }
    }
    
    func colorFor(value: Double, normal: ClosedRange<Double>) -> Color {
        if value < normal.lowerBound { return .orange }
        if value > normal.upperBound { return .red }
        return .green
    }

    var body: some View {
        ZStack {
            // Background arc
            Circle()
                .trim(from: 0.0, to: 0.5)
                .rotation(.degrees(180))
                .stroke(Color.gray.opacity(0.2),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

            // Foreground arc
            Circle()
                .trim(from: 0.0, to: progress * 0.5)
                .rotation(.degrees(180))
                .stroke(color,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
        // Half donut wants a 2:1 aspect; give it a fixed height that fits your small card
        .aspectRatio(2, contentMode: .fit)
        .frame(width: 130, height: 90)                // adjust to your container
        .padding(lineWidth / 2)           // avoid clipping the stroke
        .overlay(alignment: .bottom) {    // label stays inside without Spacer
            if showLabel {
                Text("\(Int(value)) / \(Int(maxValue))")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 2)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Value")
        .accessibilityValue("\(Int(value)) of \(Int(maxValue))")
    }
}

#Preview {
    VStack(spacing: 30) {
        DataHoldingContainer(title: "Hemoglobin") {
            HalfDonutChartView(value: 4, maxValue: 20)   // red
        }
        HalfDonutChartView(value: 12, maxValue: 20)  // yellow
        HalfDonutChartView(value: 18, maxValue: 20)  // green
    }
    .padding()
}
