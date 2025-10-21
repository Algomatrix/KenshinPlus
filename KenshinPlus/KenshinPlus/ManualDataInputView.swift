//
//  ManualDataInputView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/13.
//

import SwiftUI

struct ManualDataInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date = .init()
    @State private var unit: LengthUnit = .cm
    @State private var heightCm: Double = 170.0  // single source of truth
    @State private var gender: Gender = .Male  // Gender
    
    // Weight Unit
    @State private var weightKg: Double? = nil
    @State private var weightUnit: WeightUnit = .Kg

    @State private var systolic: Double? = nil
    @State private var diastolic: Double? = nil
    @State private var rbcMillionPeruL: Double? = nil
    @State private var hgbPerdL: Double? = nil
    @State private var hctPercent: Double? = nil
    @State private var pltThousandPeruL: Double? = nil
    @State private var wbcThousandPeruL: Double? = nil

    
    // Fat % and Abdominal girth
    @State private var fatPercent: Double? = nil
    @State private var abdominalGirthCm: Double? = nil
    @State private var ast: Double? = nil
    @State private var alt: Double? = nil
    @State private var ggt: Double? = nil
    @State private var totalProtein: Double? = nil
    @State private var albumin: Double? = nil

    @State private var creatinine: Double? = nil
    @State private var uricAcid: Double? = nil

    @State private var fastingBloodGlucose: Double? = nil
    @State private var hbA1c: Double? = nil

    @State private var totalCholesterol: Double? = nil
    @State private var hdl: Double? = nil
    @State private var ldl: Double? = nil
    @State private var triglycerides: Double? = nil
    
    // --- Eye (state for inputs)
    @State private var uncorrectedRight: Double? = nil
    @State private var uncorrectedLeft:  Double? = nil
    @State private var correctedRight:   Double? = nil
    @State private var correctedLeft:    Double? = nil

    @State private var iopRight: Double? = nil
    @State private var iopLeft:  Double? = nil
    @State private var nearBothEyes: Double? = nil
    @State private var colorPlatesCorrect: Int? = nil
    @State private var colorPlatesTotal:   Int? = nil
    @State private var rSphere: Double? = nil
    @State private var rCylinder: Double? = nil
    @State private var lSphere: Double? = nil
    @State private var lCylinder: Double? = nil

    // --- Hearing (state for inputs)
    @State private var hearingL1k:  TestResultState = .normal
    @State private var hearingR1k:  TestResultState = .normal
    @State private var hearingL4k:  TestResultState = .normal
    @State private var hearingR4k:  TestResultState = .normal

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PutBarChartInContainer(title: nil) {
                    ManualDataBasicInfoArea(
                        date: $date,
                        unit: $unit,
                        heightCm: $heightCm,
                        gender: $gender,
                        weightKg: $weightKg,
                        weightUnit: $weightUnit,
                        fatPercent: $fatPercent,
                        abdominalGirthCm: $abdominalGirthCm
                    )
                }
                
                PutBarChartInContainer(title: "Blood Pressure") {
                    ManualDataBloodPressure(
                        systolic: $systolic,
                        diastolic: $diastolic
                    )
                }

                PutBarChartInContainer(title: "Blood Test") {
                    ManualDataBloodTest(
                        gender: $gender,
                        rbc: $rbcMillionPeruL,
                        hgb: $hgbPerdL,
                        hct: $hctPercent,
                        plt: $pltThousandPeruL,
                        wbc: $wbcThousandPeruL
                    )
                }

                PutBarChartInContainer(title: "Liver Function") {
                    ManualDataLiverFunction(
                        gender: $gender,
                        ast: $ast,
                        alt: $alt,
                        ggt: $ggt,
                        totalProtein: $totalProtein,
                        albumin: $albumin
                    )
                }
                
                PutBarChartInContainer(title: "Creatinine and Uric Acid") {
                    ManualDataRenalUrate(
                        gender: $gender,
                        creatinine: $creatinine,
                        uricAcid: $uricAcid
                    )
                }
                
                PutBarChartInContainer(title: "Metabolism") {
                    ManualDataMetabolism(
                        fastingGlucoseMgdl: $fastingBloodGlucose,
                        hba1cPercent: $hbA1c
                    )
                }
                
                PutBarChartInContainer(title: "Lipid Data") {
                    ManualDataLipids(gender: $gender, totalCholesterol: $totalCholesterol, hdl: $hdl, ldl: $ldl, triglycerides: $triglycerides)
                }
                
//                Text("Oprional Data")
//                    .foregroundStyle(.secondary)
                
//                PutBarChartInContainer(title: "Eye Test Data") {
//                    ManualDataEyeInput(
//                        uncorrectedRight: $uncorrectedRight,
//                        uncorrectedLeft:  $uncorrectedLeft,
//                        correctedRight:   $correctedRight,
//                        correctedLeft:    $correctedLeft,
//                        iopRight:         $iopRight,
//                        iopLeft:          $iopLeft,
//                        nearBothEyes:     $nearBothEyes,
//                        colorPlatesCorrect: $colorPlatesCorrect,
//                        colorPlatesTotal:   $colorPlatesTotal,
//                        rSphere: $rSphere,
//                        rCylinder: $rCylinder,
//                        lSphere: $lSphere,
//                        lCylinder: $lCylinder
//                    )
//                }

