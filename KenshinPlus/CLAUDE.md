# CLAUDE.md — KenshinPlus Project Briefing

> This file gives Claude instant, full context about KenshinPlus so every session starts with zero ramp-up.
> Place this file at the **repository root**: `KenshinPlus/CLAUDE.md`

---

## 🎯 Project Goal

**KenshinPlus** is a privacy-first iOS app that helps people in Japan track and understand their annual health checkup (健康診断 / 定期健診) results. The core mission is to make Japan's mandatory annual health checkup data accessible, visual, and meaningful — turning a paper report into long-term personal health insights.

**Guiding principle for every feature iteration:**
> Make it simpler to enter data, richer to visualize trends, and smarter to interpret results — all without ever sending data to a third party.

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9+ |
| UI | SwiftUI (NavigationStack, Sheets, Focus Management) |
| Data & Sync | SwiftData + CloudKit (private iCloud DB) |
| Charts | Swift Charts |
| OCR | Apple Vision framework |
| Parsing | NSRegularExpression |
| Payments | StoreKit 2 (Tip Jar) |
| Localization | String Catalogs (`.xcstrings`) — English 🇬🇧 + Japanese 🇯🇵 |
| Persistence | iCloud ID: `iCloud.com.Shubham.KenshinPlus` |
| Min Target | iOS 26.0+ / Xcode 26+ |

**Zero external dependencies** — only Apple frameworks. No SPM packages.

---

## 🏗 Architecture

### Pattern: Flat SwiftUI — no MVVM, no coordinators

This is a **single-layer architecture** appropriate for a solo-developer app. SwiftUI Views handle UI, state, and business logic together. There are no explicit ViewModels yet (this is a known debt item — see below).

### App Structure

```
KenshinPlusApp (@main)
    └── ModelContainer (SwiftData + CloudKit)   ← shared via @Environment(\.modelContext)
            └── CheckupRecord                   ← THE single @Model class for all health data
    └── RootTabsView (TabView)
            ├── Tab 1: DashboardView (NavigationStack)
            │       ├── @Query → [CheckupRecord] filtered (pendingDeletion == false), sorted by date desc
            │       ├── DataAtGlanceContainerSmall cards (latest values at a glance)
            │       ├── CitedDashboardCard wrapper (shows citation info popover on each card)
            │       ├── NavigationLink → detail chart views (receive records[] as props):
            │       │       BloodPressureView, CholesterolTestView, LiverTestView,
            │       │       KidneyTestView, MetabolicTestView, BloodTestView,
            │       │       EyeTestView, HearingTestView (partial)
            │       ├── Checkup History List → CheckupDetailView (edit a single record)
            │       └── Toolbar "+" → ManualDataInputView
            │                               └── VisionSweep (OCR camera/PDF import)
            │                                       └── DocumentCBCParser
            │                                               ├── CoreOCR (OCRText.compact() used internally)
            │                                               ├── AnalyteLexicon (EN+JP keyword map)
            │                                               └── OCRParse.numbers(in: txt).first (regex)
            └── Tab 2: SettingsView
                        ├── Date of birth picker (stored locally)
                        ├── CloudStatusRow (live iCloud status check)
                        ├── HealthSourcesView (reference citations)
                        └── TipJarSheet (StoreKit 2)
```

### Data Flow

**Strictly unidirectional:**
`ManualDataInputView creates CheckupRecord` → `saved to SwiftData` → `@Query in DashboardView auto-refreshes` → `child views receive records: [CheckupRecord] as props`

### Soft Delete (Undo) Pattern

Records are **not hard-deleted immediately**. Instead:
1. `record.pendingDeletion = true` is set
2. A `Timer.publish(every: 0.2)` checks against an `undoDeadline: Date`
3. User can undo within ~5 seconds
4. After deadline: hard delete from context

---

## 📦 Data Model — `CheckupRecord`

Single `@Model` class. All health categories live as optional `Double` fields in one flat SwiftData table (mirrored to CloudKit private DB).

```swift
// Identity
var id: UUID
var createdAt: Date
var date: Date
var pendingDeletion: Bool

// Anthropometrics
var gender: SDGender       // .male / .female
var heightCm: Double?
var weightKg: Double?
var fatPercent: Double?
var waistCm: Double?
var bmi: Double            // computed, not stored

// Unit prefs (per-record)
var lengthUnit: SDLengthUnit   // .cm / .ft
var weightUnit: SDWeightUnit   // .kg / .pounds

// Blood Pressure
var systolic: Double?
var diastolic: Double?

// CBC (Complete Blood Count)
var rbcMillionPeruL: Double?
var hgbPerdL: Double?
var hctPercent: Double?
var pltThousandPeruL: Double?
var wbcThousandPeruL: Double?

// Liver
var ast: Double?
var alt: Double?
var ggt: Double?
var totalProtein: Double?
var albumin: Double?

// Renal
var creatinine: Double?
var uricAcid: Double?

// Metabolism
var fastingGlucoseMgdl: Double?
var hba1cNgspPercent: Double?

// Lipids
var totalChol: Double?
var hdl: Double?
var ldl: Double?
var triglycerides: Double?

// Eye Tests
var uncorrectedAcuityRight: Double?
var uncorrectedAcuityLeft: Double?
var correctedAcuityRight: Double?
var correctedAcuityLeft: Double?
var iopRight: Double?
var iopLeft: Double?
var nearAcuityBoth: Double?
var colorPlatesCorrect: Int?
var colorPlatesTotal: Int?
var refractionSphereRight: Double?
var refractionCylinderRight: Double?
var refractionSphereLeft: Double?
var refractionCylinderLeft: Double?

// Hearing
var hearingLeft1kHz: TestResultState?
var hearingRight1kHz: TestResultState?
var hearingLeft4kHz: TestResultState?
var hearingRight4kHz: TestResultState?
```

