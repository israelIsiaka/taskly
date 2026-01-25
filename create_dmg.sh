#!/bin/bash

# Script to build taskly app and create a DMG for distribution
# Usage: ./create_dmg.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="taskly"
SCHEME="taskly"
PROJECT_PATH="taskly.xcodeproj"
BUILD_DIR="build"
DMG_NAME="${APP_NAME}.dmg"
DMG_TEMP_DIR="${BUILD_DIR}/dmg_temp"
APP_PATH="${BUILD_DIR}/Release/${APP_NAME}.app"
DMG_PATH="${BUILD_DIR}/${DMG_NAME}"

echo -e "${GREEN}🚀 Starting DMG creation process...${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Build the app for Universal (Apple Silicon + Intel) - unsigned
echo -e "${YELLOW}🔨 Building ${APP_NAME} (Universal: arm64 + x86_64)...${NC}"

xcodebuild clean build \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME}" \
    -configuration Release \
    -derivedDataPath "${BUILD_DIR}" \
    ARCHS="arm64 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    DEVELOPMENT_TEAM="" \
    PROVISIONING_PROFILE_SPECIFIER=""

# Check if app was built successfully
if [ ! -d "${APP_PATH}" ]; then
    echo -e "${YELLOW}💡 App not at expected path, searching...${NC}"
    
    # Try to find the app in derived data (xcodebuild puts it in Build/Products/Release)
    APP_PATH=$(find "${BUILD_DIR}" -name "${APP_NAME}.app" -type d | head -n 1)
    
    if [ -z "${APP_PATH}" ]; then
        # Try alternative derived data location
        APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "${APP_NAME}.app" -path "*/Build/Products/Release/*" -type d 2>/dev/null | head -n 1)
    fi
    
    if [ -z "${APP_PATH}" ] || [ ! -d "${APP_PATH}" ]; then
        echo -e "${RED}❌ Error: Could not find built app${NC}"
        echo -e "${YELLOW}💡 Make sure the build completed successfully${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Found app at: ${APP_PATH}${NC}"
else
    echo -e "${GREEN}✅ App found at: ${APP_PATH}${NC}"
fi

# Create DMG directory structure
echo -e "${YELLOW}📦 Creating DMG structure...${NC}"
rm -rf "${DMG_TEMP_DIR}"
mkdir -p "${DMG_TEMP_DIR}"

# Copy app to DMG directory
cp -R "${APP_PATH}" "${DMG_TEMP_DIR}/"

# Create Applications symlink
ln -s /Applications "${DMG_TEMP_DIR}/Applications"