//                PutBarChartInContainer(title: "Hearing Test Data") {
//                    ManualDataHearingInput(
//                        left1k:  $hearingL1k,
//                        right1k: $hearingR1k,
//                        left4k:  $hearingL4k,
//                        right4k: $hearingR4k
//                    )
//                }
            }
            .padding()
        }
        .navigationTitle("Add Checkup Data")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    saveRecord()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "tray.and.arrow.down.fill")
                        Text("Save")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func saveRecord() {
        let record = CheckupRecord(
            id: UUID(),
            createdAt: date,
            date: date,
            gender: (gender == .Male) ? .male : .female,
            heightCm: heightCm,
            weightKg: weightKg,
            fatPercent: fatPercent,
            waistCm: abdominalGirthCm,
            systolic: systolic,
            diastolic: diastolic,
            rbcMillionPeruL: rbcMillionPeruL,
            hgbPerdL: hgbPerdL,
            hctPercent: hctPercent,
            pltThousandPeruL: pltThousandPeruL,
            wbcThousandPeruL: wbcThousandPeruL,
            ast: ast,
            alt: alt,
            ggt: ggt,
            totalProtein: totalProtein,
            albumin: albumin,
            creatinine: creatinine,
            uricAcid: uricAcid,
            fastingGlucoseMgdl: fastingBloodGlucose,
            hba1cNgspPercent: hbA1c,
            totalChol: totalCholesterol,
            hdl: hdl,
            ldl: ldl,
            triglycerides: triglycerides,
            lengthUnit: (unit == .cm ? .cm : .ft),
            weightUnit: (weightUnit == .Kg ? .kg : .pounds),
            uncorrectedAcuityRight: uncorrectedRight,
            uncorrectedAcuityLeft: uncorrectedLeft,
            correctedAcuityRight: correctedRight,
            correctedAcuityLeft: correctedLeft,
            iopRight: iopRight,
            iopLeft: iopLeft,
            nearAcuityBoth: nearBothEyes,
            colorPlatesCorrect: colorPlatesCorrect,
            colorPlatesTotal: colorPlatesTotal,
            refractionSphereRight: rSphere,
            refractionCylinderRight: rCylinder,
            refractionSphereLeft: lSphere,
            refractionCylinderLeft: lCylinder,
            hearingLeft1kHz: hearingL1k,
            hearingRight1kHz: hearingR1k,
            hearingLeft4kHz: hearingL4k,
            hearingRight4kHz: hearingR4k
        )
        modelContext.insert(record)
        // SwiftData autosaves on runloop
        try? modelContext.save()
    }
}

struct ManualDataBasicInfoArea: View {
    @Binding var date: Date
    @Binding var unit: LengthUnit
    @Binding var heightCm: Double
    @Binding var gender: Gender
    @Binding var weightKg: Double?
    @Binding var weightUnit: WeightUnit
    @Binding var fatPercent: Double?
    @Binding var abdominalGirthCm: Double?

    // Local state only for the feet/inches UI
    @State private var feet: Int = 5
    @State private var inches: Int = 7
    @FocusState private var weightFocused: Bool

    // Reasonable range and step in cm
    private let cmRange = Array(stride(from: 130.0, through: 220.0, by: 0.1))

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Basic Info")
                .font(.title3).bold()
            
            HStack {
                Image(systemName: "calendar")
                DatePicker("Test Date", selection: $date, displayedComponents: .date)
            }
            Divider()
            
            if unit == .cm {
                HStack {
                    Image(systemName: "figure")
                    Text("Body height: \(heightCm, specifier: "%.1f") cm")
                    Picker("Height (cm)", selection: $heightCm) {
                        ForEach(cmRange, id: \.self) { h in
                            Text("\(h, specifier: "%.1f")")
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: 150)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "figure")
                    Text("Body height: \(feet)′ \(inches)″")
                    
                    Picker("Feet", selection: $feet) {
                        ForEach(4...7, id: \.self) { f in Text("\(f)") }
                    }
                    .pickerStyle(.wheel)
                    
                    Picker("Inches", selection: $inches) {
                        ForEach(0...11, id: \.self) { i in Text("\(i)") }
                    }
                    .pickerStyle(.wheel)
                }
                .onChange(of: feet) { _, _ in heightCm = feetInchesToCm(feet, inches) }
                .onChange(of: inches) { _, _ in heightCm = feetInchesToCm(feet, inches) }
                .onAppear {
                    let (f, i) = cmToFeetInches(heightCm)
                    feet = f; inches = i
                }
            }
            
            genderSelectPicker
            Divider()

            inputBodyWeight
            Divider()
            HStack {
                Image(systemName: "scalemass")
                Text("BMI (auto): \(bmiString)")
                    .font(.headline)
            }

            // --- BMI reference bar with current BMI rule ---
            MeasurementBar(
                title: "BMI",
                value: bmi,
                domain: bmiDomain,
                segments: bmiSegments,
                valueFormatter: { String(format: "%.1f", $0) }
            )

            Usual2Reference()
            Divider()

            inputFatPercent

            Divider()

            LabeledNumberField(title: "Abdominal Girth", value: $abdominalGirthCm, precision: 1, unitText: "cm", systemImage: "ruler", keyboard: .decimalPad)
                .accessibilityLabel("Abdominal Girth")
            
            if let abdo = abdominalGirthCm {
                // Wasit Range Chart
                MeasurementBar(
                    title: "Waist",
                    value: abdo,
                    domain: waistDomain,
                    segments: waistSegments,
                    valueFormatter: { String(format: "%.1f cm", $0) }
                )
            }
            
