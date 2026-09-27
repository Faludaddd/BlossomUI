# BlossomUI

A Delta-compatible, UI-only Roblox Lua library based on the supplied legacy `Library.lua.txt` source and reconstructed against the reference video. This build preserves the legacy visual architecture instead of replacing it with a separate widget system:

`window → tab → sub-tab → column → section → control`

It retains the original compact 700×565 shell, 196 px navigation rail, title/footer treatment, dark palette, accent tracking, rounded section cards, tab transitions, dropdown popovers, color picker, keybind, list, textbox, slider, toggle, button, notification, and drag/resize behaviors.

It contains no gameplay exploit logic, remotes, targeting, automation, or game-affecting behavior.

## Delta load

Execute the complete script directly:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/BlossomUI_Executor.lua"))()
```

The script waits for the game/player, mounts automatically, and exposes:

- `BlossomUI` — the legacy library table
- `BlossomUIApp` — the mounted legacy-style window object

Re-execution destroys the previous app and removes same-name `BlossomUI` GUI remnants before mounting again.

## Example

[`Example.lua`](Example.lua) demonstrates the intended clean load/use pattern:

```lua
local window = loadstring(game:HttpGet("https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/BlossomUI_Executor.lua"))()
window.toggle_menu(true)
```

The window is already visible after load. Its original public construction API remains available for extensions:

```lua
local library = BlossomUI
local extraTab = window:tab({name = "Extra", tabs = {"Main"}})
local column = extraTab:column({size = 1})
local section = column:section({name = "Example", default = true})
section:toggle({name = "UI-only option"})
section:slider({name = "Amount", min = 0, max = 100, default = 50})
section:dropdown({name = "Mode", items = {"One", "Two"}, default = "One"})
```

Lifecycle calls include `window.toggle_menu(true/false)`, `window:Destroy()`, and `BlossomUI:unload_menu()`.

## Delta compatibility repairs

The original constructors and styling are retained, while executor-sensitive pieces were repaired:

- Classic Lua syntax: no type annotations, casts, generic types, `continue`, `:Once`, `task.delay`, compound assignments, or `UIFlexAlignment`.
- Standard Roblox fonts are used instead of mandatory custom-font filesystem/download setup.
- GUI parent fallback: `gethui()` → `CoreGui` → the original Roblox CoreGui path.
- Guarded common protection helpers: `syn.protect_gui`, `protect_gui`, and `protectgui`.
- Automatic game/player readiness and guarded startup diagnostics beginning with `[BlossomUI] startup failed:`.
- Duplicate cleanup for the previous active app and named `BlossomUI`/`BlossomUI_Overlays` ScreenGuis.
- The original config/file code is not called during auto-mount; the visible Settings surface uses UI-only demonstration callbacks, so filesystem APIs are not required to start the UI.

## Troubleshooting

If Delta shows no UI, execute the entire raw file directly rather than only a returned fragment and check the executor console for `[BlossomUI] startup failed:`. Delta builds differ in `gethui`, CoreGui access policy, GUI protection, HTTP/loadstring behavior, Unicode glyph rendering, and input routing. Those remain executor-specific uncertainties; the UI does not depend on remotes or game-state services.

The main window and legacy card elements use the original drag/resize paths. If pointer input is blocked by a particular Delta build, test without GUI protection first; protection helpers are optional and guarded.
