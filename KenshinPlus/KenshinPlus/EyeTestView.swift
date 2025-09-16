//
//  EyeTestView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/16.
//

import SwiftUI
import Charts

struct Band: Identifiable { let id = UUID(); let y0: Double; let y1: Double; let color: Color }

struct EyeTestView: View {
    let sample: [EyeExamSample]
    
    // Helpers for shaded band extent on X
    private var startDate: Date? { sample.map { $0.date }.min() }
    private var endDate: Date? { sample.map { $0.date }.max() }
    
    // Derived series
    private var acuitySeries: [(date: Date, eye: String, value: Double)] {
        sample.flatMap { s in
            let r = (s.correctedRight ?? s.uncorrectedRight)
            let l = (s.correctedLeft  ?? s.uncorrectedLeft)
            return [
                (date: s.date, eye: "Right", value: r),
                (date: s.date, eye: "Left", value: l)
            ]
        }
        .sorted { $0.date < $1.date }
    }
    
    private var iopSeries: [(date: Date, eye: String, value: Double)] {
        sample.compactMap { s -> [(Date, String, Double)]? in
            guard let r = s.iopRight, let l = s.iopLeft else { return nil }
            return [(s.date, "Right", r), (s.date, "Left", l)]
        }
        .flatMap { $0 }
        .sorted { $0.0 < $1.0 }
    }
    
    private var nearVisionSeries: [(date: Date, value: Double)] {
        sample.compactMap { s in
            guard let v = s.nearBothEyes else { return nil }
            return (s.date, v)
        }
        .sorted { $0.date < $1.date }
    }
    
    private var colorVisionLatest: (correct: Int, total: Int)? {
        // Use the most recent entry that has color data
        sample.sorted { $0.date > $1.date }
            .compactMap { s -> (Int, Int)? in
                if let c = s.colorPlatesCorrect, let t = s.colorPlatesTotal { return (c, t) }
                return nil
            }
            .first
    }
    
    private var refractionPoints: [(eye: String, sphere: Double, cylinder: Double)] {
        // Use most recent with refraction available
        guard let s = sample.sorted(by: { $0.date > $1.date }).first else { return [] }
        var arr: [(String, Double, Double)] = []
        if let rr = s.refractionRight { arr.append(("Right", rr.sphere, rr.cylinder)) }
        if let rl = s.refractionLeft  { arr.append(("Left",  rl.sphere, rl.cylinder)) }
        return arr
    }
    
    // MARK: Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                colorVisionView
                
                PutBarChartInContainer(title: "Visual Acuity (JP decimal)") {
                    visualAcuity
                }
                
                PutBarChartInContainer(title: "Intraocular Pressure (mmHg)") {
                    intraocularPressure
                }
                
                PutBarChartInContainer(title: "Refraction Snapshot (most recent)") {
                    refractionSnapshot
                }
                