            Usual4Reference()
        }
    }

    // MARK: - Conversions

    private func feetInchesToCm(_ feet: Int, _ inches: Int) -> Double {
        Double(feet) * 30.48 + Double(inches) * 2.54
    }

    private func cmToFeetInches(_ cm: Double) -> (Int, Int) {
        let totalInches = cm / 2.54
        let f = Int(totalInches / 12.0)
        let i = Int(round(totalInches - Double(f) * 12.0))
        return (f, min(i, 11))
    }
    
    private var weightDisplayBinding: Binding<Double?> {
        Binding<Double?> {
            switch weightUnit {
            case .Kg:     return weightKg
            case .Pounds: return weightKg.map { $0 * 2.20462 }
            }
        } set: { newValue in
            // if user clears the field, don’t modify the source
            guard let newValue else { return }
            let clamped = max(20, min(newValue, 400)) // sensible range in active unit
            switch weightUnit {
            case .Kg:
                weightKg = clamped
            case .Pounds:
                weightKg = clamped / 2.20462
            }
        }
    }
    
    private var bmi: Double {
        let m = heightCm / 100.0
        guard m > 0, let weight = weightKg else { return 0 } // Handle nil weightKg
        return weight / (m * m)
    }
    
    private var bmiString: String {
        bmi.isFinite ? String(format: "%.1f", bmi) : "-"
    }

    // Reference segments (WHO-ish adult cutoffs)
    private let bmiSegments: [RangeSeg] = [
        .init(label: "Follow-up", start: 10,  end: 18.5, color: .red.opacity(0.7)),
        .init(label: "Reference", start: 18.5, end: 24.9, color: .green.opacity(0.7)),
        .init(label: "Follow-up", start: 24.9, end: 40,  color: .red.opacity(0.7))
    ]
    
    private let bmiDomain: ClosedRange<Double> = 10.0...40.0
    
    
    // Abdominal girth reference by gender (WHO Asian cutoffs commonly used in JP)
    // Men: <90 normal, 90–100 slightly abnormal, 100–110 follow-up, ≥110 medical care needed (example buckets)
    // Women: <80 normal, 80–90 slightly abnormal, 90–100 follow-up, ≥100 medical care needed (example buckets)
    private var waistDomain: ClosedRange<Double> { 50.0...130.0 }

    private var waistSegments: [RangeSeg] {
        switch gender {
        case .Male:
            return [
                RangeSeg(label: "Follow-up (low)", start: waistDomain.lowerBound, end: 60, color: .red.opacity(0.7)), // optional low edge
                RangeSeg(label: "Reference", start: 60, end: 90, color: .green.opacity(0.7)),
                RangeSeg(label: "Slightly abnormal", start: 90, end: 100, color: .yellow.opacity(0.7)),
                RangeSeg(label: "Follow-up", start: 100, end: 110, color: .orange.opacity(0.7)),
                RangeSeg(label: "Medical care", start: 110, end: waistDomain.upperBound, color: .red.opacity(0.7))
            ]
        case .Female:
            return [
                RangeSeg(label: "Follow-up (low)", start: waistDomain.lowerBound, end: 55, color: .red.opacity(0.7)),
                RangeSeg(label: "Reference", start: 55, end: 80, color: .green.opacity(0.7)),
                RangeSeg(label: "Slightly abnormal", start: 80, end: 90, color: .yellow.opacity(0.7)),
                RangeSeg(label: "Follow-up", start: 90, end: 100, color: .orange.opacity(0.7)),
                RangeSeg(label: "Medical care", start: 100, end: waistDomain.upperBound, color: .red.opacity(0.7))
            ]
        }
    }

    // MARK: View as var
    var genderSelectPicker: some View {
        HStack {
            Picker("Gender", selection: $gender) {
                ForEach(Gender.allCases) { gender in
                    Text(gender.rawValue).tag(gender)
                }
            }
            .pickerStyle(.segmented)
            
            UnitPicker(unit: $unit)
                .onChange(of: unit) { _, newValue in
                    // Keep feet/inches UI in sync when switching units
                    if newValue == .ft {
                        let (f, i) = cmToFeetInches(heightCm)
                        feet = f; inches = i
                    }
                }
        }
    }
    
    var inputBodyWeight: some View {
        VStack {
            LabeledNumberField(title: "Body Weight:", value: weightDisplayBinding, precision: 1, unitText: nil, systemImage: "figure", keyboard: .numberPad)
                    .focused($weightFocused)
            Picker("Weight", selection: $weightUnit) {
                ForEach(WeightUnit.allCases) { weightUnit in
                    Text(weightUnit.rawValue).tag(weightUnit)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    var inputFatPercent: some View {
        LabeledNumberField(title: "Body Fat:", value: $fatPercent, precision: 1, unitText: "%", systemImage: "figure", keyboard: .numberPad)
    }
}

struct ManualDataBloodPressure: View {
    @Binding var systolic: Double?
    @Binding var diastolic: Double?


    // Systolic domain & segments
    private let sysDomain: ClosedRange<Double> = 80...200
    private let sysSegments: [RangeSeg] = [
        .init(label: "Normal",     start: 80,  end: 120, color: .green.opacity(0.7)),
        .init(label: "Elevated",   start: 120, end: 130, color: .yellow.opacity(0.7)),
        .init(label: "Stage 1",    start: 130, end: 140, color: .orange.opacity(0.7)),
        .init(label: "Stage 2",    start: 140, end: 180, color: .red.opacity(0.7)),
        .init(label: "Crisis",     start: 180, end: 200, color: .purple.opacity(0.7))
    ]

    // Diastolic domain & segments
    private let diaDomain: ClosedRange<Double> = 50...120
    private let diaSegments: [RangeSeg] = [
        .init(label: "Normal",     start: 50, end: 80,  color: .green.opacity(0.7)),
        .init(label: "Elevated",   start: 80, end: 90,  color: .yellow.opacity(0.7)),
        .init(label: "Stage 1",    start: 90, end: 100, color: .orange.opacity(0.7)),
        .init(label: "Stage 2",    start: 100, end: 120,color: .red.opacity(0.7))
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Input fields
            LabeledNumberField(title: "Systolic",
                               value: $systolic,
                               precision: 0,
                               unitText: "mmHg",
                               systemImage: "heart.fill",
                               keyboard: .numberPad)

            if let sys = systolic {
                MeasurementBar(title: "Systolic",
                               value: sys,
                               domain: sysDomain,
                               segments: sysSegments,
                               valueFormatter: { "\(Int($0)) mmHg" })
            }

            LegendRow(items: [
                (.green.opacity(0.7), "Normal"),
                (.yellow.opacity(0.7), "Elevated"),
                (.orange.opacity(0.7), "Stage 1"),
                (.red.opacity(0.7), "Stage 2"),
                (.purple.opacity(0.7), "Crisis")
            ])

            Divider()

            LabeledNumberField(title: "Diastolic",
                               value: $diastolic,
                               precision: 0,
                               unitText: "mmHg",
                               systemImage: "heart.circle.fill",
                               keyboard: .numberPad)

            if let dia = diastolic {
                MeasurementBar(title: "Diastolic",
                               value: dia,
                               domain: diaDomain,
                               segments: diaSegments,
                               valueFormatter: { "\(Int($0)) mmHg" })
            }

            LegendRow(items: [
                (.green.opacity(0.7), "Normal"),
                (.yellow.opacity(0.7), "Elevated"),
                (.orange.opacity(0.7), "Stage 1"),
                (.red.opacity(0.7), "Stage 2")
            ])
        }
        .padding(.vertical)
    }
}

struct ManualDataBloodTest: View {
    @Binding var gender: Gender

    @Binding var rbc: Double?       // x10^6/µL
    @Binding var hgb: Double?       // g/dL
    @Binding var hct: Double?       // %
    @Binding var plt: Double?       // x10^3/µL
    @Binding var wbc: Double?       // x10^3/µL
    
    // Domains
    private let rbcDomain: ClosedRange<Double> = 3.0...7.5      // x10^6/µL
    private let hgbDomain: ClosedRange<Double> = 8.0...20.0     // g/dL
    private let hctDomain: ClosedRange<Double> = 25.0...60.0    // %
    private let pltDomain: ClosedRange<Double> = 50.0...700.0   // x10^3/µL
    private let wbcDomain: ClosedRange<Double> = 2.0...20.0     // x10^3/µL
    
    // Segments
    private var rbcSegments: [RangeSeg] {
        switch gender {
        case .Male:
            return [
                .init(label: "Low", start: rbcDomain.lowerBound, end: 4.7, color: .red.opacity(0.7)),
                .init(label: "Reference", start: 4.7, end: 6.1, color: .green.opacity(0.7)),
                .init(label: "High", start: 6.1, end: rbcDomain.upperBound, color: .red.opacity(0.7))
            ]
        case .Female:
            return [
                .init(label: "Low", start: rbcDomain.lowerBound, end: 4.2, color: .red.opacity(0.7)),
                .init(label: "Reference", start: 4.2, end: 5.4, color: .green.opacity(0.7)),
                .init(label: "High", start: 5.4, end: rbcDomain.upperBound, color: .red.opacity(0.7))
            ]
        }
    }

    private var hgbSegments: [RangeSeg] {
        switch gender {
        case .Male:
            return [
                .init(label: "Low", start: hgbDomain.lowerBound, end: 13.5, color: .red.opacity(0.7)),
                .init(label: "Reference", start: 13.5, end: 17.5, color: .green.opacity(0.7)),
                .init(label: "High", start: 17.5, end: hgbDomain.upperBound, color: .red.opacity(0.7))
            ]
        case .Female:
            return [
                .init(label: "Low", start: hgbDomain.lowerBound, end: 12.0, color: .red.opacity(0.7)),
                .init(label: "Reference", start: 12.0, end: 15.5, color: .green.opacity(0.7)),
                .init(label: "High", start: 15.5, end: hgbDomain.upperBound, color: .red.opacity(0.7))
            ]
        }
    }
    
    private var hctSegments: [RangeSeg] {
        switch gender {
        case .Male:
            return [
                .init(label: "Low", start: hctDomain.lowerBound, end: 41.0, color: .red.opacity(0.7)),
                .init(label: "Reference", start: 41.0, end: 53.0, color: .green.opacity(0.7)),
                .init(label: "High", start: 53.0, end: hctDomain.upperBound, color: .red.opacity(0.7))
            ]
        case .Female:
            return [
                .init(label: "Low", start: hctDomain.lowerBound, end: 36.0, color: .red.opacity(0.7)),
                .init(label: "Reference", start: 36.0, end: 46.0, color: .green.opacity(0.7)),
                .init(label: "High", start: 46.0, end: hctDomain.upperBound, color: .red.opacity(0.7))
            ]
        }
    }
    
    private var pltSegments: [RangeSeg] {
        [
            .init(label: "Low", start: pltDomain.lowerBound, end: 150, color: .red.opacity(0.7)),
            .init(label: "Reference", start: 150, end: 450, color: .green.opacity(0.7)),
            .init(label: "High", start: 450, end: pltDomain.upperBound, color: .red.opacity(0.7))
        ]
    }
    
    private var wbcSegments: [RangeSeg] {
        [
            .init(label: "Low", start: wbcDomain.lowerBound, end: 4.0, color: .red.opacity(0.7)),
            .init(label: "Reference", start: 4.0, end: 11.0, color: .green.opacity(0.7)),
            .init(label: "High", start: 11.0, end: wbcDomain.upperBound, color: .red.opacity(0.7))
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // RBC
            LabeledNumberField(title: "RBC", value: $rbc, precision: 2, unitText: "M/µL", systemImage: "drop.fill", keyboard: .decimalPad)

            if let measureRbc = rbc {
                MeasurementBar(title: "RBC", value: measureRbc, domain: rbcDomain, segments: rbcSegments, valueFormatter: { String(format: "%.2f M/µL", $0) })
            }

            LegendRow(items: [(.green.opacity(0.7), "Reference"), (.red.opacity(0.7), "Low/High")])
            Divider()
            
            // Hemoglobin
            LabeledNumberField(title: "Hemoglobin", value: $hgb, precision: 1, unitText: "g/dL", systemImage: "drop.circle", keyboard: .decimalPad)

            if let measureHgb = hgb {
                MeasurementBar(title: "Hemoglobin", value: measureHgb, domain: hgbDomain, segments: hgbSegments, valueFormatter: { String(format: "%.1f g/dL", $0) })
            }

            LegendRow(items: [(.green.opacity(0.7), "Reference"), (.red.opacity(0.7), "Low/High")])
            Divider()

            // Hematocrit
            LabeledNumberField(title: "Hematocrit", value: $hct, precision: 1, unitText: "%", systemImage: "gauge", keyboard: .decimalPad)

            if let measureHct = hct {
                MeasurementBar(title: "Hematocrit", value: measureHct, domain: hctDomain, segments: hctSegments,
                               valueFormatter: { String(format: "%.1f %%", $0) })
            }

            LegendRow(items: [(.green.opacity(0.7), "Reference"), (.red.opacity(0.7), "Low/High")])
            Divider()

            // Platelet
            LabeledNumberField(title: "Platelet", value: $plt, precision: 0, unitText: "K/µL", systemImage: "pills", keyboard: .numberPad)

            if let measurePlt = plt {
                MeasurementBar(title: "Platelet", value: measurePlt, domain: pltDomain, segments: pltSegments,
                               valueFormatter: { "\(Int($0)) K/µL" })
            }

            LegendRow(items: [(.green.opacity(0.7), "Reference"), (.red.opacity(0.7), "Low/High")])
            Divider()

            // WBC
            LabeledNumberField(title: "WBC", value: $wbc, precision: 1, unitText: "K/µL", systemImage: "face.smiling", keyboard: .decimalPad)
            
            if let measureWbc = wbc {
                MeasurementBar(title: "WBC", value: measureWbc, domain: wbcDomain, segments: wbcSegments,
                               valueFormatter: { String(format: "%.1f K/µL", $0) })
            }

            LegendRow(items: [(.green.opacity(0.7), "Reference"), (.red.opacity(0.7), "Low/High")])
        }
    }
}

struct ManualDataLiverFunction: View {
    @Binding var gender: Gender
    
    @Binding var ast: Double?       // U/L
    @Binding var alt: Double?       // U/L
    @Binding var ggt: Double?       // U/L
    @Binding var totalProtein: Double? // g/dL
    @Binding var albumin: Double?      // g/dL

    // -------- Domains (x-axis ranges) --------
    private let astDomain: ClosedRange<Double> = 0...200
    private let altDomain: ClosedRange<Double> = 0...200
    private let ggtDomain: ClosedRange<Double> = 0...300
    private let tpDomain:  ClosedRange<Double> = 4.0...9.5
    private let albDomain: ClosedRange<Double> = 2.0...6.0

    // AST (adult, typical lab): Ref ≤ 35 U/L; visualize mild vs marked elevation
    private var astSegments: [RangeSeg] {
        [
            .init(label: "Reference", start: 0,  end: 35,  color: .green.opacity(0.7)),
            .init(label: "Mild ↑",    start: 35, end: 120, color: .orange.opacity(0.7)),
            .init(label: "Marked ↑",  start: 120,end: astDomain.upperBound, color: .red.opacity(0.7))
        ]
    }

    // ALT (adult, typical lab): Ref ≤ 45 U/L (many labs 35–45)
    private var altSegments: [RangeSeg] {
        [
            .init(label: "Reference", start: 0,  end: 45,  color: .green.opacity(0.7)),
            .init(label: "Mild ↑",    start: 45, end: 120, color: .orange.opacity(0.7)),
            .init(label: "Marked ↑",  start: 120,end: altDomain.upperBound, color: .red.opacity(0.7))
        ]
    }

    // GGT is commonly higher in men
    private var ggtSegments: [RangeSeg] {
        switch gender {
        case .Male:
            return [
                .init(label: "Reference", start: 0, end: 60,  color: .green.opacity(0.7)),
                .init(label: "Mild ↑",    start: 60, end: 200, color: .orange.opacity(0.7)),
                .init(label: "Marked ↑",  start: 200,end: ggtDomain.upperBound, color: .red.opacity(0.7))
            ]
        case .Female:
            return [
                .init(label: "Reference", start: 7,  end: 40,  color: .green.opacity(0.7)),
                .init(label: "Mild ↑",    start: 40, end: 150, color: .orange.opacity(0.7)),
                .init(label: "Marked ↑",  start: 150,end: ggtDomain.upperBound, color: .red.opacity(0.7))
            ]
        }
    }

    // Total Protein (adult): ~6.0–8.0 g/dL
    private var tpSegments: [RangeSeg] {
        [
            .init(label: "Low",       start: tpDomain.lowerBound, end: 6.0, color: .red.opacity(0.7)),
            .init(label: "Reference", start: 6.0,                 end: 8.0, color: .green.opacity(0.7)),
            .init(label: "High",      start: 8.0,                 end: tpDomain.upperBound, color: .orange.opacity(0.7))
        ]
    }

    // Albumin (adult): ~3.5–5.0 g/dL
    private var albSegments: [RangeSeg] {
        [
            .init(label: "Low",       start: albDomain.lowerBound, end: 3.5, color: .red.opacity(0.7)),
            .init(label: "Reference", start: 3.5,                  end: 5.0, color: .green.opacity(0.7)),
            .init(label: "High",      start: 5.0,                  end: albDomain.upperBound, color: .orange.opacity(0.7))
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            // AST
            LabeledNumberField(title: "AST (GOT)", value: $ast,
                               precision: 0, unitText: "U/L", systemImage: "waveform.path.ecg", keyboard: .numberPad)
            
            if let vast = ast {
                MeasurementBar(title: "AST (GOT)", value: vast, domain: astDomain, segments: astSegments,
                               valueFormatter: { "\(Int($0)) U/L" })
            }

            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.orange.opacity(0.7), "Mild ↑"),
                (.red.opacity(0.7), "Marked ↑")
            ])
            Divider()

            // ALT
            LabeledNumberField(title: "ALT (GPT)", value: $alt,
                               precision: 0, unitText: "U/L", systemImage: "waveform.path.ecg.rectangle", keyboard: .numberPad)

            if let valt = alt {
                MeasurementBar(title: "ALT (GPT)", value: valt, domain: altDomain, segments: altSegments,
                               valueFormatter: { "\(Int($0)) U/L" })
            }

            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.orange.opacity(0.7), "Mild ↑"),
                (.red.opacity(0.7), "Marked ↑")
            ])
            Divider()

            // GGT
            LabeledNumberField(title: "GGT (γ-GT)", value: $ggt,
                               precision: 0, unitText: "U/L", systemImage: "waveform", keyboard: .numberPad)

            if let vggt = ggt {
                MeasurementBar(title: "GGT (γ-GT)", value: vggt, domain: ggtDomain, segments: ggtSegments,
                               valueFormatter: { "\(Int($0)) U/L" })
            }

            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.orange.opacity(0.7), "Mild ↑"),
                (.red.opacity(0.7), "Marked ↑")
            ])
            Divider()

            // Total Protein
            LabeledNumberField(title: "Total Protein", value: $totalProtein,
                               precision: 1, unitText: "g/dL", systemImage: "square.grid.2x2", keyboard: .decimalPad)

            if let vtotPro = totalProtein {
                MeasurementBar(title: "Total Protein", value: vtotPro, domain: tpDomain, segments: tpSegments,
                               valueFormatter: { String(format: "%.1f g/dL", $0) })
            }

            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.red.opacity(0.7),   "Low"),
                (.orange.opacity(0.7),"High")
            ])
            Divider()

            // Albumin
            LabeledNumberField(title: "Albumin", value: $albumin,
                               precision: 1, unitText: "g/dL", systemImage: "circle.grid.2x2", keyboard: .decimalPad)

            if let valb = albumin {
                MeasurementBar(title: "Albumin", value: valb, domain: albDomain, segments: albSegments,
                               valueFormatter: { String(format: "%.1f g/dL", $0) })
            }

            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.red.opacity(0.7),   "Low"),
                (.orange.opacity(0.7),"High")
            ])
        }
        .padding(.vertical)
    }
}


