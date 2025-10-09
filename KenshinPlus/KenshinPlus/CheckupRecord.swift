//
//  CheckupRecord.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/16.
//

import Foundation
import SwiftData

enum SDGender: String, Codable, CaseIterable { case male, female }
enum SDLengthUnit: String, Codable, CaseIterable { case cm, ft }
enum SDWeightUnit: String, Codable, CaseIterable { case kg, pounds }
enum EyeSide: String, CaseIterable { case right = "Right", left = "Left" }

@Model
final class CheckupRecord {
    // Identity/meta
    var id: UUID = UUID()
    var createdAt: Date = Date.now
    var date: Date = Date.now

    // Anthropometrics
    var gender: SDGender = SDGender.male
    var heightCm: Double?
    var weightKg: Double?
    var fatPercent: Double?
    var waistCm: Double?

    // Blood Pressure
    var systolic: Double?
    var diastolic: Double?

    // CBC
    var rbcMillionPeruL: Double?
    var hgbPerdL: Double?
    var hctPercent: Double?
    var pltThousandPeruL: Double?
    var wbcThousandPeruL: Double?

    // Liver
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

    // UI prefs
    var lengthUnit: SDLengthUnit = SDLengthUnit.cm
    var weightUnit: SDWeightUnit = SDWeightUnit.kg

    // Derived
    var bmi: Double {
        guard let h = heightCm, h > 0, let w = weightKg, w > 0 else { return 0 }
        let m = h / 100.0
        return w / (m * m)
    }

    // MARK: - Weight
    public func kgToLb(_ kg: Double) -> Double { kg * 2.2046226218 }
    public func lbToKg(_ lb: Double) -> Double { lb / 2.2046226218 }

    // MARK: - Height
    public func cmToFeetInches(_ cm: Double) -> (feet: Int, inches: Int) {
        let totalInches = cm / 2.54
        let f = Int(totalInches / 12.0)
        let i = Int(round(totalInches - Double(f) * 12.0))
        return (f, min(i, 11))
    }
    public func feetInchesToCm(feet: Int, inches: Int) -> Double {
        Double(feet) * 30.48 + Double(inches) * 2.54
    }

    // EYE — acuity (names matched to your extension)
    var uncorrectedAcuityRight: Double?
    var uncorrectedAcuityLeft:  Double?
    var correctedAcuityRight:   Double?
    var correctedAcuityLeft:    Double?

    // EYE — IOP
    var iopRight: Double?
    var iopLeft:  Double?

    // EYE — near vision
    var nearAcuityBoth: Double?

    // EYE — color vision
    var colorPlatesCorrect: Int?
    var colorPlatesTotal:   Int?

    // EYE — refraction
    var refractionSphereRight:   Double?
    var refractionCylinderRight: Double?
    var refractionSphereLeft:    Double?
    var refractionCylinderLeft:  Double?

    // HEARING — 1k / 4k Hz snapshots
    var hearingLeft1kHz:  TestResultState?
    var hearingRight1kHz: TestResultState?
    var hearingLeft4kHz:  TestResultState?
    var hearingRight4kHz: TestResultState?

    // MARK: Init
    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        date: Date = .now,
        gender: SDGender = .male,
        heightCm: Double? = nil,
        weightKg: Double? = nil,
        fatPercent: Double? = nil,
        waistCm: Double? = nil,
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
        creatinine: Double? = nil,
        uricAcid: Double? = nil,
        fastingGlucoseMgdl: Double? = nil,
        hba1cNgspPercent: Double? = nil,
        totalChol: Double? = nil,
        hdl: Double? = nil,
        ldl: Double? = nil,
        triglycerides: Double? = nil,
        lengthUnit: SDLengthUnit = .cm,
        weightUnit: SDWeightUnit = .kg,
        // eye defaults matching extension
        uncorrectedAcuityRight: Double? = nil,
        uncorrectedAcuityLeft:  Double? = nil,
        correctedAcuityRight:   Double? = nil,
        correctedAcuityLeft:    Double? = nil,
        iopRight: Double? = nil,
        iopLeft:  Double? = nil,
        nearAcuityBoth: Double? = nil,
        colorPlatesCorrect: Int? = nil,
        colorPlatesTotal:   Int? = nil,
        refractionSphereRight:   Double? = nil,
        refractionCylinderRight: Double? = nil,
        refractionSphereLeft:    Double? = nil,
        refractionCylinderLeft:  Double? = nil,
        // hearing defaults
        hearingLeft1kHz:  TestResultState? =  .none,
        hearingRight1kHz: TestResultState? =  .none,
        hearingLeft4kHz:  TestResultState? =  .none,
        hearingRight4kHz: TestResultState? = .none
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

