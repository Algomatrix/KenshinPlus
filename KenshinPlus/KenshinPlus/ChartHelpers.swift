//
//  ChartHelpers.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/11/01.
//

import SwiftUI
import Charts

// MARK: - Namespaced helpers
enum ChartAxis {
    static let cal = Calendar.current
    // Collapse to start of day so "same-day different times" don't create nearly-overlapping points.
    static func startOfDay(_ d: Date) -> Date { cal.startOfDay(for: d) }
    // Bounds for a sequence of samples (generic over any type with a Date key path)
    static func bounds<S>(_ samples: S, date: KeyPath<S.Element, Date>) -> (start: Date, end: Date)? where S: Sequence {
        var minD: Date? = nil, maxD: Date? = nil
        for s in samples {
            let d = s[keyPath: date]
            if minD == nil || d < minD! { minD = d }
            if maxD == nil || d > maxD! { maxD = d }
        }
        if let a = minD, let b = maxD { return (a, b) }
        return nil
    }

    // MARK: Axis builders
    /// Axis content that adapts tick spacing to the span of the series.
    @AxisContentBuilder
    static func axisForSpan<S>(_ samples: S, date: KeyPath<S.Element, Date>) -> some AxisContent where S: Sequence {
        if let (s, e) = bounds(samples, date: date) {
            let days  = cal.dateComponents([.day],  from: s, to: e).day  ?? 0
            let years = cal.dateComponents([.year], from: s, to: e).year ?? 0
            if days <= 60 {
                AxisMarks(values: .automatic(desiredCount: 6)) {
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            } else if years < 5 {
                AxisMarks(values: .stride(by: .month)) {
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.year(.twoDigits).month(.twoDigits).day(.twoDigits))
                }
            } else {
                AxisMarks(values: .stride(by: .year)) {
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.year())
                }
            }
        } else {
            // fallback when we don't know the span yet
            AxisMarks(values: .automatic(desiredCount: 6)) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
    }
    
    @AxisContentBuilder
    static func axisAtDataDates<S>(_ samples: S, date: KeyPath<S.Element, Date>) -> some AxisContent where S: Sequence {
        // unique, sorted, normalized to start-of-day
        let ds: [Date] = Array(Set(samples.map { startOfDay($0[keyPath: date]) })).sorted()

        if ds.isEmpty {
            // nothing to show → fallback
            axisForSpan(samples, date: date)
        } else if ds.count <= 200 { // prevent label soup; tweak threshold as you like
            AxisMarks(values: ds) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.year(.twoDigits).month(.twoDigits).day(.twoDigits))
            }
        } else {
            // too many ticks → readable default
            axisForSpan(samples, date: date)
        }
    }
}

// MARK: - Small convenience View extensions (Not much used right now. Maybe in future)
// Apply initial domain if present
extension View {
    func chartInitialXDomain(_ domain: ClosedRange<Date>?) -> some View {
        guard let domain else { return AnyView(self) }
        return AnyView(self.chartXScale(domain: domain))
    }
    
    // Apply a full-span domain if we have bounds
    func applyFullDomain(_ bounds: (Date, Date)?) -> some View {
        guard let b = bounds else { return AnyView(self) }
        // normalize to start of day for both ends
        let domain = ChartAxis.startOfDay(b.0)...ChartAxis.startOfDay(b.1)
        return AnyView(self.chartXScale(domain: domain))
    }
    
    func applyPaddedDomain(_ bounds: (Date, Date)?,
                           leftPadDays: Int = 0,
                           rightPadDays: Int = 0) -> some View {
        guard let b = bounds else { return AnyView(self) }
        let cal = Calendar.current
        let start = cal.startOfDay(for: cal.date(byAdding: .day, value: -leftPadDays,  to: b.0) ?? b.0)
        let end   = cal.startOfDay(for: cal.date(byAdding: .day, value:  rightPadDays, to: b.1) ?? b.1)
        return AnyView(self.chartXScale(domain: start...end))
    }
}
