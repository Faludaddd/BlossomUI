-- BlossomUI Delta executor example.
-- This file is intentionally UI-only: it demonstrates loading and interacting
-- with the library, without gameplay, remotes, targeting, automation, or exploits.

local SOURCE = "https://raw.githubusercontent.com/Faludaddd/BlossomUI/main/BlossomUI_Executor.lua"
local loadLibrary = loadstring or load
assert(type(loadLibrary) == "function", "BlossomUI requires loadstring or load")

local app = loadLibrary(game:HttpGet(SOURCE))()
app = app or BlossomUIApp
assert(app, "BlossomUI did not return an app handle; check the executor diagnostic")

-- The script auto-mounts on load. These calls demonstrate the public surface.
app:SelectPage("Rage")
app:Notify({
    Title = "Example",
    Text = "BlossomUI loaded successfully.",
})

-- Uncomment to demonstrate the recorded detached-card state:
-- app:ShowDetachedCombat()

-- Other useful calls:
-- app:SetTheme("Obsidian")
-- app:SelectPage("Settings")
-- app:ShowCompactCombat()
-- app:Toggle()
-- app:Destroy()

return app
