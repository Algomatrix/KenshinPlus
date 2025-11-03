//
//  Extensions.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/17.
//

import Foundation

// Generic value sample for charting any metric
struct MetricSample: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

extension Collection where Element == CheckupRecord {
    func metricSamples(_ keyPath: KeyPath<CheckupRecord, Double?>,
                       limit: Int? = nil) -> [MetricSample] {
        var out = self.compactMap { rec -> MetricSample? in
            guard let v = rec[keyPath: keyPath] else { return nil }
            return MetricSample(date: rec.date, value: v)
        }
        .sorted { $0.date < $1.date }
        
        if let limit, out.count > limit { out = Array(out.suffix(limit)) }
        return out
    }

    // Convenience: latest value for a metric
    func latestValue(_ keyPath: KeyPath<CheckupRecord, Double?>) -> Double? {
        self.metricSamples(keyPath).last?.value
    }
    
    /// Visual acuity time series; prefers corrected if available
    func acuitySamples(useCorrected: Bool = true) -> [EyeMetricSample] {
        var out: [EyeMetricSample] = []
        for rec in self {
            let r = useCorrected ? (rec.correctedAcuityRight ?? rec.uncorrectedAcuityRight)
            :  rec.uncorrectedAcuityRight
            let l = useCorrected ? (rec.correctedAcuityLeft  ?? rec.uncorrectedAcuityLeft)
            :  rec.uncorrectedAcuityLeft
            if let v = r { out.append(.init(date: rec.date, eye: .right, value: v)) }
            if let v = l { out.append(.init(date: rec.date, eye: .left,  value: v)) }
        }
        return out.sorted { $0.date < $1.date }
    }
    
    /// IOP series (per eye)
    func iopSamples() -> [EyeMetricSample] {
        var out: [EyeMetricSample] = []
        for rec in self {
            if let v = rec.iopRight { out.append(.init(date: rec.date, eye: .right, value: v)) }
            if let v = rec.iopLeft  { out.append(.init(date: rec.date, eye: .left,  value: v)) }
        }
        return out.sorted { $0.date < $1.date }
    }
    
    /// Near vision (both eyes)
    func nearVisionSamples() -> [MetricSample] {
        self.compactMap { rec in
            rec.nearAcuityBoth.map { MetricSample(date: rec.date, value: $0) }
        }
        .sorted { $0.date < $1.date }
    }
    
    /// Latest color vision, if present
    func latestColorVision() -> (correct: Int, total: Int)? {
        self.sorted { $0.date > $1.date }
            .compactMap { rec in
                if let c = rec.colorPlatesCorrect, let t = rec.colorPlatesTotal { return (c,t) }
                return nil
            }
            .first
    }
    
    /// Latest refraction snapshot, sphere/cylinder per eye
    func latestRefractionPoints() -> [(eye: EyeSide, sphere: Double, cylinder: Double)] {
        guard let rec = self.sorted(by: { $0.date > $1.date }).first else { return [] }
        var pts: [(EyeSide, Double, Double)] = []
        if let s = rec.refractionSphereRight, let c = rec.refractionCylinderRight {
            pts.append((.right, s, c))
        }
        if let s = rec.refractionSphereLeft, let c = rec.refractionCylinderLeft {
            pts.append((.left, s, c))
        }
        return pts
    }
    
    /// Padded domain from all eye-related dates
    var eyeDatesDomain: ClosedRange<Date>? {
        let dates = self.map(\.date)
        guard let minD = dates.min(), let maxD = dates.max() else { return nil }
        let cal = Calendar.current
        let lo = cal.date(byAdding: .day, value: -1, to: minD)!
        let hi = cal.date(byAdding: .day, value:  1, to: maxD)!
        return lo...hi
    }

    func hearingResults() -> [HearingResult] {
        guard let latest = self.sorted(by: { $0.date > $1.date }).first else { return [] }
        var out: [HearingResult] = []
        if let s = latest.hearingLeft1kHz {
            out.append(HearingResult(ear: .left, band: .k1, state: s))
        }
        if let s = latest.hearingRight1kHz {
            out.append(HearingResult(ear: .right, band: .k1, state: s))
        }
        if let s = latest.hearingLeft4kHz {
            out.append(HearingResult(ear: .left, band: .k4, state: s))
        }
        if let s = latest.hearingRight4kHz {
            out.append(HearingResult(ear: .right, band: .k4, state: s))
        }
        return out
    }
}