struct ManualDataRenalUrate: View {
    @Binding var gender: Gender

    // Bind these from the parent so it owns the truth
    @Binding var creatinine: Double?   // mg/dL
    @Binding var uricAcid: Double?     // mg/dL

    // ---- Domains (x-axis) ----
    private let crDomain: ClosedRange<Double> = 0.3...3.0     // mg/dL
    private let uaDomain: ClosedRange<Double> = 1.0...12.0    // mg/dL

    // Creatinine (adult, typical): Men ~0.74–1.35; Women ~0.59–1.04 mg/dL
    private var crSegments: [RangeSeg] {
        switch gender {
        case .Male:
            return [
                .init(label: "Low",       start: crDomain.lowerBound, end: 0.74, color: .red.opacity(0.7)),
                .init(label: "Reference", start: 0.74,                end: 1.35, color: .green.opacity(0.7)),
                .init(label: "High",      start: 1.35,                end: crDomain.upperBound, color: .orange.opacity(0.8))
            ]
        case .Female:
            return [
                .init(label: "Low",       start: crDomain.lowerBound, end: 0.59, color: .red.opacity(0.7)),
                .init(label: "Reference", start: 0.59,                end: 1.04, color: .green.opacity(0.7)),
                .init(label: "High",      start: 1.04,                end: crDomain.upperBound, color: .orange.opacity(0.8))
            ]
        }
    }

