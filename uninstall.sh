#!/usr/bin/env bash
set -euo pipefail

rm -rf "$HOME/.config/omarchy/plugins/jlord.mouse-focus"

omarchy shell shell rescanPlugins
printf 'Removed the jlord.mouse-focus plugin.\n'
printf 'Remove the jlord.mouse-focus entry from ~/.config/omarchy/shell.json if present.\n'
printf 'If persistence was enabled, remove the managed Hyprland files manually if desired.\n'
