#!/usr/bin/env bash
set -euo pipefail

# Resolve Windows PowerShell path
POWERSHELL="$(command -v powershell.exe || echo '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe')"

# Get Windows %APPDATA% path via PowerShell and convert to WSL path
WIN_APPDATA=$("$POWERSHELL" -NoProfile -NonInteractive -Command '[Environment]::GetFolderPath("ApplicationData")' | tr -d '\r')
WIN_APPDATA_LINUX=$(wslpath "$WIN_APPDATA")

# Alacritty config folder inside Windows
ALACRITTY_WIN_DIR="$WIN_APPDATA_LINUX/alacritty"
mkdir -p "$ALACRITTY_WIN_DIR/themes"

# Source config folders
WSL_CONFIG_DIR="$HOME/.config/alacritty"
SRC_BASE="$WSL_CONFIG_DIR/alacritty.toml"
SRC_WIN="$WSL_CONFIG_DIR/os/windows.toml"
THEMES_DIR="$WSL_CONFIG_DIR/themes"

# Destination config files
DST_BASE="$ALACRITTY_WIN_DIR/alacritty.base.toml"
DST_WIN="$ALACRITTY_WIN_DIR/os.windows.toml"

# Destination main config
DST_MAIN="$ALACRITTY_WIN_DIR/alacritty.toml"

# If main config exists, confirm overwrite
if [ -f "$DST_MAIN" ]; then
    echo "⚠️  $DST_MAIN already exists."
    read -rp "Do you want to overwrite it? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "❌ Aborted. Existing alacritty.toml preserved."
        exit 0
    fi
fi

# --- Theme Selection ---
echo "🎨 Available themes:"
mapfile -t themes < <(find "$THEMES_DIR" -maxdepth 1 -name "*.toml" -exec basename {} \;)
for i in "${!themes[@]}"; do
    echo "[$((i+1))] ${themes[$i]}"
done

read -rp "Select a theme [1-${#themes[@]}]: " theme_index
if ! [[ "$theme_index" =~ ^[0-9]+$ ]] || (( theme_index < 1 || theme_index > ${#themes[@]} )); then
    echo "❌ Invalid selection."
    exit 1
fi

SELECTED_THEME="${themes[$((theme_index - 1))]}"
SRC_THEME="$THEMES_DIR/$SELECTED_THEME"
DST_THEME="$ALACRITTY_WIN_DIR/themes/$SELECTED_THEME"

# Copy base and OS-specific configs
cp "$SRC_BASE" "$DST_BASE"
cp "$SRC_WIN" "$DST_WIN"

# Copy selected theme
cp "$SRC_THEME" "$DST_THEME"

# Write main config with imports
cat > "$DST_MAIN" <<EOF
[general]
import = [
  "alacritty.base.toml",
  "os.windows.toml",
  "themes/$SELECTED_THEME"
]
EOF

echo "✅ Linked Alacritty config into: $ALACRITTY_WIN_DIR"
echo "🌈 Theme applied: $SELECTED_THEME"
