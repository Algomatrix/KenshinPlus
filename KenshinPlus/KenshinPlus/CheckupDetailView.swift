//
//  CheckupDetailView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/22.
//

import SwiftUI

struct CheckupDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var record: CheckupRecord   // SwiftData magic

    // For feet/inches editor we keep small local state but write back to cm
    @State private var ft: Int = 5
    @State private var inch: Int = 7
    @State private var kg: Int = 5
    @State private var lb: Int = 14

    // Weight binding that converts to/from kg based on record.weightUnit
    // TODO: Make weightDisplayBinding common utility (used at two places)
    private var weightDisplayBinding: Binding<Double?> {
        Binding<Double?> {
            guard let kg = record.weightKg else { return nil }
            switch record.weightUnit {
            case .kg:     return kg
            case .pounds: return record.kgToLb(kg)
            }
        } set: { newValue in
            guard let v = newValue else { record.weightKg = nil; return }
            switch record.weightUnit {
            case .kg:     record.weightKg = v
            case .pounds: record.weightKg = record.lbToKg(v)
            }
        }
    }

    var body: some View {
        Form {
            DatePicker("Date", selection: $record.date, displayedComponents: .date)

            Picker("Gender", selection: $record.gender) {
                Text("Male").tag(SDGender.male)
                Text("Female").tag(SDGender.female)
            }

            // ---- Height (unit-aware) ----
            Picker("Height Unit", selection: $record.lengthUnit) {
                Text("cm").tag(SDLengthUnit.cm)
                Text("ft/in").tag(SDLengthUnit.ft)
            }
            .pickerStyle(.segmented)
            .onChange(of: record.lengthUnit) { _, newUnit in
                if newUnit == .ft, let h = record.heightCm {
                    let p = record.cmToFeetInches(h)
                    ft = p.feet; inch = p.inches
                }
            }

            if record.lengthUnit == .cm {
                LabeledNumberField(
                    title: "Height",
                    value: $record.heightCm,
                    precision: 1,
                    unitText: "cm",
                    systemImage: "ruler",
                    color: .blue
                )
            } else {
                HStack {
                    Label("Height", systemImage: "ruler")
                    Spacer()
                    Picker("ft", selection: $ft) {
                        ForEach(3...8, id: \.self) { Text("\($0) ft") }
                    }
                    .frame(width: 90)

                    Picker("in", selection: $inch) {
                        ForEach(0...11, id: \.self) { Text("\($0) in") }
                    }
                    .frame(width: 90)
                }
                .onAppear {
                    if let h = record.heightCm {
                        let p = record.cmToFeetInches(h)
                        ft = p.feet; inch = p.inches
                    }
                }
                .onChange(of: ft)   { _, _ in record.heightCm = record.feetInchesToCm(feet: ft, inches: inch) }
                .onChange(of: inch) { _, _ in record.heightCm = record.feetInchesToCm(feet: ft, inches: inch) }
            }

            // ---- Weight (unit-aware) ----
            Picker("Weight Unit", selection: $record.weightUnit) {
                Text("kg").tag(SDWeightUnit.kg)
                Text("lb").tag(SDWeightUnit.pounds)
            }
            .pickerStyle(.segmented)

            LabeledNumberField(
                title: "Weight",
                value: weightDisplayBinding,
                precision: 1,
                unitText: record.weightUnit == .kg ? "kg" : "lb",
                systemImage: "figure",
                keyboard: .numberPad,
                color: .blue
            )

            Text("BMI: \(String(format: "%.1f", record.bmi))")
            LabeledNumberField(title: "Body Fat", value: $record.fatPercent, precision: 1, unitText: "%", systemImage: "figure", color: .blue)
            LabeledNumberField(title: "Abdominal Girth", value: $record.waistCm, precision: 1, unitText: "cm", systemImage: "ruler", color: .blue)

            bpDetails // Blood Pressure details
            
            bloodDetails // Blood test details
            
            liverDetails // Liver test details
            
            urinDetails // Urin test details
            
            metabolismDetails // Metabolism test details
            
            cholesterolDetails // Cholesterol test details
            
//            eyeDetails // Eye test details
        }
        .formStyle(.automatic)
        .navigationTitle("Checkup")
        .toolbar {
            Button("Save") {
                try? modelContext.save()
                dismiss()
            }
        }
    }
    
    var bpDetails: some View {
        // DisclosureGroup for Blood Pressure details
        DisclosureGroup {
            LabeledNumberField(title: "Systolic", value: $record.systolic, precision: 1, unitText: "mmHg")
            LabeledNumberField(title: "Diastolic", value: $record.diastolic, precision: 1, unitText: "mmHg")
        } label: {
            Label("Blood Pressure", systemImage: "blood.pressure.cuff.badge.gauge.with.needle.fill")
        }
        .padding(.vertical, 5) // Some vertical padding for better spacing
    }
    
    var bloodDetails: some View {
        // DisclosureGroup for Blood test details
        DisclosureGroup {
            LabeledNumberField(title: "RBC", value: $record.rbcMillionPeruL, precision: 1, unitText: "M/µL")
            LabeledNumberField(title: "Hemoglobin", value: $record.hgbPerdL, precision: 1, unitText: "g/dL")
            LabeledNumberField(title: "Hematocrit", value: $record.hctPercent, precision: 1, unitText: "%")
            LabeledNumberField(title: "Platelet", value: $record.pltThousandPeruL, precision: 1, unitText: "K/µL")
            LabeledNumberField(title: "WBC", value: $record.wbcThousandPeruL, precision: 1, unitText: "K/µL")
        } label: {
            Label("Blood Test", systemImage: "syringe.fill")
        }
        .padding(.vertical, 5) // Some vertical padding for better spacing
    }
    
    var liverDetails: some View {
        // DisclosureGroup for liver test details
        DisclosureGroup {
            LabeledNumberField(title: "AST", value: $record.ast, precision: 0, unitText: "U/L")
            LabeledNumberField(title: "ALT", value: $record.alt, precision: 0, unitText: "U/L")
            LabeledNumberField(title: "GGT", value: $record.ggt, precision: 0, unitText: "U/L")
            LabeledNumberField(title: "Total Protein", value: $record.totalProtein, precision: 1, unitText: "g/dL")
            LabeledNumberField(title: "Albumin", value: $record.albumin, precision: 1, unitText: "g/dL")
        } label: {
            Label("Liver", systemImage: "chart.line.text.clipboard.fill")
        }
        .padding(.vertical, 5) // Some vertical padding for better spacing
    }
    
    var urinDetails: some View {
        // DisclosureGroup for urin test details
        DisclosureGroup {
            LabeledNumberField(title: "Creatinine", value: $record.creatinine, precision: 1, unitText: "mg/dL")
            LabeledNumberField(title: "Uric Acid", value: $record.uricAcid, precision: 1, unitText: "mg/dL")
        } label: {
            Label("Urin", systemImage: "vial.viewfinder")
        }
        .padding(.vertical, 5) // Some vertical padding for better spacing
    }
    
    var metabolismDetails: some View {
        // DisclosureGroup for metabolism test details
        DisclosureGroup {
            LabeledNumberField(title: "Fasting Glucose", value: $record.fastingGlucoseMgdl, precision: 0, unitText: "mg/dL")
            LabeledNumberField(title: "HBA1C", value: $record.hba1cNgspPercent, precision: 1, unitText: "%")
        } label: {
            Label("Metabolism", systemImage: "flame.fill")
        }
        .padding(.vertical, 5) // Some vertical padding for better spacing
    }
    
    var cholesterolDetails: some View {
        // DisclosureGroup for Cholesterol test details
        DisclosureGroup {
            LabeledNumberField(title: "Total Cholesterol", value: $record.totalChol, precision: 0, unitText: "mg/dL")
            LabeledNumberField(title: "HDL", value: $record.hdl, precision: 0, unitText: "mg/dL")
            LabeledNumberField(title: "LDL", value: $record.ldl, precision: 0, unitText: "mg/dL")
            LabeledNumberField(title: "Triglycerides", value: $record.triglycerides, precision: 0, unitText: "mg/dL")
        } label: {
            Label("Cholesterol", systemImage: "heart.circle")
        }
        .padding(.vertical, 5) // Some vertical padding for better spacing
    }
    
    var eyeDetails: some View {
        // DisclosureGroup for Vision test details
        DisclosureGroup {
            LabeledNumberField(title: "Uncorrected R", value: $record.totalChol, precision: 2, unitText: nil)
            LabeledNumberField(title: "Uncorrected L", value: $record.hdl, precision: 2, unitText: nil)
            LabeledNumberField(title: "Corrected R", value: $record.ldl, precision: 2, unitText: nil)
            LabeledNumberField(title: "Corrected L", value: $record.triglycerides, precision: 2, unitText: nil)
            LabeledNumberField(title: "Right IOP", value: $record.triglycerides, precision: 0, unitText: "mmHg")
            LabeledNumberField(title: "Left IOP", value: $record.triglycerides, precision: 0, unitText: "mmHg")
            LabeledNumberField(title: "Near Vision (both eyes)", value: $record.triglycerides, precision: 2, unitText: "mg/dL")
            LabeledNumberField(title: "Plates Correct", value: $record.triglycerides, unitText: nil)
            LabeledNumberField(title: "Plates Total", value: $record.triglycerides, unitText: nil)
            LabeledNumberField(title: "Right Sphere", value: $record.triglycerides, precision: 2, unitText: "D")
            LabeledNumberField(title: "Right Cylinder", value: $record.triglycerides, precision: 2, unitText: "D")
            LabeledNumberField(title: "Left Sphere", value: $record.triglycerides, precision: 2, unitText: "D")
            LabeledNumberField(title: "Left Cylinder", value: $record.triglycerides, precision: 2, unitText: "D")
        } label: {
            Label("Vision", systemImage: "eye")
        }
        .padding(.vertical, 5) // Some vertical padding for better spacing
    }
}

