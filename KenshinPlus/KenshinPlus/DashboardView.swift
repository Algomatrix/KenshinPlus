//
//  ContentView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/05.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CheckupRecord.date, order: .reverse)
    private var records: [CheckupRecord]

    // MARK: - DashboardView state
    @State private var undoStack: [CheckupRecordSnapshot] = []
    @State private var undoDeadline: Date? = nil
    private let undoTick = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    let mockData = MockDataForPreview()
    var body: some View {
//        let mockBloodData = mockData.mockBloodTestSeries()

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
                        destination: LiverTestView(records: records)
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Liver Info",
                            symbol: "chart.line.text.clipboard.fill",
                            subtitle: "Systolic and Diastolic",
                            color: .red
                        )
                    }
                    
                    NavigationLink(
                        destination: KidneyTestView(records: records)
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
                        destination: MetabolicTestView(records: records)
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Metabolism",
                            symbol: "flame.fill",
                            subtitle: "HbA1c, Fasting Glucose",
                            color: .orange
                        )
                    }
                    
                    NavigationLink(
                        destination: CholesterolTestView(records: records)
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
//                HStack(spacing: 20) {
//                    NavigationLink(
//                        destination: EyeTestView(records: records)
//                    ) {
//                        DataAtGlanceContainerSmall(
//                            title: "Eyesight",
//                            symbol: "eye",
//                            subtitle: "Left and Right",
//                            color: .green
//                        )
//                    }
//
//                    NavigationLink(
//                        destination: HearingTestView(records: records)
//                    ) {
//                        DataAtGlanceContainerSmall(
//                            title: "Hearing",
//                            symbol: "ear.badge.waveform",
//                            subtitle: "Left and Right",
//                            color: .green
//                        )
//                    }
//                }

                PutBarChartInContainer(title: "") {
                    DisclosureGroup {
                        PutBarChartInContainer(title: "Checkup History") {
                            if records.isEmpty {
                                ContentUnavailableView(
                                    "No records yet",
                                    systemImage: "tray",
                                    description: Text("Tap \(Image(systemName: "plus.circle.fill")) to add one from Dashbaord.")
                                )
                            } else {
                                testHistoryListView
                            }
                        }
                    } label: {
                        Label("History : ^[\(records.count) record](inflect: true)", systemImage: "list.bullet.clipboard")
                            .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                        if !undoStack.isEmpty {
                            Button {
                                undoDelete()
                            } label: {
                                Label("Undo", systemImage: "arrow.uturn.left.circle")
                                    .tint(.red)
                            }
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                    }
                }
            }
            .navigationTitle("Health Dashboard")
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ManualDataInputView()) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .onReceive(undoTick) { _ in
                if let ddl = undoDeadline, Date() >= ddl {
                    withAnimation {
                        undoStack.removeAll()
                        undoDeadline = nil
                    }
                }
            }
        }
//                .background(RoundedRectangle(cornerRadius: 12, style: .circular).fill(.tertiary.opacity(0.5)))
    }

    private var testHistoryListView: some View {
        List {
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
                // Optional: per-row swipe actions (Delete, Info)
                .swipeActions {
                    Button(role: .destructive) {
                        deleteWithUndo(rec)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .onDelete { offsets in
                let toDelete = offsets.map { records[$0] }
                deleteWithUndo(toDelete)
            }
        }
        .frame(height: !records.isEmpty ? 300 : 120) // Needed if List in a card inside ScrollView
    }
    
    private func deleteWithUndo(_ recs: [CheckupRecord]) {
        // 1) snapshot
        let snaps = recs.map(CheckupRecordSnapshot.init)

        // 2) delete
        recs.forEach { modelContext.delete($0) }
        try? modelContext.save()

        // 3) push + reset window
        undoStack.append(contentsOf: snaps)
        undoDeadline = Date().addingTimeInterval(5)   // 5s from the last delete
    }

    private func deleteWithUndo(_ rec: CheckupRecord) {
        deleteWithUndo([rec])
    }

    private func undoDelete() {
        guard let snap = undoStack.popLast() else { return }
        let restored = snap.restoreRecord()
        modelContext.insert(restored)
        try? modelContext.save()

        // keep button visible if there are more items; otherwise close window
        if undoStack.isEmpty {
            withAnimation { undoDeadline = nil }
        } else {
            undoDeadline = Date().addingTimeInterval(5) // optional: give user more time for next undo
        }
    }

    // Latest (most recent) record
    private var latest: CheckupRecord? { records.first } // Because records is reverse sorted
    
    private var latestWeightText: String {
        guard let r = latest else { return "-" }
        return String(format: "%.1f kg", r.weightKg ?? 0)
    }
    
    // Latest Fat percent
    private var latestFatPercentText: String {
        guard let r = latest, let fat = r.fatPercent else { return "-" }
        return String(format: "%.1f %%", fat)
    }
    
    // Latest Height
    private var latestHeightText: String {
        guard let r = latest else { return "-" }
        return String(format: "%.1f cm", r.heightCm!)
    }
    
    // Latest BMI
    private var latestBmiText: String {
        guard let r = latest else { return "-" }
        return String(format: "%.1f", r.bmi)
    }
}


#Preview {
    DashboardView()
        .modelContainer(for: CheckupRecord.self, inMemory: true)
}
