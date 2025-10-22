//
//  LabProbe.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/21.
//

import Foundation
import OSLog
import Vision

// Heuristics
/// Header tokens that likely denote a label/parameter column.
/// Used to *penalize* choosing this column as the values column.
private let LABEL_HEADER_TOKENS  = ["項目名","検査項目","項目","名称","parameter","test","analyte"]
/// Header tokens that likely denote a units column. Penalized in value picking.
private let UNIT_HEADER_TOKENS   = ["単位","unit"]
/// Header tokens for reference ranges, also penalized in value column scoring.
private let RANGE_HEADER_TOKENS  = ["基準","参考","範囲","レンジ","range","ref"]
/// Header tokens that tend to mark the “current/value/result” column.
/// Includes JP terms like “今回” and EN fallbacks (result/value/current).
private let VALUE_HEADER_TOKENS  = ["今回","現値","結果","測定値","実測","当日","result","value","current"] // extensible

// MARK: - Public entry

/// Heuristic analyte mining from Vision-recognized documents.
///
/// Provides:
///  - A reading-order “probe” mapping labels → nearby plausible numbers
///  - A generic panel/table parser that auto-selects the value column
///  - Helpers for units/ranges/plausibility filters
///
/// Designed to be composable with bespoke table parsers.
public enum LabProbe {

    /// Logger for LabProbe summaries and captures.
    public static let log = Logger(subsystem: "com.kenshin.plus", category: "LabProbe")
    
    /// Final analyte result emitted by `probe(document:)`.
    ///
    /// - Parameters:
    ///   - key: Canonical analyte key (e.g., "AST").
    ///   - label: Matched label text in the document.
    ///   - value: Numeric value captured.
    ///   - unit: Normalized unit token if detected (may be empty).
    ///   - valueLine: Reading-order line index for the value.
    ///   - labelLine: Reading-order line index where the label was seen.
    public struct Result: Sendable {
        public let key: String
        public let label: String
        public let value: Double
        public let unit: LabUnit
        public let valueLine: Int
        public let labelLine: Int
    }

    /// Internal candidate capture (value + unit + label + source line indices).
    /// Keeps richer provenance while selecting the best analyte values.
    /// - Note: `Sendable` for async safety.
    struct Cand: Sendable {
        let value: Double
        let unit: LabUnit
        let label: String
        let labelLine: Int
        let valueLine: Int
    }
    
    /// Canonical analytes recognized by the heuristics.
    /// Extend as needed for your domain.
    public enum Analyte: String, CaseIterable, Sendable {
        case WBC, RBC, HGB, GLU, HbA1c, LDL, HDL, TG, TC, AST, ALT, ALP, GGT, LDH, TP, ALB, CRE, eGFR, UA, HCT, PLT
    }
    
    /// Label keywords per analyte (JP/EN and common OCR quirks).
    /// Used by reading-order probe to anchor search windows.
    private static let KEYWORDS: [Analyte: [String]] = {
        var out: [Analyte: [String]] = [:]
        func mapKey(_ k: AnalyteKey) -> Analyte? {
            switch k {
            case .WBC: return .WBC
            case .RBC: return .RBC
            case .HGB: return .HGB
            case .HCT: return .HCT
            case .PLT: return .PLT
            case .AST: return .AST
            case .ALT: return .ALT
            case .ALP: return .ALP
            case .GGT: return .GGT
            case .LDH: return .LDH
            case .TP: return .TP
            case .ALB: return .ALB
            case .CRE: return .CRE
            case .eGFR: return .eGFR
            case .UA: return .UA
            case .GLU: return .GLU
            case .HbA1c: return .HbA1c
            case .LDL: return .LDL
            case .HDL: return .HDL
            case .TG: return .TG
            case .TC: return .TC
            }
        }
        for (k, labels) in AnalyteLexicon.labels {
            if let a = mapKey(k) { out[a] = labels }
        }
        return out
    }()
    
    // MARK: Public probe
    
