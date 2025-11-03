//
//  CoreOCR.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/22.
//

import Foundation

enum OCRText {
  /// Aggressive normalization for OCR’d text that may have full-width glyphs.
  static func compact(_ s: String) -> String {
    s.lowercased()
     .replacingOccurrences(of: " ", with: "")
     .replacingOccurrences(of: "　", with: "")
     .replacingOccurrences(of: "\n", with: "")
     .replacingOccurrences(of: "∕", with: "/")
     .replacingOccurrences(of: "⁄", with: "/")
     .replacingOccurrences(of: "／", with: "/")
     .replacingOccurrences(of: "μ", with: "µ")
  }

  /// “Readable” normalization (keeps spaces) for logs/debug.
  static func normalize(_ s: String) -> String {
    s.lowercased()
     .replacingOccurrences(of: "∕", with: "/")
     .replacingOccurrences(of: "⁄", with: "/")
     .replacingOccurrences(of: "／", with: "/")
     .replacingOccurrences(of: "μ", with: "µ")
  }
}


/// Small helpers for numeric token extraction from OCR text.
///
/// Compiles a single `NSRegularExpression` once (thread-safe) and exposes
/// convenience methods to pull numeric values from mixed-language strings.
///
/// - Note: Replaces “,” with “.” before parsing to accommodate common OCR
///         decimal punctuation.
/// - ThreadSafety: All APIs are static and re-use a compiled regex.
enum OCRParse {

    /// Pre-compiled numeric matcher: `-?\d+(?:\.\d+)?`
    ///
    /// - Important: Kept private; use `numbers(in:)` / `firstNumber(in:)`.
    /// - Performance: Compiled once and reused to avoid per-call overhead.
  private static let re: NSRegularExpression = try! .init(
    pattern: #"-?\d+(?:\.\d+)?"#, options: []
  )

    /// Extracts all numeric tokens from a string, tolerant of OCR punctuation.
    ///
    /// The function first normalizes decimal commas to periods, then scans the
    /// string for integers or decimals and returns them as `Double`s.
    ///
    /// - Parameter s: Source text (e.g., a cell transcript or line).
    /// - Returns: An array of `Double` values in source order. Empty if none found.
    /// - Example:
    ///   ```swift
    ///   OCRParse.numbers(in: "LDL 132, HDL 58, TG 121")  // [132, 58, 121]
    ///   ```

  static func numbers(in s: String) -> [Double] {
    let s2 = s.replacingOccurrences(of: ",", with: ".")
    let r  = NSRange(s2.startIndex..., in: s2)
    return re.matches(in: s2, range: r)
      .compactMap { Range($0.range, in: s2) }
      .compactMap { Double(String(s2[$0])) }
  }

    /// Convenience for the first numeric token in a string.
    ///
    /// - Parameter s: Source text to scan.
    /// - Returns: The first parsed `Double`, or `nil` if none exist.
    /// - SeeAlso: `numbers(in:)`.
  static func firstNumber(in s: String) -> Double? {
    numbers(in: s).first
  }
}

// Swift 6 Sendable compatibility for LabUnit used in Result/Cand
public enum LabUnit: Equatable, @unchecked Sendable {
  case mg_dL, g_dL, U_L, percent
  case per_uL        // absolute /µL
  case k_per_uL      // 10^3/µL
  case m_per_uL      // 10^6/µL  (RBC M/µL)
  case ten4_per_uL   // 10^4/µL  (JP “万/µL”)
  case mmol_L
  case cm, kg, mmHg
  case unknown
}

enum UnitDetector {
  /// Detects a unit token from any chunk of text.
  static func detect(in raw: String) -> LabUnit {
    let t = OCRText.compact(raw)

    if t.contains("mg/dl")                 { return .mg_dL }
    if t.contains("g/dl")                  { return .g_dL }
    if t.contains("u/l") || t.contains("iu/l") { return .U_L }
    if t.contains("%")                     { return .percent }
    if t.contains("mmol/l")                { return .mmol_L }
    if t.contains("cm")                    { return .cm }
    if t.contains("kg")                    { return .kg }
    if t.contains("mmhg") || t.contains("mmig") { return .mmHg }

    // CBC scales
    if t.contains("10^6") || t.contains("mill")      { return .m_per_uL }
    if t.contains("10^3") || t.contains("k/") || t.contains("10^9/l")
                                                       { return .k_per_uL }
    if t.contains("万/ul") || t.contains("万/µl")     { return .ten4_per_uL }
    if t.contains("10^4/") || t.contains("10⁴/") || t.contains("x10^4/")
                                                       { return .ten4_per_uL }
    if t.contains("/ul") || t.contains("/µl") || t.contains("cumm")
                                                       { return .per_uL }
    return .unknown
  }
}

enum Convert {
  // RBC → M/µL (aka 10^6/µL)
  static func rbcToMillionPeruL(value v: Double, unit: LabUnit) -> Double {
    switch unit {
      case .m_per_uL:    return v
      case .ten4_per_uL: return v / 100.0
      case .per_uL:      return v / 1_000_000.0
      case .unknown:     return v > 50 ? v / 100.0 : v  // JP heuristic
      default:           return v
    }
  }

  // WBC/PLT → 10^3/µL
  static func toThousandsPeruL(value v: Double, unit: LabUnit) -> Double {
    switch unit {
      case .k_per_uL: return v
      case .ten4_per_uL: return v * 10.0
      case .per_uL:   return v / 1000.0
      case .unknown:  return v > 2000 ? v / 1000.0 : v
      default:        return v
    }
  }

  // Common chem conversions (leave as-is if no change needed)
  static func glucoseMgdl(_ v: Double, unit: LabUnit) -> Double {
    unit == .mmol_L ? v * 18.0 : v
  }
  static func cholesterolMgdl(_ v: Double, unit: LabUnit) -> Double {
    unit == .mmol_L ? v * 38.67 : v
  }
  static func triglycerideMgdl(_ v: Double, unit: LabUnit) -> Double {
    unit == .mmol_L ? v * 88.57 : v
  }
  static func creatinineMgdl(_ v: Double, text: String) -> Double {
    let t = OCRText.compact(text)
    if t.contains("µmol/l") || t.contains("umol/l") { return v / 88.4 }
    return v
  }
  static func uricAcidMgdl(_ v: Double, text: String) -> Double {
    let t = OCRText.compact(text)
    if t.contains("µmol/l") || t.contains("umol/l") { return v / 59.48 }
    return v
  }
}

enum UnitString {
  static func describe(_ u: LabUnit) -> String {
    switch u {
      case .mg_dL: return "mg/dL"
      case .g_dL: return "g/dL"
      case .U_L: return "U/L"
      case .percent: return "%"
      case .per_uL: return "/µL"
      case .k_per_uL: return "10^3/µL"
      case .m_per_uL: return "10^6/µL"
      case .ten4_per_uL: return "10^4/µL"
      case .mmol_L: return "mmol/L"
      case .cm: return "cm"
      case .kg: return "kg"
      case .mmHg: return "mmHg"
      case .unknown: return ""
    }
  }
}
