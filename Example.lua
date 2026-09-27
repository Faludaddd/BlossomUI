-- Blossom Delta example: UI/demo state only. No gameplay, remote, targeting, or automation logic.
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/Library_Blossom_Delta.lua"))()

local Window = Library:window({
    name = "Blossom",
    suffix = "",
    gameInfo = "Delta executor",
    size = UDim2.fromOffset(480, 395),
})

local Rage = Window:tab({name = "Rage", tabs = {"Combat", "Targeting"}})
local Combat = Rage:column({size = 0.5})
local Ragebot = Combat:section({name = "Ragebot", default = true, detachable = true})
Ragebot:toggle({name = "Enabled", flag = "rage_enabled", type = "toggle", default = true})
Ragebot:toggle({name = "Auto Shoot", flag = "auto_shoot", type = "toggle"})
Ragebot:toggle({name = "Auto Scope", flag = "auto_scope", type = "toggle"})
Ragebot:slider({name = "Min Damage", flag = "min_damage", min = 0, max = 100, default = 20, suffix = "%"})
Ragebot:slider({name = "Hitchance", flag = "hitchance", min = 0, max = 100, default = 75, suffix = "%"})
Ragebot:dropdown({name = "Target Selection", flag = "target_selection", items = {"Closest to Crosshair", "Lowest Health", "Distance"}, default = "Closest to Crosshair"})

local Silent = Combat:section({name = "Silent Aim", default = true, detachable = true})
Silent:toggle({name = "Enabled", flag = "silent_enabled", type = "toggle"})
Silent:toggle({name = "Use FOV", flag = "silent_fov", type = "toggle", default = true})
Silent:slider({name = "FOV Size", flag = "silent_fov_size", min = 1, max = 180, default = 90})
Silent:dropdown({name = "Aim Point", flag = "aim_point", items = {"Head", "Torso", "Random"}, default = "Head"})

local Legit = Window:tab({name = "Legit", tabs = {"Aim Assist"}})
local Aim = Legit:column({size = 1}):section({name = "Aim Assist", default = true, detachable = true})
Aim:toggle({name = "Enabled", flag = "assist_enabled", type = "toggle"})
Aim:slider({name = "Smoothness", flag = "smoothness", min = 1, max = 100, default = 27})
Aim:dropdown({name = "Hitpart", flag = "hitpart", items = {"Head", "Torso", "Random"}, default = "Head"})
Aim:toggle({name = "Visible Only", flag = "visible_only", type = "checkbox", default = true})

local Settings = Window:tab({name = "Settings", tabs = {"Profiles"}})
local SettingsColumn = Settings:column({size = 1})
local Profile = SettingsColumn:section({name = "Profiles", default = true, detachable = false})
Profile:textbox({name = "Config name", flag = "config_name_text", placeholder = "test.cfg"})
Profile:button({name = "Save UI config", callback = function() end})
Profile:button({name = "Load UI config", callback = function() end})
Profile:colorpicker({name = "Menu Accent", flag = "menu_accent", color = Color3.fromRGB(155, 150, 219)})

Window:toggle_menu(true)
Library.diagnostics.startup.example = true
Library.diagnostics.startup.note = "Delta UI demo loaded; gameplay logic intentionally absent"