    /// Scans the document text in reading order, anchors on label keywords,
    /// and chooses the nearest plausible number within `lookahead` lines.
    /// Also tries a lipid “row bundle” pattern before the generic sweep.
    ///
    /// - Parameters:
    ///   - document: Vision document container.
    ///   - lookahead: Lines to search forward from a label anchor.
    /// - Returns: Best-guess results per analyte (sorted by key).
    /// - SideEffects: Prints a human-readable summary and logs values.
    /// - Note: This path ignores geometry; pairs labels to values by proximity.
    @discardableResult
    public static func probe(document: DocumentObservation.Container,
                             lookahead: Int = 6) -> [Result] {
        let lines = document.text.lines.map { $0.transcript }
        
        print("=== LAB PROBE ===")
        print("Lines: \(lines.count)")
        print("Strategy: reading-order, label→nearest numeric (unit + plausibility gated)")
        
        
        
        var best: [Analyte: Cand] = [:]
        
        // 1) Lipid “row” bundle (labels then a single numbers line); maps by order
        merge(into: &best, from: tryLipidRowBundle(lines: lines))
        
        // 2) Simple label -> nearest plausible value
        func capture(_ a: Analyte, keys: [String]) {
          guard best[a] == nil else { return } // keep lipid bundle if already set
          guard let idx = firstIndex(ofAny: keys, in: lines) else { return }
          if let found = bestAfterLabel(for: a, from: idx, lines: lines, maxLookahead: lookahead) {
              let unitTok: LabUnit = UnitDetector.detect(in: lines[found.valueLine])
              best[a] = Cand(value: found.value,
                             unit: unitTok,
                             label: lines[idx],
                             labelLine: idx,
                             valueLine: found.valueLine)
            debugFound(a, value: found.value, label: lines[idx], labelIdx: idx, valueIdx: found.valueLine)
          }
        }
        
        // Map analytes you care about
        capture(.CRE,   keys: KEYWORDS[.CRE]  ?? [])
        capture(.eGFR,  keys: KEYWORDS[.eGFR] ?? [])
        capture(.UA,    keys: KEYWORDS[.UA]   ?? [])
        capture(.GLU,   keys: KEYWORDS[.GLU]  ?? [])
        capture(.HbA1c, keys: KEYWORDS[.HbA1c] ?? [])
        capture(.AST,   keys: KEYWORDS[.AST]  ?? [])
        capture(.ALT,   keys: KEYWORDS[.ALT]  ?? [])
        capture(.ALP,   keys: KEYWORDS[.ALP]  ?? [])
        capture(.GGT,   keys: KEYWORDS[.GGT]  ?? [])
        capture(.LDH,   keys: KEYWORDS[.LDH]  ?? [])
        capture(.TP,    keys: KEYWORDS[.TP]   ?? [])
        capture(.ALB,   keys: KEYWORDS[.ALB]  ?? [])
        capture(.TC,    keys: KEYWORDS[.TC]   ?? [])
        capture(.LDL,   keys: KEYWORDS[.LDL]  ?? [])
        capture(.HDL,   keys: KEYWORDS[.HDL]  ?? [])
        capture(.TG,    keys: KEYWORDS[.TG]   ?? [])
        // Optional CBC examples:
        // capture(.HCT,   keys: KEYWORDS[.HCT] ?? [])
        // capture(.PLT,   keys: KEYWORDS[.PLT] ?? [])
        
        // Final summary
        print("--- SUMMARY (best per key) ---")
        for a in Analyte.allCases.sorted(by: { $0.rawValue < $1.rawValue }) {
            if let c = best[a] {
                let val = String(format: "%.3f", c.value)
                let uStr = UnitString.describe(c.unit)
                print("• \(a.rawValue.padding(toLength: 6, withPad: " ", startingAt: 0))  \(val)\(uStr.isEmpty ? "" : " \(uStr)")")
            }
        }
        
        let out = best.map { (a, c) in
            Result(key: a.rawValue,
                   label: c.label,
                   value: c.value,
                   unit: c.unit,
                   valueLine: c.valueLine,
                   labelLine: c.labelLine)
        }
            .sorted { $0.key < $1.key }
        
        // Log
        log.info("\(out.map { "\($0.key)=\($0.value)" }.joined(separator: ", "), privacy: .public)")
        return out
    }
    
