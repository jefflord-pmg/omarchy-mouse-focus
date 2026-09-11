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

Marketplace installation does not modify your Hyprland configuration by
default. Selecting a mode in the widget is an explicit action that applies the
selected `input:follow_mouse` value to the running Hyprland session.

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
| Persist toggle | Opt in to saving the selected mode in Hyprland configuration files |

## Configuration Behavior

Selecting a mode applies `input:follow_mouse` immediately through Hyprland's
Lua runtime configuration. The change is made only after selecting a mode in
the widget.

Persistence is disabled by default. Enabling `Persist` in the selector is
explicit consent for the plugin to manage these two files:

- `~/.config/hypr/mouse-focus.lua`, containing the selected mode
- `~/.config/hypr/input.lua`, containing `require("hypr.mouse-focus")`

While enabled, selecting another mode updates the managed module as well as
the running Hyprland setting. Turning persistence off stops future writes but
does not remove the files or require line.

The local and marketplace installers both leave persistence disabled. Use the
`Persist` toggle when you want the plugin to manage these files.

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

Then remove the widget entry from `~/.config/omarchy/shell.json`. If you
enabled `Persist`, also remove the managed Hyprland file:

```bash
rm -f ~/.config/hypr/mouse-focus.lua
```

Remove this line from `~/.config/hypr/input.lua`:

```lua
require("hypr.mouse-focus")
```

Remove the matching `require("hypr.mouse-focus")` line from
`~/.config/hypr/input.lua` if persistence was enabled. For local development,
`./uninstall.sh` removes the plugin directory but does not remove persisted
Hyprland files or edit `shell.json`.

## Dependencies

- Omarchy Quattro
- Hyprland with the `input:follow_mouse` option

## License

[MIT](LICENSE) © 2026 jlord
