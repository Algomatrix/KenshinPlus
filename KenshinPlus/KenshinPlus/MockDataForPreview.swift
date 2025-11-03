//
//  MockDataForPreview.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/06.
//

import Foundation

struct BloodPressureSample: Identifiable {
    let id = UUID()
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

struct LiverTestSample {
    var id = UUID()
    let ast: Double      // U/L
    let alt: Double      // U/L
    let ggt: Double      // U/L
    let totalProtein: Double // g/dL
    let albumin: Double  // g/dL
}

struct KidneyTestSample {
    let uricAcid: Double     // mg/dL
    let creatinine: Double   // mg/dL
}

struct CholesterolTestSample: Identifiable {
    var id = UUID()
    let date: Date
    let totalCholesterol: Double  // mg/dL
    let ldl: Double               // mg/dL
    let hdl: Double               // mg/dL
    let triglycerides: Double     // mg/dL
}

struct MetabolismTestSample: Identifiable {
    var id = UUID()
    let date: Date
    let hba1c: Double           // %
    let fastingGlucose: Double  // mg/dL
}

enum EyeScreeningGrade: String, Codable {
    case A, B, C, D
}

enum ColorVisionResult: String, Codable {
    case normal = "Normal"
    case deficiencySuspected = "Deficiency suspected"
    case notTested = "Not tested"
}

struct RefractionValue: Codable {
    var sphere: Double     // Spherical power, diopters (e.g. -3.25)
    var cylinder: Double   // Cylindrical power, diopters (e.g. -1.00)
    var axis: Int          // 0–180 degrees
}

struct EyeExamSample: Identifiable, Codable {
    var id = UUID()
    let date: Date

    // Decimal visual acuity (Landolt C style). Japan uses decimals like 1.0, 0.7, etc.
    // Uncorrected (裸眼) and best-corrected (矯正)
    let uncorrectedRight: Double
    let uncorrectedLeft: Double
    let correctedRight: Double?
    let correctedLeft: Double?

    // Optional refraction (if measured)
    let refractionRight: RefractionValue?
    let refractionLeft: RefractionValue?

    // Intraocular pressure (mmHg), non-contact tonometry typical
    let iopRight: Double?
    let iopLeft: Double?

    // Near vision (decimal; optional)
    let nearBothEyes: Double?

    // Interpupillary distance (mm); optional
    let interpupillaryDistance: Double?

    // Color vision (Ishihara quick screen style)
    let colorPlatesTotal: Int?
    let colorPlatesCorrect: Int?
    let colorVisionResult: ColorVisionResult

    // Auto-derived screening grades (JP A–D bands)
    // A: ≥1.0, B: 0.7–0.9, C: 0.3–0.6, D: <0.3
    let gradeRight: EyeScreeningGrade
    let gradeLeft: EyeScreeningGrade

