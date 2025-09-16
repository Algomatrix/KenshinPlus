//
//  ManualDataInputView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/13.
//

import SwiftUI

struct ManualDataInputView: View {
    @State private var date: Date = .init()
    @State private var unit: LengthUnit = .cm
    @State private var heightCm: Double = 170.0  // single source of truth
    @State private var gender: Gender = .Male  // Gender
    
    // Weight Unit
    @State private var weightKg: Double = 65.0
    @State private var weightUnit: WeightUnit = .Kg

    // Fat % and Abdominal girth
    @State private var fatPercent: Double = 20.0
    @State private var abdominalGirthCm: Double = 85.0
    
    @State private var ast: Double = 28
    @State private var alt: Double = 32
    @State private var ggt: Double = 42
    @State private var totalProtein: Double = 7.2
    @State private var albumin: Double = 4.4

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PutBarChartInContainer(title: "") {
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
                    ManualDataBloodPressure()
                }

                PutBarChartInContainer(title: "Blood Test") {
                    ManualDataBloodTest(gender: $gender)
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
            }
            .padding()
        }
    }
}

struct ManualDataBasicInfoArea: View {
    @Binding var date: Date
    @Binding var unit: LengthUnit
    @Binding var heightCm: Double
    @Binding var gender: Gender
    @Binding var weightKg: Double
    @Binding var weightUnit: WeightUnit
    @Binding var fatPercent: Double
    @Binding var abdominalGirthCm: Double

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

            LabeledNumberField(title: "BMI (auto):", value: .constant(bmi), precision: 0...1, unitText: nil, systemImage: "scalemass").disabled(true)

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

            LabeledNumberField(title: "Abdominal girth", value: $abdominalGirthCm, precision: 0...1, unitText: nil, systemImage: "ruler", keyboard: .decimalPad)
                .accessibilityLabel("Abdominal girth")
            
            // Wasit Range Chart
            MeasurementBar(
                title: "Waist",
                value: abdominalGirthCm,
                domain: waistDomain,
                segments: waistSegments,
                valueFormatter: { String(format: "%.1f cm", $0) }
            )
            
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
    
    private var weightDisplayBinding: Binding<Double> {
        Binding<Double> {
            switch weightUnit {
            case .Kg:
                return weightKg
            case .Pounds:
                return weightKg * 2.20462
            }
        } set: { newValue in
            // Clamp to a sensible range before converting back
            let clamped = max(20, min(newValue, 400)) // 20–400 in the active unit
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
        guard m > 0 else { return 0 }
        return weightKg / (m * m)
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
        HStack {
            LabeledNumberField(title: "Body\nWeight:", value: weightDisplayBinding, precision: 0...1, unitText: nil, systemImage: "figure", keyboard: .numberPad)
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
        HStack {
            Text("Fat:")
            TextField("Enter Fat percentage", value: $fatPercent, format: .number.precision(.fractionLength(0...1)))
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            Image(systemName: "percent")
        }
    }
}

struct ManualDataBloodPressure: View {
    @State private var systolic: Double = 120
    @State private var diastolic: Double = 80

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
                               precision: 0...0,
                               unitText: "mmHg",
                               systemImage: "heart.fill",
                               keyboard: .numberPad)

            MeasurementBar(title: "Systolic",
                           value: systolic,
                           domain: sysDomain,
                           segments: sysSegments,
                           valueFormatter: { "\(Int($0)) mmHg" })

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
                               precision: 0...0,
                               unitText: "mmHg",
                               systemImage: "heart.circle.fill",
                               keyboard: .numberPad)

            MeasurementBar(title: "Diastolic",
                           value: diastolic,
                           domain: diaDomain,
                           segments: diaSegments,
                           valueFormatter: { "\(Int($0)) mmHg" })

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

    @State private var rbc: Double = 4.8        // x10^6/µL
    @State private var hgb: Double = 14.0       // g/dL
    @State private var hct: Double = 42.0       // %
    @State private var plt: Double = 250        // x10^3/µL
    @State private var wbc: Double = 6.0        // x10^3/µL
    
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
            LabeledNumberField(title: "RBC", value: $rbc, precision: 0...2, unitText: "×10⁶/µL", systemImage: "drop.fill", keyboard: .decimalPad)
            MeasurementBar(title: "RBC", value: rbc, domain: rbcDomain, segments: rbcSegments, valueFormatter: { String(format: "%.2f ×10⁶/µL", $0) })
            LegendRow(items: [(.green.opacity(0.7), "Reference"), (.red.opacity(0.7), "Low/High")])
            Divider()
            
