-- Blossom Delta complete UI showcase.
-- This file demonstrates every evidence-supported page/state using UI controls only.
-- It intentionally contains no gameplay, targeting implementation, automation, remotes, or game-affecting logic.

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/Library_Blossom_Delta.lua"))()

local Window = Library:window({
    name = "Blossom",
    suffix = "",
    gameInfo = "Delta executor",
    size = UDim2.fromOffset(480, 395),
})

local function toggle(section, name, flag, default, kind)
    return section:toggle({name = name, flag = flag, type = kind or "toggle", default = default == true, callback = function() end})
end

local function slider(section, name, flag, min, max, default, suffix)
    return section:slider({name = name, flag = flag, min = min, max = max, default = default, suffix = suffix or "", callback = function() end})
end

local function dropdown(section, name, flag, items, default, callback)
    return section:dropdown({name = name, flag = flag, items = items, default = default, callback = callback or function() end})
end

local function harmless_button(section, name)
    return section:button({name = name, callback = function() end})
end

-- Combat > Rage: compact two-column opening state.
Window:seperator({name = "Combat"})
local Rage, Targeting = Window:tab({name = "Rage", tabs = {"Combat", "Targeting"}})
local RageLeft = Rage:column({size = 0.5})
local Ragebot = RageLeft:section({name = "Ragebot", default = true, detachable = true})
toggle(Ragebot, "Enabled", "rage_enabled", true)
toggle(Ragebot, "Auto Shoot", "auto_shoot", false)
toggle(Ragebot, "Auto Scope", "auto_scope", false)
toggle(Ragebot, "Auto Reload", "auto_reload", false)
toggle(Ragebot, "Force Headshot", "force_headshot", false)
toggle(Ragebot, "Autowall", "autowall", false)
slider(Ragebot, "Min Damage", "min_damage", 0, 100, 20, "%")
slider(Ragebot, "Hitchance", "hitchance", 0, 100, 75, "%")
dropdown(Ragebot, "Target Selection", "target_selection", {"Closest to Crosshair", "Lowest Health", "Distance"}, "Closest to Crosshair")
slider(Ragebot, "Max Distance", "max_distance", 0, 1000, 500, "u")

local SilentAim = RageLeft:section({name = "Silent Aim", default = true, detachable = true})
toggle(SilentAim, "Enabled", "silent_enabled", false)
toggle(SilentAim, "Use FOV", "silent_use_fov", true)
toggle(SilentAim, "Draw FOV", "silent_draw_fov", true)
slider(SilentAim, "FOV Size", "silent_fov_size", 1, 180, 90, "°")
dropdown(SilentAim, "Aim Point", "silent_aim_point", {"Head", "Torso", "Random"}, "Head")
toggle(SilentAim, "Prediction", "silent_prediction", true)
slider(SilentAim, "Prediction Amount", "prediction_amount", 0, 100, 12, "x")

local RageRight = Rage:column({size = 0.5})
local AntiAim = RageRight:section({name = "Anti Aim", default = true, detachable = true})
toggle(AntiAim, "Enabled", "anti_aim_enabled", false)
dropdown(AntiAim, "Pitch", "pitch", {"None", "Down", "Up", "Zero", "Random"}, "None")
dropdown(AntiAim, "Yaw", "yaw", {"Backward", "Spin", "Jitter", "Random"}, "Backward")
slider(AntiAim, "Spin Speed", "spin_speed", 0, 100, 35, "%")
slider(AntiAim, "Jitter Range", "jitter_range", 0, 180, 30, "°")
toggle(AntiAim, "Fake Duck", "fake_duck", false)
toggle(AntiAim, "Freestanding", "freestanding", false)

-- Combat > Targeting: rearranged and independently detachable cards.
local TargetLeft = Targeting:column({size = 0.5})
local TargetCard = TargetLeft:section({name = "Targeting", default = true, detachable = true})
dropdown(TargetCard, "Hitboxes", "hitboxes", {"Head, Torso", "Head", "Torso", "All"}, "Head, Torso")
toggle(TargetCard, "Ignore Teammates", "ignore_teammates", true)
toggle(TargetCard, "Ignore Friends", "ignore_friends", true)
toggle(TargetCard, "Ignore Knifing", "ignore_knifing", false)
toggle(TargetCard, "Visible Check", "visible_check", true)
toggle(TargetCard, "Baim If Lethal", "baim_if_lethal", false)
toggle(TargetCard, "Prefer Body When Airborne", "prefer_body_airborne", false)

