#!/usr/bin/env bash
set -euo pipefail

# Resolve Windows PowerShell from system (no hardcoding path)
POWERSHELL="$(command -v powershell.exe || echo '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe')"

# Get %APPDATA% path via PowerShell
WIN_APPDATA=$("$POWERSHELL" -NoProfile -NonInteractive -Command '[Environment]::GetFolderPath("ApplicationData")' | tr -d '\r')
WIN_APPDATA_LINUX=$(wslpath "$WIN_APPDATA")

# Alacritty config folder inside Windows
ALACRITTY_WIN_DIR="$WIN_APPDATA_LINUX/alacritty"
mkdir -p "$ALACRITTY_WIN_DIR"

# Source configs inside WSL
WSL_CONFIG_DIR="$HOME/.config/alacritty"
SRC_BASE="$WSL_CONFIG_DIR/alacritty.toml"
SRC_CLR="$WSL_CONFIG_DIR/colorscheme.toml"
SRC_WIN="$WSL_CONFIG_DIR/os/windows.toml"

# Destination "cached" configs in Windows
DST_BASE="$ALACRITTY_WIN_DIR/alacritty.base.toml"
DST_CLR="$ALACRITTY_WIN_DIR/alacritty.colorscheme.toml"
DST_WIN="$ALACRITTY_WIN_DIR/os.windows.toml"

# Destination main config in Windows
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

# Copy WSL configs into Windows (always refresh these)
cp "$SRC_BASE" "$DST_BASE"
cp "$SRC_CLR" "$DST_CLR"
cp "$SRC_WIN" "$DST_WIN"

# Write main Windows config with local imports
cat > "$DST_MAIN" <<EOF
[general]
import = [
  "alacritty.base.toml",
  "alacritty.colorscheme.toml",
  "os.windows.toml"
]
EOF

echo "✅ Linked Alacritty config into: $ALACRITTY_WIN_DIR"
