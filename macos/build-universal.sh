#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
BUILD_DIR="$SCRIPT_DIR/build"
APP_PATH="$BUILD_DIR/猫咪桌宠.app"
SDK_PATH="$(xcrun --show-sdk-path)"
MODULE_CACHE_DIR="$BUILD_DIR/module-cache"

mkdir -p "$BUILD_DIR/arm64" "$BUILD_DIR/x86_64" "$MODULE_CACHE_DIR"
rm -rf "$APP_PATH"

xcrun swiftc \
  -target arm64-apple-macos13.0 \
  -sdk "$SDK_PATH" \
  -module-cache-path "$MODULE_CACHE_DIR" \
  -framework AppKit \
  "$SCRIPT_DIR/CatPetMain.swift" \
  -o "$BUILD_DIR/arm64/CatPet"

xcrun swiftc \
  -target x86_64-apple-macos13.0 \
  -sdk "$SDK_PATH" \
  -module-cache-path "$MODULE_CACHE_DIR" \
  -framework AppKit \
  "$SCRIPT_DIR/CatPetMain.swift" \
  -o "$BUILD_DIR/x86_64/CatPet"

mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources"
lipo -create \
  "$BUILD_DIR/arm64/CatPet" \
  "$BUILD_DIR/x86_64/CatPet" \
  -output "$APP_PATH/Contents/MacOS/CatPet"

chmod +x "$APP_PATH/Contents/MacOS/CatPet"
cp "$SCRIPT_DIR/Info.plist" "$APP_PATH/Contents/Info.plist"
cp "$SCRIPT_DIR/Resources/sleep_0.png" "$APP_PATH/Contents/Resources/sleep_0.png"
cp "$SCRIPT_DIR/Resources/sleep_1.png" "$APP_PATH/Contents/Resources/sleep_1.png"

codesign --force --deep --sign - "$APP_PATH"
codesign --verify --deep --strict "$APP_PATH"

echo "构建完成：$APP_PATH"
file "$APP_PATH/Contents/MacOS/CatPet"
