# Omarchy Mouse Focus

`jlord.mouse-focus` is an Omarchy bar widget for selecting Hyprland's
`input:follow_mouse` behavior. Left-click the target icon to cycle to the next
mode. Right-click opens a window with one button for each mode. The current
mode is shown as the selected/pressed button; clicking another button applies
it immediately.

## Modes

- `Click` (`follow_mouse = 0`): focus changes when clicking a window.
- `Hover` (`follow_mouse = 1`): focus follows the pointer.
- `Hover on entry` (`follow_mouse = 2`): focus changes when entering another window.
- `Hover through floating` (`follow_mouse = 3`): focus follows the pointer through floating windows.

## Installation

Run:

```bash
./install.sh
```

Then add this widget before the clock in the center section of
`~/.config/omarchy/shell.json`:

```json
{
  "id": "jlord.mouse-focus"
}
```

The installer copies the plugin to `~/.config/omarchy/plugins/` and installs
the managed Hyprland module at `~/.config/hypr/mouse-focus.lua`.

The user's `~/.config/hypr/input.lua` must load the module:

```lua
require("hypr.mouse-focus")
```

## Uninstallation

Run:

```bash
./uninstall.sh
```

Also remove the widget entry from `~/.config/omarchy/shell.json`. The uninstall
script does not edit that file automatically.

## Development

The active installed copy is separate from this repository. After editing the
repository copy, rerun `./install.sh` to copy it into the Omarchy plugin
directory.
