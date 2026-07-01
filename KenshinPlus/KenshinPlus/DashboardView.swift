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
                
                // MARK: - Hero Insight Card
                if !allInsights.isEmpty {
                    TabView(selection: $currentInsightIndex) {
                        ForEach(Array(allInsights.enumerated()), id: \.offset) { index, insight in
                            HeroInsightCard(insight: insight)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 90)
                    .onChange(of: currentInsightIndex) { _, _ in
                        // User swiped manually — pause auto-rotation for 8 seconds
                        insightPauseUntil = Date().addingTimeInterval(8)
                    }
                    .onReceive(insightTick) { now in
                        guard allInsights.count > 1,
                              now >= insightPauseUntil else { return }
                        withAnimation {
                            currentInsightIndex = (currentInsightIndex + 1) % allInsights.count
                        }
                        // Wait 5 seconds before next auto-advance
                        insightPauseUntil = now.addingTimeInterval(5)
                    }
                    
                    if allInsights.count > 1 {
                        HStack(spacing: 6) {
                            ForEach(0..<allInsights.count, id: \.self) { i in
                                Circle()
                                    .fill(i == currentInsightIndex ? allInsights[currentInsightIndex % allInsights.count].color : Color.secondary.opacity(0.3))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.bottom, 4)
                    }
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

    // MARK: - Hero Insight Logic
    @State private var currentInsightIndex = 0
    @State private var insightAutoRotate = true
    @State private var insightPauseUntil: Date = .distantPast
    private let insightTick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    /// Generates all applicable insights by comparing the latest two records.
    private var allInsights: [DashboardInsight] {
        guard records.count >= 2 else { return [] }
        let current = records[0]   // most recent
        let previous = records[1]  // second most recent
        var insights: [DashboardInsight] = []
        
        // Check BMI change
        let currentBMI = current.bmi
        let previousBMI = previous.bmi
        if currentBMI > 0 && previousBMI > 0 {
            let delta = currentBMI - previousBMI
            if abs(delta) >= 0.3 {
                let direction: String = delta < 0 ? "decreased" : "increased"
                insights.append(DashboardInsight(
                    icon: delta < 0 ? "arrow.down.right" : "arrow.up.right",
                    color: delta < 0 ? .green : .orange,
                    title: "BMI \(direction)",
                    message: String(format: "Your BMI went from %.1f to %.1f since your last checkup.", previousBMI, currentBMI)
                ))
            }
        }
        
        // Check blood pressure
        if let curSys = current.systolic, let prevSys = previous.systolic {
            let delta = curSys - prevSys
            if abs(delta) >= 5 {
                let direction: String = delta < 0 ? "lower" : "higher"
                insights.append(DashboardInsight(
                    icon: delta < 0 ? "heart.fill" : "exclamationmark.heart.fill",
                    color: delta < 0 ? .green : .red,
                    title: "Blood pressure is \(direction)",
                    message: String(format: "Systolic changed from %.0f to %.0f mmHg.", prevSys, curSys)
                ))
            }
        }
        
        // Check HbA1c
        if let curA1c = current.hba1cNgspPercent, let prevA1c = previous.hba1cNgspPercent {
            let delta = curA1c - prevA1c
            if abs(delta) >= 0.1 {
                let direction: String = delta < 0 ? "improved" : "increased"
                insights.append(DashboardInsight(
                    icon: delta < 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
                    color: delta < 0 ? .green : .orange,
                    title: "HbA1c \(direction)",
                    message: String(format: "HbA1c went from %.1f%% to %.1f%%.", prevA1c, curA1c)
                ))
            }
        }
        
        // Check LDL cholesterol
        if let curLDL = current.ldl, let prevLDL = previous.ldl {
            let delta = curLDL - prevLDL
            if abs(delta) >= 5 {
                let direction: String = delta < 0 ? "decreased" : "increased"
                insights.append(DashboardInsight(
                    icon: delta < 0 ? "arrow.down.heart.fill" : "exclamationmark.triangle.fill",
                    color: delta < 0 ? .green : .orange,
                    title: "LDL cholesterol \(direction)",
                    message: String(format: "LDL went from %.0f to %.0f mg/dL.", prevLDL, curLDL)
                ))
            }
        }
        
        // Check Hemoglobin
        if let curHgb = current.hgbPerdL, let prevHgb = previous.hgbPerdL {
            let delta = curHgb - prevHgb
            if abs(delta) >= 0.5 {
                let direction: String = delta < 0 ? "dropped" : "increased"
                let color: Color = (curHgb < 13.5) ? .red : (delta < 0 ? .orange : .green)
                insights.append(DashboardInsight(
                    icon: delta < 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                    color: color,
                    title: "Hemoglobin \(direction)",
                    message: String(format: "Hemoglobin went from %.1f to %.1f g/dL.", prevHgb, curHgb)
                ))
            }
        }
        
        // Check WBC
        if let curWBC = current.wbcThousandPeruL, let prevWBC = previous.wbcThousandPeruL {
            let delta = curWBC - prevWBC
            if abs(delta) >= 1.5 {
                let direction: String = delta > 0 ? "elevated" : "decreased"
                let color: Color = (curWBC > 11.0 || curWBC < 4.5) ? .red : .orange
                insights.append(DashboardInsight(
                    icon: delta > 0 ? "exclamationmark.triangle.fill" : "arrow.down.circle.fill",
                    color: color,
                    title: "WBC \(direction)",
                    message: String(format: "WBC went from %.1f to %.1f thousand/µL.", prevWBC, curWBC)
                ))
            }
        }
        
        // Check AST (liver)
        if let curAST = current.ast, let prevAST = previous.ast {
            let delta = curAST - prevAST
            if abs(delta) >= 10 {
                let direction: String = delta > 0 ? "elevated" : "improved"
                let color: Color = curAST > 40 ? .red : (delta > 0 ? .orange : .green)
                insights.append(DashboardInsight(
                    icon: delta > 0 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",
                    color: color,
                    title: "AST(GOT) \(direction)",
                    message: String(format: "AST went from %.0f to %.0f U/L.", prevAST, curAST)
                ))
            }
        }
        
        // Check ALT (liver)
        if let curALT = current.alt, let prevALT = previous.alt {
            let delta = curALT - prevALT
            if abs(delta) >= 10 {
                let direction: String = delta > 0 ? "elevated" : "improved"
                let color: Color = curALT > 56 ? .red : (delta > 0 ? .orange : .green)
                insights.append(DashboardInsight(
                    icon: delta > 0 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",
                    color: color,
                    title: "ALT(GPT) \(direction)",
                    message: String(format: "ALT went from %.0f to %.0f U/L.", prevALT, curALT)
                ))
            }
        }
        
        // Check Creatinine (kidney)
        if let curCr = current.creatinine, let prevCr = previous.creatinine {
            let delta = curCr - prevCr
            if abs(delta) >= 0.2 {
                let direction: String = delta > 0 ? "elevated" : "improved"
                let color: Color = curCr > 1.1 ? .red : (delta > 0 ? .orange : .green)
                insights.append(DashboardInsight(
                    icon: delta > 0 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",
                    color: color,
                    title: "Creatinine \(direction)",
                    message: String(format: "Creatinine went from %.2f to %.2f mg/dL.", prevCr, curCr)
                ))
            }
        }
        
        // If nothing changed, show stable message
        if insights.isEmpty {
            insights.append(DashboardInsight(
                icon: "checkmark.seal.fill",
                color: .green,
                title: "Looking stable",
                message: "No significant changes between your last two checkups. Keep it up!"
            ))
        }
        
        return insights
    }
}


#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(for: CheckupRecord.self, inMemory: true)
}

// MARK: - Hero Insight Types

struct DashboardInsight {
    let icon: String
    let color: Color
    let title: String
    let message: String
}

struct HeroInsightCard: View {
    let insight: DashboardInsight
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: insight.icon)
                .font(.title2)
                .foregroundStyle(insight.color)
                .frame(width: 40, height: 40)
                .background(insight.color.opacity(0.12), in: Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(insight.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(insight.color.opacity(0.06))
                .strokeBorder(insight.color.opacity(0.15), lineWidth: 0.5)
        )
    }
}
