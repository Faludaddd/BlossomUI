# BlossomUI

A source-preserving reconstruction of the compact dark **Blossom** Roblox UI library, targeted at the Delta executor. The canonical implementation remains structurally derived from the supplied original library: its window, tab, column, section, control, popup, theme, config, and notification APIs are preserved rather than replaced with a new architecture.

## Quick load

Paste this exact one-line loader into Delta:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/Library_Blossom_Delta.lua"))()
```

The canonical source is [`Library_Blossom_Delta.lua`](Library_Blossom_Delta.lua). The ready-to-run UI-only example is [`Example.lua`](Example.lua).

## Delta usage

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/Library_Blossom_Delta.lua"))()

local Window = Library:window({
    name = "Blossom",
    suffix = "",
    gameInfo = "Delta executor",
    size = UDim2.fromOffset(480, 395),
})

local Rage = Window:tab({name = "Rage", tabs = {"Combat", "Targeting"}})
local Column = Rage:column({size = 1})
local Card = Column:section({name = "Ragebot", default = true, detachable = true})
Card:toggle({name = "Enabled", flag = "enabled", type = "toggle", default = true})
Card:slider({name = "Hitchance", flag = "hitchance", min = 0, max = 100, default = 75, suffix = "%"})
Card:dropdown({name = "Aim Point", flag = "aim_point", items = {"Head", "Torso", "Random"}, default = "Head"})
```

This repository contains UI primitives and demo state only. It intentionally does **not** include gameplay exploit, targeting implementation, automation, remote invocation, or game-affecting logic.

## Preserved API

- `Library:window(properties)` and `Window:toggle_menu(bool)`
- `Window:tab(properties)`, `Tab:column(properties)`, `Column:section(properties)`
- `Section:toggle`, `slider`, `dropdown`, `colorpicker`, `textbox`, `keybind`, `button`, and `label`
- `Section:set_detached(bool)` for independently draggable cards
- `Library:apply_theme_preset(name)` for Blossom, Obsidian, Afterglow, Frostbite, Volt, Sakura Drift, Neon Mirage, Copper Dust, Abyss, and Porcelain
- `Library:init_config(window)`, `Library:get_config()`, `Library:load_config(json)`, and notification helpers

## What was repaired

The rebuild keeps the original dark charcoal surfaces, compact rail/content proportions, Inter font path, rounded section hierarchy, control primitives, animations, popovers, and theme propagation. Concrete repairs include:

- Initializes the hidden page cache before cached pages are parented.
- Repairs explicit `false`/`0` defaults and separator/visibility handling.
- Fixes config-name precedence and sanitizes config paths.
- Makes main-window dragging reliable across mouse/touch release paths and clamps it to the viewport.
- Adds detachable/draggable section cards.
- Creates the missing settings fade target and improves popup cleanup.
- Adds observed theme presets and `Applied "…" theme.` notifications.
- Cleans expired notification stack entries and refreshes remaining positions.

## Troubleshooting

### The loader returns an HTTP or raw-file error

Confirm Delta has network access and that this exact URL is used:

`https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/Library_Blossom_Delta.lua`

If GitHub is temporarily unavailable, open the repository URL in a browser and verify that `Library_Blossom_Delta.lua` is visible on the `main` branch.

### The UI does not appear

The library creates its ScreenGuis under `CoreGui`, which is required by the executor context. Run the loader from Delta after joining a Roblox experience, and check `Library.diagnostics.startup` in the returned library object.

### Fonts or external assets do not load

The original library's font registration path uses Delta filesystem/custom-asset helpers. Allow the executor's filesystem and asset APIs, or use its common fallbacks. The UI remains source-compatible with common executor environments where those helpers are present.

### A config cannot be loaded

Use a config name containing letters, numbers, `_`, `-`, or `.`, and ensure the config was saved under the same Delta workspace. The settings helpers now choose the explicit config textbox name first and otherwise use the selected config list entry.

## Evidence

The reconstruction report and representative video-state references are included in the original working deliverables. The repository includes [`evidence/Blossom_video_reference_contact_sheet.jpg`](evidence/Blossom_video_reference_contact_sheet.jpg) plus timestamped stills used to compare combat, detached cards, dropdowns, color picker, settings, theme, utility, and movement states.
