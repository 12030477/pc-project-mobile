# 🖥️ PC Build Budget Helper

> A sleek Flutter app that helps you plan your PC build budget and power requirements — fast, intuitive, and offline-ready.

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue)]()  
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)]()  
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-green)]()

---

## ✨ Features

- 💰 **Real-Time Cost Estimation** – Instantly calculates your total build cost as you add components  
- ⚡ **Auto-Calculate Mode** – Automatically calculates totals as you type (optional)  
- 💱 **Multi-Currency Support** – Supports 15+ currencies with real-time exchange rates and automatic conversion  
- 🔋 **Smart PSU Calculator** – Recommends ideal PSU wattage based on CPU/GPU TDP values  
- 📋 **Build Summary** – Detailed formatted summary with all components, totals, and PSU recommendations  
- 📄 **Copy to Clipboard** – One-click copy of the entire build summary for sharing  
- 🌙 **Dark & Light Mode** – Easily toggle between themes with persistent preference saving  
- ✅ **Input Validation** – Real-time validation with helpful error messages  
- 🔄 **Reset Functionality** – Quick reset button to clear all inputs  
- 📱 **Mobile-Optimized UI** – Responsive design with mobile-specific layouts and optimizations  
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

## 📋 Build Summary

The app generates a detailed, formatted build summary that includes:

- **Component Prices** – All entered component prices with currency symbols  
- **Total Build Cost** – Total cost in selected currency with USD equivalent  
- **Power Requirements** – CPU and GPU TDP values with recommended PSU wattage  
- **Date & Currency Info** – Timestamp and selected currency information  

The summary can be:
- **Viewed** – Displayed in a formatted card after calculation  
- **Copied** – One-click copy to clipboard for sharing or saving  
- **Toggled** – Show or hide the summary card using the checkbox option

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

## 🎮 Usage

### Basic Workflow

1. **Enter Component Prices** – Add prices for CPU, GPU, RAM, Storage, Motherboard, Case, PSU, and Accessories
2. **Set TDP Values** (Optional) – Enter CPU and GPU TDP values for PSU recommendations
3. **Select Currency** – Choose your preferred currency from the dropdown
4. **Enable Auto-Calculate** (Optional) – Toggle auto-calculate to update totals automatically as you type
5. **Calculate** – Click the Calculate button to see your total build cost and recommended PSU
6. **View Summary** – Review the detailed build summary and copy it to clipboard if needed
7. **Reset** – Use the Reset button to clear all inputs and start over

### Tips

- Enable **Auto-Calculate** for real-time updates as you type
- Toggle **Show Build Summary** to show/hide the summary card
- Use the refresh button to update exchange rates manually
- The app works offline with cached exchange rates
- Theme preferences are automatically saved and restored

---

## 🧩 Planned Enhancements

- 🔧 Add presets for popular CPUs and GPUs  
- 💾 Save/load build profiles  
- 📶 Enhanced offline data persistence
- 📊 Price history and trends

---

## 🧠 Tech Stack

| Technology        | Purpose                |
|-------------------|------------------------|
| Flutter           | UI framework           |
| Dart              | Programming language   |
| Material Design 3 | UI components          |
| HTTP              | API calls for exchange rates |
| SharedPreferences | Local storage for theme preferences |

---

## 🧾 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

---

## 👨‍💻 Author

Built with ❤️ by *Mantach*
 — for PC builders everywhere.