local TargetRight = Targeting:column({size = 0.5})
local TargetAntiAim = TargetRight:section({name = "Anti Aim", default = true, detachable = true})
dropdown(TargetAntiAim, "Pitch", "target_pitch", {"None", "Down", "Up", "Zero", "Random"}, "None")
dropdown(TargetAntiAim, "Yaw", "target_yaw", {"Backward", "Spin", "Jitter", "Random"}, "Backward")
slider(TargetAntiAim, "Spin Speed", "target_spin_speed", 0, 100, 35, "%")
slider(TargetAntiAim, "Jitter Range", "target_jitter_range", 0, 180, 30, "°")
toggle(TargetAntiAim, "Fake Duck", "target_fake_duck", false)
toggle(TargetAntiAim, "Freestanding", "target_freestanding", false)

-- Legit page: aim assist, recoil control, triggerbot, and misc rows.
Window:seperator({name = "Legit"})
local Legit = Window:tab({name = "Legit", tabs = {"Aim Assist"}})
local LegitLeft = Legit:column({size = 0.5})
local AimAssist = LegitLeft:section({name = "Aim Assist", default = true, detachable = true})
toggle(AimAssist, "Enabled", "assist_enabled", false)
toggle(AimAssist, "Draw FOV", "assist_draw_fov", false)
slider(AimAssist, "FOV", "assist_fov", 1, 180, 32, "°")
slider(AimAssist, "Smoothness", "smoothness", 1, 100, 27, "%")
dropdown(AimAssist, "Hitpart", "hitpart", {"Head", "Torso", "Random"}, "Head")
toggle(AimAssist, "Visible Only", "visible_only", true)
toggle(AimAssist, "Team Check", "team_check", true)
slider(AimAssist, "Deadzone", "deadzone", 0, 100, 8, "%")

local Recoil = LegitLeft:section({name = "Recoil Control", default = true, detachable = true})
toggle(Recoil, "Enabled", "recoil_enabled", false)
slider(Recoil, "Vertical", "recoil_vertical", 0, 100, 20, "%")
slider(Recoil, "Horizontal", "recoil_horizontal", 0, 100, 10, "%")

local Trigger = Legit:column({size = 0.5}):section({name = "Triggerbot", default = true, detachable = true})
toggle(Trigger, "Enabled", "trigger_enabled", false)
slider(Trigger, "Reaction Delay", "reaction_delay", 0, 250, 50, "ms")
toggle(Trigger, "Magnet Trigger", "magnet_trigger", false)
slider(Trigger, "Magnet FOV", "magnet_fov", 1, 180, 20, "°")
toggle(Trigger, "Head Only", "head_only", false)

local LegitMisc = Legit:column({size = 0.5}):section({name = "Misc", default = true, detachable = true})
toggle(LegitMisc, "No Spread", "legit_no_spread", false, "checkbox")
toggle(LegitMisc, "Quickstop", "quickstop", false, "checkbox")
toggle(LegitMisc, "Jump Check", "jump_check", true, "checkbox")
toggle(LegitMisc, "Flash Check", "flash_check", true, "checkbox")

-- Visuals > Players and Effects.
Window:seperator({name = "Visuals"})
local PlayersPage = Window:tab({name = "Players", tabs = {"Players"}})
local PlayerVisuals = PlayersPage:column({size = 0.5}):section({name = "Players", default = true, detachable = true})
toggle(PlayerVisuals, "Enabled", "players_enabled", true)
toggle(PlayerVisuals, "Boxes", "player_boxes", false)
toggle(PlayerVisuals, "Names", "player_names", true)
toggle(PlayerVisuals, "Health", "player_health", true)
toggle(PlayerVisuals, "Distance", "player_distance", false)
dropdown(PlayerVisuals, "Box Style", "box_style", {"2D", "Corner", "Filled"}, "2D")

local PlayerFilters = PlayersPage:column({size = 0.5}):section({name = "Filters", default = true, detachable = true})
toggle(PlayerFilters, "Team Check", "visual_team_check", true)
toggle(PlayerFilters, "Visible Only", "visual_visible_only", false)
toggle(PlayerFilters, "Show Friends", "show_friends", true)
slider(PlayerFilters, "Max Distance", "visual_max_distance", 0, 1000, 500, "u")

