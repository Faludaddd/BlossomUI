-- BlossomUI Delta executor example.
-- UI-only demonstration: no gameplay, remotes, targeting, automation, or exploits.

local SOURCE = "https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/BlossomUI_Executor.lua"
local loadLibrary = loadstring or load
assert(type(loadLibrary) == "function", "BlossomUI requires loadstring or load")

-- The library auto-mounts its original legacy-style window before returning it.
local window = loadLibrary(game:HttpGet(SOURCE))()
assert(window, "BlossomUI did not return a window; check the [BlossomUI] startup diagnostic")

-- The returned object follows the legacy window API.
window.toggle_menu(true)

-- Useful lifecycle call:
-- window:Destroy()

-- The UI itself contains the original tab/section controls plus the Settings
-- surface for profiles and theming. This example intentionally does not add
-- any game-affecting callbacks.
return window