### ⚠️ CRITICAL: Adding a new field to `CheckupRecord`

When adding any new field, you **must** update all three of these or there will be silent bugs:
1. `CheckupRecord.swift` — add the `@Model` field + init parameter
2. `ManualDataInputView.swift` — add matching `@State` var + UI field
3. `CheckupRecordSnapshot.restoreRecord()` — add the field to the copy

---

## 🔑 Key Patterns & Conventions

### Citation System
Every health metric card has a `CitedDashboardCard` wrapper that shows a popover with a scientific reference source. New dashboard cards should always use `CitedDashboardCard` and reference `HealthCitationLibrary`.

### Chart Views
All chart views follow the same shape:
- Receive `records: [CheckupRecord]` as a prop (no @Query inside)
- Use `ChartAxis.axisAtDataDates()` for smart X-axis date labels
- Use `ChartAxis.startOfDay()` to align data points
- Use `.chartScrollableAxes(.horizontal)` for multi-record scrolling
- Show `NoChartDataView` overlay when the data series is empty

### Localization
- All user-facing strings **must** use the String Catalog (`.xcstrings`)
- Never hardcode English strings in views — always use `LocalizedStringKey` or `Text("key")`
- Every new string needs both EN and JA translations

### Error Handling
- Currently `try? modelContext.save()` is used everywhere (swallows errors silently)
- New code should prefer `do { try modelContext.save() } catch { /* show user feedback */ }`

---

## 🚧 Known Technical Debt (do not introduce more of these)

| Debt | Location | Notes |
|---|---|---|
| Business logic in Views | `DashboardView` owns delete/undo/timer logic | Should move to a ViewModel |
| God object model | `CheckupRecord` has 40+ fields | Adding new test types keeps inflating this |
| Silent save errors | `try? modelContext.save()` everywhere | Should surface errors to the user |
| Timer-based undo | `Timer.publish(every: 0.2)` for undo | Should use `Task { try await Task.sleep(...) }` |
| Eye fields in `CheckupDetailView` | Uses wrong bindings (cholesterol fields reused) | Needs fixing with proper eye field bindings |
| Dead code | Eye/Hearing tabs commented out in DashboardView | Clean up when features are complete |
| `CheckupRecordSnapshot` fragility | `restoreRecord()` manually copies every field | Silent bug if a new field is forgotten |

---

## ✅ Iteration Goals (what we're building toward)

These are the areas we want to improve with each session. When suggesting changes, prioritize these goals:

1. **Richer health insights** — Add reference ranges, color-coded status (normal / borderline / abnormal) to all metrics so users understand their results, not just see numbers.

2. **Complete the incomplete views** — Eye test and Hearing test views exist but aren't fully wired up in the dashboard. Finish and activate them.

3. **Better OCR accuracy** — The VisionSweep/DocumentCBCParser pipeline works but misses edge cases. Improve `AnalyteLexicon` coverage and numeric extraction robustness.

4. **Smarter data entry** — Reduce the friction of entering 40+ fields manually. Consider section-by-section input flow rather than one giant form.

5. **Export / sharing** — Let users export their checkup history as PDF or CSV for sharing with doctors.

6. **Widgets** — Home screen widget showing last checkup date + key metrics (BMI, blood pressure, HbA1c).

7. **Architecture cleanup** — Gradually extract business logic from Views into lightweight ViewModels, starting with `DashboardView`.

8. **Error surfacing** — Replace silent `try?` saves with user-visible error handling.

---

## 🚫 Hard Rules (never violate these)

- **No external network calls** — No third-party APIs, analytics SDKs, or tracking. Data stays on-device or in the user's own iCloud.
- **No new SPM dependencies** — Apple frameworks only.
- **Always localize** — Every new user-facing string needs an EN + JA entry in the String Catalog.
- **Privacy policy compliance** — Any new data collected must be reflected in `PrivacyPolicyView.swift`.
- **iCloud schema stability** — SwiftData/CloudKit schema changes require careful migration. Never rename or remove existing `CheckupRecord` fields without a migration plan.

---

## 📁 Key Files Quick Reference

| File | Purpose |
|---|---|
| `KenshinPlusApp.swift` | App entry, ModelContainer setup, CloudKit config |
| `CheckupRecord.swift` | The single data model + `CheckupRecordSnapshot` |
| `DashboardView.swift` | Main screen, @Query, undo/delete logic, card grid |
| `CheckupDetailView.swift` | Edit a single checkup record (Form-based) |
| `ManualDataInputView.swift` | Create new record + OCR import entry point |
| `VisionSweep.swift` | OCR pipeline orchestrator |
| `DocumentCBCParser.swift` | Parses OCR text into field values |
| `AnalyteLexicon.swift` | EN+JP keyword map for OCR field matching |
| `HealthCitation.swift` | Citation model + `CitedDashboardCard` + `HealthCitationLibrary` |
| `BloodPressureView.swift` | Systolic/diastolic trend charts |
| `BloodTestView.swift` | CBC trend charts (WBC, RBC, HGB, HCT, PLT) |
| `EyeTestView.swift` | Eye test charts (acuity, IOP, refraction) |
| `SettingsView.swift` | Settings, DOB, iCloud status, health sources, tip jar |
| `Localizable.xcstrings` | All EN+JA localized strings |
| `PrivacyPolicyView.swift` | APPI + GDPR privacy policy |