local EffectsPage = Window:tab({name = "Effects", tabs = {"Effects"}})
local WorldEffects = EffectsPage:column({size = 0.5}):section({name = "Effects", default = true, detachable = true})
toggle(WorldEffects, "Enabled", "effects_enabled", true)
toggle(WorldEffects, "Glow", "glow", false)
toggle(WorldEffects, "Ambient", "ambient", false)
toggle(WorldEffects, "Full Bright", "full_bright", false)
toggle(WorldEffects, "Crosshair", "crosshair", true)
slider(WorldEffects, "Opacity", "effects_opacity", 0, 100, 80, "%")

local WorldColors = EffectsPage:column({size = 0.5}):section({name = "Colors", default = true, detachable = true})
WorldColors:colorpicker({name = "Accent", flag = "effects_accent", color = Color3.fromRGB(155, 150, 219), callback = function() end})
WorldColors:colorpicker({name = "Glow Color", flag = "glow_color", color = Color3.fromRGB(155, 150, 219), callback = function() end})
dropdown(WorldColors, "Render Mode", "render_mode", {"Normal", "Flat", "Outline"}, "Normal")

-- Player > Movement and Bunny Hop.
Window:seperator({name = "Player"})
local Movement, BunnyHop = Window:tab({name = "Movement", tabs = {"Movement", "Bunny Hop"}})
local MoveCard = Movement:column({size = 0.5}):section({name = "Movement", default = true, detachable = true})
toggle(MoveCard, "Speed", "speed", false)
slider(MoveCard, "Speed Amount", "speed_amount", 1, 100, 16, "u/s")
dropdown(MoveCard, "Speed Type", "speed_type", {"WalkSpeed", "CFrame", "Velocity"}, "WalkSpeed")
toggle(MoveCard, "Fly", "fly", false)
slider(MoveCard, "Fly Speed", "fly_speed", 1, 100, 16, "u/s")
toggle(MoveCard, "No Clip", "no_clip", false)

local MoveExtras = Movement:column({size = 0.5}):section({name = "Extras", default = true, detachable = true})
toggle(MoveExtras, "Auto Peek", "auto_peek", false)
toggle(MoveExtras, "Edge Jump", "edge_jump", false)
toggle(MoveExtras, "Jump Bug", "jump_bug", false)
slider(MoveExtras, "Jump Power", "jump_power", 1, 100, 50, "%")

local HopCard = BunnyHop:column({size = 0.5}):section({name = "Bunny Hop", default = true, detachable = true})
toggle(HopCard, "Enabled", "bhop_enabled", false)
dropdown(HopCard, "Mode", "bhop_mode", {"Legit", "Perfect", "Auto"}, "Legit")
toggle(HopCard, "Auto Strafe", "auto_strafe", false)
slider(HopCard, "Strafe Strength", "strafe_strength", 0, 100, 50, "%")

local HopMisc = BunnyHop:column({size = 0.5}):section({name = "Bunny Hop Misc", default = true, detachable = true})
toggle(HopMisc, "No Slow", "bhop_no_slow", false)
toggle(HopMisc, "Jump Check", "bhop_jump_check", true)
toggle(HopMisc, "Air Duck", "air_duck", false)

-- Exploits is presented as harmless visual/demo controls only.
Window:seperator({name = "Exploits"})
local GunMods, Utility = Window:tab({name = "Exploits", tabs = {"Gun Mods", "Utility"}})
local GunCard = GunMods:column({size = 0.5}):section({name = "Gun Mods", default = true, detachable = true})
toggle(GunCard, "No Recoil", "gun_no_recoil", false)
toggle(GunCard, "No Spread", "gun_no_spread", false)
toggle(GunCard, "Infinite Ammo", "infinite_ammo", false)
toggle(GunCard, "Rapid Fire", "rapid_fire", false)
slider(GunCard, "Fire Rate Multiplier", "fire_rate_multiplier", 1, 10, 1, "x")
toggle(GunCard, "No Muzzle Flash", "no_muzzle_flash", false)

local UtilityCard = GunMods:column({size = 0.5}):section({name = "Utility", default = true, detachable = true})
toggle(UtilityCard, "Hitbox Expander", "hitbox_expander", false)
slider(UtilityCard, "Hitbox Size", "hitbox_size", 1, 20, 2, "u")
toggle(UtilityCard, "Grenade Teleport", "grenade_teleport", false)
toggle(UtilityCard, "Grenade Target", "grenade_target", false)
toggle(UtilityCard, "Silent Target", "silent_target", false)
harmless_button(UtilityCard, "Killsay")
UtilityCard:label({name = "blossomed.", seperator = false})

