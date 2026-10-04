#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

# Ensure app is built
if [ ! -d "build/DeepSeek Peak Hours.app" ]; then
    ./scripts/build_app.sh
fi

DMG_NAME="DeepSeek-Peak-Hours"
DMG_PATH="build/${DMG_NAME}.dmg"
STAGING="build/dmg_staging"

echo "==> Creating DMG staging directory..."
rm -rf "${STAGING}" "${DMG_PATH}"
mkdir -p "${STAGING}"

# Copy App to staging
cp -R "build/DeepSeek Peak Hours.app" "${STAGING}/"

# Create symlink to /Applications
ln -s /Applications "${STAGING}/Applications"

echo "==> Creating DMG ${DMG_PATH}..."
hdiutil create -volname "DeepSeek Peak Hours" \
               -srcfolder "${STAGING}" \
               -ov \
               -format UDZO \
               "${DMG_PATH}"

rm -rf "${STAGING}"
echo "==> Successfully created ${DMG_PATH}!"
