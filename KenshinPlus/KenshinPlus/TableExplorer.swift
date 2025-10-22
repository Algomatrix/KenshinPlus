//
//  TableExplorer.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/21.
//

import Foundation
import OSLog
import Vision

/// Debug utilities for visualizing detected tables in the console.
/// Prints grid shape, bounding regions, and short cell transcripts.
/// Non-production, but invaluable for tuning heuristics.
enum TableExplorer {
    /// Logger for TableExplorer messages.
    static let log = Logger(subsystem: "com.kenshin.plus", category: "TableExplorer")

    /// Prints a human-friendly dump of each table: row/column counts, cell row/col
    /// spans, and a truncated transcript per cell.
    ///
    /// - Parameters:
    ///   - document: The `DocumentObservation.Container` holding tables.
    ///   - maxCellsPerRow: Max cells to show per row before truncation.
    ///   - maxCellChars: Max characters to print per cell.
    /// - Note: Safe to call with no tables; prints a friendly message.
    static func dumpTables(in document: DocumentObservation.Container,
                           maxCellsPerRow: Int = 8,
                           maxCellChars: Int = 40) {
        let tables = document.tables
        print("=== TABLE EXPLORER ===")
        print("Tables found: \(tables.count)")
        guard !tables.isEmpty else {
            print("No tables on this page.")
            print("=== END TABLE EXPLORER ===")
            return
        }

        for (ti, t) in tables.enumerated() {
            let rows = t.rows.count
            let maxCols = t.rows.map(\.count).max() ?? 0
            print("-- Table #\(ti)  rows=\(rows)  maxCols=\(maxCols)")
            print("   boundingRegion: \(t.boundingRegion)")

            // Rows
            for (r, row) in t.rows.enumerated() {
                let shown = row.prefix(maxCellsPerRow)
                for (c, cell) in shown.enumerated() {
                    let rr = cell.rowRange
                    let cr = cell.columnRange
                    let txt = cell.content.text.transcript
                        .replacingOccurrences(of: "\n", with: " ")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let short = txt.prefix(maxCellChars)
                    print(String(format: "   [r%02d c%02d] rows=%d..%d cols=%d..%d  \"%@\"",
                                 r, c, rr.lowerBound, rr.upperBound, cr.lowerBound, cr.upperBound, String(short)))
                }
                if row.count > maxCellsPerRow {
                    print("   …(\(row.count - maxCellsPerRow) more cells hidden)")
                }
            }
        }
        print("=== END TABLE EXPLORER ===")
        log.info("Dumped \(tables.count) tables")
    }

    /// Prints each table as a CSV-ish text preview (no quotes/escapes).
    ///
    /// - Parameters:
    ///   - document: The `DocumentObservation.Container`.
    ///   - maxCols: Max columns to include before printing an ellipsis.
    static func dumpTablesAsCSV(in document: DocumentObservation.Container,
                                maxCols: Int = 12) {
        let tables = document.tables
        guard !tables.isEmpty else { return }
        for (ti, t) in tables.enumerated() {
            print("=== TABLE #\(ti) CSV ===")
            for row in t.rows {
                let cols = row.prefix(maxCols).map { cell in
                    cell.content.text.transcript
                        .replacingOccurrences(of: "\n", with: " ")
                        .replacingOccurrences(of: ",", with: " ")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
                print(cols.joined(separator: ","))
                if row.count > maxCols { print("…") }
            }
            print("=== END TABLE #\(ti) CSV ===")
        }
    }
}
