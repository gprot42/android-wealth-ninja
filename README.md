# Wealth Ninja 🥷💰

> A comprehensive mobile investment tracking and calculation tool built with Flutter. Track stocks, cryptocurrencies, and cash holdings with real-time prices, manage your portfolio with detailed analytics, and project future investment growth with our advanced compound calculator.

---

## 🚀 Key Features

* **Price Tracker:** Add stocks or cryptocurrencies to your watchlist to monitor their current prices, updated every minute.
* **Portfolio Tracker:** Log your owned assets with details like quantity and purchase price. Instantly see your portfolio's total value, profits/losses, and an allocation pie chart.
* **Compound Calculator:** Project future investment values using Compound Annual Growth Rate (CAGR) calculations. Supports multiple currencies and assets including USD, CHF, GBP, BTC, ETH, MSTR with real-time price integration.
* **Customization:** Switch between light and dark themes, change your preferred display currency (e.g., USD to EUR), and view an "About" page.
* **Splash Screen:** A welcoming 3-second splash screen greets you on app launch before loading the main interface.

---

## 🛠️ How It Works

* **Data Sources:** Prices are fetched from reliable APIs: `Yahoo Finance` for stocks, `CoinGecko` for cryptocurrencies, and `exchangerate.host` for currency conversions, with a CHF-denominated fallback table to ensure rates are always available even if the external service is unreachable.
* **Compound Calculations:** The calculator uses the formula `FV = PV × (1 + r)^n` where FV is future value, PV is present value, r is the annual growth rate, and n is the number of years. For crypto and stocks, it fetches current prices to calculate quantities and project future values.
* **Local Storage:** All your data is saved locally on your device, ensuring offline access and data persistence between sessions.
* **Dynamic Updates:** Easily add or remove items through simple dialogs. Prices auto-refresh to keep you informed.

### Using the Compound Calculator
The calculator helps you project future investment values by applying compound growth rates:

1. **Enter your starting amount** (e.g., $1000)
2. **Set the annual growth rate** (e.g., 30% for aggressive growth)
3. **Specify the time period** in years (e.g., 5 years)
4. **Choose your currency/asset** from the dropdown (USD, BTC, ETH, MSTR, CHF, GBP, PHP)
5. **Tap Calculate** to see projected results

For cryptocurrencies and stocks, the calculator fetches current market prices to determine how many units your investment would buy, then projects the future value based on the growth rate.

---

## ⚠️ Important Notes

* The app is designed to be **user-friendly**, and no account registration is required.
* An active **internet connection** is necessary to fetch the latest price data.
* Data fetching is dependent on third-party APIs and may be subject to rate limits.

---

## 🏗️ Building & Running

### Prerequisites
* Flutter SDK (3.0.0 or higher)
* Android Studio (for Android builds) or Xcode (for iOS builds)
* For Android: Android SDK with proper environment variables set
* Ruby toolchain (via `rbenv` or system Ruby) with CocoaPods available for iOS/macOS targets

### Build Commands
```bash
# Build for Android (release)
./build.sh android release

# Build for Android (debug)
./build.sh android debug

# Build for iOS
./build.sh ios

# Build for macOS
./build.sh macos

# Run in development mode
flutter run
```

### macOS CocoaPods Setup

If you encounter pod-related errors when building on macOS, reinstall CocoaPods under a supported Ruby version:

```bash
# Ensure ruby-build is current
brew upgrade ruby-build

# Install a recent Ruby and set it globally (example: 3.3.10)
rbenv install 3.3.10
rbenv global 3.3.10

# Install CocoaPods and refresh shims
gem install cocoapods
rbenv rehash

# Verify the installation
pod --version
```

After the Ruby/CocoaPods environment is ready, rerun `flutter run -d macos` or `./build.sh macos`.

### APK Output
Release builds are automatically copied to `~/Downloads/wealth-ninja-release.apk`

---

## 📸 Screenshots

<p align="center">
  <img width="252" height="561" alt="Screenshot of the price tracker screen" src="https://github.com/user-attachments/assets/7c9bfdaf-351c-4158-9312-8d3fc0766159">
  <img width="252" height="561" alt="Screenshot of the portfolio tracker screen" src="https://github.com/user-attachments/assets/3f38723c-a974-468b-a476-6246e3134b8b">
  <img width="252" height="561" alt="Screenshot of the settings screen" src="https://github.com/user-attachments/assets/899afbb6-7260-450c-a45e-379e3231422a">
</p>