    // Uric Acid (adult, common): Men ~3.4–7.0; Women ~2.4–6.0 mg/dL
    private var uaSegments: [RangeSeg] {
        switch gender {
        case .Male:
            return [
                .init(label: "Low",       start: uaDomain.lowerBound, end: 3.4, color: .red.opacity(0.7)),
                .init(label: "Reference", start: 3.4,                 end: 7.0, color: .green.opacity(0.7)),
                .init(label: "High",      start: 7.0,                 end: 9.0, color: .orange.opacity(0.8)),
                .init(label: "Very high", start: 9.0,                 end: uaDomain.upperBound, color: .red.opacity(0.8))
            ]
        case .Female:
            return [
                .init(label: "Low",       start: uaDomain.lowerBound, end: 2.4, color: .red.opacity(0.7)),
                .init(label: "Reference", start: 2.4,                 end: 6.0, color: .green.opacity(0.7)),
                .init(label: "High",      start: 6.0,                 end: 8.0, color: .orange.opacity(0.8)),
                .init(label: "Very high", start: 8.0,                 end: uaDomain.upperBound, color: .red.opacity(0.8))
            ]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Creatinine
            LabeledNumberField(title: "Creatinine", value: $creatinine,
                               precision: 2, unitText: "mg/dL",
                               systemImage: "square.grid.2x2", keyboard: .decimalPad)
            if let screatinine = creatinine {
                MeasurementBar(title: "Creatinine",
                               value: screatinine,
                               domain: crDomain,
                               segments: crSegments,
                               valueFormatter: { String(format: "%.2f mg/dL", $0) })
            }
            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.orange.opacity(0.8), "High"),
                (.red.opacity(0.7), "Low/Very high")
            ])
            Divider()

            // Uric Acid
            LabeledNumberField(title: "Uric Acid", value: $uricAcid,
                               precision: 1, unitText: "mg/dL",
                               systemImage: "drop.triangle", keyboard: .decimalPad)
            if let sUA = uricAcid {
                MeasurementBar(title: "Uric Acid",
                               value: sUA,
                               domain: uaDomain,
                               segments: uaSegments,
                               valueFormatter: { String(format: "%.1f mg/dL", $0) })
            }
            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.orange.opacity(0.8), "High"),
                (.red.opacity(0.8), "Very high / Low")
            ])
        }
    }
}

