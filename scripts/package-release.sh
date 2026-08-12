#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
REPO_DIR="${SCRIPT_DIR:h}"
DIST_DIR="$REPO_DIR/dist"
TEMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

"$REPO_DIR/macos/build-universal.sh"

ditto -c -k --sequesterRsrc --keepParent \
  "$REPO_DIR/macos/build/猫咪桌宠.app" \
  "$DIST_DIR/CatPet-2.3-macOS-universal.zip"

cp -R "$REPO_DIR/windows" "$TEMP_DIR/CatPet-Windows-2.3"
(
  cd "$TEMP_DIR"
  /usr/bin/zip -r -X "$DIST_DIR/CatPet-2.3-Windows-portable.zip" CatPet-Windows-2.3
)

shasum -a 256 "$DIST_DIR"/*.zip
