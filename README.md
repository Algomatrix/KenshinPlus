# KenshinPlus

A **privacy-first iOS app** for tracking health checkup results, visualizing trends, and importing values from paper or PDF using on-device OCR.  
Built entirely with **SwiftUI**, **SwiftData**, and **Vision**, following Apple’s Human Interface Guidelines — no external servers, no tracking.

![KenshinPlus Banner](docs/images/banner.png)

> 🛡 **Privacy First** — All data stays on your device.  
> ☁ Optional sync with iCloud using your Apple ID.  
> 📱 100% native Swift implementation.

---

## 📋 Table of Contents
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)

---

## ✨ Features

- **Fast data entry**
  - Clean, keyboard-friendly number fields
  - Height & weight unit handling (cm/ft, kg)
  - Blood pressure and key lab metrics

- **On-device OCR import**
  - Detects and parses checkup tables using Apple’s Vision framework
  - Extracts numeric values accurately (e.g. “5,4” → 5.4)

- **Trend visualization**
  - Powered by Swift Charts  
  - Interactive graphs with rule marks & thresholds (e.g. HbA1c ≥ 6.5%)

- **Sync & backup**
  - SwiftData + CloudKit for optional sync
  - Works fully offline by default

- **Localization**
  - String Catalog-based (English 🇬🇧 / Japanese 🇯🇵)
  - Dynamic light/dark mode adaptation

- **Tip Jar**
  - Simple StoreKit 2 integration to support the developer

---

## 🖼 Screenshots

<img width="1206" height="2622" alt="1" src="https://github.com/user-attachments/assets/383a0094-133f-48c6-a238-e7bde5da56fe" />
<img width="1206" height="2622" alt="5" src="https://github.com/user-attachments/assets/e7ae26c4-2b1d-426b-99b9-a462faa64390" />



---

## 🧰 Tech Stack

**Languages & Tools**
- Swift (Swift 5.9+)
- Xcode 15+

**UI & UX**
- SwiftUI (NavigationStack, Sheets, Focus Management)
- Swift Charts

**Data & Sync**
- SwiftData
- CloudKit

**OCR & Parsing**
- Vision (text recognition)
- NSRegularExpression (numeric extraction helpers)

**Commerce & System**
- StoreKit 2 (Tip Jar)
- AppStorage / UserDefaults

**Localization**
- String Catalogs (`.xcstrings`)

> Note: Sign in with Apple was explored during early versions but is not required.  
> iCloud sync uses your existing iCloud account automatically.

---

## 📱 Requirements

- iOS **26.0+**
- Xcode **26+**
- Apple Developer account for iCloud / StoreKit features
