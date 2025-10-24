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
    @Query(
        filter: #Predicate<CheckupRecord> { $0.pendingDeletion == false },
        sort: \CheckupRecord.date, order: .reverse
    )
    private var records: [CheckupRecord]

    // MARK: - DashboardView state
    @State private var undoStack: [UUID] = []   // IDs of rows pending deletion
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
                        destination: BloodPressureView(records: records)
                            .navigationTitle("Blood Pressure Data")
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Blood Pressure",
                            symbol: "blood.pressure.cuff.badge.gauge.with.needle.fill",
                            subtitle: String(localized: "Systolic and Diastolic"),
                            color: .red
                        )
                    }

                    NavigationLink(
                        destination: BloodTestView(records: records) // for mockdata: destination: BloodTestView(data: mockBloodData)
                            .navigationTitle("Blood Test Data")
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Blood Test",
                            symbol: "syringe.fill",
                            subtitle: String(localized: "RBC, WBC, etc"),
                            color: .red
                        )
                    }
                }
                
                // Liver and Uric Acid
                HStack(spacing: 20) {
                    NavigationLink(
                        destination: LiverTestView(records: records)
                            .navigationTitle("Liver Test Data")
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Liver Info",
                            symbol: "chart.line.text.clipboard.fill",
                            subtitle: String(localized: "AST, ALT, etc"),
                            color: .red
                        )
                    }
                    
                    NavigationLink(
                        destination: KidneyTestView(records: records)
                            .navigationTitle("Kidney Test Data")
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Uric Acid",
                            symbol: "vial.viewfinder",
                            subtitle: String(localized: "Creatinine and Uric Acid"),
                            color: .red
                        )
                    }
                }
                
                // Metabolism and Cholesterol
                HStack(spacing: 20) {
                    NavigationLink(
                        destination: MetabolicTestView(records: records)
                            .navigationTitle("Metabolic Test Data")
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Metabolism",
                            symbol: "flame.fill",
                            subtitle: String(localized: "HbA1c, Fasting Glucose"),
                            color: .orange
                        )
                    }
                    
                    NavigationLink(
                        destination: CholesterolTestView(records: records)
                            .navigationTitle("Cholesterol Test Data")
                    ) {
                        DataAtGlanceContainerSmall(
                            title: "Cholesterol",
                            symbol: "heart.circle",
                            subtitle: String(localized: "HDL, LDL, etc"),
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

                PutBarChartInContainer(title: nil) {
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
                        // Permanently delete anything still pending
                        let ids = undoStack
                        undoStack.removeAll()
                        undoDeadline = nil
                        finalizePendingDeletes(for: ids)
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
        // 1) mark rows as pending deletion
        for r in recs {
            r.pendingDeletion = true
            undoStack.append(r.id) // track the IDs we can restore
        }
        try? modelContext.save()

        // 2) (re)start the undo window
        undoDeadline = Date().addingTimeInterval(5)   // give the user 5s to undo
    }

    private func deleteWithUndo(_ rec: CheckupRecord) {
        deleteWithUndo([rec])
    }

    private func undoDelete() {
        // Restore everything currently in the stack
        var restoredAny = false
        while let id = undoStack.popLast() {
            if let rec = fetchRecord(by: id) {
                rec.pendingDeletion = false
                restoredAny = true
            }
        }
        if restoredAny { try? modelContext.save() }

        // Close the undo window
        withAnimation { undoDeadline = nil }
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
        guard let r = latest, let h = r.heightCm else { return "-" }
        return String(format: "%.1f cm", h)
    }
    
    // Latest BMI
    private var latestBmiText: String {
        guard let r = latest else { return "-" }
        return String(format: "%.1f", r.bmi)
    }
    
    private func fetchRecord(by id: UUID) -> CheckupRecord? {
        var fd = FetchDescriptor<CheckupRecord>(
            predicate: #Predicate { $0.id == id }
        )
        fd.fetchLimit = 1
        return (try? modelContext.fetch(fd))?.first
    }

    /// Permanently deletes any records currently marked for deletion (used when undo window expires)
    private func finalizePendingDeletes(for ids: [UUID]) {
        for id in ids {
            if let rec = fetchRecord(by: id) {
                modelContext.delete(rec)
            }
        }
        try? modelContext.save()
    }
}


#Preview {
    DashboardView()
        .modelContainer(for: CheckupRecord.self, inMemory: true)
}