struct ManualDataMetabolism: View {
    // Bind from parent so it owns the truth
    @Binding var fastingGlucoseMgdl: Double?   // mg/dL
    @Binding var hba1cPercent: Double?         // %, NGSP

    // ---------- Domains ----------
    private let gluDomain: ClosedRange<Double> = 50...300       // mg/dL
    private let a1cDomain: ClosedRange<Double> = 4.0...14.0     // %

    // Fasting Plasma Glucose (FPG), mg/dL
    // <70 hypoglycemia flag (optional), 70–99 normal, 100–125 prediabetes (IFG), ≥126 diabetes
    private var gluSegments: [RangeSeg] {
        [
            .init(label: "Low",        start: gluDomain.lowerBound, end: 70,  color: .cyan.opacity(0.7)),
            .init(label: "Reference",  start: 70,  end: 100, color: .green.opacity(0.7)),
            .init(label: "Prediabetes",start: 100, end: 126, color: .yellow.opacity(0.8)),
            .init(label: "Diabetes",   start: 126, end: 200, color: .red.opacity(0.75)),
            .init(label: "Very high",  start: 200, end: gluDomain.upperBound, color: .purple.opacity(0.7))
        ]
    }

    // HbA1c (NGSP), %
    // <5.7 normal, 5.7–6.4 prediabetes, ≥6.5 diabetes
    private var a1cSegments: [RangeSeg] {
        [
            .init(label: "Reference",  start: 4.0, end: 5.7, color: .green.opacity(0.7)),
            .init(label: "Prediabetes",start: 5.7, end: 6.5, color: .yellow.opacity(0.8)),
            .init(label: "Diabetes",   start: 6.5, end: 10.0, color: .red.opacity(0.75)),
            .init(label: "Very high",  start: 10.0, end: a1cDomain.upperBound, color: .purple.opacity(0.7))
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // --- Fasting Glucose ---
            LabeledNumberField(
                title: "Fasting Glucose",
                value: $fastingGlucoseMgdl,
                precision: 0,
                unitText: "mg/dL",
                systemImage: "drop.fill",
                keyboard: .numberPad
            )
            if let sfasGlu = fastingGlucoseMgdl {
                MeasurementBar(
                    title: "Fasting Glucose",
                    value: sfasGlu,
                    domain: gluDomain,
                    segments: gluSegments,
                    valueFormatter: { "\(Int($0)) mg/dL" }
                )
            }
            
            LegendRow(items: [
                (.cyan.opacity(0.7), "Low"),
                (.green.opacity(0.7), "Reference"),
                (.yellow.opacity(0.8), "Prediabetes"),
                (.red.opacity(0.75), "Diabetes"),
                (.purple.opacity(0.7), "Very high")
            ])

            Divider()

            // --- HbA1c (NGSP) ---
            LabeledNumberField(
                title: "HbA1c (NGSP)",
                value: $hba1cPercent,
                precision: 1,
                unitText: "%",
                systemImage: "flame.fill",
                keyboard: .decimalPad
            )
            if let shba = hba1cPercent {
                MeasurementBar(
                    title: "HbA1c (NGSP)",
                    value: shba,
                    domain: a1cDomain,
                    segments: a1cSegments,
                    valueFormatter: { String(format: "%.1f %%", $0) }
                )
            }
            
            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.yellow.opacity(0.8), "Prediabetes"),
                (.red.opacity(0.75), "Diabetes"),
                (.purple.opacity(0.7), "Very high")
            ])
        }
    }
}