        self.uncorrectedAcuityRight = uncorrectedAcuityRight
        self.uncorrectedAcuityLeft  = uncorrectedAcuityLeft
        self.correctedAcuityRight   = correctedAcuityRight
        self.correctedAcuityLeft    = correctedAcuityLeft
        self.iopRight = iopRight
        self.iopLeft  = iopLeft
        self.nearAcuityBoth = nearAcuityBoth
        self.colorPlatesCorrect = colorPlatesCorrect
        self.colorPlatesTotal   = colorPlatesTotal
        self.refractionSphereRight   = refractionSphereRight
        self.refractionCylinderRight = refractionCylinderRight
        self.refractionSphereLeft    = refractionSphereLeft
        self.refractionCylinderLeft  = refractionCylinderLeft

        self.hearingLeft1kHz  = hearingLeft1kHz
        self.hearingRight1kHz = hearingRight1kHz
        self.hearingLeft4kHz  = hearingLeft4kHz
        self.hearingRight4kHz = hearingRight4kHz
    }
}

// Keep only what you need to restore; include the ID to keep continuity
struct CheckupRecordSnapshot {
    let record: CheckupRecord

    init(_ rec: CheckupRecord) {
        self.record = rec
    }

    func restoreRecord() -> CheckupRecord {
        // Recreate with the same id & fields so charts/history look identical
        let r = CheckupRecord(
            id: record.id,
            createdAt: record.createdAt,
            date: record.date,
            gender: record.gender,
            heightCm: record.heightCm,
            weightKg: record.weightKg,
            // …copy all optionals…
            fatPercent: record.fatPercent,
            waistCm: record.waistCm,
            systolic: record.systolic,
            diastolic: record.diastolic,
            rbcMillionPeruL: record.rbcMillionPeruL,
            hgbPerdL: record.hgbPerdL,
            hctPercent: record.hctPercent,
            pltThousandPeruL: record.pltThousandPeruL,
            wbcThousandPeruL: record.wbcThousandPeruL,
            ast: record.ast, alt: record.alt, ggt: record.ggt,
            totalProtein: record.totalProtein, albumin: record.albumin,
            creatinine: record.creatinine, uricAcid: record.uricAcid,
            fastingGlucoseMgdl: record.fastingGlucoseMgdl,
            hba1cNgspPercent: record.hba1cNgspPercent,
            totalChol: record.totalChol, hdl: record.hdl,
            ldl: record.ldl, triglycerides: record.triglycerides,
            lengthUnit: record.lengthUnit, weightUnit: record.weightUnit,
            // Eye & Hearing…
            uncorrectedAcuityRight: record.uncorrectedAcuityRight,
            uncorrectedAcuityLeft: record.uncorrectedAcuityLeft,
            correctedAcuityRight: record.correctedAcuityRight,
            correctedAcuityLeft: record.correctedAcuityLeft,
            iopRight: record.iopRight, iopLeft: record.iopLeft,
            nearAcuityBoth: record.nearAcuityBoth,
            colorPlatesCorrect: record.colorPlatesCorrect,
            colorPlatesTotal: record.colorPlatesTotal,
            refractionSphereRight: record.refractionSphereRight,
            refractionCylinderRight: record.refractionCylinderRight,
            refractionSphereLeft: record.refractionSphereLeft,
            refractionCylinderLeft: record.refractionCylinderLeft,
            hearingLeft1kHz: record.hearingLeft1kHz,
            hearingRight1kHz: record.hearingRight1kHz,
            hearingLeft4kHz: record.hearingLeft4kHz,
            hearingRight4kHz: record.hearingRight4kHz
        )
        return r
    }
}
