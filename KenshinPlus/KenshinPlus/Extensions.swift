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
}
