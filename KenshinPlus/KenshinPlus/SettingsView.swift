//
//  SettingsView.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/09.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @State private var tab: MainTab = .settings
    @State private var isiCloudSyncEnabled = false
    @State private var isSectionDisabled = true
    @StateObject private var auth = AppleAuth()
    @AppStorage("birthDateISO") private var birthDateISO: String = ""
    @State private var dob = DOBState()
    @Query(sort: \CheckupRecord.date, order: .reverse)
    private var record: [CheckupRecord]
    @State private var showClearDialog = false
    @Environment(\.modelContext) private var modelContext
    

    private var latestDate: String{
        guard let d = record.first?.date else{ return "No Data" }
        let date = DateFormatter.birthMedium.string(from: d)
        let rel = RelativeDateTimeFormatter().localizedString(for: d, relativeTo: Date())
        return"\(date) (\(rel))"
    }

    var body: some View {
        TabView(selection: $tab) {
            VStack{
                Form {
                    yourAccount

                    dataManagement

                    privacy
                    
                    appInfo

                }
            }
        }
    }
    
    // MARK: - Your Account
    var yourAccount: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(auth.isSignedIn ? auth.account?.displayName ?? "Apple User" : "Account (Guest)")
                        .font(.headline)
                    if let email = auth.account?.email { Text(email).foregroundStyle(.secondary).font(.subheadline) }
                    if !auth.isSignedIn, let err = auth.errorMessage { Text(err).foregroundStyle(.red).font(.footnote) }
                }
                Spacer()
                Image(systemName: auth.isSignedIn ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.questionmark.fill")
                    .imageScale(.large)
                    .foregroundStyle(auth.isSignedIn ? .green : .secondary)
            }
            
            if !auth.isSignedIn {
                AppleSignInButtonView(auth: auth)
                    .padding(.top, 6)
            } else {
                HStack {
                    Button(role: .none) {
                        auth.refreshCredentialState()
                    } label: {
                        Label("Check status", systemImage: "arrow.clockwise")
                    }
                    Spacer()
                    Button(role: .destructive) { auth.signOut() } label: {
                        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            
            BirthDateRow(dob: $dob)
            
            HStack {
                Text("Last Checkup Date")
                Spacer()
                Text(latestDate)
                    .foregroundStyle(record.isEmpty ? .secondary : .primary)
            }
        } header: {
            Label("Your Account", systemImage: "person.crop.circle")
        }
        .onAppear {
            auth.refreshCredentialState()
            if auth.isSignedIn {
                isSectionDisabled = false // If no sign in, disable iCloud sync section
            }

            if !birthDateISO.isEmpty { dob.date = birthISO.date(from: birthDateISO) }
        }
        .onChange(of: dob.date) { new, _ in
            birthDateISO = new.map { birthISO.string(from: $0) } ?? ""
        }
    }
    
    // MARK: - Data Management
    var dataManagement: some View {
        Section {
            Toggle("Sync to iCloud", isOn: $isiCloudSyncEnabled)
                .foregroundStyle(isSectionDisabled ? .secondary : .primary)
            if !isiCloudSyncEnabled {
                Link("Manual Sync to iCloud", destination: URL(string: "https://www.apple.com")!)
            }
            Text("Restore from iCloud Backup")
                .foregroundStyle(isSectionDisabled ? .secondary : .primary)
        } header: {
            Label("Data Management", systemImage: "lock.icloud")
        }
        .disabled(isSectionDisabled)
    }
    
    // MARK: - Privacy
    var privacy: some View {
        Section {
            Button(role: .destructive) { showClearDialog = true } label: { Text("Clear Local Data") }
                .confirmationDialog("Delete all local data?", isPresented: $showClearDialog, titleVisibility: .visible) {
                    Button("Delete All Data", role: .destructive) { clearLocalData() }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This removes all checkups, settings, and your signed-in session from this device. If iCloud sync is enabled, data may sync back from the cloud.")
                }.foregroundStyle(.red)
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
                Text("1.1.0")
                    .foregroundStyle(.secondary)
            }
            NavigationLink("Future Updates", destination: FutureUpdates())
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
            // Optional: show an alert instead of printing
            print("Failed to delete records:", error)
        }

        // 2) Reset UserDefaults / @AppStorage
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }

        // 3) Clear any Keychain items you used (e.g., Sign in with Apple session)
        _ = Keychain.delete("appleAccount.json")

        // 4) Reset in-memory UI state as needed (examples)
        // auth.signOut()
        // dob = DOBState()
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
                Text("Birth date")
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
        .navigationTitle("Birth date")
        .onAppear {
            if let existing = dob.date { tempDate = existing }
        }
        .onDisappear {
            dob.date = tempDate
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
