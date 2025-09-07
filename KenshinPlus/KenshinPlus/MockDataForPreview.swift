//
//  MockDataForPreview.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/06.
//

import Foundation

struct BloodPressureSample: Identifiable {
    var id = UUID()
    let date: Date
    let systolic: Double
    let diastolic: Double
}

@Observable class MockDataForPreview {
    func mockSystolicBloodPressure() -> [BloodPressureSample] {
        var mockSample: [BloodPressureSample] = []
        
        for i in 0..<10 {
            // Generate random systolic and diastolic blood pressure values
            let systolicValue = Double.random(in: 110...140) // Example range for systolic pressure
            let diastolicValue = Double.random(in: 70...90) // Example range for diastolic pressure
            
            let sampleDates = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            
            let sample = BloodPressureSample(date: sampleDates, systolic: systolicValue, diastolic: diastolicValue)
            mockSample.append(sample)
            
        }

        print("✅ Mock Blood Pressure Data generated")
        return mockSample
    }
}