    // Free text notes from screener
    let notes: String?
}

fileprivate func jpScreeningGrade(for decimalAcuity: Double) -> EyeScreeningGrade {
    switch decimalAcuity {
    case let x where x >= 1.0: return .A
    case 0.7..<1.0: return .B
    case 0.3..<0.7: return .C
    default: return .D
    }
}

fileprivate func randomJPDecimalAcuity(mean: Double = 1.0, sd: Double = 0.2, clamp: ClosedRange<Double> = 0.05...1.5) -> Double {
    // Simple Box–Muller for a bell-ish distribution
    let u1 = Double.random(in: 0.0001...1.0)
    let u2 = Double.random(in: 0.0001...1.0)
    let z = sqrt(-2.0 * log(u1)) * cos(2.0 * .pi * u2)
    let val = (mean + sd * z)
    return min(max(val, clamp.lowerBound), clamp.upperBound).rounded(to: 1)
}

fileprivate func randomRefraction() -> RefractionValue {
    // Myopia-biased distribution common in JP
    let sphere = (Double.random(in: -6.0 ... -0.5) + (Bool.random() ? 0.0 : Double.random(in: 0.0 ... 2.0))).rounded(to: 2)
    let cylinder = (-Double.random(in: 0.0 ... 2.5)).rounded(to: 2) // negative cyl format
    let axis = Int.random(in: 0...180)
    return RefractionValue(sphere: sphere, cylinder: cylinder, axis: axis)
}


fileprivate func randomColorVision() -> (total: Int, correct: Int, result: ColorVisionResult) {
    let total = 14 // common short Ishihara set
    // ~8% males w/ red-green deficiency → bias a little
    let hasDef = Bool.random(probability: 0.1)
    let correct = hasDef ? Int.random(in: 6...11) : Int.random(in: 12...14)
    let result: ColorVisionResult = hasDef ? .deficiencySuspected : .normal
    return (total, correct, result)
}


fileprivate func randomIOP() -> Double {
    Double.random(in: 11.0...20.0).rounded(to: 1) // normal-ish 10–21
}

extension Bool {
    /// Probability helper: returns true with given probability (0.0–1.0)
    static func random(probability p: Double) -> Bool {
        Double.random(in: 0...1) < p
    }
}

// MARK: - MockDataForPreview additions

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
            rbc: Double.random(in: 4.0...6.0),         // million/µL
            hemoglobin: Double.random(in: 12.0...16.0), // g/dL
            hematocrit: Double.random(in: 36.0...50.0), // %
            platelet: Double.random(in: 150...450),     // ×10³/µL
            wbc: Double.random(in: 4.0...11.0)          // ×10³/µL
        )
    }

    /// Fixed-interval (weekly) test data
    func mockBloodTestSeriesByWeek(count: Int = 6) -> [(date: Date, sample: BloodTestSample)] {
        let cal = Calendar.current
        return (0..<count).map { i in
            let date = cal.date(byAdding: .weekOfYear, value: -i, to: Date())!
            return (date, mockBloodTest())
        }.sorted { $0.date < $1.date }
    }

    /// Random but chronological dates
    func mockBloodTestSeriesRandomDates(count: Int, withinDays: Int = 600) -> [Date] {
        var dates: [Date] = []
        var current = Date()
        for _ in 0..<count {
            let randomGap = Int.random(in: 5...60)
            current = Calendar.current.date(byAdding: .day, value: -randomGap, to: current)!
            dates.append(current)
        }
        return dates.sorted()
    }

    /// Random-dated blood test samples
    func mockBloodTestSeriesRandom(count: Int = 6) -> [(date: Date, sample: BloodTestSample)] {
        let randomDates = mockBloodTestSeriesRandomDates(count: count)
        
        // Combine each random date with a mock sample
        let randomSeries = randomDates.map { date in
            (date: date, sample: mockBloodTest())
        }
        
        // Optional: print for debugging
        for entry in randomSeries {
            print("Date: \(entry.date), Hgb: \(entry.sample.hemoglobin)")
        }
        
        // ✅ Return the generated series
        return randomSeries.sorted { $0.date < $1.date }
    }
    
    func randomChronologicalDates(count: Int, startYear: Int = 2020, endYear: Int = 2025) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current

        for _ in 0..<count {
            let year = Int.random(in: startYear...endYear)
            let month = Int.random(in: 1...12)
            let day = Int.random(in: 1...28) // safe for all months

            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day

            if let date = calendar.date(from: components) {
                dates.append(date)
            }
        }

        return dates.sorted()
    }

    func mockLiverTest() -> LiverTestSample {
        return LiverTestSample(
            ast: Double.random(in: 10...40),          // U/L
            alt: Double.random(in: 7...56),           // U/L
            ggt: Double.random(in: 9...48),           // U/L
            totalProtein: Double.random(in: 6.0...8.3), // g/dL
            albumin: Double.random(in: 3.5...5.0)     // g/dL
        )
    }

    func mockLiverTestSeries(count: Int = 6) -> [(date: Date, sample: LiverTestSample)] {
        let cal = Calendar.current
        return (0..<count).map { i in
            let date = cal.date(byAdding: .weekOfYear, value: -i, to: Date())!
            return (date, mockLiverTest())
        }.sorted { $0.date < $1.date }
    }
    
    func mockKidneyTest() -> KidneyTestSample {
        return KidneyTestSample(
            uricAcid: Double.random(in: 3.6...7.0),     // reference range mg/dL
            creatinine: Double.random(in: 0.6...1.1)    // reference range mg/dL
        )
    }
    
    func mockKidneyTestSeries(count: Int = 6) -> [(date: Date, sample: KidneyTestSample)] {
        let cal = Calendar.current
        return (0..<count).map { i in
            let date = cal.date(byAdding: .weekOfYear, value: -i, to: Date())!
            return (date, mockKidneyTest())
        }.sorted { $0.date < $1.date }
    }


    func mockMetabolismTest(at date: Date = Date()) -> MetabolismTestSample {
        MetabolismTestSample(
            date: date,
            hba1c: Double.random(in: 4.6...6.5).rounded(to: 1),   // %
            fastingGlucose: Double.random(in: 70...110).rounded(to: 0) // mg/dL
        )
    }
    
    func mockMetabolismTestSeries(count: Int = 6) -> [MetabolismTestSample] {
        let randomDates = randomChronologicalDates(count: count)
        return randomDates.map { mockMetabolismTest(at: $0) }
    }
    
    func mockCholesterolTest(at date: Date = Date()) -> CholesterolTestSample {
        return CholesterolTestSample(
            date: date,
            totalCholesterol: Double.random(in: 150...240),     // mg/dL
            ldl: Double.random(in: 70...160),                   // mg/dL
            hdl: Double.random(in: 35...70),                    // mg/dL
            triglycerides: Double.random(in: 80...200)          // mg/dL
        )
    }
    
    func mockCholesterolTestSeries(count: Int = 6) -> [CholesterolTestSample] {
        let cal = Calendar.current
        let samples = (0..<count).map { i -> CholesterolTestSample in
            let date = cal.date(byAdding: .day, value: -i, to: Date())!
            return mockCholesterolTest(at: date)
        }

        // ascending for better chart display
        return samples.sorted { $0.date < $1.date }
    }
    
    func mockEyeExam(on date: Date = Date(), includeRefraction: Bool = true, includeIOP: Bool = true, includeNear: Bool = false, includeIPD: Bool = false, includeColor: Bool = false) -> EyeExamSample {
        
        // Uncorrected tends to be worse than corrected; bias slightly lower
        let unRight = randomJPDecimalAcuity(mean: 0.7, sd: 0.25)
        let unLeft = randomJPDecimalAcuity(mean: 0.7, sd: 0.25)
        
        
        // If corrected measured, aim ≥ 1.0 but allow imperfect correction
        let corrRight: Double? = includeRefraction ? randomJPDecimalAcuity(mean: max(1.1, unRight + 0.3), sd: 0.15) : nil
        let corrLeft: Double?  = includeRefraction ? randomJPDecimalAcuity(mean: max(1.1, unLeft  + 0.3), sd: 0.15) : nil
        
        let refR: RefractionValue? = includeRefraction ? randomRefraction() : nil
        let refL: RefractionValue? = includeRefraction ? randomRefraction() : nil
        
        let iopR: Double? = includeIOP ? randomIOP() : nil
        let iopL: Double? = includeIOP ? randomIOP() : nil
        
        let near: Double? = includeNear ? randomJPDecimalAcuity(mean: 1.0, sd: 0.1) : nil
        let ipd: Double?  = includeIPD ? Double.random(in: 58...68).rounded(to: 1) : nil
        
        let color: (Int, Int, ColorVisionResult)? = includeColor ? randomColorVision() : nil
        
        let gradeR = jpScreeningGrade(for: corrRight ?? unRight)
        let gradeL = jpScreeningGrade(for: corrLeft ?? unLeft)
        
        return EyeExamSample(
            date: date,
            uncorrectedRight: unRight,
            uncorrectedLeft: unLeft,
            correctedRight: corrRight,
            correctedLeft: corrLeft,
            refractionRight: refR,
            refractionLeft: refL,
            iopRight: iopR,
            iopLeft: iopL,
            nearBothEyes: near,
            interpupillaryDistance: ipd,
            colorPlatesTotal: color?.0,
            colorPlatesCorrect: color?.1,
            colorVisionResult: color?.2 ?? .notTested,
            gradeRight: gradeR,
            gradeLeft: gradeL,
            notes: nil
        )
    }
    
    func mockEyeExamSeries(count: Int = 6) -> [EyeExamSample] {
        let cal = Calendar.current
        let samples = (0..<count).map { i -> EyeExamSample in
            let date = cal.date(byAdding: .year, value: -i, to: Date())!
            return mockEyeExam(on: date,
                               includeRefraction: true,
                               includeIOP: Bool.random(probability: 0.8),
                               includeNear: Bool.random(probability: 0.4),
                               includeIPD: Bool.random(probability: 0.3),
                               includeColor: Bool.random(probability: 0.9))
        }
        return samples.sorted { $0.date < $1.date }
    }

}

