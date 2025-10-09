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
    @Binding var value: Double?
    var unitText: String? = nil
    var systemImage: String? = nil
    var keyboard: UIKeyboardType = .decimalPad
    var precision: Int = 2
    var color: Color? = nil

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    init(title: String,
         value: Binding<Double?>,
         precision: Int = 2,
         unitText: String? = nil,
         systemImage: String? = nil,
         keyboard: UIKeyboardType = .decimalPad,
         color: Color? = nil)
    {
        self.title = title
        self._value = value
        self.unitText = unitText
        self.systemImage = systemImage
        self.keyboard = keyboard
        self.precision = precision
        self.color = color
        // Prefill ONCE, but formatted (not raw Double)
        let v = value.wrappedValue
        self._text = State(initialValue: v.map { Self.format($0, precision: precision) } ?? "")
    }

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage { Image(systemName: systemImage).foregroundStyle(color ?? .clear) }
            Text(title)
            Spacer()
            TextField("", text: $text)
                .keyboardType(keyboard)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100, alignment: .trailing)
                .focused($isFocused)
                // 1) User typing → parse only (don’t over-format while editing)
                .onChange(of: text) { _, new in
                    value = parse(new)
                }
                // 2) Model changes (e.g., unit switch) → if not editing, show formatted
                .onChange(of: value) { _, new in
                    guard !isFocused else { return }
                    text = new.map { Self.format($0, precision: precision) } ?? ""
                }
                // 3) Editing ended → format once with requested precision
                .onChange(of: isFocused) { _, nowFocused in
                    guard !nowFocused else { return }
                    if let v = value {
                        text = Self.format(v, precision: precision)
                    } else {
                        text = ""
                    }
                }

            if let unitText { Text(unitText).foregroundStyle(.secondary) }
        }
    }

    // Locale-aware parse using NumberFormatter (handles "," vs ".")
    private func parse(_ s: String) -> Double? {
        let nf = Self.makeFormatter(precision: precision)
        // Allow both "," and "." while typing by normalizing only if needed
        if let n = nf.number(from: s) { return n.doubleValue }
        // Fallback: replace comma with dot for safety
        return Double(s.replacingOccurrences(of: ",", with: ".")
                        .trimmingCharacters(in: .whitespacesAndNewlines))
    }

    // MARK: - Formatting helpers
    private static func makeFormatter(precision: Int) -> NumberFormatter {
        let nf = NumberFormatter()
        nf.locale = .current
        nf.numberStyle = .decimal
        nf.usesGroupingSeparator = false
        nf.minimumFractionDigits = precision
        nf.maximumFractionDigits = precision
        return nf
    }

    private static func format(_ v: Double, precision: Int) -> String {
        let nf = makeFormatter(precision: precision)
        return nf.string(from: NSNumber(value: v)) ?? String(format: "%.\(precision)f", v)
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
    LabeledNumberField(title: "Hello", value: .constant(20.0), precision: 2, unitText: nil, systemImage: "figure", keyboard: .decimalPad, color: .blue)
    Usual4Reference()
    Usual2Reference()
}
