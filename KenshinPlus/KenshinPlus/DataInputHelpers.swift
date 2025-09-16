//
//  DataInputHelpers.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/13.
//

import SwiftUI
import Charts

enum LengthUnit: String, CaseIterable, Identifiable {
    case cm = "cm"
    case ft = "ft"
    var id: Self { self }
}

enum Gender: String, CaseIterable, Identifiable {
    case Male = "Male"
    case Female = "Female"
    var id: Self { self }
}

enum WeightUnit: String, CaseIterable, Identifiable {
    case Kg = "Kg"
    case Pounds = "Pounds"
    var id: Self { self }
}

// MARK: - Reusable building blocks

struct PutBarChartInContainer<Content: View>: View {
    let title: String?
    @ViewBuilder var content: () -> Content
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
            VStack {
                if let title = title, !title.isEmpty {
                    Text(title)
                        .padding()
                }
                content()
                    .padding()
            }
        }
    }
}

/// Text + numeric TextField with optional leading/trailing icons/labels.
struct LabeledNumberField: View {
    let title: String
    @Binding var value: Double
    let precision: ClosedRange<Int> // e.g., 0...1
    var unitText: String? = nil
    var systemImage: String? = nil
    var keyboard: UIKeyboardType = .decimalPad

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage { Image(systemName: systemImage) }
            Text(title)
                .scaledToFill()
            TextField(title,
                      value: $value,
                      format: .number.precision(.fractionLength(precision)))
                .textFieldStyle(.roundedBorder)
                .keyboardType(keyboard)
            if let unitText { Text(unitText) }
        }
    }
}

// Small helper for legend chips
struct LabelChip: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Rectangle().frame(width: 10, height: 10).foregroundStyle(color)
            Text(text).font(.caption)
        }
    }
}

struct Usual4Reference: View {
    var body: some View {
        HStack(spacing: 20) {
            LabelChip(color: .green.opacity(0.7), text: "Reference range")
            LabelChip(color: .yellow.opacity(0.7), text: "Slightly abnormal")
            LabelChip(color: .orange.opacity(0.7), text: "Follow-up")
            LabelChip(color: .red.opacity(0.7), text: "Medical care")
        }
    }
}

struct Usual2Reference: View {
    var body: some View {
        HStack(spacing: 20) {
            LabelChip(color: .green.opacity(0.7), text: "Reference range")
            LabelChip(color: .red.opacity(0.7), text: "Require Follow-up")
        }
    }
}

/// A single-row horizontal bar with reference segments and a filled “progress” from domain start to the current value.
struct MeasurementBar: View {
    let title: String
    let value: Double
    let domain: ClosedRange<Double>
    let segments: [RangeSeg]
    var lineColor: Color = .blue
    var valueFormatter: (Double) -> String = { String(format: "%.1f", $0) }

    private var clampedValue: Double {
        min(max(value, domain.lowerBound), domain.upperBound)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Chart {
                // Background reference segments
                ForEach(segments) { seg in
                    BarMark(xStart: .value("Start", seg.start),
                            xEnd:   .value("End", seg.end),
                            y:      .value("Band", title))
                    .foregroundStyle(seg.color)
                }
                // Progress fill from domain lower bound → current value
                RuleMark(xStart: .value("Start", domain.lowerBound),
                        xEnd:   .value("Value", clampedValue),
                        y:      .value("Band", title))
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(lineColor)
                .annotation(position: .topTrailing, alignment: .center) {
                    Text(valueFormatter(value))
                        .font(.caption)
                        .padding(4)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
                }
            }
            .chartXScale(domain: domain)
            .frame(height: 60)
        }
    }
}

struct LegendRow: View {
    let items: [(Color, String)]
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, it in
                LabelChip(color: it.0, text: it.1)
            }
        }
    }
}

#Preview {
    LabeledNumberField(title: "Hello", value: .constant(20.0), precision: 0...2, unitText: nil, systemImage: "figure", keyboard: .decimalPad)
    Usual4Reference()
    Usual2Reference()
}