struct ManualDataLipids: View {
    @Binding var gender: Gender

    // Bind values from parent so it owns the truth
    @Binding var totalCholesterol: Double?      // mg/dL
    @Binding var hdl: Double?            // mg/dL
    @Binding var ldl: Double?            // mg/dL
    @Binding var triglycerides: Double?  // mg/dL

    // ---- Domains (x-axis) ----
    private let tcDomain: ClosedRange<Double> = 100...320
    private let hdlDomain: ClosedRange<Double> = 20...100
    private let ldlDomain: ClosedRange<Double> = 50...250
    private let tgDomain: ClosedRange<Double>  = 30...600

    // Total Cholesterol (mg/dL): <200 desirable, 200–239 borderline, ≥240 high
    private var tcSegments: [RangeSeg] {
        [
            .init(label: "Desirable", start: tcDomain.lowerBound, end: 200, color: .green.opacity(0.7)),
            .init(label: "Borderline", start: 200, end: 240, color: .yellow.opacity(0.8)),
            .init(label: "High", start: 240, end: tcDomain.upperBound, color: .red.opacity(0.75))
        ]
    }

    // HDL (mg/dL): low <40 (men) / <50 (women); ≥60 protective
    private var hdlSegments: [RangeSeg] {
        let lowCut = (gender == .Male) ? 40.0 : 50.0
        return [
            .init(label: "Low",        start: hdlDomain.lowerBound, end: lowCut, color: .red.opacity(0.75)),
            .init(label: "Reference",  start: lowCut, end: 60,      color: .green.opacity(0.7)),
            .init(label: "Protective", start: 60,     end: hdlDomain.upperBound, color: .blue.opacity(0.6))
        ]
    }

    // LDL (mg/dL): <100 optimal, 100–129 near optimal, 130–159 borderline high, 160–189 high, ≥190 very high
    private var ldlSegments: [RangeSeg] {
        [
            .init(label: "Optimal",       start: ldlDomain.lowerBound, end: 100, color: .green.opacity(0.7)),
            .init(label: "Near optimal",  start: 100, end: 130, color: .teal.opacity(0.7)),
            .init(label: "Borderline",    start: 130, end: 160, color: .yellow.opacity(0.8)),
            .init(label: "High",          start: 160, end: 190, color: .orange.opacity(0.8)),
            .init(label: "Very high",     start: 190, end: ldlDomain.upperBound, color: .red.opacity(0.75))
        ]
    }

    // Triglycerides (mg/dL): <150 normal, 150–199 borderline, 200–499 high, ≥500 very high
    private var tgSegments: [RangeSeg] {
        [
            .init(label: "Normal",        start: tgDomain.lowerBound, end: 150, color: .green.opacity(0.7)),
            .init(label: "Borderline",    start: 150, end: 200, color: .yellow.opacity(0.8)),
            .init(label: "High",          start: 200, end: 500, color: .orange.opacity(0.8)),
            .init(label: "Very high",     start: 500, end: tgDomain.upperBound, color: .red.opacity(0.75))
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            // Total Cholesterol
            LabeledNumberField(title: "Total Cholesterol",
                               value: $totalCholesterol,
                               precision: 0,
                               unitText: "mg/dL",
                               systemImage: "circle.grid.2x2",
                               keyboard: .numberPad)
            
            if let stotChol = totalCholesterol {
                MeasurementBar(title: "Total Cholesterol",
                               value: stotChol,
                               domain: tcDomain,
                               segments: tcSegments,
                               valueFormatter: { "\(Int($0)) mg/dL" })
            }
            
            LegendRow(items: [
                (.green.opacity(0.7), "Desirable"),
                (.yellow.opacity(0.8), "Borderline"),
                (.red.opacity(0.75), "High")
            ])
            Divider()

            // HDL
            LabeledNumberField(title: "HDL",
                               value: $hdl,
                               precision: 0,
                               unitText: "mg/dL",
                               systemImage: "shield.lefthalf.fill",
                               keyboard: .numberPad)
            
            if let shdl = hdl {
                MeasurementBar(title: "HDL",
                               value: shdl,
                               domain: hdlDomain,
                               segments: hdlSegments,
                               valueFormatter: { "\(Int($0)) mg/dL" })
            }
            
            LegendRow(items: [
                (.red.opacity(0.75), "Low"),
                (.green.opacity(0.7), "Reference"),
                (.blue.opacity(0.6), "Protective")
            ])
            Divider()

            // LDL
            LabeledNumberField(title: "LDL",
                               value: $ldl,
                               precision: 0,
                               unitText: "mg/dL",
                               systemImage: "triangle.lefthalf.filled",
                               keyboard: .numberPad)
            
            if let sldla = ldl {
                MeasurementBar(title: "LDL",
                               value: sldla,
                               domain: ldlDomain,
                               segments: ldlSegments,
                               valueFormatter: { "\(Int($0)) mg/dL" })
            }
            
            LegendRow(items: [
                (.green.opacity(0.7), "Optimal"),
                (.teal.opacity(0.7), "Near optimal"),
                (.yellow.opacity(0.8), "Borderline"),
                (.orange.opacity(0.8), "High"),
                (.red.opacity(0.75), "Very high")
            ])
            Divider()

            // Triglycerides
            LabeledNumberField(title: "Triglycerides",
                               value: $triglycerides,
                               precision: 0,
                               unitText: "mg/dL",
                               systemImage: "drop.triangle",
                               keyboard: .numberPad)
            
            if let strigly = triglycerides {
                MeasurementBar(title: "Triglycerides",
                               value: strigly,
                               domain: tgDomain,
                               segments: tgSegments,
                               valueFormatter: { "\(Int($0)) mg/dL" })
            }
            LegendRow(items: [
                (.green.opacity(0.7), "Normal"),
                (.yellow.opacity(0.8), "Borderline"),
                (.orange.opacity(0.8), "High"),
                (.red.opacity(0.75), "Very high")
            ])
        }
    }
}

