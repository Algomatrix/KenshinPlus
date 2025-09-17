//
//  CheckupRecord.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/16.
//

import Foundation
import SwiftData

// Persistable enums (SwiftData-Friendly)
enum SDGender: String, Codable, CaseIterable {
    case male, female
}
enum SDLengthUnit: String, Codable, CaseIterable { case cm, ft }
enum SDWeightUnit: String, Codable, CaseIterable { case kg, pounds }

@Model
final class CheckupRecord {
    // Identity/meta
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var date: Date
    
    // Basic info / anthropometrics
    var gender: SDGender
    var heightCm: Double
    var weightKg: Double
    var fatPercent: Double?
    var waistCm: Double?
    
    // Blood Pressure
    var systolic: Double?
    var diastolic: Double?
    
    // Blood test (CBC core)
    var rbcMillionPeruL: Double?
    var hgbPerdL: Double?
    var hctPercent: Double?
    var pltThousandPeruL: Double?
    var wbcThousandPeruL: Double?
    
    // Liver Function
    var ast: Double?
    var alt: Double?
    var ggt: Double?
    var totalProtein: Double?
    var albumin: Double?
    
    // Renal / Urate
    var creatinine: Double?
    var uricAcid: Double?
    
    // Metabolism
    var fastingGlucoseMgdl: Double?
    var hba1cNgspPercent: Double?
    
    // Lipids
    var totalChol: Double?
    var hdl: Double?
    var ldl: Double?
    var triglycerides: Double?
    
    // UI Prefs (How the user enetered things)
    var lengthUnit: SDLengthUnit
    var weightUnit: SDWeightUnit
    
    // Derived & convenience
    var bmi: Double {
        guard heightCm > 0 else { return 0 }
        let m = heightCm / 100.0
        return weightKg / (m * m)
    }
    
    init(
        id: UUID = UUID(),
        createdAt: Date = .init(),
        date: Date,
        gender: SDGender,
        heightCm: Double,
        weightKg: Double,
        // keep all optionals defaulted to nil:
        fatPercent: Double? = nil,
        waistCm: Double? = nil,   // or rename to waistCm if that was a typo
        systolic: Double? = nil,
        diastolic: Double? = nil,
        rbcMillionPeruL: Double? = nil,
        hgbPerdL: Double? = nil,
        hctPercent: Double? = nil,
        pltThousandPeruL: Double? = nil,
        wbcThousandPeruL: Double? = nil,
        ast: Double? = nil,
        alt: Double? = nil,
        ggt: Double? = nil,
        totalProtein: Double? = nil,
        albumin: Double? = nil,
        creatinine: Double? = nil,   // consider renaming to creatinine
        uricAcid: Double? = nil,
        fastingGlucoseMgdl: Double? = nil,
        hba1cNgspPercent: Double? = nil,
        totalChol: Double? = nil,
        hdl: Double? = nil,
        ldl: Double? = nil,
        triglycerides: Double? = nil,
        lengthUnit: SDLengthUnit = .cm,
        weightUnit: SDWeightUnit = .kg
    ) {
        self.id = id
        self.createdAt = createdAt
        self.date = date
        self.gender = gender
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.fatPercent = fatPercent
        self.waistCm = waistCm
        self.systolic = systolic
        self.diastolic = diastolic
        self.rbcMillionPeruL = rbcMillionPeruL
        self.hgbPerdL = hgbPerdL
        self.hctPercent = hctPercent
        self.pltThousandPeruL = pltThousandPeruL
        self.wbcThousandPeruL = wbcThousandPeruL
        self.ast = ast
        self.alt = alt
        self.ggt = ggt
        self.totalProtein = totalProtein
        self.albumin = albumin
        self.creatinine = creatinine
        self.uricAcid = uricAcid
        self.fastingGlucoseMgdl = fastingGlucoseMgdl
        self.hba1cNgspPercent = hba1cNgspPercent
        self.totalChol = totalChol
        self.hdl = hdl
        self.ldl = ldl
        self.triglycerides = triglycerides
        self.lengthUnit = lengthUnit
        self.weightUnit = weightUnit
    }
}
