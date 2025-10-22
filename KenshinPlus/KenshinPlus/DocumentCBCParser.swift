//
//  DocumentCBCParser.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/21.
//

import Foundation
import Vision
import OSLog

/// Logger for document inventory and debug table dumps.
private let docLogger = Logger(subsystem: "com.kenshin.plus", category: "Documents")

/// Errors thrown by the checkup parsing pipeline.
/// - noDocument: Vision found no document container in the image.
/// - noTable: No tables detected (even after sweep).
/// - emptyResults: Nothing extractable was found in the parsed tables.
public enum ParserError: LocalizedError {
    case noDocument
    case noTable
    case emptyResults

    /// Human-readable descriptions for `ParserError` cases.
    public var errorDescription: String? {
        switch self {
        case .noDocument:   return "No document detected in the image."
        case .noTable:      return "No table detected. Try a straighter photo with better lighting."
        case .emptyResults: return "Couldn’t extract any values from the table."
        }
    }
}

/// Sparse container for any metric we might parse from a health check sheet.
/// All properties are optional; only fields that were detected are set.
/// Mergeable and suitable for binding into your ManualInputView.
public struct CheckupPatch {
    // Anthropometrics & BP
    /// Height in centimeters (cm).
    public var heightCm: Double?
    /// Weight in kilograms (kg).
    public var weightKg: Double?
    /// Waist circumference in centimeters (cm).
    public var waistCm:  Double?
    /// Body fat percentage (%).
    public var fatPercent: Double?
    /// Body mass index (BMI).
    public var bmi:      Double?
    /// Systolic blood pressure (mmHg).
    public var systolic: Double?
    /// Diastolic blood pressure (mmHg).
    public var diastolic: Double?
    
    // CBC
    /// RBC in 10^6/µL.
    public var rbcMillionPeruL: Double?
    /// Hemoglobin in g/dL.
    public var hgbPerdL: Double?
    /// Hematocrit in %.
    public var hctPercent: Double?
    /// WBC in 10^3/µL.
    public var wbcThousandPeruL: Double?
    /// Platelets in 10^3/µL.
    public var pltThousandPeruL: Double?
    
    // Liver
    /// AST in U/L.
    public var ast: Double?
    /// ALT in U/L.
    public var alt: Double?
    /// GGT in U/L.
    public var ggt: Double?
    /// Total protein in g/dL.
    public var totalProtein: Double?
    /// Albumin in g/dL.
    public var albumin: Double?
    
    // Renal / Urate
    /// Creatinine in mg/dL (normalized if possible).
    public var creatinine: Double?
    /// Uric acid in mg/dL.
    public var uricAcid: Double?
    
    // Metabolism
    /// Fasting glucose in mg/dL.
    public var fastingGlucoseMgdl: Double?
    /// HbA1c (NGSP) in %.
    public var hba1cNgspPercent: Double?
    
    // Lipids
    /// Total cholesterol in mg/dL.
    public var totalChol: Double?
    /// HDL in mg/dL.
    public var hdl: Double?
    /// LDL in mg/dL.
    public var ldl: Double?
    /// Triglycerides in mg/dL.
    public var triglycerides: Double?
}

/// Recognizes a checkup sheet and returns a best-effort `CheckupPatch`.
///
/// Pipeline:
/// 1. Runs Vision document recognition on the full image.
/// 2. If no tables are found, optionally performs a multi-scale, multi-crop sweep
///    (see `findTablesBySweeping`) and merges any tables discovered.
/// 3. Parses tables via a generic value-column picker and any bespoke table
///    parsers you provide; falls back to line-based heuristics for exploration.
///
/// - Parameters:
///   - imageData: The source image data to analyze.
///   - onProgress: Optional progress callback invoked from background work with
///                 coarse `ParseProgress` updates. Bridge to `SweepProgress` for UI.
/// - Returns: A `CheckupPatch` containing only the fields successfully extracted.
/// - Throws: `ParserError.noDocument` if Vision cannot detect a document,
///           `ParserError.noTable` if no tables are found even after sweep,
///           `ParserError.emptyResults` if parsing yields no usable values.
/// - Note: The function makes no network calls; all recognition is on-device.
/// - SeeAlso: `CheckupPatch`, `ParserError`, `VisionSweep.findTablesBySweeping(...)`.
public func parseCheckup(
    from imageData: Data,
    onProgress: ParseProgressHandler? = nil
) async throws -> CheckupPatch {
    let req = RecognizeDocumentsRequest()
    let observations = try await req.perform(on: imageData)
    guard let document = observations.first?.document else { throw ParserError.noDocument }

    dumpDocumentInventoryDeep(document)

    var tables = document.tables

    if tables.isEmpty {
        if #available(iOS 18.0, *) {
            let swept = await VisionSweep.findTablesBySweeping(
                imageData: imageData,
                onProgress: onProgress   // <-- forward
            )
            if !swept.isEmpty {
                print("Sweep recovered \(swept.count) table(s).")
                tables = swept
            }
        }
    }

    if !tables.isEmpty {
        var merged = LabProbe.parseTablesGeneric(tables)
        for t in tables {
            let part = parseTable(t)
            merged.merge(with: part, policy: .preferExisting)
        }
        if merged.isEmpty { _ = LabProbe.probe(document: document, lookahead: 6) }
        return merged
    } else {
        _ = LabProbe.probe(document: document, lookahead: 6)
        return CheckupPatch()
    }
}

