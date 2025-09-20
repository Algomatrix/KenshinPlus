//
//  HearingTestView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/13.
//

import SwiftUI

enum Ear: String, CaseIterable {
    case left = "Left Ear"
    case right = "Right Ear"
    var title: String { rawValue }
}

enum HzBand: Int, CaseIterable {
    case k1 = 1000
    case k4 = 4000
    var label: String { "\(rawValue) Hz" }
}

struct HearingResult: Identifiable, Equatable {
    let id = UUID()
    let ear: Ear
    let band: HzBand
    let state: TestResultState
}

enum TestResultState: String, Codable, CaseIterable {
    case good, normal, bad
    var title: String { rawValue.capitalized }
    var color: Color { self == .good ? .green : self == .normal ? .yellow : .red }
}

struct HearingTestView: View {
    let records: [CheckupRecord]

    private var results: [HearingResult] { records.hearingResults() }

    private let cols = [GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)]

    private func state(for ear: Ear, band: HzBand) -> TestResultState {
        results.first { $0.ear == ear && $0.band == band }?.state ?? .normal
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: cols, spacing: 16) {
                ForEach(HzBand.allCases, id: \.self) { band in
                    ForEach(Ear.allCases, id: \.self) { ear in
                        ResultCard(
                            ear: ear,
                            band: band,
                            state: state(for: ear, band: band)
                        )
                    }
                }
            }
            .padding()
        }
    }
}

private struct ResultCard: View {
    let ear: Ear
    let band: HzBand
    let state: TestResultState

    var body: some View {
        PutBarChartInContainer(title: ear.title) {
            Text(band.label)
                .font(.callout)
                .foregroundStyle(.secondary)

            Text(state.title)
                .font(.headline)
                .foregroundStyle(state.color)
                .padding(.top, 2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(ear.title), \(band.label), \(state.title)")
    }
}

#Preview {
    let r = CheckupRecord(date: .now, gender: .male, heightCm: 170, weightKg: 70)
    r.hearingLeft1kHz = .good
    r.hearingRight1kHz = .normal
    r.hearingLeft4kHz = .bad
    r.hearingRight4kHz = .good

    return HearingTestView(records: [r])
}