extension Double {
    func rounded(to places: Int = 0) -> Double {
        let p = pow(10.0, Double(places))
        return (self * p).rounded(.toNearestOrAwayFromZero) / p
    }
}

extension MockDataForPreview {
    /// Generate a single mock CheckupRecord with realistic combined values
    func mockCheckupRecord(on date: Date = Date()) -> CheckupRecord {
        let record = CheckupRecord()
        record.date = date
        
        // Random anthropometrics
        record.gender = Bool.random() ? .male : .female
        record.heightCm = Double.random(in: 160...180).rounded(to: 1)
        record.weightKg = Double.random(in: 55...80).rounded(to: 1)
        record.fatPercent = Double.random(in: 10...25).rounded(to: 1)
        record.waistCm = Double.random(in: 70...90).rounded(to: 1)
        
        // Blood pressure
        let bp = mockSystolicBloodPressure().randomElement()!
        record.systolic = bp.systolic
        record.diastolic = bp.diastolic
        
        // Blood test (CBC)
//        let cbc = mockBloodTest()
//        record.rbcMillionPeruL = cbc.rbc
//        record.hgbPerdL = cbc.hemoglobin
//        record.hctPercent = cbc.hematocrit
//        record.pltThousandPeruL = cbc.platelet
//        record.wbcThousandPeruL = cbc.wbc
        let cbcSeries = mockBloodTestSeriesRandom(count: 6)
        if let randomEntry = cbcSeries.randomElement() {
            let sample = randomEntry.sample
            record.rbcMillionPeruL = sample.rbc
            record.hgbPerdL = sample.hemoglobin
            record.hctPercent = sample.hematocrit
            record.pltThousandPeruL = sample.platelet
            record.wbcThousandPeruL = sample.wbc
        }
        
        // Liver test
        let liver = mockLiverTest()
        record.ast = liver.ast
        record.alt = liver.alt
        record.ggt = liver.ggt
        record.totalProtein = liver.totalProtein
        record.albumin = liver.albumin
        
        // Kidney test
        let kidney = mockKidneyTest()
        record.uricAcid = kidney.uricAcid
        record.creatinine = kidney.creatinine
        
        // Metabolism
        let meta = mockMetabolismTest(at: date)
        record.hba1cNgspPercent = meta.hba1c
        record.fastingGlucoseMgdl = meta.fastingGlucose
        
        // Lipids
        let chol = mockCholesterolTest(at: date)
        record.totalChol = chol.totalCholesterol
        record.hdl = chol.hdl
        record.ldl = chol.ldl
        record.triglycerides = chol.triglycerides
        
        // Eye exam
        let eye = mockEyeExam(on: date,
                              includeRefraction: true,
                              includeIOP: true,
                              includeNear: Bool.random(probability: 0.4),
                              includeIPD: Bool.random(probability: 0.3),
                              includeColor: Bool.random(probability: 0.9))
        record.uncorrectedAcuityRight = eye.uncorrectedRight
        record.uncorrectedAcuityLeft = eye.uncorrectedLeft
        record.correctedAcuityRight = eye.correctedRight
        record.correctedAcuityLeft = eye.correctedLeft
        record.refractionSphereRight = eye.refractionRight?.sphere
        record.refractionCylinderRight = eye.refractionRight?.cylinder
        record.refractionSphereLeft = eye.refractionLeft?.sphere
        record.refractionCylinderLeft = eye.refractionLeft?.cylinder
        record.iopRight = eye.iopRight
        record.iopLeft = eye.iopLeft
        record.nearAcuityBoth = eye.nearBothEyes
        record.colorPlatesTotal = eye.colorPlatesTotal
        record.colorPlatesCorrect = eye.colorPlatesCorrect

        return record
    }

    /// Generate multiple mock CheckupRecords (e.g. for chart previews)
    func mockCheckupRecordSeries(count: Int = 6) -> [CheckupRecord] {
        let cal = Calendar.current
        return (0..<count).map { i in
            let date = cal.date(byAdding: .month, value: -i, to: Date())!
            return mockCheckupRecord(on: date)
        }.sorted { $0.date < $1.date }
    }
}
