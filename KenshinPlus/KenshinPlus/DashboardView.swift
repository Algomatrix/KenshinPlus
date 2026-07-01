//
//  DashboardView.swift
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

    // MARK: - Zoom transition namespace
    @Namespace private var dashboardNamespace

    let mockData = MockDataForPreview()
    var body: some View {
//        let mockCheckupRecords = mockData.mockCheckupRecordSeries()

        ScrollView {
                if records.isEmpty {
                    emptyStateHint
                }
                
                HStack(spacing: 20) {
                    CitedDashboardCard(citation: HealthCitationLibrary.bodyWeight) {
                        DataAtGlanceContainerSmall(
                            title: "Body Weight",
                            symbol: "figure",
                            subtitle: latestWeightText,
                            color: .indigo
                        )
                    }
                    
                    CitedDashboardCard(citation: HealthCitationLibrary.bodyFat) {
                        DataAtGlanceContainerSmall(
                            title: "Body Fat",
                            symbol: "figure.walk",
                            subtitle: latestFatPercentText,
                            color: .indigo
                        )
                    }
                }

                HStack(spacing: 20) {
                    CitedDashboardCard(citation: HealthCitationLibrary.bmi) {
                        DataAtGlanceContainerSmall(
                            title: "BMI",
                            symbol: "figure",
                            subtitle: latestBmiText,
                            color: .mint
                        )
                    }
                    
                    CitedDashboardCard(citation: HealthCitationLibrary.height) {
                        DataAtGlanceContainerSmall(
                            title: "Height",
                            symbol: "ruler",
                            subtitle: latestHeightText,
                            color: .mint
                        )
                    }
                }
                
                HStack(spacing: 20) {
                    CitedDashboardCard(citation: HealthCitationLibrary.bloodPressure) {
                        NavigationLink(
                            destination: BloodPressureView(records: records)
                                .navigationTitle("Blood Pressure Data")
                                .navigationTransition(.zoom(sourceID: "bloodPressure", in: dashboardNamespace))
                        ) {
                            DataAtGlanceContainerSmall(
                                title: "Blood Pressure",
                                symbol: "blood.pressure.cuff.badge.gauge.with.needle.fill",
                                subtitle: String(localized: "Systolic and Diastolic"),
                                color: .red
                            )
                        }
                        .matchedTransitionSource(id: "bloodPressure", in: dashboardNamespace)
                    }
                    
                    CitedDashboardCard(citation: HealthCitationLibrary.bloodTest) {
                        NavigationLink(
                            destination: BloodTestView(records: records)
                                .navigationTitle("Blood Test Data")
                                .navigationTransition(.zoom(sourceID: "bloodTest", in: dashboardNamespace))
                        ) {
                            DataAtGlanceContainerSmall(
                                title: "Blood Test",
                                symbol: "syringe.fill",
                                subtitle: String(localized: "RBC, WBC, etc"),
                                color: .red
                            )
                        }
                        .matchedTransitionSource(id: "bloodTest", in: dashboardNamespace)
                    }
                }
                
                // Liver and Uric Acid
                HStack(spacing: 20) {
                    CitedDashboardCard(citation: HealthCitationLibrary.liver) {
                        NavigationLink(
                            destination: LiverTestView(records: records)
                                .navigationTitle("Liver Test Data")
                                .navigationTransition(.zoom(sourceID: "liver", in: dashboardNamespace))
                        ) {
                            DataAtGlanceContainerSmall(
                                title: "Liver Info",
                                symbol: "chart.line.text.clipboard.fill",
                                subtitle: String(localized: "AST, ALT, etc"),
                                color: .red
                            )
                        }
                        .matchedTransitionSource(id: "liver", in: dashboardNamespace)
                    }
                    
                    CitedDashboardCard(citation: HealthCitationLibrary.kidney) {
                        NavigationLink(
                            destination: KidneyTestView(records: records)
                                .navigationTitle("Kidney Test Data")
                                .navigationTransition(.zoom(sourceID: "kidney", in: dashboardNamespace))
                        ) {
                            DataAtGlanceContainerSmall(
                                title: "Uric Acid",
                                symbol: "vial.viewfinder",
                                subtitle: String(localized: "Creatinine and Uric Acid"),
                                color: .red
                            )
                        }
                        .matchedTransitionSource(id: "kidney", in: dashboardNamespace)
                    }
                }
                
                // Metabolism and Cholesterol
                HStack(spacing: 20) {
                    CitedDashboardCard(citation: HealthCitationLibrary.metabolism) {
                        NavigationLink(
                            destination: MetabolicTestView(records: records)
                                .navigationTitle("Metabolic Test Data")
                                .navigationTransition(.zoom(sourceID: "metabolism", in: dashboardNamespace))
                        ) {
                            DataAtGlanceContainerSmall(
                                title: "Metabolism",
                                symbol: "flame.fill",
                                subtitle: String(localized: "HbA1c, Fasting Glucose"),
                                color: .orange
                            )
                        }
                        .matchedTransitionSource(id: "metabolism", in: dashboardNamespace)
                    }
                    
                    CitedDashboardCard(citation: HealthCitationLibrary.cholesterol) {
                        NavigationLink(
                            destination: CholesterolTestView(records: records)
                                .navigationTitle("Cholesterol Test Data")
                                .navigationTransition(.zoom(sourceID: "cholesterol", in: dashboardNamespace))
                        ) {
                            DataAtGlanceContainerSmall(
                                title: "Cholesterol",
                                symbol: "heart.circle",
                                subtitle: String(localized: "HDL, LDL, etc"),
                                color: .orange
                            )
                        }
                        .matchedTransitionSource(id: "cholesterol", in: dashboardNamespace)
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

                Text("Disclaimer: This app does not provide medical diagnosis or treatment advice. Always consult your doctor for any medical concerns.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .navigationTitle("Health Dashboard")
            .padding()
            .fontDesign(.rounded)
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

    // MARK: - Empty State Onboarding Hint
    private var emptyStateHint: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.clipboard")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Welcome to Kenshin Plus+")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Add your first health checkup to start tracking your results over time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            NavigationLink(destination: ManualDataInputView()) {
                Label("Add Your First Checkup", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .foregroundStyle(.white)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
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
    NavigationStack {
        DashboardView()
    }
    .modelContainer(for: CheckupRecord.self, inMemory: true)
}
