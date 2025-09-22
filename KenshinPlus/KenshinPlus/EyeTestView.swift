//
//  EyeTestView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/16.
//

import SwiftUI
import Charts

struct Band: Identifiable { let id = UUID(); let y0: Double; let y1: Double; let color: Color }

struct EyeMetricSample: Identifiable {
    let id = UUID()
    let date: Date
    let eye: EyeSide
    let value: Double
}

struct EyeTestView: View {
    let records: [CheckupRecord]
    
    // Helpers for shaded band extent on X
    private var startDate: Date? { records.map { $0.date }.min() }
    private var endDate: Date? { records.map { $0.date }.max() }
    
    // Derived series
    private var acuity: [EyeMetricSample] { records.acuitySamples(useCorrected: true) }
    private var iop:    [EyeMetricSample] { records.iopSamples() }
    private var near:   [MetricSample]    { records.nearVisionSamples() }
    private var colorLatest: (correct: Int, total: Int)? { records.latestColorVision() }
    private var refrPoints: [(eye: EyeSide, sphere: Double, cylinder: Double)] { records.latestRefractionPoints() }
    private var xDomain: ClosedRange<Date>? { records.eyeDatesDomain }
    
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
                
                if !near.isEmpty {
                    PutBarChartInContainer(title: "Near Vision (Both Eyes)") {
                        nearVision
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: 1) Color Vision (donut-like gauge)
    var colorVisionView: some View {
        PutBarChartInContainer(title: "Color Vision (Shikaku Kensa)") {
            Group {
                if let cv = colorLatest {
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
                    Chart {}
                    .overlay {
                        NoChartDataView(systemImageName: "eye.slash", title: "No Data", description: "There is no color vision data available from App.")
                    }
                }
            }
        }
    }
    
    
    // MARK: 2) Visual Acuity (time-series, grade bands)
    private var visualAcuity: some View {
        Group {
            if acuity.isEmpty || xDomain == nil {
                NoChartDataView(systemImageName: "eye.slash",
                               title: "No Data",
                               description: "There is no Acuity data from the app.")
            } else {
                Chart {
                    // Bands
                    RectangleMark(xStart: .value("Start", Date.distantPast),
                                  xEnd:   .value("End",   Date.distantFuture),
                                  yStart: .value("y0", 1.0),
                                  yEnd:   .value("y1", 1.5))
                    .foregroundStyle(.green.opacity(0.12)).zIndex(0)

                    RectangleMark(xStart: .value("Start", Date.distantPast),
                                  xEnd:   .value("End",   Date.distantFuture),
                                  yStart: .value("y0", 0.7),
                                  yEnd:   .value("y1", 0.99))
                    .foregroundStyle(.blue.opacity(0.10)).zIndex(0)

                    RectangleMark(xStart: .value("Start", Date.distantPast),
                                  xEnd:   .value("End",   Date.distantFuture),
                                  yStart: .value("y0", 0.3),
                                  yEnd:   .value("y1", 0.69))
                    .foregroundStyle(.orange.opacity(0.10)).zIndex(0)

                    RectangleMark(xStart: .value("Start", Date.distantPast),
                                  xEnd:   .value("End",   Date.distantFuture),
                                  yStart: .value("y0", 0.0),
                                  yEnd:   .value("y1", 0.29))
                    .foregroundStyle(.red.opacity(0.10)).zIndex(0)

                    // Lines
                    ForEach(acuity) { p in
                        LineMark(
                            x: .value("Date", p.date, unit: .day),
                            y: .value("Acuity", p.value),
                            series: .value("Eye", p.eye.rawValue)
                        )
                        .symbol(.circle)
                        .interpolationMethod(.linear)
                        .foregroundStyle(by: .value("Eye", p.eye.rawValue))
                    }

                    // Ref line
                    RuleMark(y: .value("A (1.0)", 1.0))
                        .lineStyle(.init(dash: [4,4]))
                        .annotation(position: .automatic, alignment: .leading) {
                            Text("A (≥ 1.0)")
                                .font(.caption2)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
                        }
                }
                .chartXScale(domain: xDomain!) // safe: only in non-empty branch
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).year(.twoDigits))
                    }
                }
                .chartForegroundStyleScale([
                    EyeSide.right.rawValue: .blue,
                    EyeSide.left.rawValue:  .green
                ])
                .frame(height: 200)
                .chartLegend(.automatic)
            }
        }
    }

    // MARK: 3) IOP (grouped bars)
    private var intraocularPressure: some View {
        Group {
            if iop.isEmpty {
                NoChartDataView(systemImageName: "gauge.low",
                               title: "No Data",
                               description: "There is no intraocular pressure data.")
            } else {
                Chart {
                    ForEach(iop.indices, id: \.self) { idx in
                        let p = iop[idx]
                        BarMark(
                            x: .value("Date", p.date, unit: iopBarUnit),
                            y: .value("IOP", p.value)
                        )
                        .foregroundStyle(by: .value("Eye", p.eye.rawValue))
                        .position(by: .value("Eye", p.eye.rawValue))
                    }

                    RuleMark(y: .value("Threshold", 21))
                        .lineStyle(.init(dash: [4,4]))
                        .annotation(position: .automatic, alignment: .leading) {
                            Text("21 mmHg").font(.caption2)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
                        }
                }
                .frame(height: 200)
                .chartLegend(.automatic)
            }
        }
    }
    
    
    // MARK: 4) Refraction snapshot (scatter)
    private var refractionSnapshot: some View {
        Group {
            if refrPoints.isEmpty {
                NoChartDataView(systemImageName: "viewfinder",
                               title: "No Data",
                               description: "There is no refraction snapshot.")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sphere vs Cylinder • closer to (0,0) = weaker correction")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Chart {
                        RuleMark(x: .value("Zero X", 0.0)).foregroundStyle(.secondary.opacity(0.5))
                        RuleMark(y: .value("Zero Y", 0.0)).foregroundStyle(.secondary.opacity(0.5))

                        ForEach(refrPoints, id: \.eye) { p in
                            PointMark(
                                x: .value("Sphere (D)", p.sphere),
                                y: .value("Cylinder (D)", p.cylinder)
                            )
                            .symbol(by: .value("Eye", p.eye.rawValue))
                            .foregroundStyle(by: .value("Eye", p.eye.rawValue))
                            .annotation(position: .topLeading) {
                                Text(String(p.eye.rawValue.prefix(1)))
                                    .font(.caption2)
                            }
                        }
                    }
                    .chartXScale(domain: refractionDomainX(refrPoints))
                    .chartYScale(domain: refractionDomainY(refrPoints))
                    .frame(height: 220)
                }
            }
        }
    }

    // MARK: 5) Near Vision
    private var nearVision: some View {
        Group {
            if near.isEmpty {
                NoChartDataView(systemImageName: "text.viewfinder",
                               title: "No Data",
                               description: "There is no near-vision data.")
            } else {
                Chart {
                    ForEach(near) { p in
                        LineMark(x: .value("Date", p.date),
                                 y: .value("Near Vis", p.value))
                        PointMark(x: .value("Date", p.date),
                                  y: .value("Near Vis", p.value))
                    }
                    RuleMark(y: .value("Reference 1.0", 1.0))
                        .lineStyle(.init(dash: [4,4]))
                        .annotation(position: .automatic, alignment: .leading) {
                            Text("1.0").font(.caption2)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
                        }
                }
                .frame(height: 200)
            }
        }
    }

    // MARK: Helpers
    private var iopBarUnit: Calendar.Component {
        let dates = Array(Set(iop.map { $0.date })).sorted()
        guard dates.count >= 2 else { return .day }
        let diffs = zip(dates.dropFirst(), dates).map { later, earlier in
            Calendar.current.dateComponents([.day], from: earlier, to: later).day ?? 1
        }.sorted()
        let median = diffs[diffs.count / 2]
        switch median {
        case ...1:      return .day
        case 2...10:    return .weekOfYear
        case 11...80:   return .month
        default:        return .year
        }
    }
    
    
    private func refractionDomainX(_ pts: [(eye: EyeSide, sphere: Double, cylinder: Double)]) -> ClosedRange<Double> {
        guard let minV = pts.map({ $0.sphere }).min(),
              let maxV = pts.map({ $0.sphere }).max() else { return -8...4 }
        let pad = max(1.0, (maxV - minV) * 0.2)
        return (minV - pad)...(maxV + pad)
    }
    private func refractionDomainY(_ pts: [(eye: EyeSide, sphere: Double, cylinder: Double)]) -> ClosedRange<Double> {
        guard let minV = pts.map({ $0.cylinder }).min(),
              let maxV = pts.map({ $0.cylinder }).max() else { return -3...1 }
        let pad = max(0.5, (maxV - minV) * 0.2)
        return (minV - pad)...(maxV + pad)
    }
}

