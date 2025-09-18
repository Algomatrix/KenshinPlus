//
//  ContentView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/05.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \CheckupRecord.date, order: .reverse)
    private var records: [CheckupRecord]
    
    @State private var showManualInputScreen = false

    let mockData = MockDataForPreview()
    var body: some View {
//        let mockBloodData = mockData.mockBloodTestSeries()
        let mockLiverData = mockData.mockLiverTestSeries()
        let mockKidneyData = mockData.mockKidneyTestSeries()
        let mockMetabolismData = mockData.mockMetabolismTestSeries()
        let mockCholesterolData = mockData.mockCholesterolTestSeries()
        let mockEyeData = mockData.mockEyeExamSeries()

        NavigationStack {
            ScrollView {
                HStack(spacing: 20) {
                    DataAtGlanceContainerSmall(title: "Body Weight", symbol: "figure", subtitle: latestWeightText, color: .indigo)
                    DataAtGlanceContainerSmall(title: "Body Fat", symbol: "figure.walk", subtitle: latestFatPercentText, color: .indigo)
                }

                HStack(spacing: 20) {
                    DataAtGlanceContainerSmall(title: "BMI", symbol: "figure", subtitle: latestBmiText, color: .mint)
                    DataAtGlanceContainerSmall(title: "Height", symbol: "ruler", subtitle: latestHeightText, color: .mint)
                }

                HStack(spacing: 20) {
                    NavigationLink(
                        destination: BloodPressureView(title: "Blood Pressure", subtitle: "Systolic and Diastolic", symbol: "blood.pressure.cuff.badge.gauge.with.needle.fill", color: .red, records: records)
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Blood Pressure",
                            symbol: "heart",
                            subtitle: "Systolic and Diastolic",
                            color: .red
                        )
                    }

                    NavigationLink(
                        destination: BloodTestView(records: records) // for mockdata: destination: BloodTestView(data: mockBloodData)
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Blood Test",
                            symbol: "syringe.fill",
                            subtitle: "RBC, WBC, etc",
                            color: .red
                        )
                    }
                }
                
                // Liver and Uric Acid
                HStack(spacing: 20) {
                    NavigationLink(
                        destination: LiverTestView(data: mockLiverData)
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Liver Info",
                            symbol: "chart.line.text.clipboard.fill",
                            subtitle: "Systolic and Diastolic",
                            color: .red
                        )
                    }
                    
                    NavigationLink(
                        destination: KidneyTestView(data: mockKidneyData)
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Uric Acid",
                            symbol: "vial.viewfinder",
                            subtitle: "Creatine and Uric Acid",
                            color: .red
                        )
                    }
                }
                
                // Metabolism and Cholesterol
                HStack(spacing: 20) {
                    NavigationLink(
                        destination: MetabolicTestView(samples: mockMetabolismData)
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Metabolism",
                            symbol: "flame.fill",
                            subtitle: "HbA1c, Fasting Glucose",
                            color: .orange
                        )
                    }
                    
                    NavigationLink(
                        destination: CholesterolTestView(sample: mockCholesterolData)
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Cholesterol",
                            symbol: "heart.circle",
                            subtitle: "Creatine and Uric Acid",
                            color: .orange
                        )
                    }
                }
                
                // Eyesight and Hearing
                HStack(spacing: 20) {
                    NavigationLink(
                        destination: EyeTestView(sample: mockEyeData)
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Eyesight",
                            symbol: "eye",
                            subtitle: "Left and Right",
                            color: .green
                        )
                    }
                    
                    NavigationLink(
                        destination: HearingTestView(results: [HearingResult(ear: .allCases.randomElement()!, band: .allCases.randomElement()!, state: .allCases.randomElement()!)])
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Hearing",
                            symbol: "ear.badge.waveform",
                            subtitle: "Left and Right",
                            color: .green
                        )
                    }
                }

                PutBarChartInContainer(title: "Checkup History") {
                    testHistoryListView
                }
            }
            .navigationTitle("Health Dashboard")
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showManualInputScreen = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .fullScreenCover(isPresented: $showManualInputScreen, onDismiss: {
                showManualInputScreen = false
            }) {
                NavigationStack {
                    ManualDataInputView()
                }
            }
        }
//                .background(RoundedRectangle(cornerRadius: 12, style: .circular).fill(.tertiary.opacity(0.5)))
    }
    
    var testHistoryListView: some View {
        List {
            if records.isEmpty {
                Text("No records yet. Tap \(Image(systemName: "plus.circle.fill")) to add one.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(records) { rec in
                    NavigationLink {
                        CheckupDetailView(record: rec)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(rec.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.headline)
                            Text("BMI \(String(format: "%.1f", rec.bmi)) • \(rec.gender == .male ? "Male" : "Female")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .frame(height: !records.isEmpty ? 300 : 120)
    }
    
    // Latest (most recent) record
    private var latest: CheckupRecord? { records.first } // Because records is reverse sorted
    
    private var latestWeightText: String {
        guard let r = latest else { return "-" }
        return String(format: "%.1f kg", r.weightKg)
    }
    
    // Latest Fat percent
    private var latestFatPercentText: String {
        guard let r = latest, let fat = r.fatPercent else { return "-" }
        return String(format: "%.1f %%", fat)
    }
    
    // Latest Height
    private var latestHeightText: String {
        guard let r = latest else { return "-" }
        return String(format: "%.1f cm", r.heightCm)
    }
    
    // Latest BMI
    private var latestBmiText: String {
        guard let r = latest else { return "-" }
        return String(format: "%.1f", r.bmi)
    }
}

struct CheckupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var record: CheckupRecord   // SwiftData magic

    var body: some View {
        Form {
            DatePicker("Date", selection: $record.date, displayedComponents: .date)
            Picker("Gender", selection: $record.gender) {
                Text("Male").tag(SDGender.male)
                Text("Female").tag(SDGender.female)
            }
            LabeledNumberField(title: "Height", value: $record.heightCm, precision: 0...1, unitText: "cm")
            LabeledNumberField(title: "Weight", value: $record.weightKg, precision: 0...1, unitText: "kg")
            Text("BMI: \(String(format: "%.1f", record.bmi))")
        }
        .navigationTitle("Checkup")
        .toolbar {
            Button("Save") { try? modelContext.save() }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: CheckupRecord.self, inMemory: true)
}