                if !nearVisionSeries.isEmpty {
                    PutBarChartInContainer(title: "Near Vision (Both Eyes)") {
                        nearVision
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Helpers for refraction chart domains
    private func refractionDomainX(_ pts: [(eye: String, sphere: Double, cylinder: Double)]) -> ClosedRange<Double> {
        guard let minV = pts.map({ $0.sphere }).min(),
              let maxV = pts.map({ $0.sphere }).max() else {
            return -8...4
        }
        let pad = max(1.0, (maxV - minV) * 0.2)
        return (minV - pad)...(maxV + pad)
    }
    
    private func refractionDomainY(_ pts: [(eye: String, sphere: Double, cylinder: Double)]) -> ClosedRange<Double> {
        guard let minV = pts.map({ $0.cylinder }).min(),
              let maxV = pts.map({ $0.cylinder }).max() else {
            return -3...1
        }
        let pad = max(0.5, (maxV - minV) * 0.2)
        return (minV - pad)...(maxV + pad)
    }
    
    // MARK: 1) Color Vision (donut-like gauge)
    var colorVisionView: some View {
        PutBarChartInContainer(title: "Color Vision (Shikaku Kensa)") {
            Group {
                if let cv = colorVisionLatest {
                    let percent = Double(cv.correct) / Double(cv.total)
                    HStack(alignment: .center, spacing: 16) {
                        Gauge(value: percent, in: 0...1) {
                            Text("Color Vision")
                        } currentValueLabel: {
                            Text("\((percent * 100).rounded1fString())%")
                        }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .frame(width: 80, height: 80)
                        
                        VStack(alignment: .leading) {
                            Text("\(cv.correct) / \(cv.total) plates correct")
                            Text(percent >= 0.85 ? "Status: Normal" : "Status: Deficiency suspected")
                                .foregroundStyle(percent >= 0.85 ? .green : .orange)
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                } else {
                    Text("No color vision data available.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        
    }
    
    private var acuityPoints: [AcuityPoint] {
        sample.flatMap { s in
            [
                AcuityPoint(
                    id: "R-\(s.date.timeIntervalSince1970)",
                    date: s.date,
                    eye: .right,
                    value: s.correctedRight ?? s.uncorrectedRight
                ),
                AcuityPoint(
                    id: "L-\(s.date.timeIntervalSince1970)",
                    date: s.date,
                    eye: .left,
                    value: s.correctedLeft ?? s.uncorrectedLeft
                )
            ]
        }
        .sorted { $0.date < $1.date }
    }
    
    // MARK: 2) Visual Acuity (time-series, grade bands)
    
    var visualAcuity: some View {
        Group {
            let bands: [Band] = [
                .init(y0: 1.0, y1: 1.5, color: .green.opacity(0.2)),   // A
                .init(y0: 0.7, y1: 0.99, color: .blue.opacity(0.2)),   // B
                .init(y0: 0.3, y1: 0.69, color: .orange.opacity(0.2)), // C
                .init(y0: 0.0, y1: 0.29, color: .red.opacity(0.2))     // D
            ]
            
            if let domain = acuityXDomain {
                Chart {
                    // grade bands
                    ForEach(bands) { band in
                        RectangleMark(
                            xStart: .value("Start", domain.lowerBound, unit: .day),
                            xEnd:   .value("End", domain.upperBound, unit: .day),
                            yStart: .value("y0", band.y0),
                            yEnd:   .value("y1", band.y1)
                        )
                        .foregroundStyle(band.color)
                        .zIndex(0) // keep bands behind lines
                    }
                    
                    // one LineMark definition; Charts splits by series value
                    ForEach(acuityPoints) { p in
                        LineMark(
                            x: .value("Date", p.date, unit: iopBarUnit),
                            y: .value("Acuity", p.value),
                            series: .value("Eye", p.eye.rawValue)
                        )
                        .foregroundStyle(by: .value("Eye", p.eye.rawValue))
                        .interpolationMethod(.linear)   // avoids spline overshoot
                        .symbol(.circle)
                    }
                    
                    RuleMark(y: .value("A (1.0)", 1.0))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
                    
                    // anchor annotation at the right edge
                    if let x1 = endDate {
                        PointMark(x: .value("Date", x1, unit: .day),
                                  y: .value("A (1.0)", 1.0))
                        .opacity(0)
                        .annotation(position: .bottomTrailing) {
                            Text("A (≥ 1.0)").font(.caption2)
                        }
                    }
                }
                .chartXScale(domain: domain)
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).year(.twoDigits))
                    }
                }
                .chartForegroundStyleScale([
                    EyeSide.right.rawValue: .blue,
                    EyeSide.left.rawValue:  .green
                ])
                .frame(height: 220)
                .chartLegend(.automatic)
            } else {
                Text("Not enough data to plot acuity.")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: 3) Intraocular Pressure (grouped bars)
    var intraocularPressure: some View {
        Group {
            Chart {
                ForEach(iopSeries.indices, id: \.self) { idx in
                    let p = iopSeries[idx]
                    BarMark(
                        x: .value("Date", p.date, unit: iopBarUnit),
                        y: .value("IOP", p.value)
                    )
                    .foregroundStyle(by: .value("Eye", p.eye))
                    .position(by: .value("Eye", p.eye)) // group by eye
                }
                
                // Threshold for glaucoma screening ~21 mmHg
                if let end = endDate {
                    RuleMark(y: .value("Threshold", 21))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
                    
                    PointMark(x: .value("Date", end), y: .value("IOP", 21))
                        .opacity(0)
                        .annotation(position: .topTrailing) {
                            Text("Threshold 21").font(.caption2)
                        }
                }
                RuleMark(y: .value("Threshold", 21))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
            }
            
            .frame(height: 200)
            .accessibilityLabel("Intraocular pressure grouped by eye")
        }
    }
    
    // MARK: 4) Refraction scatter (Sphere vs Cylinder)
    var refractionSnapshot: some View {
        Group {
            Text("Sphere vs Cylinder • closer to (0,0) = weaker correction")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Chart {
                // Quadrant reference lines
                RuleMark(x: .value("Zero", 0.0))
                    .foregroundStyle(.secondary.opacity(0.5))
                RuleMark(y: .value("Zero", 0.0))
                    .foregroundStyle(.secondary.opacity(0.5))
                
                ForEach(refractionPoints, id: \.eye) { p in
                    PointMark(
                        x: .value("Sphere (D)", p.sphere),
                        y: .value("Cylinder (D)", p.cylinder)
                    )
                    .symbol(by: .value("Eye", p.eye))
                    .foregroundStyle(by: .value("Eye", p.eye))
                    .annotation(position: .topLeading) {
                        Text(p.eye.prefix(1))
                            .font(.caption2)
                    }
                }
            }
            .chartXScale(domain: refractionDomainX(refractionPoints))
            .chartYScale(domain: refractionDomainY(refractionPoints))
            .frame(height: 220)
            .accessibilityLabel("Refraction scatter plot")
        }
    }
    
    // MARK: 5) Near Vision (if available)
    var nearVision: some View {
        Group {
            Chart {
                ForEach(nearVisionSeries, id: \.date) { p in
                    LineMark(
                        x: .value("Date", p.date),
                        y: .value("Near Vis", p.value)
                    )
                    .interpolationMethod(.monotone)
                    .symbol(Circle())
                }
                RuleMark(y: .value("Reference 1.0", 1.0))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
                
                if let date = nearVisionSeries.last?.date {
                    PointMark(x: .value("Date", date), y: .value("IOP", 1))
                        .opacity(0)
                        .annotation(position: .topTrailing) {
                            Text("Ref 1.0").font(.caption2)
                        }
                }
                
                
            }
            .frame(height: 200)
            .accessibilityLabel("Near vision over time")
        }
    }
    
    private var iopBarUnit: Calendar.Component {
        let dates = Array(Set(iopSeries.map { $0.date })).sorted()
        guard dates.count >= 2 else { return .day }
        let diffs = zip(dates.dropFirst(), dates).map { later, earlier in
            Calendar.current.dateComponents([.day], from: earlier, to: later).day ?? 1
        }.sorted()
        
        let median = diffs[diffs.count / 2]
        switch median {
        case ...1:
            return .day
        case 2...10:
            return .weekOfYear
        case 11...80:
            return .month
        default:
            return .year
        }
    }
    
    // 1) Padded X domain
    private var acuityXDomain: ClosedRange<Date>? {
        guard let minD = sample.map(\.date).min(),
              let maxD = sample.map(\.date).max()
        else { return nil }
        let cal = Calendar.current
        let lo = cal.date(byAdding: .day, value: -1, to: minD)!  // left pad
        let hi = cal.date(byAdding: .day, value:  +1, to: maxD)! // right pad
        return lo...hi
    }
}

enum EyeSide: String, CaseIterable {
    case right = "Right"
    case left  = "Left"
}

struct AcuityPoint: Identifiable {
    let id: String
    let date: Date
    let eye: EyeSide
    let value: Double
}

// MARK: - Small formatting helpers
fileprivate extension Double {
    func rounded1fString() -> String {
        String(format: "%.1f", self)
    }
}

#Preview {
    let mockTest = MockDataForPreview()
    EyeTestView(sample: mockTest.mockEyeExamSeries(count: 6))
}
