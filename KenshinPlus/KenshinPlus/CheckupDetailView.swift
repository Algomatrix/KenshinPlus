//
//  CheckupDetailView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/22.
//

import SwiftUI

struct CheckupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var record: CheckupRecord   // SwiftData magic

    var body: some View {
        Form {
            DatePicker("Date", selection: $record.date, displayedComponents: .date)
            Picker("Gender", selection: $record.gender) {
                Text("Male").tag(SDGender.male)
                Text("Female").tag(SDGender.female)
            }
            LabeledNumberField(title: "Height", value: $record.heightCm, precision: 1, unitText: "cm", systemImage: "ruler", color: .blue)
            LabeledNumberField(title: "Weight", value: $record.weightKg, precision: 1, unitText: "kg", systemImage: "figure", color: .blue)
            Text("BMI: \(String(format: "%.1f", record.bmi))")
            LabeledNumberField(title: "Body Fat", value: $record.fatPercent, precision: 1, unitText: "%", systemImage: "figure", color: .blue)
            LabeledNumberField(title: "Abdominal Girth", value: $record.waistCm, precision: 1, unitText: "cm", systemImage: "ruler", color: .blue)

            bpDetails // Blood Pressure details
            
            bloodDetails // Blood test details
            
            liverDetails // Liver test details
            
            urinDetails // Urin test details
            
            metabolismDetails // Metabolism test details
            
            cholesterolDetails // Cholesterol test details
            
            eyeDetails // Eye test details
        }
        .formStyle(.automatic)
        .navigationTitle("Checkup")
        .toolbar {
            Button("Save") { try? modelContext.save() }
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
            LabeledNumberField(title: "RBC", value: $record.rbcMillionPeruL, precision: 1, unitText: "x10^6/µL")
            LabeledNumberField(title: "WBC", value: $record.wbcThousandPeruL, precision: 1, unitText: "x10^3/µL")
            LabeledNumberField(title: "Hemoglobin", value: $record.hgbPerdL, precision: 1, unitText: "g/dL")
            LabeledNumberField(title: "Hematocrit", value: $record.hctPercent, precision: 1, unitText: "%")
            LabeledNumberField(title: "Platelet", value: $record.pltThousandPeruL, precision: 1, unitText: "x10^3/µL")
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
