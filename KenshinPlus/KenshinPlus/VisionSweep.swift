//
//  VisionSweep.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/21.
//

import UIKit
import Vision
import OSLog

/// A small utility namespace that discovers tables by sweeping an image
/// at multiple scales and crops. Pure discovery - no parsing.
///
/// Uses `Vision.RecognizeDocumentsRequest` (iOS 18+) to harvest
/// `DocumentObservation.Container.Table` instances for downstream parsing.
enum VisionSweep {
    /// Logger for VisionSweep diagnostics (table counts, sweep errors).
    static let log = Logger(subsystem: "com.kenshin.plus", category: "VisionSweep")

    /// Runs a multi-scale, multi-crop sweep to coax table detections from a page.
    ///
    /// The image is optionally down-scaled to several long-edge sizes, then
    /// scanned over a set of normalized crop tiles. Any tables discovered are
    /// aggregated and de-duplicated before returning.
    ///
    /// - Parameters:
    ///   - imageData: Original image bytes (e.g., JPEG/PNG).
    ///   - crops: Normalized crop windows (0…1) tested per scale. Defaults cover
    ///            full page, 4 quadrants, and a centered tile.
    ///   - maxLongEdgeCandidates: Target long-edge sizes (in pixels/points) to try
    ///            before recognition. Order matters; earlier entries run first.
    ///   - onProgress: Optional callback invoked on each pass with a `ParseProgress`
    ///            snapshot (safe to bridge to `SweepProgress` for UI).
    /// - Returns: A de-duplicated array of `DocumentObservation.Container.Table`.
    /// - Note: This function **discovers** tables only; it does not parse values.
    /// - Important: Requires iOS 18+ (Vision document recognition).
    /// - Complexity: O(S × C) Vision passes where S = `maxLongEdgeCandidates.count`
    ///               and C = `crops.count`.
    /// - SeeAlso: `LabProbe.parseTablesGeneric(_:)`, `parseCheckup(from:onProgress:)`.
    static func findTablesBySweeping(
        imageData: Data,
        crops: [CGRect] = defaultCrops,
        maxLongEdgeCandidates: [CGFloat] = [2400, 1800, 1400],
        onProgress: ParseProgressHandler? = nil
    ) async -> [DocumentObservation.Container.Table] {
        guard let base = UIImage(data: imageData) else { return [] }
        var found: [DocumentObservation.Container.Table] = []
        
        let total = maxLongEdgeCandidates.count * crops.count
        var done = 0
        
        for target in maxLongEdgeCandidates {
            await onProgress?(ParseProgress(completed: done, total: total,
                                            phase: "Preparing Images",
                                            detail: "Downscaling to \(Int(target)) px"))
            let scaled = base.resizedTo(maxLongEdge: target)
            
            for (i, rect) in crops.enumerated() {
                done += 1
                await onProgress?(ParseProgress(
                    completed: done, total: total,
                    phase: "Reading Tables...",
                    detail: "Scale \(Int(target)) • Crop \(i+1)/\(crops.count)"
                ))
                
                guard let sub = scaled.cropped(normalized: rect),
                      let subData = sub.jpegData(compressionQuality: 0.9) else { continue }
                
                do {
                    let req = RecognizeDocumentsRequest()
                    let obs = try await req.perform(on: subData)
                    if let doc = obs.first?.document, !doc.tables.isEmpty {
                        found.append(contentsOf: doc.tables)
                        TableExplorer.dumpTables(in: doc)
                    }
                } catch {
                    log.error("Sweep step failed: \(error.localizedDescription)")
                }
            }
        }
        
        await onProgress?(ParseProgress(
            completed: total, total: total,
            phase: "Merging results...", detail: "De-duplicating tables"
        ))
        
        return dedupe(found)
    }

    /// 4 quadrants + full + centered half; tweak as needed
    /// Normalized crop presets (full, 4 quadrants, centered half).
    /// Tweak to your page layouts or add more tiles for narrower columns.
    static let defaultCrops: [CGRect] = [
        CGRect(x: 0,    y: 0,    width: 1,   height: 1),   // full
        CGRect(x: 0,    y: 0,    width: 0.5, height: 0.5), // TL
        CGRect(x: 0.5,  y: 0,    width: 0.5, height: 0.5), // TR
        CGRect(x: 0,    y: 0.5,  width: 0.5, height: 0.5), // BL
        CGRect(x: 0.5,  y: 0.5,  width: 0.5, height: 0.5), // BR
        CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)  // center
    ]
    
    /// Generates a coarse textual fingerprint for a table by sampling a few
    /// top-left cells. Used solely for de-duplication across overlapping sweeps.
    ///
    /// - Parameter t: The table to fingerprint.
    /// - Returns: A short string signature (rows x cols + sampled text).
    private static func fingerprint(_ t: DocumentObservation.Container.Table) -> String {
        // first few cells → text blob
        let rows = t.rows.prefix(6).map { row in
            row.prefix(6).map { $0.content.text.transcript.replacingOccurrences(of: "\n", with: " ") }
                .joined(separator: "|")
        }.joined(separator: "||")
        return "\(t.rows.count)x\((t.rows.map{$0.count}.max() ?? 0)):\(rows)"
    }

    /// Removes duplicate tables across sweep results using `fingerprint(_:)`.
    ///
    /// - Parameter tables: Tables found by the sweep.
    /// - Returns: Tables with near-identical content collapsed to one instance.
    private static func dedupe(_ tables: [DocumentObservation.Container.Table]) -> [DocumentObservation.Container.Table] {
        var seen = Set<String>()
        var out: [DocumentObservation.Container.Table] = []
        for t in tables {
            let f = fingerprint(t)
            if !seen.contains(f) {
                seen.insert(f)
                out.append(t)
            }
        }
        return out
    }
}

private extension UIImage {
    /// Returns a new image scaled so the longer side equals `maxLongEdge` (if larger).
    ///
    /// - Parameter maxLongEdge: Target long-edge in points/pixels (no scale factor).
    /// - Returns: The resized image, or `self` if no downscale was needed.
    /// - Note: Uses `UIGraphicsImageRenderer` with scale=1 to keep Vision happy.
    func resizedTo(maxLongEdge: CGFloat) -> UIImage {
        let longEdge = max(size.width, size.height)
        guard longEdge > maxLongEdge else { return self }
        let scale = maxLongEdge / longEdge
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let fmt = UIGraphicsImageRendererFormat.default()
        fmt.scale = 1
        return UIGraphicsImageRenderer(size: newSize, format: fmt).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// `rect` is normalized (0..1 in both axes).
    /// Crops the image to a normalized rect (0…1 coordinates).
    ///
    /// - Parameter rect: Normalized crop in image coordinate space.
    /// - Returns: Cropped `UIImage` or `nil` if cropping fails.
    /// - Important: Coordinates are *not* adjusted for orientation metadata.
    func cropped(normalized rect: CGRect) -> UIImage? {
        let pxRect = CGRect(x: rect.minX * size.width,
                            y: rect.minY * size.height,
                            width: rect.width * size.width,
                            height: rect.height * size.height).integral
        guard let cg = self.cgImage?.cropping(to: pxRect) else { return nil }
        return UIImage(cgImage: cg)
    }
}
