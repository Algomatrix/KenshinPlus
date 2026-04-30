//
//  HealthCitation.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2026/04/30.
//

import Foundation
import SwiftUI

struct HealthCitation {
    let title: String
    let description: String
    let url: URL
}

enum HealthCitationLibrary {
    static let bodyWeight = HealthCitation(
        title: "Body Weight - MedlinePlus",
        description: "General reference for healthy body weight and factors that affect weight.",
        url: URL(string: "https://medlineplus.gov/bodyweight.html")!
    )

    static let bodyFat = HealthCitation(
        title: "Obesity Screening - MedlinePlus Medical Test",
        description: "Reference for BMI-based obesity screening and body fat risk context.",
        url: URL(string: "https://medlineplus.gov/lab-tests/obesity-screening/")!
    )

    static let bmi = HealthCitation(
        title: "About BMI - CDC",
        description: "Reference for adult BMI calculation and category interpretation.",
        url: URL(string: "https://www.cdc.gov/bmi/about/index.html")!
    )

    static let height = HealthCitation(
        title: "Adult BMI Calculator - CDC",
        description: "Reference for BMI calculation using height and weight.",
        url: URL(string: "https://www.cdc.gov/bmi/adult-calculator/index.html")!
    )

    static let bloodPressure = HealthCitation(
        title: "Understanding Blood Pressure Readings - American Heart Association",
        description: "Reference for systolic/diastolic readings and blood pressure categories.",
        url: URL(string: "https://www.heart.org/en/health-topics/high-blood-pressure/understanding-blood-pressure-readings")!
    )

    static let bloodTest = HealthCitation(
        title: "Complete Blood Count (CBC) - MedlinePlus Medical Test",
        description: "Reference for CBC components such as RBC, WBC, hemoglobin, hematocrit, and platelets.",
        url: URL(string: "https://medlineplus.gov/lab-tests/complete-blood-count-cbc/")!
    )

    static let liver = HealthCitation(
        title: "Diagnosis of NAFLD & NASH - NIDDK",
        description: "Reference for liver evaluation and the use of blood tests such as ALT and AST.",
        url: URL(string: "https://www.niddk.nih.gov/health-information/liver-disease/nafld-nash/diagnosis")!
    )

    static let kidney = HealthCitation(
        title: "Chronic Kidney Disease Tests & Diagnosis - NIDDK",
        description: "Reference for kidney testing, including creatinine-based evaluation of kidney function.",
        url: URL(string: "https://www.niddk.nih.gov/health-information/kidney-disease/chronic-kidney-disease-ckd/tests-diagnosis")!
    )

    static let metabolism = HealthCitation(
        title: "A1C Test for Diabetes and Prediabetes - CDC",
        description: "Reference for A1C testing and diabetes/prediabetes screening context.",
        url: URL(string: "https://www.cdc.gov/diabetes/diabetes-testing/prediabetes-a1c-test.html")!
    )

    static let cholesterol = HealthCitation(
        title: "Cholesterol Levels - MedlinePlus Medical Test",
        description: "Reference for HDL, LDL, triglycerides, and cholesterol test interpretation context.",
        url: URL(string: "https://medlineplus.gov/lab-tests/cholesterol-levels/")!
    )
}

struct CitationInfoButton: View {
    let citation: HealthCitation
    @State private var showCitation = false

    var body: some View {
        Button {
            showCitation.toggle()
        } label: {
            Image(systemName: "info.circle")
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .controlSize(.mini)
        .accessibilityLabel("View source")
        .popover(isPresented: $showCitation,
                 attachmentAnchor: .point(.top),
                 arrowEdge: .none) {
            CitationPopoverView(citation: citation)
                .presentationCompactAdaptation(.popover)
        }
    }
}

struct CitationPopoverView: View {
    let citation: HealthCitation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Source")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(citation.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text(citation.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            Link("Open reference", destination: citation.url)
                .font(.caption)
        }
        .padding(12)
        .frame(width: 240, alignment: .leading)
        .background(Color(.systemBackground))
    }
}

struct CitedDashboardCard<Content: View>: View {
    let citation: HealthCitation
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .topTrailing) {
            content()

            CitationInfoButton(citation: citation)
                .padding(10)
        }
    }
}
