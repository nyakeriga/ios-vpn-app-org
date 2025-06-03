
# iOS VPN App

This is a custom VPN app for iOS that uses a Network Extension and integrates a bundled **Sing-box** core to support VMESS + WebSocket + TLS and VLESS + WebSocket + TLS protocols.

> ✅ Works on iOS 15+  
> ✅ Built in Swift  
> ✅ Ready for App Store submission (with correct provisioning)

---

## ✨ Features

- [x] Custom VPN engine (Sing-box integration)
- [x] Supports VMESS and VLESS protocols
- [x] Handles both TCP and UDP tunneling
- [x] Minimal UI for server configuration and connection
- [x] GitHub Actions CI/CD support for Xcode builds

---

## 📦 Project Structure

ios-vpn-app/
├── ios-vpn-app/
│ ├── EmbeddedSingBox/ # Put the Sing-box binary here
│ ├── Info.plist # Contains VPN entitlements
│ ├── ViewController.swift # Main UI screen
│ ├── PacketTunnelProvider.swift # VPN tunnel logic
├── .github/
│ └── workflows/
│ └── build-ios.yml # GitHub Actions CI script
├── ExportOptions.plist # For .ipa export
├── README.md

## 🚀 Getting Started

### 1. Requirements

- macOS 12 or later
- Xcode 15 or later
- Apple Developer Account (with NetworkExtension entitlement)

### 2. Setup

1. Clone the repo and open `ios-vpn-app.xcodeproj`
2. Set your team and bundle ID in project settings
3. Replace the binary in `EmbeddedSingBox/` with your compiled Sing-box
4. Build and run on a real iOS device

---

## 🤖 GitHub Actions (CI/CD)

This repo uses **GitHub Actions** to automate Xcode builds.

### 📄 `.github/workflows/build-ios.yml`

- Builds the app with `xcodebuild`
- Uses `ExportOptions.plist` for correct provisioning
- macOS runners with Xcode preinstalled

> 🔧 Customize this file if you want to automate `.ipa` generation or run tests

---

## 🛡️ App Store Submission Notes

- Make sure your `Info.plist` includes all required entitlements
- You **must** enable `NetworkExtension` and `Personal VPN` in your Apple Developer account
- Submit from Xcode or via Transporter app

---

## 🙋‍♂️ Credits

Built with ❤️ using Swift and Apple's Network Extension framework. Sing-box project: https://github.com/SagerNet/sing-box

---

## 📄 License

This project is private/client-bound. Redistribution of code, binaries, or configurations is restricted without permission.