// MARK: - Merge policy

/// Conflict resolution when merging patches:
/// - preferExisting: Keep existing values; only fill missing fields.
/// - preferIncoming: Overwrite with incoming values.
enum MergePolicy { case preferExisting, preferIncoming }

// MARK: - Table → struct (Apple-style) → Patch (now covers more panels)

/// Apple-style row parser for “label … value [unit]” across a row.
/// Looks up recognized labels (JP/EN) and pulls the first plausible number,
/// with unit from the same or the next cell.
///
/// - Parameter table: A Vision table to parse.
/// - Returns: A partial `CheckupPatch` (merge with others as needed).
public func parseTable(_ table: DocumentObservation.Container.Table) -> CheckupPatch {
    var out = CheckupPatch()

    for row in table.rows {
        let label = rowLabel(row)

        // --- Anthropometrics ---
        if label.contains("身長") || labelLocalized(label, hasAnyOf: ["height"]) {
            if let (v, u) = firstNumericAndUnit(in: row), u == "cm" || u.isEmpty { out.heightCm = v }
            continue
        }
        if label.contains("体重") || labelLocalized(label, hasAnyOf: ["weight"]) {
            if let (v, u) = firstNumericAndUnit(in: row), u == "kg" || u.isEmpty { out.weightKg = v }
            continue
        }
        if label.contains("腹") || labelLocalized(label, hasAnyOf: ["waist", "abdominal", "waist circumference"]) {
            if let (v, u) = firstNumericAndUnit(in: row), u == "cm" || u.isEmpty { out.waistCm = v }
            continue
        }
        if label.contains("BMI") {
            if let (v, _) = firstNumericAndUnit(in: row) { out.bmi = v }
            continue
        }
        if labelLocalized(label, hasAnyOf: ["body fat", "fat%","体脂肪"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.fatPercent = v }
            continue
        }

        // --- Blood Pressure ---
        if label.contains("血圧") || label.contains("血1回目") || label.contains("血2回目") ||
           labelLocalized(label, hasAnyOf: ["blood pressure", "bp"]) {
            if let bp = plausibleBPValues(from: row) {
                out.systolic = out.systolic ?? bp.sys
                out.diastolic = out.diastolic ?? bp.dia
            }
            continue
        }

        // --- CBC ---
        if labelLocalized(label, hasAnyOf: ["hemoglobin", "hgb", "ヘモグロビン"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.hgbPerdL = v; continue }
        }
        if labelLocalized(label, hasAnyOf: ["rbc", "赤血球"]) {
            if let (v, u) = firstNumericAndUnit(in: row) { out.rbcMillionPeruL = toRBCMillionPeruL(value: v, unit: u); continue }
        }
        if labelLocalized(label, hasAnyOf: ["hematocrit", "hct", "pcv", "ヘマトクリット"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.hctPercent = v; continue }
        }
        if labelLocalized(label, hasAnyOf: ["wbc", "白血球"]) {
            if let (v, u) = firstNumericAndUnit(in: row) { out.wbcThousandPeruL = toThousandsPeruL(value: v, unit: u); continue }
        }
        if labelLocalized(label, hasAnyOf: ["platelet", "platelets", "血小板", "plt"]) {
            if let (v, u) = firstNumericAndUnit(in: row) { out.pltThousandPeruL = toThousandsPeruL(value: v, unit: u); continue }
        }

        // --- Liver ---
        if labelLocalized(label, hasAnyOf: ["ast","got","a s t"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.ast = v; continue }
        }
        if labelLocalized(label, hasAnyOf: ["alt","gpt","a l t"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.alt = v; continue }
        }
        if labelLocalized(label, hasAnyOf: ["ggt","γ-gt","γgt","γ-gtp","γgtp"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.ggt = v; continue }
        }
        if labelLocalized(label, hasAnyOf: ["total protein","tp","総蛋白","総たんぱく"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.totalProtein = v; continue }
        }
        if labelLocalized(label, hasAnyOf: ["albumin","alb","アルブミン"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.albumin = v; continue }
        }

        // --- Renal / Urate ---
        if labelLocalized(label, hasAnyOf: ["creatinine","cr","クレアチニン"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.creatinine = v; continue }
        }
        if labelLocalized(label, hasAnyOf: ["uric acid","ua","尿酸"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.uricAcid = v; continue }
        }

        // --- Metabolism ---
        if labelLocalized(label, hasAnyOf: ["fasting glucose","glucose","空腹時血糖","血糖"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.fastingGlucoseMgdl = v; continue }
        }
        if labelLocalized(label, hasAnyOf: ["hba1c","a1c","ヘモグロビンa1c"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.hba1cNgspPercent = v; continue }
        }

        // --- Lipids ---
        if labelLocalized(label, hasAnyOf: ["total cholesterol","tc","総コレステロール"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.totalChol = v; continue }
        }
        if labelLocalized(label, hasAnyOf: ["hdl","hdl-c","hdlコレステロール"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.hdl = v; continue }
        }
        if labelLocalized(label, hasAnyOf: ["ldl","ldl-c","ldlコレステロール"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.ldl = v; continue }
        }
        if labelLocalized(label, hasAnyOf: ["triglycerides","tg","中性脂肪","トリグリセリド"]) {
            if let (v, _) = firstNumericAndUnit(in: row) { out.triglycerides = v; continue }
        }
    }

    return out
}
// MARK: - Fallback (no table)