            // Hemoglobin
            LabeledNumberField(title: "Hemoglobin", value: $hgb, precision: 0...1, unitText: "g/dL", systemImage: "drop.circle", keyboard: .decimalPad)
            MeasurementBar(title: "Hemoglobin", value: hgb, domain: hgbDomain, segments: hgbSegments, valueFormatter: { String(format: "%.1f g/dL", $0) })
            LegendRow(items: [(.green.opacity(0.7), "Reference"), (.red.opacity(0.7), "Low/High")])
            Divider()

            // Hematocrit
            LabeledNumberField(title: "Hematocrit", value: $hct, precision: 0...1, unitText: "%", systemImage: "gauge", keyboard: .decimalPad)
            MeasurementBar(title: "Hematocrit", value: hct, domain: hctDomain, segments: hctSegments,
                           valueFormatter: { String(format: "%.1f %%", $0) })
            LegendRow(items: [(.green.opacity(0.7), "Reference"), (.red.opacity(0.7), "Low/High")])
            Divider()

            // Platelet
            LabeledNumberField(title: "Platelet", value: $plt, precision: 0...0, unitText: "×10³/µL", systemImage: "pills", keyboard: .numberPad)
            MeasurementBar(title: "Platelet", value: plt, domain: pltDomain, segments: pltSegments,
                           valueFormatter: { "\(Int($0)) ×10³/µL" })
            LegendRow(items: [(.green.opacity(0.7), "Reference"), (.red.opacity(0.7), "Low/High")])
            Divider()

            // WBC
            LabeledNumberField(title: "WBC", value: $wbc, precision: 0...1, unitText: "×10³/µL", systemImage: "face.smiling", keyboard: .decimalPad)
            MeasurementBar(title: "WBC", value: wbc, domain: wbcDomain, segments: wbcSegments,
                           valueFormatter: { String(format: "%.1f ×10³/µL", $0) })
            LegendRow(items: [(.green.opacity(0.7), "Reference"), (.red.opacity(0.7), "Low/High")])
        }
    }
}

struct ManualDataLiverFunction: View {
    @Binding var gender: Gender
    
    @Binding var ast: Double       // U/L
    @Binding var alt: Double       // U/L
    @Binding var ggt: Double       // U/L
    @Binding var totalProtein: Double // g/dL
    @Binding var albumin: Double      // g/dL

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
                               precision: 0...0, unitText: "U/L", systemImage: "waveform.path.ecg", keyboard: .numberPad)
            MeasurementBar(title: "AST (GOT)", value: ast, domain: astDomain, segments: astSegments,
                           valueFormatter: { "\(Int($0)) U/L" })
            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.orange.opacity(0.7), "Mild ↑"),
                (.red.opacity(0.7), "Marked ↑")
            ])
            Divider()

            // ALT
            LabeledNumberField(title: "ALT (GPT)", value: $alt,
                               precision: 0...0, unitText: "U/L", systemImage: "waveform.path.ecg.rectangle", keyboard: .numberPad)
            MeasurementBar(title: "ALT (GPT)", value: alt, domain: altDomain, segments: altSegments,
                           valueFormatter: { "\(Int($0)) U/L" })
            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.orange.opacity(0.7), "Mild ↑"),
                (.red.opacity(0.7), "Marked ↑")
            ])
            Divider()

            // GGT
            LabeledNumberField(title: "GGT (γ-GT)", value: $ggt,
                               precision: 0...0, unitText: "U/L", systemImage: "waveform", keyboard: .numberPad)
            MeasurementBar(title: "GGT (γ-GT)", value: ggt, domain: ggtDomain, segments: ggtSegments,
                           valueFormatter: { "\(Int($0)) U/L" })
            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.orange.opacity(0.7), "Mild ↑"),
                (.red.opacity(0.7), "Marked ↑")
            ])
            Divider()

            // Total Protein
            LabeledNumberField(title: "Total Protein", value: $totalProtein,
                               precision: 0...1, unitText: "g/dL", systemImage: "square.grid.2x2", keyboard: .decimalPad)
            MeasurementBar(title: "Total Protein", value: totalProtein, domain: tpDomain, segments: tpSegments,
                           valueFormatter: { String(format: "%.1f g/dL", $0) })
            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.red.opacity(0.7),   "Low"),
                (.orange.opacity(0.7),"High")
            ])
            Divider()

            // Albumin
            LabeledNumberField(title: "Albumin", value: $albumin,
                               precision: 0...1, unitText: "g/dL", systemImage: "circle.grid.2x2", keyboard: .decimalPad)
            MeasurementBar(title: "Albumin", value: albumin, domain: albDomain, segments: albSegments,
                           valueFormatter: { String(format: "%.1f g/dL", $0) })
            LegendRow(items: [
                (.green.opacity(0.7), "Reference"),
                (.red.opacity(0.7),   "Low"),
                (.orange.opacity(0.7),"High")
            ])
        }
        .padding(.vertical)
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
}