struct ManualDataEyeInput: View {
    // Acuity
    @Binding var uncorrectedRight: Double?
    @Binding var uncorrectedLeft:  Double?
    @Binding var correctedRight:   Double?
    @Binding var correctedLeft:    Double?
    // IOP
    @Binding var iopRight: Double?
    @Binding var iopLeft:  Double?
    
    // Near Vision & Color Vision
    @Binding var nearBothEyes: Double?
    @Binding var colorPlatesCorrect: Int?
    @Binding var colorPlatesTotal:   Int?
    
    // Refraction
    @Binding var rSphere: Double?
    @Binding var rCylinder: Double?
    @Binding var lSphere: Double?
    @Binding var lCylinder: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Eye Test").font(.title3).bold()

            // Acuity (JP decimal)
            Group {
                Text("Visual Acuity (JP decimal)").font(.headline)
                VStack {
                    LabeledNumberField(title: "Uncorrected R", value: $uncorrectedRight, precision: 2, unitText: nil, systemImage: "eye", keyboard: .decimalPad)
                    LabeledNumberField(title: "Uncorrected L", value: $uncorrectedLeft,  precision: 2, unitText: nil, systemImage: "eye", keyboard: .decimalPad)
                }
                VStack {
                    LabeledNumberField(title: "Corrected R",   value: $correctedRight, precision: 2, unitText: nil, systemImage: "eyeglasses", keyboard: .decimalPad)
                    LabeledNumberField(title: "Corrected L",   value: $correctedLeft,  precision: 2, unitText: nil, systemImage: "eyeglasses", keyboard: .decimalPad)
                }
            }
            Divider()
            // IOP
            Group {
                Text("Intraocular Pressure (mmHg)").font(.headline)
                VStack {
                    LabeledNumberField(title: "Right IOP", value: $iopRight, precision: 0, unitText: "mmHg", systemImage: "gauge", keyboard: .numberPad)
                    LabeledNumberField(title: "Left IOP",  value: $iopLeft,  precision: 0, unitText: "mmHg", systemImage: "gauge", keyboard: .numberPad)
                }
            }
            Divider()

            // Near vision & Color vision
            Group {
                Text("Near Vision & Color Vision").font(.headline)
                LabeledNumberField(title: "Near Vision (both eyes)", value: $nearBothEyes, precision: 2, unitText: nil, systemImage: "book", keyboard: .decimalPad)
                HStack {
                    LabeledNumberField_Int(title: "Plates Correct", value: $colorPlatesCorrect, unitText: nil, systemImage: "circle.grid.3x3", keyboard: .numberPad)
                    LabeledNumberField_Int(title: "Plates Total",   value: $colorPlatesTotal,   unitText: nil, systemImage: "circle.grid.3x3", keyboard: .numberPad)
                }
            }
            Divider()

            // Refraction
            Group {
                Text("Refraction (Diopters)").font(.headline)
                VStack {
                    LabeledNumberField(title: "Right Sphere",   value: $rSphere,   precision: 2, unitText: "D", systemImage: "circle.righthalf.filled", keyboard: .decimalPad)
                    LabeledNumberField(title: "Right Cylinder", value: $rCylinder, precision: 2, unitText: "D", systemImage: "circle.righthalf.filled", keyboard: .decimalPad)
                }
                VStack {
                    LabeledNumberField(title: "Left Sphere",    value: $lSphere,   precision: 2, unitText: "D", systemImage: "circle.lefthalf.filled", keyboard: .decimalPad)
                    LabeledNumberField(title: "Left Cylinder",  value: $lCylinder, precision: 2, unitText: "D", systemImage: "circle.lefthalf.filled", keyboard: .decimalPad)
                }
            }
        }
    }
}

/// small integer field helper mirroring your LabeledNumberField
struct LabeledNumberField_Int: View {
    let title: String
    @Binding var value: Int?
    var unitText: String? = nil
    var systemImage: String? = nil
    var keyboard: UIKeyboardType = .numberPad

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if let systemImage { Image(systemName: systemImage) }
            Text(title)
            TextField("", text: $text)
                .keyboardType(keyboard)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .onChange(of: text) { _, new in
                    value = Int(new.trimmingCharacters(in: .whitespaces))
                }
                .onChange(of: value) { _, new in
                    guard !isFocused else { return }
                    text = new.map(String.init) ?? ""
                }
                .onChange(of: isFocused) { _, nowFocused in
                    guard !nowFocused else { return }
                    text = value.map(String.init) ?? ""
                }
            if let unitText { Text(unitText).foregroundStyle(.secondary) }
        }
    }
}

struct ManualDataHearingInput: View {
    @Binding var left1k:  TestResultState
    @Binding var right1k: TestResultState
    @Binding var left4k:  TestResultState
    @Binding var right4k: TestResultState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hearing Test").font(.title3).bold()

            HearingRow(title: "1 kHz", left: $left1k, right: $right1k)
            HearingRow(title: "4 kHz", left: $left4k, right: $right4k)
        }
    }
}

private struct HearingRow: View {
    let title: String
    @Binding var left: TestResultState
    @Binding var right: TestResultState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            HStack {
                Picker("Left", selection: $left) {
                    ForEach(TestResultState.allCases, id: \.self) { state in
                        Text(state.title)
                            .foregroundColor(left == state ? .blue : .primary) // Change color based on selection
                            .tag(state)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Right", selection: $right) {
                    ForEach(TestResultState.allCases, id: \.self) { state in
                        Text(state.title)
                            .foregroundColor(right == state ? .blue : .primary) // Change color based on selection
                            .tag(state)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

struct UnitPicker: View {
    @Binding var unit: LengthUnit

    var body: some View {
        Picker("Unit", selection: $unit) {
            ForEach(LengthUnit.allCases) { u in
                Text(u.rawValue).tag(u)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - segment model
struct RangeSeg: Identifiable {
    let id = UUID()
    let label: String
    let start: Double
    let end: Double
    let color: Color
}

#Preview {
    ManualDataInputView()
    
    // For save data test
    /*
     NavigationStack {
         VStack {
             Text("Preview of Dashboard View")
                 .font(.largeTitle)
                 .padding()

             // Here you can add your toolbar
             .toolbar {
                 ToolbarItem(placement: .topBarTrailing) {
                     NavigationLink(destination: ManualDataInputView()) {
                         Image(systemName: "plus.circle.fill")
                     }
                 }
             }
         }
     }
     */
}