/// Fallback regex-based miner when no tables are present.
/// Scans full text for common CBC patterns and returns a partial patch.
///
/// - Note: Limited scope by design; extend with care to avoid false positives.
private func parseFromDocumentText(_ document: DocumentObservation.Container) -> CheckupPatch {
    var out = CheckupPatch()
    let text = document.text.transcript

    func firstDouble(_ pattern: String) -> Double? {
        let r = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
        let range = NSRange(text.startIndex..., in: text)
        guard let m = r.firstMatch(in: text, options: [], range: range),
              let rr = Range(m.range(at: 1), in: text) else { return nil }
        return Double(text[rr].replacingOccurrences(of: ",", with: "."))
    }

    // Keep the useful CBC fallbacks; extend as needed:
    out.hgbPerdL = firstDouble(#"(?:(?:Hemoglobin(?:\s*\(Hb\))?)|HGB)[^0-9]{0,40}(\d{1,2}(?:[.,]\d)?)"#)
    out.rbcMillionPeruL = firstDouble(#"(?:(?:Total\s*)?RBC(?:\s*COUNT)?)[^0-9]{0,40}(\d{1,3}(?:[.,]\d{1,3})?)"#)
    out.hctPercent = firstDouble(#"(?:(?:Packed\s*Cell\s*Volume|PCV|Hematocrit|HCT))[^0-9]{0,40}(\d{1,2}(?:[.,]\d)?)"#)
    if let wbcAbs = firstDouble(#"(?:(?:Total\s*)?WBC(?:\s*COUNT)?)[^0-9]{0,40}(\d{3,7})"#) {
        out.wbcThousandPeruL = wbcAbs / 1000.0
    }
    if let pltAbs = firstDouble(#"(?:Platelet(?:\s*Count)?)[^0-9]{0,40}(\d{4,8})"#) {
        out.pltThousandPeruL = pltAbs / 1000.0
    }
    return out
}

// MARK: - Selection & Debug - Shared helpers

/// Example ranker that returns the largest table by area (rows * maxCols).
/// Not used in the multi-table merge flow, but useful for single-table UIs.
private func pickBestTable(from document: DocumentObservation.Container) -> DocumentObservation.Container.Table? {
    document.tables.max { a, b in
        let aCols = a.rows.map { $0.count }.max() ?? 0
        let bCols = b.rows.map { $0.count }.max() ?? 0
        return (a.rows.count * aCols) < (b.rows.count * bCols)
    }
}

/// Prints a verbatim dump of a single table with cell positions and text.
/// Handy during heuristic tuning. Also logs via `docLogger`.
public func debugDump(table: DocumentObservation.Container.Table, header: String = "DOCUMENT TABLE DUMP") -> String {
    var out: [String] = []
    let rowCount = table.rows.count
    let maxCols = table.rows.map(\.count).max() ?? 0
    out.append("=== \(header) ===")
    out.append("Rows: \(rowCount), Max Cols: \(maxCols)")
    for (r, row) in table.rows.enumerated() {
        out.append("-- Row \(r) (cells: \(row.count))")
        for (c, cell) in row.enumerated() {
            let t = cell.content.text
            out.append("  [\(r),\(c)] \"\(t.transcript)\"")
        }
    }
    out.append("=== END \(header) ===")
    let s = out.joined(separator: "\n")
    docLogger.info("\(s, privacy: .public)")
    print(s)
    return s
}

// MARK: - Row + value helpers

/// Joins the first ~3 cells and fixes frequent OCR quirks to produce a stable row label.
/// Examples: “B M I” → “BMI”, “血王” → “血圧”.
private func rowLabel(_ row: [DocumentObservation.Container.Table.Cell]) -> String {
    let joined = row.prefix(3)
        .map { $0.content.text.transcript }
        .joined()
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "　", with: "")
        .replacingOccurrences(of: "\n", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)

    return joined
        .replacingOccurrences(of: "BM", with: "BMI")   // "B M" → "BMI"
        .replacingOccurrences(of: "血王", with: "血圧")   // 王→圧
        .replacingOccurrences(of: "力左", with: "視力左")
        .replacingOccurrences(of: "視右", with: "視力右")
}

/// Scans rightward from `startCol` and returns the first `(value, unit)`
/// pair, using the next cell as a unit fallback.
///
/// - Parameters:
///   - row: The table row cells.
///   - startCol: Column index to start scanning for values (default 3).
private func firstNumericAndUnit(in row: [DocumentObservation.Container.Table.Cell], startCol: Int = 3) -> (value: Double, unit: String)? {
    let tail = Array(row.dropFirst(startCol))
    for (i, cell) in tail.enumerated() {
        let txt = cell.content.text.transcript
        if let v = OCRParse.numbers(in: txt).first {
            // Unit can be in same cell or next cell
            let unitCandidates = [txt] + (i + 1 < tail.count ? [tail[i + 1].content.text.transcript] : [])
            let unit = normalizedUnit(from: unitCandidates.joined(separator: " "))
            return (v, unit)
        }
    }
    return nil
}

/// Normalizes raw unit text to standard tokens (mmHg, cm, kg, %, mg/dL, g/dL, U/L, CBC units).
private func normalizedUnit(from s: String) -> String {
    let t = s
      .replacingOccurrences(of: "μ", with: "µ")
      .replacingOccurrences(of: "∕", with: "/")
      .replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: "　", with: "")
      .replacingOccurrences(of: "\n", with: "")
      .lowercased()

    if t.contains("mmhg") || t.contains("mmig") { return "mmHg" }
    if t.contains("cm") { return "cm" }
    if t.contains("kg") { return "kg" }
    if t.contains("%")  { return "%" }
    if t.contains("10^6") || t.contains("mill") { return "10^6/µl" }
    if t.contains("10^3") || t.contains("k/") || t.contains("10^9/l") { return "10^3/µl" }
    if t.contains("/µl") || t.contains("/ul") || t.contains("cumm") { return "/µl" }
    if t.contains("mg/dl") || t.contains("mg∕dl") { return "mg/dL" }
    if t.contains("iu/l") || t.contains("u/l") { return "U/L" }
    if t.contains("g/dl") { return "g/dL" }
    if t.contains("万/µl") || t.contains("万/ul") { return "10^4/µL" }
    if t.contains("千/µl") || t.contains("千/ul") { return "10^3/µL" }

    // Also accept explicit 10^4 patterns (including superscript)
    if t.contains("10^4/") || t.contains("10⁴/") { return "10^4/µL" }

    return ""
}

/// Attempts to extract a (systolic, diastolic) pair by taking the last two plausible BP numbers in the row (30…250), ordering them as max/min.
private func plausibleBPValues(from row: [DocumentObservation.Container.Table.Cell]) -> (sys: Double, dia: Double)? {
    let withIndex: [(idx: Int, value: Double)] = row.enumerated().flatMap { (cIdx, cell) in
        OCRParse.numbers(in: cell.content.text.transcript).map { (cIdx, $0) }
    }
    let candidates = withIndex.filter { 30...250 ~= $0.value }.sorted { $0.idx < $1.idx }
    guard candidates.count >= 2 else { return nil }
    let pair = Array(candidates.suffix(2)).map(\.value)
    guard let maxVal = pair.max(), let minVal = pair.min() else { return nil }
    return (sys: maxVal, dia: minVal)
}

/// Returns true if `label` contains any of the provided keys (case-insensitive), supporting JP and EN mixed labels.
private func labelLocalized(_ label: String, hasAnyOf keys: [String]) -> Bool {
    let low = label.lowercased()
    return keys.contains { low.contains($0) } || keys.contains { label.contains($0) }
}

// MARK: - Unit conversions (best-effort, safe defaults)

/// Converts RBC absolute or 10^12/L to 10^6/µL.
private func toRBCMillionPeruL(value v: Double, unit: String) -> Double {
  let u = unit
    .replacingOccurrences(of: "μ", with: "µ")
    .lowercased()

  if u.contains("10^6") { return v }            // already M/µL
  if u.contains("10^4") { return v / 100.0 }    // 万/µL → ÷100
  if u.contains("/µl") || u.contains("/ul") {   // absolute per µL → ÷1e6
    return v / 1_000_000.0
  }
  // no unit? gentle heuristic: values > 50 look like 万/µL → ÷100
  return v > 50 ? v / 100.0 : v
}

/// Converts WBC/PLT absolute counts to 10^3/µL if needed.
private func toThousandsPeruL(value v: Double, unit: String) -> Double {
  let u = unit
    .replacingOccurrences(of: "μ", with: "µ")
    .lowercased()

  if u.contains("10^3") { return v }            // 千/µL
  if u.contains("10^4") { return v * 10.0 }     // 万/µL → ×10
  if u.contains("/µl") || u.contains("/ul") { return v / 1000.0 }
  return v > 2000 ? (v / 1000.0) : v
}

/// Converts glucose mmol/L → mg/dL; cholesterol mmol/L → mg/dL; TG mmol/L → mg/dL.
private func toGlucoseMgdl(value v: Double, unit: String) -> Double {
    let u = unit.lowercased()
    if u == "mg/dl" || u.isEmpty { return v }
    if u == "mmol/l" { return v * 18.0 }
    return v
}

private func toCholMgdl(value v: Double, unit: String) -> Double {
    let u = unit.lowercased()
    if u == "mg/dl" || u.isEmpty { return v }
    if u == "mmol/l" { return v * 38.67 }
    return v
}

private func toTgMgdl(value v: Double, unit: String) -> Double {
    let u = unit.lowercased()
    if u == "mg/dl" || u.isEmpty { return v }
    if u == "mmol/l" { return v * 88.57 }
    return v
}

/// Converts creatinine µmol/L → mg/dL; uric acid µmol/L → mg/dL.
private func toCreatinineMgdl(value v: Double, unit: String) -> Double {
    let u = unit.lowercased()
    if u == "mg/dl" || u.isEmpty { return v }
    if u == "µmol/l" || u == "umol/l" { return v / 88.4 }
    return v
}

private func toUricAcidMgdl(value v: Double, unit: String) -> Double {
    let u = unit.lowercased()
    if u == "mg/dl" || u.isEmpty { return v }
    if u == "µmol/l" || u == "umol/l" { return v / 59.48 }
    return v
}


// Detect if the patch actually contains anything.
extension CheckupPatch {
    /// Returns `true` if all fields are `nil` (no data captured).
    var isEmpty: Bool {
        Mirror(reflecting: self).children
            .compactMap { $0.value as? Double? }
            .allSatisfy { $0 == nil }
    }

    /// Merges fields from another patch using `MergePolicy`.
    /// - Important: Only `Double?` fields are considered; extend if adding types.
    mutating func merge(with other: CheckupPatch, policy: MergePolicy) {
        func pick(_ current: inout Double?, _ incoming: Double?) {
            guard let inc = incoming else { return }
            switch policy {
            case .preferExisting:
                if current == nil { current = inc }
            case .preferIncoming:
                current = inc
            }
        }

        // Anthropometrics
        pick(&heightCm, other.heightCm)
        pick(&weightKg, other.weightKg)
        pick(&bmi, other.bmi)
        pick(&fatPercent, other.fatPercent)
        pick(&waistCm, other.waistCm)

        // BP
        pick(&systolic, other.systolic)
        pick(&diastolic, other.diastolic)

        // CBC
        pick(&rbcMillionPeruL, other.rbcMillionPeruL)
        pick(&hgbPerdL, other.hgbPerdL)
        pick(&hctPercent, other.hctPercent)
        pick(&pltThousandPeruL, other.pltThousandPeruL)
        pick(&wbcThousandPeruL, other.wbcThousandPeruL)

        // Liver
        pick(&ast, other.ast)
        pick(&alt, other.alt)
        pick(&ggt, other.ggt)
        pick(&totalProtein, other.totalProtein)
        pick(&albumin, other.albumin)

        // Renal / Urate
        pick(&creatinine, other.creatinine)
        pick(&uricAcid, other.uricAcid)

        // Metabolism
        pick(&fastingGlucoseMgdl, other.fastingGlucoseMgdl)
        pick(&hba1cNgspPercent, other.hba1cNgspPercent)

        // Lipids
        pick(&totalChol, other.totalChol)
        pick(&hdl, other.hdl)
        pick(&ldl, other.ldl)
        pick(&triglycerides, other.triglycerides)
    }
}

/// Thin wrapper over `RecognizeDocumentsRequest.perform(on:)`.
/// Returns raw document observations from Vision for custom consumers.
///
/// - Returns: `[DocumentObservation]` (not just tables).
func extractTable(from image: Data) async throws -> [DocumentObservation] {
    
    // The Vision request.
    let request = RecognizeDocumentsRequest()
    
    // Perform the request on the image data and return the results.
    let observations = try await request.perform(on: image)
    
    return observations
}

/// Prints a concise inventory of tables and the first `maxLines` lines of text in reading order. Good first look before deeper debugging.
func dumpDocumentInventory(_ document: DocumentObservation.Container, maxLines: Int = 80) {
    let tables = document.tables
    let text = document.text

    print("=== DOCUMENT INVENTORY ===")
    print("Tables: \(tables.count)")
    if !tables.isEmpty {
        for (ti, t) in tables.enumerated() {
            let rows = t.rows.count
            let maxCols = t.rows.map(\.count).max() ?? 0
            print("  Table #\(ti): rows=\(rows), maxCols=\(maxCols)")
        }
    }

    print("Lines in reading order: \(text.lines.count)")
    for (i, line) in text.lines.prefix(maxLines).enumerated() {
        print(String(format: "[%02d] %@", i, line.transcript))
    }
    
    
    print("=== END INVENTORY ===")
    docLogger.info("Tables=\(tables.count), lines=\(text.lines.count)")
}

/// Attempts to infer a table-like structure using **only** consecutive lines (no geometry). Best-effort heuristic; used as a fallback in some flows.
private func parseQuasiTableFromLines(_ document: DocumentObservation.Container) -> CheckupPatch {
    var out = CheckupPatch()
    let lines = document.text.lines.map { $0.transcript }

    func unitToken(_ s: String) -> String {
        let t = s
          .replacingOccurrences(of: "μ", with: "µ")
          .replacingOccurrences(of: "∕", with: "/")
          .replacingOccurrences(of: " ", with: "")
          .replacingOccurrences(of: "　", with: "")
          .replacingOccurrences(of: "\n", with: "")
          .lowercased()

        if t.contains("g/dl") { return "g/dL" }
        if t.contains("mg/dl") || t.contains("mg∕dl") { return "mg/dL" }
        if t.contains("mmhg") || t.contains("mmig") { return "mmHg" }
        if t.contains("10^3") || t.contains("k/") || t.contains("10^9/l") { return "10^3/µl" }
        if t.contains("10^6") || t.contains("mill") { return "10^6/µl" }
        if t.contains("/µl") || t.contains("/ul") || t.contains("cumm") { return "/µl" }
        if t.contains("%") { return "%" }
        if t.contains("cm") { return "cm" }
        if t.contains("kg") { return "kg" }
        if t.contains("万/µl") || t.contains("万/ul") { return "10^4/µL" }
        if t.contains("千/µl") || t.contains("千/ul") { return "10^3/µL" }

        // Accept explicit 10^4 patterns
        if t.contains("10^4/") || t.contains("10⁴/") { return "10^4/µL" }

        return ""
    }

    func norm(_ s: String) -> String {
        s.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "　", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
    
    for (i, raw) in lines.enumerated() {
        let lab = norm(raw)
        // try to grab the current line’s numbers; if none, peek next line
        var values = OCRParse.numbers(in: raw)
        var unit = unitToken(raw)
        if values.isEmpty, i + 1 < lines.count {
            values = OCRParse.numbers(in: lines[i + 1])
            if unit.isEmpty { unit = unitToken(lines[i + 1]) }
        }
        guard let v = values.first else { continue }
        
        // Anthropometrics
        if lab.contains("身長") || lab.contains("height") { if unit == "cm" || unit.isEmpty { out.heightCm = v }; continue }
        if lab.contains("体重") || lab.contains("weight") { if unit == "kg" || unit.isEmpty { out.weightKg = v }; continue }
        if lab.contains("腹") || lab.contains("waist") { if unit == "cm" || unit.isEmpty { out.waistCm = v }; continue }
        if lab.contains("bmi") { out.bmi = v; continue }
        if lab.contains("体脂肪") || lab.contains("bodyfat") { out.fatPercent = v; continue }
        
        // Blood pressure – look for two plausible values on this/next line
        if lab.contains("血圧") || lab.contains("bp") {
            let more = (i + 1 < lines.count) ? OCRParse.numbers(in: lines[i + 1]) : []
            let both = (values + more).filter { 30...250 ~= $0 }
            if both.count >= 2 {
                let sys = max(both[both.count - 1], both[both.count - 2])
                let dia = min(both[both.count - 1], both[both.count - 2])
                out.systolic = out.systolic ?? sys
                out.diastolic = out.diastolic ?? dia
            }
            continue
        }
        
        // CBC
        if lab.contains("hemoglobin") || lab.contains("hgb") || lab.contains("ヘモグロビン") { out.hgbPerdL = v; continue }
        if lab.contains("rbc") || lab.contains("赤血球") {
            out.rbcMillionPeruL = (unit.contains("10^12") ? v * 1000.0 : v) ; continue
        }
        if lab.contains("hematocrit") || lab.contains("hct") || lab.contains("pcv") || lab.contains("ヘマトクリット") { out.hctPercent = v; continue }
        if lab.contains("wbc") || lab.contains("白血球") {
            out.wbcThousandPeruL = (unit == "/µl" ? v / 1000.0 : v); continue
        }
        if lab.contains("platelet") || lab.contains("血小板") || lab.contains("plt") {
            out.pltThousandPeruL = (unit == "/µl" ? v / 1000.0 : v); continue
        }
        
        // Liver
        if lab.contains("ast") || lab.contains("got") { out.ast = v; continue }
        if lab.contains("alt") || lab.contains("gpt") { out.alt = v; continue }
        if lab.contains("γ-gt") || lab.contains("ggt") || lab.contains("γgt") || lab.contains("γ-gtp") || lab.contains("γgtp") { out.ggt = v; continue }
        if lab.contains("総蛋白") || lab.contains("総たんぱく") || lab.contains("totalprotein") || lab.contains("tp") { out.totalProtein = v; continue }
        if lab.contains("アルブミン") || lab.contains("albumin") || lab.contains("alb") { out.albumin = v; continue }
        
        // Renal / urate
        if lab.contains("creatinine") || lab.contains("クレアチニン") || lab.contains("cr") { out.creatinine = v; continue }
        if lab.contains("尿酸") || lab.contains("uricacid") || lab.contains("ua") { out.uricAcid = v; continue }
        
        // Metabolism
        if lab.contains("hba1c") || lab.contains("a1c") || lab.contains("ヘモグロビンa1c") { out.hba1cNgspPercent = v; continue }
        if lab.contains("glucose") || lab.contains("空腹時血糖") || lab.contains("血糖") { out.fastingGlucoseMgdl = v; continue }
        
        // Lipids
        if lab.contains("総コレステロール") || lab.contains("totalcholesterol") || lab.contains("tc") { out.totalChol = v; continue }
        if lab.contains("hdl") || lab.contains("hdlコレステロール") { out.hdl = v; continue }
        if lab.contains("ldl") || lab.contains("ldlコレステロール") { out.ldl = v; continue }
        if lab.contains("中性脂肪") || lab.contains("トリグリセリド") || lab.contains("triglycerides") || lab.contains("tg") { out.triglycerides = v; continue }
    }
    
    return out
}

/// Verbose inventory: title, bounding region, tables (shape), lists (items), paragraphs (first few), and the first `maxExamples` reading-order lines.
func dumpDocumentInventoryDeep(_ document: DocumentObservation.Container,
                               maxExamples: Int = 80) {
    print("=== DOCUMENT INVENTORY (DEEP) ===")

    // Title is already a Text
    if let title = document.title?.transcript, !title.isEmpty {
        print("Title: \(title)")
    } else {
        print("Title: —")
    }

    print("BoundingRegion: \(String(describing: document.boundingRegion))")

    // Tables
    print("Tables: \(document.tables.count)")
    for (ti, t) in document.tables.enumerated() {
        let rows = t.rows.count
        let maxCols = t.rows.map(\.count).max() ?? 0
        print("  Table #\(ti): rows=\(rows), maxCols=\(maxCols)")
    }

    // Lists → items use content.text
    print("Lists: \(document.lists.count)")
    for (li, lst) in document.lists.enumerated() {
        print("  List #\(li): items=\(lst.items.count)")
        for (ii, item) in lst.items.prefix(8).enumerated() {
            print("    - [\(ii)] \(item.content.text.transcript)")
        }
        if lst.items.count > 8 { print("    …") }
    }

    // Paragraphs are already Text objects
    print("Paragraphs: \(document.paragraphs.count)")
    for (pi, p) in document.paragraphs.prefix(10).enumerated() {
        print("  [P\(pi)] \(p.transcript)")
    }
    if document.paragraphs.count > 10 { print("  …") }

    // Lines in reading order
    let lines = document.text.lines
    print("Lines in reading order: \(lines.count)")
    for (i, line) in lines.prefix(maxExamples).enumerated() {
        print(String(format: "[%02d] %@", i, line.transcript))
    }
    if lines.count > maxExamples { print("…") }

    print("hashValue: \(document.hashValue)")
    print("=== END INVENTORY (DEEP) ===")
}

/// Value finder that walks lists and paragraph text, biasing toward lines that also include “今回” (or split variants) when searching for values near labels.
/// Useful when tables weren’t recognized but text structure exists.
func parseFromListsAndParagraphs(_ document: DocumentObservation.Container) -> CheckupPatch {
    var out = CheckupPatch()
    // --- Small helpers ---
    func norm(_ s: String) -> String {
        s.lowercased()
         .replacingOccurrences(of: " ", with: "")
         .replacingOccurrences(of: "　", with: "")
         .replacingOccurrences(of: "\n", with: "")
    }

    func numbers(_ s: String) -> [Double] {
        let s2 = s.replacingOccurrences(of: ",", with: ".")
        let re = try! NSRegularExpression(pattern: #"-?\d+(?:\.\d+)?"#)
        let r = NSRange(s2.startIndex..., in: s2)
        return re.matches(in: s2, range: r).compactMap { Range($0.range, in: s2).flatMap { Double(String(s2[$0])) } }
    }

    func unitToken(_ s: String) -> String {
        let t = s
          .replacingOccurrences(of: "μ", with: "µ")
          .replacingOccurrences(of: "∕", with: "/")
          .replacingOccurrences(of: " ", with: "")
          .replacingOccurrences(of: "　", with: "")
          .replacingOccurrences(of: "\n", with: "")
          .lowercased()

        if t.contains("mmhg") || t.contains("mmig") { return "mmHg" }
        if t.contains("cm") { return "cm" }
        if t.contains("kg") { return "kg" }
        if t.contains("%")  { return "%" }
        if t.contains("mg/dl") || t.contains("mg∕dl") { return "mg/dL" }
        if t.contains("g/dl") { return "g/dL" }
        if t.contains("iu/l") || t.contains("u/l") { return "U/L" }
        if t.contains("10^6") || t.contains("mill") { return "10^6/µl" }
        if t.contains("10^3") || t.contains("k/") || t.contains("10^9/l") { return "10^3/µl" }
        if t.contains("/µl") || t.contains("/ul") || t.contains("cumm") { return "/µl" }
        if t.contains("万/µl") || t.contains("万/ul") { return "10^4/µL" }
        if t.contains("千/µl") || t.contains("千/ul") { return "10^3/µL" }

        // Also accept explicit 10^4 patterns (including superscript)
        if t.contains("10^4/") || t.contains("10⁴/") { return "10^4/µL" }

        return ""
    }
    // Prefer values near a “current” column marker if present
    // We just use text proximity; (geometry is optional and can be added later)
    let lines = document.text.lines.map(\.transcript)
    let normalized = lines.map(norm)
    // A quick helper that, given a set of label needles, searches forward a few lines
    // and returns the first numeric + unit it finds (preferring lines that also mention “今回”).
    func takeValue(whenLabelHas anyOf: [String], lookahead: Int = 3) -> (Double, String)? {
        // Find the first index of any label token
        for i in 0..<normalized.count {
            if anyOf.contains(where: { normalized[i].contains($0) }) {
                // Search current line first, then up to N following lines
                let end = min(i + lookahead, normalized.count - 1)
                // 1) Try lines that also have "今回" (joined or split)
                for j in i...end {
                    let hasKonkai = normalized[j].contains("今回") || (normalized[j].contains("今") && normalized[j].contains("回"))
                    if hasKonkai {
                        let txt = lines[j]
                        if let v = numbers(txt).first {
                            return (v, unitToken(txt))
                        }
                    }
                }
                // 2) Otherwise take the first numeric we see in the window
                for j in i...end {
                    let txt = lines[j]
                    if let v = numbers(txt).first {
                        return (v, unitToken(txt))
                    }
                }
            }
        }
        return nil
    }
    // --- Anthropometrics ---
    if let (v,u) = takeValue(whenLabelHas: ["身長","height"]) {
        if u == "cm" || u.isEmpty { out.heightCm = v }
    }
    if let (v,u) = takeValue(whenLabelHas: ["体重","weight"]) {
        if u == "kg" || u.isEmpty { out.weightKg = v }
    }
    if let (v,u) = takeValue(whenLabelHas: ["腹囲","腹","waist"]) {
        if u == "cm" || u.isEmpty { out.waistCm = v }
    }
    if let (v,_) = takeValue(whenLabelHas: ["bmi","bm"]) { out.bmi = v }
    if let (v,_) = takeValue(whenLabelHas: ["体脂肪","bodyfat","fat%"]) { out.fatPercent = v }
    // --- Blood pressure (try to find two plausible values close to a BP label) ---
    if let bpAnchor = lines.firstIndex(where: { norm($0).contains("血圧") || norm($0).contains("bp") }) {
        let end = min(bpAnchor + 4, lines.count - 1)
        let windowVals = (bpAnchor...end)
            .flatMap { numbers(lines[$0]) }
            .filter { 30...250 ~= $0 }
        if windowVals.count >= 2 {
            let sys = max(windowVals[0], windowVals[1])
            let dia = min(windowVals[0], windowVals[1])
            out.systolic = sys
            out.diastolic = dia
        }
    }
    // --- CBC ---
    if let (v,_) = takeValue(whenLabelHas: ["hemoglobin","hgb","ヘモグロビン"]) { out.hgbPerdL = v }
    if let (v,u) = takeValue(whenLabelHas: ["rbc","赤血球"]) {
        out.rbcMillionPeruL = (u.contains("10^12") ? v * 1000.0 : v)
    }
    if let (v,_) = takeValue(whenLabelHas: ["hematocrit","hct","pcv","ヘマトクリット"]) { out.hctPercent = v }
    if let (v,u) = takeValue(whenLabelHas: ["wbc","白血球"]) {
        out.wbcThousandPeruL = (u == "/µl" ? v / 1000.0 : v)
    }
    if let (v,u) = takeValue(whenLabelHas: ["platelet","plt","血小板"]) {
        out.pltThousandPeruL = (u == "/µl" ? v / 1000.0 : v)
    }
    // --- Liver ---
    if let (v,_) = takeValue(whenLabelHas: ["ast","got","ａｓｔ"]) { out.ast = v }
    if let (v,_) = takeValue(whenLabelHas: ["alt","gpt","ａｌｔ"]) { out.alt = v }
    if let (v,_) = takeValue(whenLabelHas: ["γ-gt","γgt","ggt","γ-gtp","γgtp","γ-gtp"]) { out.ggt = v }
    if let (v,_) = takeValue(whenLabelHas: ["総蛋白","総たんぱく","totalprotein","tp"]) { out.totalProtein = v }
    if let (v,_) = takeValue(whenLabelHas: ["アルブミン","albumin","alb"]) { out.albumin = v }
    // --- Renal / urate ---
    if let (v,_) = takeValue(whenLabelHas: ["creatinine","クレアチニン","cr","cre"]) { out.creatinine = v }
    if let (v,_) = takeValue(whenLabelHas: ["尿酸","uricacid","ua"]) { out.uricAcid = v }
    // --- Metabolism ---
    if let (v,_) = takeValue(whenLabelHas: ["hba1c","a1c","ヘモグロビンa1c"]) { out.hba1cNgspPercent = v }
    if let (v,_) = takeValue(whenLabelHas: ["glucose","空腹時血糖","血糖"]) {
        // If units ever show up, normalize; most JP sheets already mg/dL
        out.fastingGlucoseMgdl = v
    }
    // --- Lipids ---
    if let (v,_) = takeValue(whenLabelHas: ["総コレステロール","totalcholesterol","tc"]) { out.totalChol = v }
    if let (v,_) = takeValue(whenLabelHas: ["hdl","hdlコレステロール"]) { out.hdl = v }
    if let (v,_) = takeValue(whenLabelHas: ["ldl","ldlコレステロール"]) { out.ldl = v }
    if let (v,_) = takeValue(whenLabelHas: ["中性脂肪","トリグリセリド","triglycerides","tg"]) { out.triglycerides = v }
    return out
}
