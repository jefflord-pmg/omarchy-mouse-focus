# Omarchy Mouse Focus

`jlord.mouse-focus` is an Omarchy bar widget for selecting Hyprland's
`input:follow_mouse` behavior. Left-click the target icon to open a window with
one button for each mode. Right-click does nothing. The current
mode is shown as the selected/pressed button; clicking another button applies
it immediately.

![Mouse focus selector](preview.png)

Third-party plugins run as unsandboxed code inside the Omarchy shell.

## Install From Marketplace

Install and enable the plugin with:

```bash
omarchy plugin add https://github.com/jefflord-pmg/omarchy-mouse-focus.git --enable
```

Then add the widget to the center section of `~/.config/omarchy/shell.json`:

```json
{
  "id": "jlord.mouse-focus"
}
```

Marketplace installation does not modify your Hyprland configuration. Selecting
a mode in the widget is an explicit action that applies the selected
`input:follow_mouse` value to the running Hyprland session.

## Modes

- `Click Focus` (`follow_mouse = 0`): cursor movement will not change focus.
- `Click Focus, scroll under pointer` (`follow_mouse = 2`): cursor focus is detached from keyboard focus. Clicking on a window moves keyboard focus to that window.
- `Hover Focus` (`follow_mouse = 1`): cursor movement always changes focus to the window under the cursor.

Mode `3` is not exposed by this widget.

## Controls

| Input | Action |
| --- | --- |
| Left click | Open or close the mode selector |
| Right click | No action |
| Middle click | Refresh the current Hyprland value |

## Configuration Behavior

Selecting a mode applies `input:follow_mouse` immediately through Hyprland's
Lua runtime configuration. The change is made only after selecting a mode in
the widget.

The local installer manages the plugin directory and the named Hyprland module.
It overwrites `~/.config/hypr/mouse-focus.lua` and adds
`require("hypr.mouse-focus")` to `~/.config/hypr/input.lua` if it is not
already present. Use the local installer only if you want that managed module
to restore the setting after a Hyprland reload.

## Local Development

The repository includes an installer for local development. Run:

```bash
./install.sh
```

After editing the repository copy, rerun `./install.sh` to copy it into the
active Omarchy plugin directory.

## Remove

Remove the marketplace plugin with:

```bash
omarchy plugin remove jlord.mouse-focus
```

Then remove the widget entry from `~/.config/omarchy/shell.json` and remove the
Hyprland module require and file if they were installed manually or by the
local installer:

```bash
rm -f ~/.config/hypr/mouse-focus.lua
```

Remove this line from `~/.config/hypr/input.lua`:

```lua
require("hypr.mouse-focus")
```

For local development, `./uninstall.sh` removes the plugin directory, managed
Hyprland module, and the exact `require("hypr.mouse-focus")` line added to
`input.lua`. It does not edit `shell.json`.

## Dependencies

- Omarchy Quattro
- Hyprland with the `input:follow_mouse` option
- A user Hyprland input configuration that loads `hypr.mouse-focus`

## License

[MIT](LICENSE) © 2026 jlord
