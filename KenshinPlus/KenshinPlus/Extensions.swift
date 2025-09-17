//
//  Extensions.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/17.
//

extension Collection where Element == CheckupRecord {
    func bpSamples(limit: Int? = nil) -> [BloodPressureSample] {
        // Map first, then sort — keeps types obvious to the compiler
        var samples = self.compactMap { rec -> BloodPressureSample? in
            guard let sys = rec.systolic, let dia = rec.diastolic else { return nil }
            return BloodPressureSample(date: rec.date, systolic: sys, diastolic: dia)
        }
        .sorted { $0.date < $1.date }

        if let limit, samples.count > limit {
            samples = Array(samples.suffix(limit))
        }
        return samples
    }
}
