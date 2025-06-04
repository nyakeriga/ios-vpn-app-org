#!/bin/bash

set -euo pipefail

# ==========================
# Configuration
# ==========================
SCHEME="ios-vpn-app-org"
CONFIGURATION="Release"
ARCHIVE_PATH="./build/${SCHEME}_$(date +%Y%m%d_%H%M%S).xcarchive"
EXPORT_PATH="./build/export"
EXPORT_OPTIONS_PLIST="ExportOptions.plist"  # Must be preconfigured
WORKSPACE="ios-vpn-app-org.xcodeproj"       # Change to .xcworkspace if using CocoaPods/SPM

# ==========================
# Functions
# ==========================

print_banner() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔨 $1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

fail_if_missing() {
  if [[ ! -f "$1" ]]; then
    echo "❌ Error: Required file not found: $1"
    exit 1
  fi
}

# ==========================
# Main Script
# ==========================

print_banner "Starting clean build"

# Optional: Clean previous builds
xcodebuild clean -project "$WORKSPACE" -scheme "$SCHEME" -configuration "$CONFIGURATION"

print_banner "Archiving App"

xcodebuild archive \
  -project "$WORKSPACE" \
  -scheme "$SCHEME" \
  -sdk iphoneos \
  -configuration "$CONFIGURATION" \
  -archivePath "$ARCHIVE_PATH" \
  | xcpretty || exit 1

fail_if_missing "$ARCHIVE_PATH/Info.plist"

print_banner "Exporting .ipa"

mkdir -p "$EXPORT_PATH"

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
  | xcpretty || exit 1

IPA_PATH=$(find "$EXPORT_PATH" -name "*.ipa" | head -n 1)

if [[ -f "$IPA_PATH" ]]; then
  echo "✅ Export successful: $IPA_PATH"
  open "$EXPORT_PATH" || true
else
  echo "❌ Export failed. No .ipa found in $EXPORT_PATH"
  exit 2
fi