// MARK: - Small formatting helpers
fileprivate extension Double {
    func rounded1fString() -> String { String(format: "%.1f", self) }
}

#Preview {
    // 6 monthly samples ending today
    let dates: [Date] = (0..<6).reversed().compactMap {
        Calendar.current.date(byAdding: .month, value: -$0, to: .now)
    }

    // Build records with only the fields we need for EyeTestView.
    // NOTE: This uses a convenience init like:
    //   CheckupRecord(date:gender:heightCm:weightKg:)
    // If your model requires more params (id/createdAt/lengthUnit/weightUnit),
    // pass them explicitly.
    let records: [CheckupRecord] = dates.enumerated().map { idx, d in
        let r = CheckupRecord(date: d, gender: .male, heightCm: 170, weightKg: 70)

        // Visual acuity (JP decimal): simulate a mild improvement trend
        // Prefer corrected if available; we set both for variety.
        r.uncorrectedAcuityRight = 0.6 + 0.05 * Double(idx)           // 0.6 → 0.85
        r.uncorrectedAcuityLeft  = 0.5 + 0.06 * Double(idx)           // 0.5 → 0.8
        r.correctedAcuityRight   = min(1.2, 0.9 + 0.06 * Double(idx)) // 0.9 → 1.2
        r.correctedAcuityLeft    = min(1.2, 0.85 + 0.06 * Double(idx))// 0.85 → 1.15

        // Near vision (both eyes): ~1.0±
        r.nearAcuityBoth = 0.95 + 0.02 * Double(idx % 3)

        // Intraocular pressure (mmHg): keep around normal range
        r.iopRight = 15 + Double((idx % 3) - 1) * 1.5   // 13.5, 15.0, 16.5 …
        r.iopLeft  = 14.5 + Double((idx % 3) - 1) * 1.2 // 13.3, 14.5, 15.7 …

        // Color vision: set only on the latest record so "latest" logic kicks in
        if idx == dates.count - 1 {
            r.colorPlatesCorrect = 15
            r.colorPlatesTotal   = 15
        }

        // Refraction (diopters): set only on the latest record for the snapshot
        if idx == dates.count - 1 {
            r.refractionSphereRight   = -2.25
            r.refractionCylinderRight = -0.75
            r.refractionSphereLeft    = -1.75
            r.refractionCylinderLeft  = -0.50
        }

        return r
    }

    return EyeTestView(records: records)
        .padding()
}
