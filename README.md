# BlossomUI

A source-preserving reconstruction of the compact dark **Blossom** Roblox UI, targeted at the Delta executor. The canonical implementation remains structurally derived from the supplied original library: its window, tab, column, section, control, popup, theme, config, and notification APIs are preserved rather than replaced with a new architecture.

## Quick load: complete UI showcase

This is the ready-to-run full UI recreation. Paste this exact one-line loader into Delta:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/Example.lua"))()
```

[`Example.lua`](Example.lua) builds every evidence-supported page and state: Rage, Legit, Players, Effects, Movement, Exploits, Settings/Profiles, Settings/Theming, the observed control labels, two-column cards, detached Ragebot/Silent Aim/Targeting cards, config UI, theme presets, theme application notifications, and startup diagnostics.

The showcase is intentionally UI-only. All callbacks are harmless demo callbacks; no gameplay, targeting implementation, automation, remote invocation, or game-affecting logic is included.

## Canonical library for custom builders

Builders who want to compose their own UI should load the canonical source directly:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/Library_Blossom_Delta.lua"))()
```

Raw library URL: <https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/Library_Blossom_Delta.lua>

The complete example itself loads that canonical library URL, so the published `Library_Blossom_Delta.lua` remains the single source of the preserved implementation.

## Preserved API

- `Library:window(properties)` and `Window:toggle_menu(bool)`
- `Window:tab(properties)`, `Tab:column(properties)`, and `Column:section(properties)`
- `Section:toggle`, `slider`, `dropdown`, `colorpicker`, `textbox`, `keybind`, `button`, `label`, and `list`
- `Section:set_detached(bool)` for independently draggable cards
- `Library:apply_theme_preset(name)` for Blossom, Obsidian, Afterglow, Frostbite, Volt, Sakura Drift, Neon Mirage, Copper Dust, Abyss, and Porcelain
- `Library:init_config(window)`, `Library:get_config()`, `Library:load_config(json)`, and notification helpers

## Showcase coverage

The complete example intentionally mirrors the visible vocabulary and layout states from the supplied video:

| Page/state | Visible showcase content |
|---|---|
| Rage / Combat | Ragebot, Silent Aim, Anti Aim, Enabled, Auto Shoot, Auto Scope, Auto Reload, Force Headshot, Autowall, Min Damage, Hitchance, Target Selection, Max Distance, Use FOV, Draw FOV, FOV Size, Aim Point, Prediction, Prediction Amount, Pitch, Yaw, Spin Speed, Jitter Range, Fake Duck, Freestanding |
| Rage / Targeting | Targeting, Hitboxes, Ignore Teammates, Ignore Friends, Ignore Knifing, Visible Check, Baim If Lethal, Prefer Body When Airborne, plus detached-card support |
| Legit | Aim Assist, FOV, Smoothness, Hitpart, Visible Only, Team Check, Deadzone, Recoil Control, Vertical, Triggerbot, Reaction Delay, Magnet Trigger, Magnet FOV, Head Only, Misc, No Spread, Quickstop, Jump Check, Flash Check |
| Players | Players, Boxes, Names, Health, Distance, Box Style, Filters, Team Check, Visible Only, Show Friends, Max Distance |
| Effects | Effects, Glow, Ambient, Full Bright, Crosshair, Opacity, Colors, Accent, Glow Color, Render Mode |
| Movement | Speed, Speed Amount, Speed Type, WalkSpeed, Fly, Fly Speed, No Clip, Extras, Auto Peek, Edge Jump, Jump Bug, Jump Power |
| Bunny Hop | Enabled, Mode, Auto Strafe, Strafe Strength, No Slow, Jump Check, Air Duck |
| Exploits / Gun Mods | No Recoil, No Spread, Infinite Ammo, Rapid Fire, Fire Rate Multiplier, No Muzzle Flash |
| Exploits / Utility | Hitbox Expander, Hitbox Size, Grenade Teleport, Grenade Target, Silent Target, Killsay, `blossomed.` |
| Settings / Profiles | Configs, `test.cfg`, Config name, Create, Load, Delete, Overwrite, Autoload, Menu, Menu Bind, Accent |
| Settings / Theming | Theme, Blossom, Casing, Normal, Background, Tab, Outline, Inline, Text, Inactive Text, Accent, Element, Gradient, Shadow, Hovered Element, preset application notifications |

The example calls `Window:toggle_menu(true)` and records `Library.diagnostics.startup.example`, `example_pages`, and `note` after construction.

## What was repaired in the canonical library

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

### The full UI does not appear

Use the complete-example loader, not only the library loader:

`https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/Example.lua`

The library file only defines the API. `Example.lua` constructs the window, pages, cards, controls, themes, and diagnostics before calling `Window:toggle_menu(true)`.

### The loader returns an HTTP or raw-file error

Confirm Delta has network access and use this exact complete UI URL:

`https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/Example.lua`

For custom builders, use:

`https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/Library_Blossom_Delta.lua`

If GitHub is temporarily unavailable, open the repository URL in a browser and verify the files are visible on the `main` branch.

### Fonts or external assets do not load

The original library's font registration path uses Delta filesystem/custom-asset helpers. Allow the executor's filesystem and asset APIs, or use its common fallbacks. The UI remains source-compatible with common executor environments where those helpers are present.

### A config cannot be loaded

Use a config name containing letters, numbers, `_`, `-`, or `.`, and ensure the config was saved under the same Delta workspace. The settings helpers choose the explicit config textbox name first and otherwise use the selected config list entry.

## Evidence

The repository includes [`evidence/Blossom_video_reference_contact_sheet.jpg`](evidence/Blossom_video_reference_contact_sheet.jpg) plus timestamped stills used to compare combat, detached cards, dropdowns, color picker, settings, theme, utility, and movement states.
