#!/usr/bin/env bash
set -euo pipefail

# Build a portable AppImage for the Flutter Linux release bundle.
# Usage: ./scripts/build_appimage.sh [optional-output-name]

APP_NAME="metopi_timer"
OUT_NAME="${1:-${APP_NAME}.AppImage}"
BUNDLE_DIR="build/linux/x64/release/bundle"
APPDIR="${APP_NAME}.AppDir"

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter CLI not found in PATH. Install Flutter and try again." >&2
  exit 2
fi

echo "Building Flutter Linux release..."
flutter build linux --release

if [ ! -d "$BUNDLE_DIR" ]; then
  echo "Expected bundle at $BUNDLE_DIR not found." >&2
  exit 3
fi

rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr"

# Copy the release bundle into AppDir/usr
cp -r "$BUNDLE_DIR/"* "$APPDIR/usr/" 

# Find the main binary (it's typically in usr/ directly, not usr/bin/)
MAIN_BIN=$(find "$APPDIR/usr" -maxdepth 1 -type f -executable | head -n1 || true)
if [ -z "$MAIN_BIN" ]; then
  echo "No executable found in bundle. Check build output." >&2
  exit 4
fi

# Make it executable
chmod +x "$MAIN_BIN"

# Create a .desktop file with correct Exec path
cat > "$APPDIR/${APP_NAME}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=metopi_timer
Exec=metopi_timer
Icon=metopi_timer
Categories=Utility;
StartupNotify=false
EOF

# Copy a placeholder icon if none present
ICON_DST="$APPDIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$ICON_DST"
if [ -f "assets/icon.png" ]; then
  cp assets/icon.png "$ICON_DST/metopi_timer.png"
  # Also copy to AppDir root so appimagetool finds it
  cp assets/icon.png "$APPDIR/metopi_timer.png"
else
  # create a small placeholder PNG using ImageMagick if available, else leave it
  if command -v convert >/dev/null 2>&1; then
    convert -size 256x256 xc:#2563eb -gravity center -pointsize 48 -fill white -annotate 0 "T" "$ICON_DST/metopi_timer.png"
    cp "$ICON_DST/metopi_timer.png" "$APPDIR/metopi_timer.png"
  fi
fi

# Make sure AppDir has the .desktop and icons in expected places
mkdir -p "$APPDIR/usr/share/applications"
cp "$APPDIR/${APP_NAME}.desktop" "$APPDIR/usr/share/applications/"

# Download appimagetool if needed
if [ ! -x ./appimagetool-x86_64.AppImage ]; then
  echo "Downloading appimagetool..."
  curl -L -o appimagetool-x86_64.AppImage https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
  chmod +x appimagetool-x86_64.AppImage
fi

# Build the AppImage
./appimagetool-x86_64.AppImage "$APPDIR" "$OUT_NAME"

echo "Created $OUT_NAME"
