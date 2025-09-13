//
//  HearingTestView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/13.
//

import SwiftUI

enum TestResultState: String, CaseIterable {
    case good = "Good"
    case normal = "Normal"
    case bad = "Bad"

    var title: String { rawValue }
    var color: Color {
        switch self {
        case .good:   .green
        case .normal: .yellow
        case .bad:    .red
        }
    }
}

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

struct HearingTestView: View {
    // Inject your results here (from API, DB, etc.)
    let results: [HearingResult]

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
    HearingTestView(results: [
        .init(ear: .left,  band: .k1, state: .good),
        .init(ear: .right, band: .k1, state: .normal),
        .init(ear: .left,  band: .k4, state: .good),
        .init(ear: .right, band: .k4, state: .normal),
    ])
}