    // MARK: - Lipid bundle
    
    /// Detects clustered lipid labels followed by a single row of numbers
    /// (e.g., TC/LDL/HDL). Maps values to analytes by order.
    ///
    /// - Parameter lines: Document lines in reading order.
    /// - Returns: Partial analyte map with label provenance when matched.
    private static func tryLipidRowBundle(lines: [String]) -> [Analyte: (value: Double, unit: LabUnit, label: String, labelLine: Int, valueLine: Int)] {
        let wants: [(needle: String, analyte: Analyte)] = [
            ("総コレステロール", .TC),
            ("ldlコレステロール", .LDL),
            ("hdlコレステロール", .HDL),
            ("non-hdlコレステロール", .TC) // ignore storage for non-HDL
        ]
        
        var labelIdxs: [(idx: Int, a: Analyte)] = []
        for (i, raw) in lines.enumerated() {
            let t = low(raw)
            for (needle, a) in wants where t.contains(low(needle)) {
                labelIdxs.append((i, a))
            }
            if labelIdxs.count >= 3, let last = labelIdxs.last, i - last.idx > 8 { break }
        }
        guard !labelIdxs.isEmpty else { return [:] }
        
        let start = labelIdxs.map(\.idx).min()!
        var numbersLine: Int?
        for j in (start + 1)..<min(lines.count, start + 40) {
            let vals = OCRParse.numbers(in: lines[j])
            if vals.count >= 3 && !isRangeOrHeaderLine(lines[j]) {
                numbersLine = j; break
            }
        }
        guard let rowIdx = numbersLine else { return [:] }
        
        let vals = OCRParse.numbers(in: lines[rowIdx])
        var out: [Analyte: (Double, LabUnit, String, Int, Int)] = [:]
        let ordered: [Analyte] = [.TC, .LDL, .HDL]
        for (k, a) in ordered.enumerated() where k < vals.count {
            let v = vals[k]
            guard plausible(v, for: a) else { continue }
            let labelLine = labelIdxs.first(where: { $0.a == a })?.idx ?? start
            let detected: LabUnit = UnitDetector.detect(in: lines[rowIdx])
            out[a] = (v, detected, lines[labelLine], labelLine, rowIdx)
            debugFound(a, value: v, label: lines[labelLine], labelIdx: labelLine, valueIdx: rowIdx)
        }
        return out
    }
    
    // MARK: - Nearest-value finder
    
    /// Among numbers appearing on a label’s line or the next N lines,
    /// returns the best candidate (score favors nearer lines and unit presence).
    ///
    /// - Returns: `(value, valueLine)` if any plausible value is found.
    private static func bestAfterLabel(for a: Analyte,
                                       from labelIdx: Int,
                                       lines: [String],
                                       maxLookahead: Int) -> (value: Double, valueLine: Int)? {
        struct Candidate { let score: Double; let value: Double; let valueLine: Int }
        var best: Candidate?
        
        for offset in 0...maxLookahead {
            let i = labelIdx + offset
            guard i < lines.count else { break }
            let line = lines[i]
            if isRangeOrHeaderLine(line) { continue }
            
            let vals = OCRParse.numbers(in: line)
            guard !vals.isEmpty else { continue }
            
            let unitHere = UnitDetector.detect(in: line)
            for v in vals where plausible(v, for: a) {
              var s = 1.0 / Double(1 + offset)
              if unitHere != .unknown { s += 1.0 }   // unit presence bonus
              if [.LDL, .HDL, .TG, .TC].contains(a), abs(v.rounded() - v) < 0.001 { s += 0.1 }
              if best == nil || s > best!.score {
                best = Candidate(score: s, value: v, valueLine: i)
              }
            }
        }
        return best.map { ($0.value, $0.valueLine) }
    }
    
    // MARK: - Helpers
    
