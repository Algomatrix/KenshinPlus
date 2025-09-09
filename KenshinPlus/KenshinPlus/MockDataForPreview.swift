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


struct BloodTestSample: Identifiable {
    var id = UUID()
    var rbc: Double        // million/µL
    var hemoglobin: Double // g/dL
    var hematocrit: Double // %
    var platelet: Double   // ×10³/µL
    var wbc: Double        // ×10³/µL
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

    func mockBloodTest() -> BloodTestSample {
        return BloodTestSample(
            rbc: Double.random(in: 4.0...6.0),      // million/µL
            hemoglobin: Double.random(in: 12.0...16.0), // g/dL
            hematocrit: Double.random(in: 36.0...50.0), // %
            platelet: Double.random(in: 150...450),     // ×10³/µL
            wbc: Double.random(in: 4.0...11.0)         // ×10³/µL
        )
    }

    func mockBloodTestSeries(count: Int = 6) -> [(date: Date, sample: BloodTestSample)] {
        let cal = Calendar.current
        return (0..<count).map { i in
            let date = cal.date(byAdding: .weekOfYear, value: -i, to: Date())!
            return (date, mockBloodTest())
        }.sorted { $0.date < $1.date }
    }
}
