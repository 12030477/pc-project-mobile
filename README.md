# 🖥️ PC Build Budget Helper

> A sleek Flutter app that helps you plan your PC build budget and power requirements — fast, intuitive, and offline-ready.

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue)]()  
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)]()  
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-green)]()

---

## ✨ Features

- 💰 **Real-Time Cost Estimation** – Instantly calculates your total build cost as you add components  
- 💱 **Multi-Currency Support** – Supports 15+ currencies with real-time exchange rates and automatic conversion  
- ⚡ **Smart PSU Calculator** – Recommends ideal PSU wattage based on CPU/GPU TDP values  
- 🌙 **Dark & Light Mode** – Easily toggle between themes for comfortable viewing  
- 🎨 **Modern UI** – Built with Material Design 3 for a clean, responsive experience  
- 🌍 **Cross-Platform Support** – Runs smoothly on Android, iOS, and Web  

---

## 🖼️ Screenshots

Screenshots coming soon 😄

---

## 🚀 Getting Started

### 🔧 Prerequisites

- Flutter SDK (≥ 3.0.0)  
- Dart SDK  
- Android Studio / VS Code / Xcode (for mobile builds)

### 📦 Installation

```bash
git clone https://github.com/12030477/pc-build-budget-helper.git
cd pc-build-budget-helper
flutter pub get
flutter run
```

---

## ⚡ PSU Calculation Logic

The app estimates recommended PSU wattage using the following formula:

- Base system power: 100W  
- + CPU TDP  
- + GPU TDP  
- + 20% safety buffer  
- → Rounded up to the nearest 50W

---

## 💱 Currency Conversion

The app supports real-time currency conversion with the following features:

- **15+ Supported Currencies**: USD, EUR, GBP, JPY, CAD, AUD, CHF, CNY, INR, BRL, KRW, MXN, SAR, AED, ZAR, and more
- **Real-Time Exchange Rates**: Automatically fetches latest rates from exchangerate-api.com
- **USD Equivalent Display**: Shows USD equivalent when using non-USD currencies for easy comparison
- **Manual Refresh**: Tap the refresh button to update exchange rates anytime
- **Offline Fallback**: Works offline with cached rates (shows USD equivalent)

### How It Works

1. Select your preferred currency from the dropdown in the header
2. Enter component prices in your selected currency
3. The app automatically converts to USD internally for calculations
4. Total cost displays in your selected currency with USD equivalent shown alongside

---

## 🧩 Planned Enhancements

- 🔧 Add presets for popular CPUs and GPUs  
- 💾 Save/load build profiles  
- 📶 Offline data persistence

---

## 🧠 Tech Stack

| Technology        | Purpose                |
|-------------------|------------------------|
| Flutter           | UI framework           |
| Dart              | Programming language   |
| Material Design 3 | UI components          |
| HTTP              | API calls for exchange rates |

---

## 🧾 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

---

## 👨‍💻 Author

Built with ❤️ by *Mantach*
 — for PC builders everywhere.