local UtilityLeft = Utility:column({size = 0.5}):section({name = "Utility", default = true, detachable = true})
toggle(UtilityLeft, "Hitbox Expander", "utility_hitbox_expander", false)
slider(UtilityLeft, "Hitbox Size", "utility_hitbox_size", 1, 20, 2, "u")
toggle(UtilityLeft, "Grenade Teleport", "utility_grenade_teleport", false)
toggle(UtilityLeft, "Silent Target", "utility_silent_target", false)

local UtilityRight = Utility:column({size = 0.5}):section({name = "Actions", default = true, detachable = true})
harmless_button(UtilityRight, "Killsay")
UtilityRight:label({name = "blossomed.", seperator = false})

-- Settings > Profiles and Theming reproduce the distinct settings states.
Window:seperator({name = "Settings"})
local Profiles, Theming = Window:tab({name = "Settings", tabs = {"Profiles", "Theming"}})
local ConfigCard = Profiles:column({size = 0.5}):section({name = "Configs", default = true, detachable = false})
ConfigCard:list({options = {"test.cfg"}, flag = "config_name_list", callback = function() end})
ConfigCard:textbox({name = "Config name", flag = "config_name_text", placeholder = "test.cfg", default = "test.cfg"})
harmless_button(ConfigCard, "Create")
harmless_button(ConfigCard, "Load")
harmless_button(ConfigCard, "Delete")
harmless_button(ConfigCard, "Overwrite")

local MenuCard = Profiles:column({size = 0.5}):section({name = "Menu", default = true, detachable = false})
toggle(MenuCard, "Autoload", "autoload", false)
toggle(MenuCard, "Menu", "menu_enabled", true)
MenuCard:keybind({name = "Menu Bind", flag = "menu_bind", default = false, callback = function() end})
MenuCard:colorpicker({name = "Accent", flag = "profile_accent", color = Color3.fromRGB(155, 150, 219), callback = function() end})

local ThemeCard = Theming:column({size = 0.5}):section({name = "Theming", default = true, detachable = true})
dropdown(ThemeCard, "Theme", "theme", {"Blossom", "Obsidian", "Afterglow", "Frostbite", "Volt", "Sakura Drift", "Neon Mirage", "Copper Dust", "Abyss", "Porcelain"}, "Blossom", function(name)
    Library:apply_theme_preset(name)
end)
dropdown(ThemeCard, "Casing", "casing", {"Normal", "Lower", "Upper"}, "Normal")
ThemeCard:label({name = "Background", seperator = false})
ThemeCard:colorpicker({name = "Tab", flag = "theme_tab", color = Color3.fromRGB(22, 22, 24), callback = function() end})
ThemeCard:colorpicker({name = "Outline", flag = "theme_outline", color = Color3.fromRGB(25, 25, 29), callback = function() end})
ThemeCard:colorpicker({name = "Inline", flag = "theme_inline", color = Color3.fromRGB(22, 22, 24), callback = function() end})
ThemeCard:colorpicker({name = "Text", flag = "theme_text", color = Color3.fromRGB(245, 245, 245), callback = function() end})
ThemeCard:colorpicker({name = "Inactive Text", flag = "theme_inactive_text", color = Color3.fromRGB(72, 72, 73), callback = function() end})
ThemeCard:colorpicker({name = "Accent", flag = "theme_accent", color = Color3.fromRGB(155, 150, 219), callback = function(color) Library:update_theme("accent", color) end})
ThemeCard:colorpicker({name = "Element", flag = "theme_element", color = Color3.fromRGB(33, 33, 35), callback = function() end})
ThemeCard:colorpicker({name = "Gradient", flag = "theme_gradient", color = Color3.fromRGB(211, 211, 211), callback = function() end})
ThemeCard:colorpicker({name = "Shadow", flag = "theme_shadow", color = Color3.fromRGB(0, 0, 0), callback = function() end})
ThemeCard:colorpicker({name = "Hovered Element", flag = "theme_hovered", color = Color3.fromRGB(44, 44, 46), callback = function() end})

-- Startup visibility and diagnostics are explicit for Delta.
Window:toggle_menu(true)
Library.diagnostics.startup.example = true
Library.diagnostics.startup.example_pages = {"Rage", "Legit", "Players", "Effects", "Movement", "Exploits", "Settings/Profiles", "Settings/Theming"}
Library.diagnostics.startup.note = "Complete Blossom UI showcase loaded in Delta; all callbacks are UI/demo-only"
