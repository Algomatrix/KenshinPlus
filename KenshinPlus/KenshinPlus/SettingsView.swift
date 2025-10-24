//
//  SettingsView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/09.
//

import SwiftUI
import SwiftData
import CloudKit

enum SheetRoute: Identifiable {
    case tipJar
    case web(URL)
    
    var id: String {
        switch self {
        case .tipJar:
            return "tipJar"
        case .web(let uRL):
            return "web:\(uRL.absoluteString)"
        }
    }
}

struct SettingsView: View {
    @State private var isSectionDisabled = true
    @AppStorage("birthDateISO") private var birthDateISO: String = ""
    @State private var dob = DOBState()
    @Query(sort: \CheckupRecord.date, order: .reverse)
    private var record: [CheckupRecord]
    @State private var showClearDialog = false
    @Environment(\.modelContext) private var modelContext
    @State private var showingTipJar = false
    @State private var activeSheet: SheetRoute? = nil

    private var latestDate: String{
        guard let d = record.first?.date else{ return "No Data" }
        let date = DateFormatter.birthMedium.string(from: d)
        let rel = RelativeDateTimeFormatter().localizedString(for: d, relativeTo: Date())
        return"\(date) (\(rel))"
    }

    var body: some View {
        VStack{
            Form {
                yourAccount
                
                dataManagement
                
                privacy
                
                appInfo
                
            }
            .sheet(item: $activeSheet) { route in
                switch route {
                case .tipJar:
                    TipJarSheet()
                        .presentationDetents([.medium, .large])
                case .web(let url):
                    SafariView(url: url)
                        .ignoresSafeArea()
                }
            }
        }
    }
    
    // MARK: - Your Account
    var yourAccount: some View {
        Section {
            BirthDateRow(dob: $dob)
            
            HStack {
                Text("Last Checkup Date")
                Spacer()
                Text(latestDate)
                    .foregroundStyle(record.isEmpty ? .secondary : .primary)
            }
        } header: {
            Label("General", systemImage: "person.crop.circle")
        }
        .onAppear {
            if !birthDateISO.isEmpty { dob.date = birthISO.date(from: birthDateISO) }
        }
        .onChange(of: dob.date) { new, _ in
            birthDateISO = new.map { birthISO.string(from: $0) } ?? ""
        }
    }
    
    // MARK: - Data Management
    var dataManagement: some View {
        Section {
            CloudStatusRow()
            Text("Sync is automatic when iCloud is available on this device. You can toggle the sync in Settings app > Apple Account (Top) > iCloud > Saved to iCloud > KenshinPlus")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } header: {
            Label("Data Management", systemImage: "lock.icloud")
        }
    }
    
    // MARK: - Privacy
    var privacy: some View {
        Section {
            Button(role: .destructive) { showClearDialog = true } label: { Text("Clear Data") }
                .confirmationDialog("Delete all local data?", isPresented: $showClearDialog, titleVisibility: .visible) {
                    Button("Delete All Data", role: .destructive) { clearLocalData() }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This removes all checkups and settings from this device. If iCloud sync is enabled, data may sync back from iCloud.")
                }
                .foregroundStyle(.red)
                .disabled(record.isEmpty)

            NavigationLink("Privacy Policy", destination: PrivacyPolicyView())
        } header: {
            Text("Privacy")
        }
    }
    
    // MARK: - App Info
    var appInfo: some View {
        Section {
            HStack {
                Text("App Version")
                Spacer()
                Text(AppVersion.current)
                    .foregroundStyle(.secondary)
            }

            Button {
                activeSheet = .tipJar
            } label: {
                Label("Support Developer with a Tip", systemImage: "heart.circle.fill")
            }

            NavigationLink {
                ReachoutToDeveloper { url in
                    activeSheet = .web(url)
                }
            } label: {
                Label("Reach Out to Developer", systemImage: "lightbulb.fill")
            }

            //            NavigationLink("Future Updates", destination: FutureUpdates())
        } header: {
            Label("App Info", systemImage: "app.badge")
        }
    }
    
    private func clearLocalData() {
        // 1) Delete all SwiftData records
        do {
            let all: [CheckupRecord] = try modelContext.fetch(FetchDescriptor())
            for item in all { modelContext.delete(item) }
            try modelContext.save()
        } catch {
            print("Failed to delete records:", error)
        }

        // 2) Reset UserDefaults / @AppStorage
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
    }
}

// MARK: - Birth date components (manual only, persisted with AppStorage)
fileprivate let birthISO = ISO8601DateFormatter()

struct DOBState: Equatable {
    var date: Date? = nil
    var summary: String {
        guard let d = date else { return "Not set" }
        let age = Calendar.current.dateComponents([.year], from: d, to: Date()).year ?? 0
        return "\(DateFormatter.birthMedium.string(from: d)) (\(age)y)"
    }
}

private extension DateFormatter {
    static let birthMedium: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
}

struct BirthDateRow: View {
    @Binding var dob: DOBState
    var body: some View {
        NavigationLink {
            BirthDateEditor(dob: $dob)
        } label: {
            HStack {
                Text("Birth Date")
                Spacer()
                Text(dob.summary).foregroundStyle(.secondary)
            }
        }
    }
}

struct BirthDateEditor: View {
    @Binding var dob: DOBState
    private var range: ClosedRange<Date> {
        let cal = Calendar.current
        let min = cal.date(from: DateComponents(year: 1900, month: 1, day: 1))!
        return min...Date()
    }
    @State private var tempDate: Date = Calendar.current.date(from: DateComponents(year: 1990, month: 1, day: 1))!

    var body: some View {
        Form {
            Section {
                DatePicker("Date of birth", selection: $tempDate, in: range, displayedComponents: .date)
                    .datePickerStyle(.wheel)
            } footer: {
                Text("We only store the selected date on device. You can change it anytime.")
            }
        }
        .navigationTitle("Birth Date")
        .onAppear {
            if let existing = dob.date { tempDate = existing }
        }
        .onDisappear {
            dob.date = tempDate
        }
    }
}

struct CloudStatusRow: View {
    @State private var status: CKAccountStatus = .couldNotDetermine

    var body: some View {
        HStack {
            Label("iCloud sync", systemImage: "icloud")
            Spacer()
            Text(statusText).foregroundStyle(statusColor)
        }
        .onAppear { refresh() }
    }

    private func refresh() {
        CKContainer.default().accountStatus { s, _ in
            DispatchQueue.main.async { status = s }
        }
    }

    private var statusText: String {
        switch status {
        case .available: return "Available (sync active)"
        case .noAccount: return "Signed out"
        case .restricted: return "Restricted"
        case .temporarilyUnavailable: return "Temporarily unavailable"
        default: return "Checking…"
        }
    }
    private var statusColor: Color {
        switch status {
        case .available: return .green
        case .noAccount, .restricted, .temporarilyUnavailable: return .orange
        default: return .secondary
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