/*




/// Compact colored legend chip. Drive a row from your segments if you want.
struct LabelChip: View {
    let color: Color
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Rectangle().frame(width: 10, height: 10).foregroundStyle(color)
            Text(text).font(.caption)
        }
    }
}



// MARK: - Your screen (using the blocks)

struct ManualDataInputView: View {
    @State private var date: Date = .init()
    @State private var unit: LengthUnit = .cm
    @State private var heightCm: Double = 170
    @State private var gender: Gender = .Male
    @State private var weightKg: Double = 65
    @State private var weightUnit: WeightUnit = .Kg
    @State private var fatPercent: Double = 20
    @State private var abdominalGirthCm: Double = 85

    // BMI
    private var bmi: Double {
        let m = heightCm / 100
        return max(0, weightKg / max(0.0001, m*m))
    }
    private let bmiDomain: ClosedRange<Double> = 10...40

    // Waist (gender-based)
    private var waistDomain: ClosedRange<Double> { 50...130 }
    private var waistSegments: [RangeSeg] {
        switch gender {
        case .Male:
            return [
                .init(label: "Reference", start: 60, end: 90, color: .green.opacity(0.7)),
                .init(label: "Slightly abnormal", start: 90, end: 100, color: .yellow.opacity(0.7)),
                .init(label: "Follow-up", start: 100, end: 110, color: .orange.opacity(0.7)),
                .init(label: "Medical care", start: 110, end: waistDomain.upperBound, color: .red.opacity(0.7))
            ]
        case .Female:
            return [
                .init(label: "Reference", start: 55, end: 80, color: .green.opacity(0.7)),
                .init(label: "Slightly abnormal", start: 80, end: 90, color: .yellow.opacity(0.7)),
                .init(label: "Follow-up", start: 90, end: 100, color: .orange.opacity(0.7)),
                .init(label: "Medical care", start: 100, end: waistDomain.upperBound, color: .red.opacity(0.7))
            ]
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Top controls (date, unit, gender)
                HStack {
                    Image(systemName: "calendar")
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                HStack {
                    EnumSegmentedPicker(title: "Gender", selection: $gender)
                    EnumSegmentedPicker(title: "Length Unit", selection: $unit)
                }
                Divider()

                // Height (reuse your wheel picker logic — omitted here for brevity)
                Text("Height: \(heightCm, specifier: "%.1f") cm")

                // Weight (binding converts kg/lb as before)
                HStack {
                    Text("Weight")
                    Spacer()
                    // Keep your weightDisplayBinding if you have it; here we just use $weightKg for brevity.
                    TextField("Weight", value: $weightKg, format: .number.precision(.fractionLength(0...1)))
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                    EnumSegmentedPicker(title: "Weight Unit", selection: $weightUnit)
                        .frame(maxWidth: 180)
                }
                .padding(.vertical, 4)

                // BMI (auto) + bar
                LabeledNumberField(title: "BMI (auto)", value: .constant(bmi),
                                   precision: 0...1, unitText: nil, systemImage: "scalemass")
                    .disabled(true)

                MeasurementBar(
                    title: "BMI",
                    value: bmi,
                    domain: bmiDomain,
                    segments: bmiSegments,
                    valueFormatter: { String(format: "%.1f", $0) }
                )

                LegendRow(items: [
                    (.green.opacity(0.7), "Reference"),
                    (.red.opacity(0.7), "Follow-up")
                ])
                Divider()

                // Fat %
                LabeledNumberField(title: "Fat %", value: $fatPercent,
                                   precision: 0...1, unitText: "%", systemImage: "percent")

                // Abdominal girth + bar
                LabeledNumberField(title: "Abdominal girth", value: $abdominalGirthCm,
                                   precision: 0...1, unitText: "cm", systemImage: "ruler")

                MeasurementBar(
                    title: "Waist",
                    value: abdominalGirthCm,
                    domain: waistDomain,
                    segments: waistSegments,
                    valueFormatter: { String(format: "%.1f cm", $0) }
                )

                LegendRow(items: [
                    (.green.opacity(0.7), "Reference"),
                    (.yellow.opacity(0.7), "Slightly abnormal"),
                    (.orange.opacity(0.7), "Follow-up"),
                    (.red.opacity(0.7), "Medical care")
                ])
            }
            .padding()
        }
    }
}
*/