# Get app version (if available)
VERSION=$(defaults read "${APP_PATH}/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "1.0")
DMG_VOLUME_NAME="${APP_NAME} ${VERSION}"

# Remove existing DMG if it exists
if [ -f "${DMG_PATH}" ]; then
    echo -e "${YELLOW}🗑️  Removing existing DMG...${NC}"
    rm -f "${DMG_PATH}"
fi

# Create DMG
echo -e "${YELLOW}💿 Creating DMG...${NC}"
hdiutil create -srcfolder "${DMG_TEMP_DIR}" \
    -volname "${DMG_VOLUME_NAME}" \
    -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" \
    -format UDRW \
    -size 200m \
    "${DMG_PATH}.temp.dmg"

# Mount the DMG
echo -e "${YELLOW}📂 Mounting DMG...${NC}"
MOUNT_OUTPUT=$(hdiutil attach -readwrite -noverify -noautoopen "${DMG_PATH}.temp.dmg" 2>&1)

# Extract mount directory - get all fields from field 3 onwards (handles spaces in path)
# Format: /dev/diskXsX    Apple_HFS    /Volumes/name with spaces
MOUNT_DIR=$(echo "${MOUNT_OUTPUT}" | grep "Apple_HFS" | awk '{for(i=3;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

# If that didn't work, try using hdiutil info to find the mount point
if [ -z "${MOUNT_DIR}" ] || [ ! -d "${MOUNT_DIR}" ]; then
    DEVICE=$(echo "${MOUNT_OUTPUT}" | grep "Apple_HFS" | awk '{print $1}')
    if [ -n "${DEVICE}" ]; then
        MOUNT_DIR=$(hdiutil info | grep -A 5 "${DEVICE}" | grep "Mount Point" | sed 's/.*Mount Point[[:space:]]*:[[:space:]]*//')
    fi
fi

if [ -z "${MOUNT_DIR}" ] || [ ! -d "${MOUNT_DIR}" ]; then
    echo -e "${RED}❌ Error: Could not mount DMG${NC}"
    echo "${MOUNT_OUTPUT}"
    exit 1
fi

echo -e "${GREEN}✅ DMG mounted at: ${MOUNT_DIR}${NC}"

# Wait for mount
sleep 3

# Set DMG window properties (optional - makes it look nicer)
echo -e "${YELLOW}🎨 Configuring DMG appearance...${NC}"

# Use AppleScript to set window properties
osascript <<EOF || true
tell application "Finder"
    tell disk "${DMG_VOLUME_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 920, 420}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 72
        set position of item "${APP_NAME}.app" of container window to {160, 205}
        set position of item "Applications" of container window to {360, 205}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF

# Unmount the DMG
echo -e "${YELLOW}📤 Unmounting DMG...${NC}"
hdiutil detach "${MOUNT_DIR}" -force -quiet || {
    echo -e "${YELLOW}⚠️  Force unmounting...${NC}"
    hdiutil detach "${MOUNT_DIR}" -force || true
}

# Wait for unmount to complete and verify
sleep 2
MAX_RETRIES=5
RETRY_COUNT=0
while [ -d "${MOUNT_DIR}" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo -e "${YELLOW}⏳ Waiting for unmount to complete...${NC}"
    sleep 1
    RETRY_COUNT=$((RETRY_COUNT + 1))
    # Try unmounting again if still mounted
    if [ -d "${MOUNT_DIR}" ]; then
        hdiutil detach "${MOUNT_DIR}" -force -quiet 2>/dev/null || true
    fi
done

if [ -d "${MOUNT_DIR}" ]; then
    echo -e "${RED}❌ Error: Could not unmount DMG at ${MOUNT_DIR}${NC}"
    exit 1
fi

# Convert to compressed read-only DMG
echo -e "${YELLOW}🗜️  Compressing DMG...${NC}"
MAX_RETRIES=3
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if hdiutil convert "${DMG_PATH}.temp.dmg" \
        -format UDZO \
        -imagekey zlib-level=9 \
        -o "${DMG_PATH}" 2>&1; then
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo -e "${YELLOW}⚠️  Convert failed, retrying in 2 seconds... (attempt $RETRY_COUNT/$MAX_RETRIES)${NC}"
            sleep 2
        else
            echo -e "${RED}❌ Error: Failed to convert DMG after $MAX_RETRIES attempts${NC}"
            exit 1
        fi
    fi
done

# Remove temporary DMG
rm -f "${DMG_PATH}.temp.dmg"

# Clean up temp directory
rm -rf "${DMG_TEMP_DIR}"

# Get DMG size
DMG_SIZE=$(du -h "${DMG_PATH}" | cut -f1)

echo -e "${GREEN}✅ DMG created successfully!${NC}"
echo -e "${GREEN}📦 Location: ${DMG_PATH}${NC}"
echo -e "${GREEN}📏 Size: ${DMG_SIZE}${NC}"

# Mount and install the app
echo -e "${YELLOW}📂 Mounting DMG for installation...${NC}"
MOUNT_OUTPUT=$(hdiutil attach -readonly -noverify -noautoopen "${DMG_PATH}" 2>&1)

# Extract mount directory - get all fields from field 3 onwards (handles spaces in path)
# Format: /dev/diskXsX    Apple_HFS    /Volumes/name with spaces
MOUNT_DIR=$(echo "${MOUNT_OUTPUT}" | grep "Apple_HFS" | awk '{for(i=3;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

# If that didn't work, try using hdiutil info to find the mount point
if [ -z "${MOUNT_DIR}" ] || [ ! -d "${MOUNT_DIR}" ]; then
    DEVICE=$(echo "${MOUNT_OUTPUT}" | grep "Apple_HFS" | awk '{print $1}')
    if [ -n "${DEVICE}" ]; then
        MOUNT_DIR=$(hdiutil info | grep -A 5 "${DEVICE}" | grep "Mount Point" | sed 's/.*Mount Point[[:space:]]*:[[:space:]]*//')
    fi
fi

if [ -z "${MOUNT_DIR}" ] || [ ! -d "${MOUNT_DIR}" ]; then
    echo -e "${RED}❌ Error: Could not mount DMG for installation${NC}"
    echo "${MOUNT_OUTPUT}"
    exit 1
fi

echo -e "${GREEN}✅ DMG mounted at: ${MOUNT_DIR}${NC}"

# Wait for mount to complete
sleep 2

# Check if app exists in mounted DMG
DMG_APP_PATH="${MOUNT_DIR}/${APP_NAME}.app"
if [ ! -d "${DMG_APP_PATH}" ]; then
    echo -e "${RED}❌ Error: Could not find app in mounted DMG${NC}"
    hdiutil detach "${MOUNT_DIR}" -force -quiet || true
    exit 1
fi

# Copy app to Applications folder
echo -e "${YELLOW}📥 Installing ${APP_NAME} to /Applications...${NC}"
if [ -d "/Applications/${APP_NAME}.app" ]; then
    echo -e "${YELLOW}⚠️  App already exists in /Applications, removing old version...${NC}"
    rm -rf "/Applications/${APP_NAME}.app"
fi

cp -R "${DMG_APP_PATH}" "/Applications/"

# Remove quarantine attribute to allow the app to run
echo -e "${YELLOW}🔓 Removing quarantine attribute...${NC}"
sudo xattr -d com.apple.quarantine "/Applications/${APP_NAME}.app" 2>/dev/null || {
    echo -e "${YELLOW}⚠️  Could not remove quarantine attribute${NC}"
}

# Unmount the DMG
echo -e "${YELLOW}📤 Unmounting DMG...${NC}"
hdiutil detach "${MOUNT_DIR}" -force -quiet || {
    echo -e "${YELLOW}⚠️  Force unmounting...${NC}"
    hdiutil detach "${MOUNT_DIR}" -force || true
}

echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${GREEN}📱 App installed to: /Applications/${APP_NAME}.app${NC}"
echo -e "${GREEN}🎉 Done!${NC}"