#Preview {
    let record = CheckupRecord(
        id: UUID(),
        createdAt: Date.now,
        date: Date.now,
        gender: .male,
        heightCm: 170,
        weightKg: 65,
        fatPercent: 19,
        waistCm: 85,
        systolic: 90,
        diastolic: 100,
        rbcMillionPeruL: 6,
        hgbPerdL: 20,
        hctPercent: 20,
        pltThousandPeruL: 20,
        wbcThousandPeruL: 20,
        ast: 20,
        alt: 20,
        ggt: 20,
        totalProtein: 20,
        albumin: 20,
        creatinine: 20,
        uricAcid: 20,
        fastingGlucoseMgdl: 20,
        hba1cNgspPercent: 20,
        totalChol: 20,
        hdl: 20,
        ldl: 20,
        triglycerides: 20,
        lengthUnit: .cm,
        weightUnit: .kg,
        uncorrectedAcuityRight: 20,
        uncorrectedAcuityLeft: 20,
        correctedAcuityRight: 20,
        correctedAcuityLeft: 20,
        iopRight: 20,
        iopLeft: 20,
        nearAcuityBoth: 20,
        colorPlatesCorrect: 20,
        colorPlatesTotal: 20,
        refractionSphereRight: 20,
        refractionCylinderRight: 20,
        refractionSphereLeft: 20,
        refractionCylinderLeft: 20,
        hearingLeft1kHz: .good,
        hearingRight1kHz: .bad,
        hearingLeft4kHz: .normal,
        hearingRight4kHz: .good
    )
    CheckupDetailView(record: record)
}
