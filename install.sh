#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
plugin_dir="$HOME/.config/omarchy/plugins/jlord.mouse-focus"
hypr_dir="$HOME/.config/hypr"

mkdir -p "$HOME/.config/omarchy/plugins" "$hypr_dir"
rm -rf "$plugin_dir"
mkdir -p "$plugin_dir"
cp "$repo_dir/manifest.json" "$repo_dir/MouseFocus.qml" "$plugin_dir/"
cp "$repo_dir/hypr/mouse-focus.lua" "$hypr_dir/"

if ! grep -q 'require("hypr.mouse-focus")' "$hypr_dir/input.lua"; then
  printf '\nrequire("hypr.mouse-focus")\n' >> "$hypr_dir/input.lua"
fi

omarchy plugin validate "$plugin_dir"
omarchy shell shell rescanPlugins
hyprctl reload