    /// Finds the first line index that contains any of the provided tokens
    /// (case/space/JP-fullwidth tolerant via `low(_:)`).
    private static func firstIndex(ofAny tokens: [String], in lines: [String]) -> Int? {
        let need = tokens.map(low)
        return lines.firstIndex { L in
            let t = low(L)
            return need.contains(where: { t.contains($0) })
        }
    }
    
    /// Normalizes by lowercasing and removing ASCII/JP spaces for robust contains().
    private static func low(_ s: String) -> String {
        s.lowercased().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "　", with: "")
    }
    
    /// Detects lines that are likely headers or reference ranges. Such lines
    /// are skipped when searching for numeric values.
    private static func isRangeOrHeaderLine(_ s: String) -> Bool {
        let t = low(s)
        if t.contains("基準") || t.contains("参考") || t.contains("範囲") { return true }
        if t.contains("単位") || t.contains("検査項目") || t.contains("検査結果") { return true }
        if isRangeString(s) { return true }
        return false
    }
    
    /// Matches simple numeric ranges like “130-219” or “81.1~101.6”.
    private static func isRangeString(_ s: String) -> Bool {
        // e.g. "130-219", "81.1~101.6"
        let pattern = #"\d+(?:\.\d+)?\s*[-~]\s*\d+(?:\.\d+)?"#
        return s.range(of: pattern, options: .regularExpression) != nil
    }

    /// Plausibility gates per analyte (conservative min/max).
    /// Helps avoid capturing ref ranges or IDs.
    private static func plausible(_ v: Double, for a: Analyte) -> Bool {
        switch a {
        case .GLU:   return (50...400).contains(v)
        case .HbA1c: return (3.5...14).contains(v)
        case .LDL:   return (30...300).contains(v)
        case .HDL:   return (10...150).contains(v)
        case .TG:    return (20...1000).contains(v)
        case .TC:    return (70...400).contains(v)
        case .AST:   return (0...500).contains(v)
        case .ALT:   return (0...500).contains(v)
        case .ALP:   return (0...2000).contains(v)
        case .GGT:   return (0...1000).contains(v)
        case .LDH:   return (50...2000).contains(v)
        case .TP:    return (4...9).contains(v)
        case .ALB:   return (2...6).contains(v)
        case .CRE:   return (0.3...5).contains(v) // mg/dL
        case .eGFR:  return (5...200).contains(v)
        case .UA:    return (2...15).contains(v)
        case .HCT:   return (20...60).contains(v)
        case .PLT:   return (30...1000).contains(v) // x10^3/µL
        case .WBC:
            return (0...500).contains(v)
        case .RBC:
            return (0...500).contains(v)
        case .HGB:
            return (0...500).contains(v)
        }
    }

    /// Debug print for a captured analyte with provenance (line indices).
    private static func debugFound(_ a: Analyte, value: Double, label: String, labelIdx: Int, valueIdx: Int) {
        let v = String(format: "%.3f", value)
        print("[\(a.rawValue)] \(v)   ⟵  label: “\(label)”  (lines \(labelIdx)→\(valueIdx))")
    }

    /// Merges lipid-row captures into the working candidate map.
    private static func merge(
      into dst: inout [Analyte: Cand],
      from src: [Analyte: (value: Double, unit: LabUnit, label: String, labelLine: Int, valueLine: Int)]
    ) {
      for (a, s) in src {
        dst[a] = Cand(value: s.value, unit: s.unit, label: s.label, labelLine: s.labelLine, valueLine: s.valueLine)
      }
    }
    
    // MARK: - Generic “panel” table parser (auto-picks value column)
    
    /// Picks a plausible header row (among the first 3) by token hits (label/unit/range/value).
    /// - Returns: Header row index or 0 as a safe default.
    private static func headerRowIndex(in t: DocumentObservation.Container.Table) -> Int? {
        let rows = t.rows
        guard !rows.isEmpty else { return nil }
        var best: (idx: Int, score: Int) = (0, -1)
        for i in 0..<min(rows.count, 3) {
            let joined = rows[i].map { $0.content.text.transcript }.joined()
            let s = OCRText.compact(joined)
            var sc = 0
            if LABEL_HEADER_TOKENS.contains(where: { s.contains(OCRText.compact($0)) }) { sc += 2 }
            if UNIT_HEADER_TOKENS.contains(where:  { s.contains(OCRText.compact($0)) }) { sc += 2 }
            if RANGE_HEADER_TOKENS.contains(where: { s.contains(OCRText.compact($0)) }) { sc += 2 }
            if VALUE_HEADER_TOKENS.contains(where: { s.contains(OCRText.compact($0)) }) { sc += 3 }
            if sc > best.score { best = (i, sc) }
        }
        return best.score >= 0 ? best.idx : 0
    }
    
    /// Scores each column to pick the “current/result” column using header hints and numeric density across data rows (penalizes label/unit/range columns).
    ///
    /// - Returns: Index of the value column or `nil` if ambiguous.
    private static func pickValueColumn(in t: DocumentObservation.Container.Table, headerRow hr: Int) -> Int? {
        let rows = t.rows
        guard hr < rows.count, !rows[hr].isEmpty else { return nil }
        let colCount = rows.map(\.count).max() ?? 0
        
        func isHeaderHit(_ txt: String, tokens: [String]) -> Bool {
            let s = OCRText.compact(txt)
            return tokens.contains { s.contains(OCRText.compact($0)) }
        }
        
        var best: (col: Int, score: Double) = (-1, -1.0)
        for c in 0..<colCount {
            let headerTxt = (c < rows[hr].count) ? rows[hr][c].content.text.transcript : ""
            let headerScore =
            (isHeaderHit(headerTxt, tokens: VALUE_HEADER_TOKENS) ? 2.5 : 0) -
            (isHeaderHit(headerTxt, tokens: RANGE_HEADER_TOKENS) ? 2.0 : 0) -
            (isHeaderHit(headerTxt, tokens: UNIT_HEADER_TOKENS)  ? 2.0 : 0) -
            (isHeaderHit(headerTxt, tokens: LABEL_HEADER_TOKENS) ? 1.5 : 0)
            
            var numericRows = 0, considered = 0
            for r in (hr+1)..<rows.count {
                if c < rows[r].count {
                    let txt = rows[r][c].content.text.transcript
                    if !txt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        considered += 1
                        if !OCRParse.numbers(in: txt).isEmpty { numericRows += 1 } // <— reuse existing OCRParse.numbers(in:)
                    }
                }
            }
            let density = considered > 0 ? Double(numericRows) / Double(considered) : 0.0
            let penalty = (isHeaderHit(headerTxt, tokens: LABEL_HEADER_TOKENS) ? 1.0 : 0.0)
            + (isHeaderHit(headerTxt, tokens: UNIT_HEADER_TOKENS)  ? 1.0 : 0.0)
            + (isHeaderHit(headerTxt, tokens: RANGE_HEADER_TOKENS) ? 1.0 : 0.0)
            
            let score = headerScore + density * 3.0 - penalty * 2.0
            if score > best.score { best = (c, score) }
        }
        return best.col >= 0 ? best.col : nil
    }

    /// Returns the index of a dedicated “unit(単位)” column when present.
    private static func indexOfUnitColumn(in t: DocumentObservation.Container.Table, headerRow hr: Int) -> Int? {
        guard hr < t.rows.count else { return nil }
        for (c, cell) in t.rows[hr].enumerated() {
            if OCRText.compact(cell.content.text.transcript).contains("単位") { return c }
        }
        return nil
    }

    /// Produces a row label by joining the first couple of cells (common on JP sheets).
    private static func rowLabel(_ row: [DocumentObservation.Container.Table.Cell]) -> String {
        row.prefix(2).map { $0.content.text.transcript }.joined()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "　", with: "")
    }

    /// Parses “panel-like” tables by auto-selecting a value column, then
    /// maps each row label to known metrics (anthropometrics, CBC, liver, lipids, etc.).
    ///
    /// - Parameter tables: Tables to parse.
    /// - Returns: A `CheckupPatch` filled with whatever was confidently detected.
    /// - Note: Works best when headers clearly mark label/value/unit columns.
    /// - SeeAlso: `parseTable(_:)` (bespoke Apple-style parser).
    static func parseTablesGeneric(_ tables: [DocumentObservation.Container.Table]) -> CheckupPatch {
        var out = CheckupPatch()
        for t in tables {
            guard let hr = headerRowIndex(in: t),
                  let valueCol = pickValueColumn(in: t, headerRow: hr) else { continue }
            let unitCol = indexOfUnitColumn(in: t, headerRow: hr)
            
            for row in t.rows.dropFirst(hr+1) {
                let label = OCRText.compact(rowLabel(row))
                let valueTxt = (valueCol < row.count) ? row[valueCol].content.text.transcript : ""
                guard let v = OCRParse.numbers(in: valueTxt).first else { continue } // reuse static numbers(in:)
                
                let unitTxt = (unitCol != nil && unitCol! < row.count)
                  ? row[unitCol!].content.text.transcript
                  : valueTxt
                let u = UnitDetector.detect(in: unitTxt)
                
                // Anthropometrics
                if label.contains("身長") { out.heightCm = v; continue }
                if label.contains("体重") { out.weightKg = v; continue }
                if label.contains("腹囲") || label.contains("腹") { out.waistCm = v; continue }
                if label.contains("bmi") { out.bmi = v; continue }
                
                // CBC
                if label.contains("白血球") || label.contains("wbc") { out.wbcThousandPeruL = Convert.toThousandsPeruL(value: v, unit: u); continue }
                if label.contains("赤血球") || label.contains("rbc") { out.rbcMillionPeruL  = Convert.rbcToMillionPeruL(value: v, unit: u); continue }
                if label.contains("ヘモグロビン") || label.contains("hgb") || label.contains("hemoglobin") { out.hgbPerdL = v; continue }
                if label.contains("ヘマトクリット") || label.contains("hct") || label.contains("hematocrit") { out.hctPercent = v; continue }
                if label.contains("血小板") || label.contains("plt") || label.contains("platelet") { out.pltThousandPeruL = Convert.toThousandsPeruL(value: v, unit: u); continue }
                
                // Liver
                if label.contains("ast") || label.contains("got") { out.ast = v; continue }
                if label.contains("alt") || label.contains("gpt") { out.alt = v; continue }
                if label.contains("γ") || label.contains("y-gt") || label.contains("ggt") || label.contains("gtp") { out.ggt = v; continue }
                //                if label.contains("alp") { out.alp = v; continue }
                //                if label.contains("ldh") { out.ldh = v; continue }
                
                // Proteins
                if label.contains("総蛋白") || label.contains("総たんぱく") || label.contains("totalprotein") || label.contains("tp") { out.totalProtein = v; continue }
                if label.contains("アルブミン") || label.contains("albumin") || label.contains("alb") { out.albumin = v; continue }
                
                // Renal / urate
                if label.contains("クレアチニン") || label.contains("creatinine") || label.contains("cre") { out.creatinine = v; continue }
                if label.contains("尿酸") || label.contains("uric") || label.contains("ua") { out.uricAcid = v; continue }
                
                // Metabolism
                if label.contains("hba1c") || label.contains("ヘモグロビンa1c") { out.hba1cNgspPercent = v; continue }
                if label.contains("グルコース") || label.contains("血糖") || label.contains("glucose") { out.fastingGlucoseMgdl = v; continue }
                
                // Lipids
                if label.contains("総コレステ") || label.contains("totalcholesterol") || label.contains("tc") { out.totalChol = v; continue }
                if label.contains("ldl") { out.ldl = v; continue }
                if label.contains("hdl") { out.hdl = v; continue }
                if label.contains("中性脂肪") || label.contains("トリグリセリド") || label.contains("triglycerides") || label.contains("tg") { out.triglycerides = v; continue }
            }
        }
        return out
    }
}
