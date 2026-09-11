#!/usr/bin/env bash
set -euo pipefail

rm -rf "$HOME/.config/omarchy/plugins/jlord.mouse-focus"
rm -f "$HOME/.config/hypr/mouse-focus.lua"

if [[ -f "$HOME/.config/hypr/input.lua" ]]; then
  sed -i '\|^require("hypr.mouse-focus")$|d' "$HOME/.config/hypr/input.lua"
fi

omarchy shell shell rescanPlugins
printf 'Removed the jlord.mouse-focus plugin and its managed Hyprland file.\n'
printf 'Remove the jlord.mouse-focus entry from ~/.config/omarchy/shell.json if present.\n'
