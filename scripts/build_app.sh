#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

echo "==> Building DeepSeek Peak Hours (Release)..."
swift build -c release

APP_NAME="DeepSeek Peak Hours"
APP_BUNDLE="build/${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS="${CONTENTS}/MacOS"
RESOURCES="${CONTENTS}/Resources"

echo "==> Creating macOS App Bundle at ${APP_BUNDLE}..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS}"
mkdir -p "${RESOURCES}"

# Copy executable
cp ".build/arm64-apple-macosx/release/DeepSeekPeakHours" "${MACOS}/DeepSeekPeakHours"
chmod +x "${MACOS}/DeepSeekPeakHours"

# Copy Info.plist
cp "Support/Info.plist" "${CONTENTS}/Info.plist"

# Copy AppIcon
if [ -f "Support/AppIcon.icns" ]; then
    cp "Support/AppIcon.icns" "${RESOURCES}/AppIcon.icns"
fi

# Copy Core Resource Bundle (contains Chinese Holiday JSONs)
CORE_BUNDLE=$(find .build -name "DeepSeekPeakHours_DeepSeekPeakHoursCore.bundle" | head -n 1)
if [ -n "$CORE_BUNDLE" ] && [ -d "$CORE_BUNDLE" ]; then
    echo "==> Copying resource bundle: $CORE_BUNDLE"
    cp -R "$CORE_BUNDLE" "${RESOURCES}/"
fi

# Also copy raw Holidays folder directly to Resources for fallback
mkdir -p "${RESOURCES}/Holidays"
cp Sources/DeepSeekPeakHoursCore/Resources/Holidays/*.json "${RESOURCES}/Holidays/"

# Ad-hoc code signing
echo "==> Applying ad-hoc code signature..."
codesign --force --deep -s - "${APP_BUNDLE}"

echo "==> Verifying signature..."
codesign --verify --verbose "${APP_BUNDLE}"

echo "==> Successfully created ${APP_BUNDLE}!"
