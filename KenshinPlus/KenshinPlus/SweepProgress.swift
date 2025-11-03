//
//  SweepProgress.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/22.
//

import Foundation

/// A lightweight, value-type progress model for the table-scan UI.
///
/// `SweepProgress` is produced by the parser/sweeper and consumed by the UI
/// (e.g., a `ProgressView`). It tracks both a coarse overall fraction and
/// optional stage info suitable for user-facing labels.
///
/// Typical usage:
///
/// ```swift
/// // In your progress callback
/// updateProgress(SweepProgress(step: done,
///                              totalSteps: total,
///                              scaleIndex: currentScale,
///                              totalScales: allScales.count,
///                              cropIndex: currentCrop,
///                              totalCrops: crops.count,
///                              foundSoFar: tablesFound,
///                              stage: .recognizing))
/// ```
///
/// - Note: `fraction` clamps to `[0, 1]`.
/// - SeeAlso: `ParseProgress` for a source-agnostic progress type.
struct SweepProgress: Equatable {
    /// High-level phases for user-facing status text.
    enum Stage: String { case resizing, recognizing, deduping, done }

    /// The current completed step (0-based or 1-based, caller’s choice).
    let step: Int
    /// The total number of planned steps across all scales × crops.
    let totalSteps: Int
    /// Index of the current scale pass (0-based).
    let scaleIndex: Int
    /// Total number of scale passes to run.
    let totalScales: Int
    /// Index of the current crop tile within the scale (0-based).
    let cropIndex: Int
    /// Total number of crop tiles per scale.
    let totalCrops: Int
    /// Running count of tables detected so far across all passes.
    let foundSoFar: Int
    /// Returns a normalized 0…1 completion value derived from `step/totalSteps`.
    let stage: Stage

    /// Short user-facing label for the current `stage`.
    ///
    /// Values:
    /// - `.resizing`    → “Preparing…”
    /// - `.recognizing` → “Analyzing document…”
    /// - `.deduping`    → “Finalizing…”
    /// - `.done`        → “Done”
    let overrideLabel: String?
    
    /// Optional, secondary text. Safe to show to users (avoid debug jargon).
    /// Example: “Found 2 tables”.
    let overrideDetail: String?

    /// A zeroed-out sentinel used to initialize the UI before any work starts.
    var fraction: Double {
        guard totalSteps > 0 else { return 0 }
        return min(1, Double(step) / Double(totalSteps))
    }

    var labelText: String {
        if let s = overrideLabel { return s }
        switch stage {
        case .resizing:    return "Preparing…"
        case .recognizing: return "Analyzing document…"
        case .deduping:    return "Finalizing…"
        case .done:        return "Done"
        }
    }

    var detailText: String {
        overrideDetail ?? ""   // user UI won’t show internals
    }

    static let zero = SweepProgress(
        step: 0, totalSteps: 0,
        scaleIndex: 0, totalScales: 0,
        cropIndex: 0, totalCrops: 0,
        foundSoFar: 0, stage: .resizing,
        overrideLabel: nil, overrideDetail: nil
    )

    // User-facing bridge from ParseProgress
    init(parse p: ParseProgress, userFacing: Bool = true) {
        self.step = p.completed
        self.totalSteps = p.total
        self.scaleIndex = 0
        self.totalScales = 0
        self.cropIndex = 0
        self.totalCrops = 0
        self.foundSoFar = 0
        self.stage = .recognizing
        if userFacing {
            // Simple, friendly strings for the user
            if p.completed == 0 {
                self.overrideLabel = "Preparing…"
            } else if p.completed < p.total {
                self.overrideLabel = "Analyzing document…"
            } else {
                self.overrideLabel = "Finalizing…"
            }
            self.overrideDetail = ""   // hide scale/crop details
        } else {
            // Dev/Debug: pass through raw messages
            self.overrideLabel = p.phase
            self.overrideDetail = p.detail
        }
    }

    // Designated initializer (unchanged)
    init(step: Int, totalSteps: Int,
         scaleIndex: Int, totalScales: Int,
         cropIndex: Int, totalCrops: Int,
         foundSoFar: Int, stage: Stage,
         overrideLabel: String? = nil,
         overrideDetail: String? = nil) {
        self.step = step
        self.totalSteps = totalSteps
        self.scaleIndex = scaleIndex
        self.totalScales = totalScales
        self.cropIndex = cropIndex
        self.totalCrops = totalCrops
        self.foundSoFar = foundSoFar
        self.stage = stage
        self.overrideLabel = overrideLabel
        self.overrideDetail = overrideDetail
    }
}

// Public parser-facing types (fine as you wrote)
public struct ParseProgress: Sendable {
    public let completed: Int
    public let total: Int
    public let phase: String
    public let detail: String
    public init(completed: Int, total: Int, phase: String, detail: String) {
        self.completed = completed; self.total = total; self.phase = phase; self.detail = detail
    }
    public var fraction: Double { total > 0 ? Double(completed) / Double(total) : 0 }
    public static let zero = ParseProgress(completed: 0, total: 0, phase: "", detail: "")
}

public typealias ParseProgressHandler = @MainActor (ParseProgress) -> Void
