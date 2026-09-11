#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
plugin_dir="$HOME/.config/omarchy/plugins/jlord.mouse-focus"

mkdir -p "$HOME/.config/omarchy/plugins"
rm -rf "$plugin_dir"
mkdir -p "$plugin_dir"
cp "$repo_dir/manifest.json" "$repo_dir/MouseFocus.qml" "$plugin_dir/"

omarchy plugin validate "$plugin_dir"
omarchy shell shell rescanPlugins
