#!/bin/bash
set -e

echo "🔧 Archiving app..."
xcodebuild -scheme ios-vpn-app-org \
  -sdk iphoneos \
  -configuration Release \
  -archivePath ./build/vpnapp.xcarchive \
  archive

echo "📦 Exporting .ipa..."
xcodebuild -exportArchive \
  -archivePath ./build/vpnapp.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath ./build

echo "✅ IPA is ready at ./build"
