# BlossomUI

A compact, UI-only Roblox Lua library reconstructed from the supplied Blossom reference video. It is designed to run as a standalone script through Roblox Lua executors, including Delta. It contains no gameplay exploit logic, remotes, targeting, automation, or game-affecting behavior.

## Delta load

Execute the complete script with:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/BlossomUI_Executor.lua"))()
```

The executor script automatically waits for the game/player, mounts the UI, and exposes:

- `BlossomUI` — library table
- `BlossomUIApp` — active UI instance

Re-running the script removes the previous app and same-name GUI before mounting a replacement.

## Example

See [`Example.lua`](Example.lua) for a clean load/use pattern modeled conceptually after common executor UI-library examples.

```lua
local app = loadstring(game:HttpGet("https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/BlossomUI_Executor.lua"))()
app:SelectPage("Settings")
app:SetTheme("Obsidian")
app:ShowDetachedCombat()
app:Notify({Title = "Ready", Text = "BlossomUI is running."})
```

## API

| Call | Purpose |
|---|---|
| `BlossomUIApp:SelectPage(name)` | Select `Rage`, `Legit`, `Players`, `Effects`, `Movement`, `Exploits`, or `Settings`. |
| `BlossomUIApp:ShowDetachedCombat()` | Show independently draggable Ragebot, Silent Aim, and Targeting cards. |
| `BlossomUIApp:ShowCompactCombat()` | Return combat cards to the compact layout. |
| `BlossomUIApp:SetTheme(name)` | Apply Blossom, Obsidian, Volt, Frostbite, Afterglow, Sakura Drift, Neon Mirage, Copper Dust, Abyss, or Porcelain. |
| `BlossomUIApp:Notify(options)` | Show a timed notification; use `{Title = "...", Text = "...", Lifetime = 3}`. |
| `BlossomUIApp:Toggle()` | Toggle visibility. |
| `BlossomUIApp:Destroy()` | Disconnect inputs and remove the UI. |

The library also exposes reusable control builders for custom UI extensions: `AddPage`, `AddCard`, `AddToggle`, `AddCheckbox`, `AddSlider`, `AddDropdown`, `AddColorPicker`, `AddTextbox`, and `AddButton`.

## Compatibility and troubleshooting

The script uses parser-conservative classic Lua syntax: no type annotations, generics, union types, casts, `:Once`, `task.delay`, `table.find`, compound assignments, or newer layout-only APIs. It tries GUI parents in this order: `gethui()`, `CoreGui`, then `PlayerGui`. It tries `syn.protect_gui`, `protect_gui`, and `protectgui` independently and continues without protection if unavailable.

If Delta shows no UI, execute the complete file directly and check the executor console for `[BlossomUI] startup failed:`. The automatic mount is wrapped in `pcall`, so runtime construction errors should be visible through `warn` or `print`. Delta builds can differ in `gethui`, CoreGui access, GUI protection, Unicode glyph rendering, and HTTP/loadstring behavior; those are executor-specific caveats, not library gameplay dependencies.

Profiles/config controls are UI-only demonstrations and do not require filesystem APIs. The library does not call `writefile`, `readfile`, `makefolder`, remotes, or game-affecting services.
