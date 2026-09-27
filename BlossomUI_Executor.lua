-- BlossomUI.lua
-- Standalone executor-compatible, evidence-aligned Roblox/Luau UI script.
-- UI only: no gameplay, exploit, targeting, automation, or game-state logic.
--
-- Load pattern (recommended): execute this whole file with loadstring or paste it
-- into the executor. It creates a global `BlossomUIApp` handle automatically.
--   loadstring(game:HttpGet("your-approved-host/BlossomUI.lua"))()
--   BlossomUIApp:Notify({Title = "Hello", Text = "World"})
--   BlossomUIApp:SetTheme("Obsidian")
--   BlossomUIApp:Destroy()
--
-- The returned value is also the app handle for executors that preserve returns.
-- `BlossomUI` is exposed globally as the library table.
--   app:Notify({Title = "Hello", Text = "World"})
--   app:SetTheme("Obsidian")
--   app:Destroy()
--
-- app.Window methods:
--   :SelectPage(name), :AddPage(name, icon), :AddCard(title, opts)
--   :ShowDetachedCombat(), :ShowCompactCombat(), :Toggle(), :Destroy()
--
-- Optional executor APIs are detected and guarded. The UI falls back to PlayerGui
-- when gethui/CoreGui/protection helpers are unavailable.

pcall(function() if not game:IsLoaded() then game.Loaded:Wait() end end)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	repeat wait() LocalPlayer = Players.LocalPlayer until LocalPlayer
end

local function getGlobalEnvironment()
	local ok, environment = pcall(function()
		if type(getgenv) == "function" then return getgenv() end
		return _G
	end)
	return (ok and type(environment) == "table" and environment) or _G
end

local GlobalEnvironment = getGlobalEnvironment()
local GLOBAL_STATE_KEY = "__BLOSSOM_UI_EXECUTOR_STATE"
local DEFAULT_GUI_NAME = "BlossomUI"

local function protectGui(gui)
	local candidates = {
		function() if type(syn) == "table" and type(syn.protect_gui) == "function" then syn.protect_gui(gui); return true end end,
		function() if type(protect_gui) == "function" then protect_gui(gui); return true end end,
		function() if type(protectgui) == "function" then protectgui(gui); return true end end,
	}
	for _, candidate in ipairs(candidates) do
		local ok, protected = pcall(candidate)
		if ok and protected then return true end
	end
	return false
end

local function chooseParent(requested)
	if requested then return requested end
	local ok, hidden = pcall(function()
		if type(gethui) == "function" then return gethui() end
	end)
	if ok and hidden then return hidden end
	local okCore, core = pcall(function() return game:GetService("CoreGui") end)
	if okCore and core then return core end
	if LocalPlayer then
		local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		if playerGui then return playerGui end
		local waited = LocalPlayer:WaitForChild("PlayerGui", 5)
		if waited then return waited end
	end
	return game:GetService("CoreGui")
end

local function destroyPreviousInstance()
	local previous = GlobalEnvironment[GLOBAL_STATE_KEY]
	if type(previous) == "table" and previous.App and type(previous.App.Destroy) == "function" then
		pcall(function() previous.App:Destroy() end)
	elseif type(previous) == "table" and previous.Gui and previous.Gui.Parent then
		pcall(function() previous.Gui:Destroy() end)
	end
	GlobalEnvironment[GLOBAL_STATE_KEY] = nil
end

local Blossom = {}
Blossom.__index = Blossom

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

local function ud(x, y)
	return UDim2.fromOffset(x, y)
end

local function clamp(n, lo, hi)
	return math.max(lo, math.min(hi, n))
end

local function safeParent(parent)
	return chooseParent(parent)
end

local function textBounds(text)
	return math.max(20, text.TextBounds.Y + 8)
end

local Themes = {
	Blossom = {
		Background = rgb(14, 14, 16), Tab = rgb(21, 21, 23), Outline = rgb(25, 25, 29),
		Inline = rgb(22, 22, 24), Text = rgb(245, 245, 245), InactiveText = rgb(112, 112, 114),
		Accent = rgb(155, 150, 219), Element = rgb(33, 33, 35), Gradient = rgb(58, 58, 62),
		Shadow = rgb(0, 0, 0), Hovered = rgb(140, 140, 142), Separator = rgb(36, 36, 37),
	},
	Obsidian = {
		Background = rgb(13, 13, 15), Tab = rgb(19, 19, 22), Outline = rgb(27, 27, 32),
		Inline = rgb(21, 21, 25), Text = rgb(244, 244, 246), InactiveText = rgb(108, 108, 116),
		Accent = rgb(172, 150, 238), Element = rgb(30, 30, 36), Gradient = rgb(54, 54, 63),
		Shadow = rgb(0, 0, 0), Hovered = rgb(148, 136, 184), Separator = rgb(40, 40, 47),
	},
	Volt = {
		Background = rgb(14, 14, 16), Tab = rgb(22, 22, 22), Outline = rgb(31, 29, 25),
		Inline = rgb(25, 23, 20), Text = rgb(245, 243, 238), InactiveText = rgb(125, 119, 110),
		Accent = rgb(237, 151, 77), Element = rgb(42, 34, 27), Gradient = rgb(78, 58, 39),
		Shadow = rgb(0, 0, 0), Hovered = rgb(208, 138, 78), Separator = rgb(54, 43, 33),
	},
	Frostbite = {
		Background = rgb(13, 16, 19), Tab = rgb(19, 24, 28), Outline = rgb(29, 38, 43),
		Inline = rgb(22, 29, 34), Text = rgb(239, 247, 250), InactiveText = rgb(116, 137, 146),
		Accent = rgb(116, 200, 232), Element = rgb(29, 40, 45), Gradient = rgb(54, 76, 84),
		Shadow = rgb(0, 0, 0), Hovered = rgb(133, 207, 229), Separator = rgb(39, 52, 58),
	},
	Afterglow = {
		Background = rgb(16, 13, 14), Tab = rgb(25, 19, 20), Outline = rgb(39, 28, 27),
		Inline = rgb(29, 22, 22), Text = rgb(247, 239, 233), InactiveText = rgb(142, 117, 107),
		Accent = rgb(238, 120, 67), Element = rgb(46, 30, 25), Gradient = rgb(83, 50, 38),
		Shadow = rgb(0, 0, 0), Hovered = rgb(220, 124, 84), Separator = rgb(58, 39, 34),
	},
	SakuraDrift = {Accent = rgb(231, 137, 178)},
	NeonMirage = {Accent = rgb(91, 220, 199)},
	CopperDust = {Accent = rgb(192, 128, 76)},
	Abyss = {Accent = rgb(76, 115, 190)},
	Porcelain = {Accent = rgb(206, 213, 219)},
}

local function normalizedTheme(name)
	local base = Themes.Blossom
	local source = Themes[name] or base
	local out = {}
	for key, value in pairs(base) do
		out[key] = source[key] or value
	end
	return out
end

local function make(className, props, parent)
	local object = Instance.new(className)
	for key, value in pairs(props) do
		(object)[key] = value
	end
	if parent then object.Parent = parent end
	return object
end

local function corner(parent, radius)
	make("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function stroke(parent, color, transparency)
	make("UIStroke", {Color = color, Transparency = transparency or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, parent)
end

local function label(parent, text, size, color, props)
	local p = {
		BackgroundTransparency = 1, Text = text, TextColor3 = color, TextSize = size,
		Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center, AutomaticSize = Enum.AutomaticSize.None,
	}
	if props then for k, v in pairs(props) do p[k] = v end end
	return make("TextLabel", p, parent)
end

local function tween(object, properties, duration, style)
	local t = TweenService:Create(object, TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), properties)
	t:Play()
	return t
end

local function setVisibleAnimated(object, visible, size, duration)
	if visible then
		object.Visible = true
		tween(object, {Size = size}, duration or 0.25)
	else
		tween(object, {Size = UDim2.fromOffset(size.X.Offset, 0)}, duration or 0.2).Completed:Connect(function()
			object.Visible = false
		end)
	end
end

local function bindDrag(handle, target, bounds, cleanup)
	local dragging = false
	local dragStart = Vector2.new(0, 0)
	local startPosition = target.Position
	local inputConnection

	local function stop()
		dragging = false
		if inputConnection then inputConnection:Disconnect(); inputConnection = nil end
	end

	table.insert(cleanup, handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging = true
		dragStart = Vector2.new(input.Position.X, input.Position.Y)
		startPosition = target.Position
		if inputConnection then inputConnection:Disconnect() end
		inputConnection = UserInputService.InputChanged:Connect(function(changed)
			if not dragging then return end
			if changed.UserInputType ~= Enum.UserInputType.MouseMovement and changed.UserInputType ~= Enum.UserInputType.Touch then return end
			local delta = Vector2.new(changed.Position.X, changed.Position.Y) - dragStart
			local maxX = bounds and math.max(0, bounds.AbsoluteSize.X - target.AbsoluteSize.X) or math.huge
			local maxY = bounds and math.max(0, bounds.AbsoluteSize.Y - target.AbsoluteSize.Y) or math.huge
			local x = clamp(startPosition.X.Offset + delta.X, 0, maxX)
			local y = clamp(startPosition.Y.Offset + delta.Y, 0, maxY)
			tween(target, {Position = UDim2.fromOffset(x, y)}, 0.05, Enum.EasingStyle.Linear)
		end)
	end))
	table.insert(cleanup, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then stop() end
	end))
end

local Window = {}
Window.__index = Window

function Window:_track(connection)
	table.insert(self._connections, connection)
	return connection
end

function Window:_style(object, token)
	self._styled[object] = token
	object.BackgroundColor3 = self.Theme[token]
end

function Window:_refreshTheme()
	for object, token in pairs(self._styled) do
		if object.Parent then object.BackgroundColor3 = self.Theme[token] end
	end
	for object, token in pairs(self._textStyled) do
		if object.Parent then object.TextColor3 = self.Theme[token] end
	end
	for object, token in pairs(self._imageStyled) do
		if object.Parent then object.ImageColor3 = self.Theme[token] end
	end
end

function Window:_textStyle(object, token)
	self._textStyled[object] = token
	object.TextColor3 = self.Theme[token]
end

function Window:_imageStyle(object, token)
	self._imageStyled[object] = token
	object.ImageColor3 = self.Theme[token]
end

function Window:_closePopups(except)
	for popup, record in pairs(self._popups) do
		if popup ~= except and popup.Parent then
			record.close()
		end
	end
	if except == nil then self._openPopup = nil end
end

function Window:_popup(popup, close)
	self:_closePopups(popup)
	self._popups[popup] = {close = close}
	self._openPopup = popup
end

function Window:_makeRow(parent, name, height)
	local row = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, height or 25), Name = "Row_" .. name}, parent)
	label(row, name, 12, self.Theme.Text, {Size = UDim2.new(1, -8, 1, 0), Position = ud(4, 0)})
	return row
end

function Window:AddToggle(parent, name, default, callback)
	local row = self:_makeRow(parent, name)
	local button = make("TextButton", {AutoButtonColor = false, Text = "", Size = ud(30, 16), Position = UDim2.new(1, -34, 0.5, -8), BackgroundColor3 = self.Theme.Gradient}, row)
	corner(button, 999)
	local inner = make("Frame", {BorderSizePixel = 0, Size = UDim2.new(1, -2, 1, -2), Position = ud(1, 1), BackgroundColor3 = self.Theme.Gradient}, button)
	corner(inner, 999)
	local knob = make("Frame", {BorderSizePixel = 0, Size = ud(12, 12), Position = ud(2, 2), BackgroundColor3 = self.Theme.InactiveText}, inner)
	corner(knob, 999)
	local state = default == true
	local function set(value)
		state = value
		local accent = self.Theme.Accent
		tween(button, {BackgroundColor3 = value and accent or self.Theme.Gradient}, 0.2, Enum.EasingStyle.Quad)
		tween(inner, {BackgroundColor3 = value and accent or self.Theme.Gradient}, 0.2, Enum.EasingStyle.Quad)
		tween(knob, {Position = value and UDim2.new(1, -14, 0, 2) or ud(2, 2), BackgroundColor3 = value and self.Theme.Text or self.Theme.InactiveText}, 0.2, Enum.EasingStyle.Quad)
		if callback then callback(value) end
	end
	self:_track(button.MouseButton1Click:Connect(function() set(not state) end))
	set(state)
	return button
end

function Window:AddCheckbox(parent, name, default, callback)
	local row = self:_makeRow(parent, name)
	local button = make("TextButton", {AutoButtonColor = false, Text = "", Size = ud(16, 16), Position = UDim2.new(1, -20, 0.5, -8), BackgroundColor3 = self.Theme.Gradient}, row)
	corner(button, 4)
	local mark = label(button, "✓", 12, self.Theme.Text, {Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, Visible = false})
	local state = default == true
	local function set(value)
		state = value; mark.Visible = value
		tween(button, {BackgroundColor3 = value and self.Theme.Accent or self.Theme.Gradient}, 0.2, Enum.EasingStyle.Quad)
		if callback then callback(value) end
	end
	self:_track(button.MouseButton1Click:Connect(function() set(not state) end))
	set(state)
	return button
end

function Window:AddSlider(parent, name, options)
	local opts = options or {}
	local row = self:_makeRow(parent, name, 37)
	local minValue = opts.Min or 0; local maxValue = opts.Max or 100; local value = opts.Default or minValue
	local valueLabel = label(row, "", 10, self.Theme.InactiveText, {Size = ud(46, 15), Position = UDim2.new(1, -50, 0, 0), TextXAlignment = Enum.TextXAlignment.Right})
	local track = make("Frame", {BorderSizePixel = 0, Size = UDim2.new(1, -8, 0, 4), Position = ud(4, 28), BackgroundColor3 = self.Theme.Gradient}, row)
	corner(track, 999)
	local fill = make("Frame", {BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = self.Theme.Accent}, track)
	corner(fill, 999)
	local thumb = make("Frame", {BorderSizePixel = 0, Size = ud(7, 7), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = self.Theme.Text}, track)
	corner(thumb, 999)
	local hit = make("TextButton", {AutoButtonColor = false, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 8, 0, 18), Position = ud(-4, 20)}, row)
	local dragging = false
	local function set(v)
		value = clamp(v, minValue, maxValue)
		local alpha = (value - minValue) / math.max(0.0001, maxValue - minValue)
		fill.Size = UDim2.new(alpha, 0, 1, 0); thumb.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueLabel.Text = tostring(math.floor(value * 100 + 0.5) / 100) .. (opts.Suffix or "")
		if opts.Callback then opts.Callback(value) end
	end
	local function update(input)
		local alpha = clamp((input.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
		set(minValue + (maxValue - minValue) * alpha)
	end
	self:_track(hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end
	end))
	self:_track(UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
	end))
	self:_track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end))
	set(value)
	return row
end

function Window:AddDropdown(parent, name, options)
	local opts = options or {}; local choices = opts.Items or {"None", "Down", "Up", "Zero", "Random"}
	local row = self:_makeRow(parent, name, 30)
	local button = make("TextButton", {AutoButtonColor = false, Text = "", Size = ud(opts.Width or 130, 18), Position = UDim2.new(1, -(opts.Width or 130), 0.5, -9), BackgroundColor3 = self.Theme.Element}, row)
	corner(button, 4)
	local valueLabel = label(button, tostring(opts.Default or choices[1]), 10, self.Theme.InactiveText, {Size = UDim2.new(1, -22, 1, 0), Position = ud(6, 0)})
	label(button, "▦", 11, self.Theme.InactiveText, {Size = ud(15, 18), Position = UDim2.new(1, -18, 0, 0), TextXAlignment = Enum.TextXAlignment.Center})
	local popup = make("Frame", {Visible = false, ZIndex = 30, Size = ud(opts.Width or 130, 0), BackgroundColor3 = self.Theme.Element}, self.Gui)
	corner(popup, 4); stroke(popup, self.Theme.Outline)
	local list = make("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, popup)
	make("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)}, popup)
	local open = false
	local function close()
		open = false; popup.Visible = false; self._popups[popup] = nil
	end
	local function openPopup()
		if open then close(); return end
		self:_closePopups(popup); open = true; popup.Visible = true
		popup.Position = UDim2.fromOffset(button.AbsolutePosition.X, button.AbsolutePosition.Y + button.AbsoluteSize.Y + 4)
		local total = 8
		for _, choice in ipairs(choices) do
			local option = make("TextButton", {AutoButtonColor = false, Text = tostring(choice), TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = self.Theme.InactiveText, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), ZIndex = 31}, popup)
			local pad = make("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)}, option)
			self:_track(option.MouseButton1Click:Connect(function()
				valueLabel.Text = tostring(choice); close(); if opts.Callback then opts.Callback(choice) end
			end))
			self:_track(option.MouseEnter:Connect(function() tween(option, {TextColor3 = self.Theme.Text}, 0.12) end))
			self:_track(option.MouseLeave:Connect(function() tween(option, {TextColor3 = self.Theme.InactiveText}, 0.12) end))
			total = total + 21
		end
		popup.Size = UDim2.fromOffset(opts.Width or 130, total)
		self:_popup(popup, close)
	end
	self:_track(button.MouseButton1Click:Connect(openPopup))
	return row
end

function Window:AddColorPicker(parent, name, options)
	local opts = options or {}; local row = self:_makeRow(parent, name)
	local swatch = make("TextButton", {AutoButtonColor = false, Text = "", Size = ud(16, 16), Position = UDim2.new(1, -20, 0.5, -8), BackgroundColor3 = opts.Default or self.Theme.Accent}, row)
	corner(swatch, 4)
	local picker = make("Frame", {Visible = false, ZIndex = 40, Size = ud(166, 197), BackgroundColor3 = self.Theme.Outline}, self.Gui)
	corner(picker, 6); stroke(picker, self.Theme.Separator)
	local sv = make("Frame", {Position = ud(7, 7), Size = ud(138, 112), BackgroundColor3 = Color3.fromHSV(0, 1, 1), ZIndex = 41}, picker)
	corner(sv, 4)
	local white = make("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 42}, sv)
	make("UIGradient", {Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)), Transparency = NumberSequence.new(0, 1)}, white)
	local black = make("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 43}, sv)
	make("UIGradient", {Rotation = 270, Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)), Transparency = NumberSequence.new(0, 1)}, black)
	local satHit = make("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 44}, sv)
	local satDot = make("Frame", {Size = ud(9, 9), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -2, 0, 2), BackgroundColor3 = self.Theme.Text, ZIndex = 45}, sv)
	corner(satDot, 999); stroke(satDot, self.Theme.InactiveText)
	local hue = make("TextButton", {Text = "", AutoButtonColor = false, Position = ud(151, 7), Size = ud(8, 112), BackgroundColor3 = Color3.new(1, 0, 0), ZIndex = 41}, picker)
	corner(hue, 5)
	make("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, rgb(255, 0, 0)), ColorSequenceKeypoint.new(.17, rgb(255, 255, 0)), ColorSequenceKeypoint.new(.33, rgb(0, 255, 0)), ColorSequenceKeypoint.new(.5, rgb(0, 255, 255)), ColorSequenceKeypoint.new(.67, rgb(0, 0, 255)), ColorSequenceKeypoint.new(.83, rgb(255, 0, 255)), ColorSequenceKeypoint.new(1, rgb(255, 0, 0))})}, hue)
	local hueDot = make("Frame", {Size = ud(12, 3), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 2), BackgroundColor3 = self.Theme.Text, ZIndex = 42}, hue)
	local alpha = make("TextButton", {Text = "", AutoButtonColor = false, Position = ud(7, 128), Size = ud(152, 8), BackgroundColor3 = self.Theme.Text, ZIndex = 41}, picker)
	corner(alpha, 5)
	local animLabel = label(picker, "Animations", 11, self.Theme.Text, {Position = ud(7, 148), Size = ud(152, 18), ZIndex = 41})
	local animButton = make("TextButton", {AutoButtonColor = false, Text = "None", TextSize = 10, Font = Enum.Font.Gotham, TextColor3 = self.Theme.InactiveText, TextXAlignment = Enum.TextXAlignment.Left, Position = ud(7, 169), Size = ud(152, 20), BackgroundColor3 = self.Theme.Element, ZIndex = 41}, picker)
	corner(animButton, 4)
	local h, s, v = (opts.Default or self.Theme.Accent):ToHSV(); local a = 0
	local function paint()
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1); swatch.BackgroundColor3 = Color3.fromHSV(h, s, v)
		satDot.Position = UDim2.new(s, 0, 1 - v, 0); hueDot.Position = UDim2.new(.5, 0, h, 0)
		if opts.Callback then opts.Callback(swatch.BackgroundColor3, a) end
	end
	local function point(input, object)
		return Vector2.new(clamp((input.Position.X - object.AbsolutePosition.X) / object.AbsoluteSize.X, 0, 1), clamp((input.Position.Y - object.AbsolutePosition.Y) / object.AbsoluteSize.Y, 0, 1))
	end
	local function track(button, callback)
		local active = false
		self:_track(button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then active = true; callback(point(input, button)) end end))
		self:_track(UserInputService.InputChanged:Connect(function(input) if active and input.UserInputType == Enum.UserInputType.MouseMovement then callback(point(input, button)) end end))
		self:_track(UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then active = false end end))
	end
	track(satHit, function(p) s = p.X; v = 1 - p.Y; paint() end)
	track(hue, function(p) h = p.Y; paint() end)
	track(alpha, function(p) a = p.X; paint() end)
	local open = false
	local function close() open = false; picker.Visible = false; self._popups[picker] = nil end
	local function toggle()
		if open then close(); return end
		self:_closePopups(picker); open = true; picker.Visible = true
		picker.Position = UDim2.fromOffset(swatch.AbsolutePosition.X - 150, swatch.AbsolutePosition.Y + 20)
		self:_popup(picker, close)
	end
	self:_track(swatch.MouseButton1Click:Connect(toggle)); paint()
	return row
end

function Window:AddTextbox(parent, name, options)
	local opts = options or {}; local row = self:_makeRow(parent, name, 34)
	local box = make("TextBox", {ClearTextOnFocus = false, PlaceholderText = opts.Placeholder or "type here...", Text = opts.Default or "", TextSize = 11, Font = Enum.Font.Gotham, TextColor3 = self.Theme.InactiveText, PlaceholderColor3 = self.Theme.InactiveText, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -8, 0, 26), Position = ud(4, 4), BackgroundColor3 = self.Theme.Element}, row)
	corner(box, 4)
	make("UIPadding", {PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7)}, box)
	self:_track(box.Focused:Connect(function() tween(box, {TextColor3 = self.Theme.Text}, 0.15) end))
	self:_track(box.FocusLost:Connect(function() tween(box, {TextColor3 = self.Theme.InactiveText}, 0.15) end))
	self:_track(box.FocusLost:Connect(function() if opts.Callback then opts.Callback(box.Text) end end))
	return box
end

function Window:AddButton(parent, name, callback)
	local button = make("TextButton", {AutoButtonColor = false, Text = name, TextSize = 11, Font = Enum.Font.Gotham, TextColor3 = self.Theme.Text, Size = UDim2.new(1, -8, 0, 27), Position = ud(4, 0), BackgroundColor3 = self.Theme.Element}, parent)
	corner(button, 4); stroke(button, self.Theme.Outline)
	self:_track(button.MouseButton1Click:Connect(function() if callback then callback() end; tween(button, {TextColor3 = self.Theme.Accent}, 0.1); spawn(function() wait(0.2) if button.Parent then tween(button, {TextColor3 = self.Theme.Text}, 0.15) end end) end))
	return button
end

function Window:AddCard(parent, title, options)
	local opts = options or {}
	local card = make("Frame", {BackgroundColor3 = self.Theme.Inline, BorderSizePixel = 0, Size = opts.Size or UDim2.new(0.5, -4, 0, 180), Name = title:gsub("%s", "")}, parent)
	corner(card, 6); stroke(card, self.Theme.Outline)
	local header = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Active = true}, card)
	local icon = label(header, opts.Icon or "◈", 12, self.Theme.InactiveText, {Size = ud(20, 30), Position = ud(8, 0), TextXAlignment = Enum.TextXAlignment.Center})
	label(header, title, 11, self.Theme.InactiveText, {Size = UDim2.new(1, -35, 1, 0), Position = ud(29, 0)})
	local body = make("ScrollingFrame", {Active = true, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollBarThickness = 2, ScrollBarImageColor3 = self.Theme.Separator, BackgroundTransparency = 1, BorderSizePixel = 0, Position = ud(6, 30), Size = UDim2.new(1, -12, 1, -36)}, card)
	make("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, body)
	make("UIPadding", {PaddingBottom = UDim.new(0, 8)}, body)
	bindDrag(header, card, self.Canvas, self._connections)
	self._cards[title] = {Frame = card, Header = header, Body = body, Icon = icon}
	return card
end

function Window:_makeContentPage(page, name)
	local content = make("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}, page)
	local layout = make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, content)
	make("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, content)
	return content
end

function Window:_combatPage(page, legit)
	local content = self:_makeContentPage(page, legit and "Legit" or "Rage")
	local leftCard = self:AddCard(content, legit and "Aim Assist" or "Ragebot", {Size = UDim2.new(0.5, -4, 0, 300), Icon = legit and "◉" or "◈"})
	local rightCard = self:AddCard(content, legit and "Triggerbot" or "Silent Aim", {Size = UDim2.new(0.5, -4, 0, 300), Icon = legit and "◌" or "◌"})
	if not legit then
		local targetingCard = self:AddCard(content, "Targeting", {Size = UDim2.new(0.5, -4, 0, 300), Icon = "◈"})
		targetingCard.Visible = false
	end
	local left = self._cards[legit and "Aim Assist" or "Ragebot"].Body
	local right = self._cards[legit and "Triggerbot" or "Silent Aim"].Body
	if legit then
		self:AddToggle(left, "Enabled", true); self:AddToggle(left, "Draw FOV", true)
		self:AddSlider(left, "FOV", {Min = 0, Max = 180, Default = 48, Suffix = "°"})
		self:AddSlider(left, "Smoothness", {Min = 0, Max = 100, Default = 27, Suffix = "%"})
		self:AddDropdown(left, "Hitpart", {Items = {"Head", "Torso"}, Default = "Head"})
		self:AddToggle(left, "Visible Only", true); self:AddToggle(left, "Team Check", true)
		self:AddSlider(left, "Deadzone", {Min = 0, Max = 20, Default = 2, Suffix = "px"})
		self:AddToggle(left, "Recoil Control", false); self:AddSlider(left, "Vertical", {Min = 0, Max = 100, Default = 55, Suffix = "%"})
		self:AddToggle(right, "Enabled", false); self:AddSlider(right, "Reaction Delay", {Min = 0, Max = 300, Default = 144, Suffix = "ms"})
		self:AddToggle(right, "Magnet Trigger", false); self:AddSlider(right, "Magnet FOV", {Min = 0, Max = 90, Default = 20, Suffix = "°"})
		self:AddToggle(right, "Head Only", true); self:AddToggle(right, "No Spread", false); self:AddToggle(right, "Quickstop", false); self:AddToggle(right, "Jump Check", true); self:AddToggle(right, "Flash Check", true)
	else
		self:AddToggle(left, "Enabled", false); self:AddToggle(left, "Auto Shoot", true); self:AddToggle(left, "Auto Scope", true); self:AddToggle(left, "Auto Reload", true); self:AddToggle(left, "Force Headshot", false)
		self:AddToggle(left, "Autowall", true); self:AddSlider(left, "Min Damage", {Min = 0, Max = 100, Default = 20, Suffix = "hp"}); self:AddSlider(left, "Hitchance", {Min = 0, Max = 100, Default = 85, Suffix = "%"})
		self:AddDropdown(left, "Target Selection", {Items = {"Closest to Crosshair", "Lowest Health", "Distance"}, Default = "Closest to Crosshair", Width = 130}); self:AddSlider(left, "Max Distance", {Min = 0, Max = 1000, Default = 800, Suffix = "st"})
		self:AddToggle(right, "Enabled", false); self:AddToggle(right, "Use FOV", true); self:AddCheckbox(right, "Draw FOV", true); self:AddSlider(right, "FOV Size", {Min = 0, Max = 180, Default = 120, Suffix = "px"})
		self:AddSlider(right, "Hitchance", {Min = 0, Max = 100, Default = 100, Suffix = "%"}); self:AddDropdown(right, "Aim Point", {Items = {"Head", "Torso", "Closest"}, Default = "Head"}); self:AddToggle(right, "Prediction", true); self:AddSlider(right, "Prediction Amount", {Min = 0, Max = 2, Default = 1.2, Suffix = "x"})
	end
	return {leftCard, rightCard}
end

function Window:_settingsPage(page)
	local content = self:_makeContentPage(page, "Settings")
	local profiles = self:AddCard(content, "Profiles", {Size = UDim2.new(0.5, -4, 0, 330), Icon = "●"})
	local theming = self:AddCard(content, "Theming", {Size = UDim2.new(0.5, -4, 0, 330), Icon = "◆"})
	local p = self._cards.Profiles.Body; local t = self._cards.Theming.Body
	local configList = make("Frame", {Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = self.Theme.Element}, p); corner(configList, 4); label(configList, "test.cfg", 11, self.Theme.InactiveText, {Position = ud(8, 5), Size = UDim2.new(1, -16, 0, 22)})
	self:AddTextbox(p, "Config name", {Placeholder = "Config name"})
	self:AddButton(p, "Create", function() self:Notify({Title = "Configs", Text = "Created config."}) end)
	self:AddButton(p, "Load", function() self:Notify({Title = "Configs", Text = "Loaded config: test.cfg"}) end)
	self:AddButton(p, "Delete", function() self:Notify({Title = "Configs", Text = "Deleted config: test.cfg"}) end)
	self:AddButton(p, "Overwrite", function() self:Notify({Title = "Configs", Text = "Overwrote config: test.cfg"}) end)
	self:AddDropdown(t, "Theme", {Items = {"Obsidian", "Blossom", "Afterglow", "Frostbite", "Volt", "Sakura Drift", "Neon Mirage", "Copper Dust", "Abyss", "Porcelain"}, Default = self.ThemeName, Callback = function(name) self:SetTheme(name); self:Notify({Title = "Theme", Text = "Applied \"" .. name .. "\" theme."}) end})
	self:AddDropdown(t, "Casing", {Items = {"Normal", "Round", "Sharp"}, Default = "Normal"})
	for _, key in ipairs({"Background", "Tab", "Outline", "Inline", "Text", "Inactive Text", "Accent", "Element", "Gradient", "Shadow", "Hovered Element"}) do
		self:AddColorPicker(t, key, {Default = self.Theme[key:gsub(" ", "")] or self.Theme.Accent, Callback = function(color) if key == "Accent" then self.Theme.Accent = color; self:_refreshTheme() end end})
	end
	self:AddToggle(t, "Gradient", true); self:AddToggle(t, "Shadow", true); self:AddToggle(t, "Autoload", false); self:AddToggle(t, "Menu", true)
end

function Window:_simplePage(page, pageName)
	local content = self:_makeContentPage(page, pageName)
	local left = self:AddCard(content, pageName == "Movement" and "Movement" or "Gun Mods", {Size = UDim2.new(0.5, -4, 0, 240), Icon = "◉"})
	local right = self:AddCard(content, pageName == "Movement" and "Bunny Hop" or "Utility", {Size = UDim2.new(0.5, -4, 0, 240), Icon = "◆"})
	local l = self._cards[pageName == "Movement" and "Movement" or "Gun Mods"].Body; local r = self._cards[pageName == "Movement" and "Bunny Hop" or "Utility"].Body
	if pageName == "Movement" then
		self:AddToggle(l, "Speed", false); self:AddSlider(l, "Speed Amount", {Min = 0, Max = 100, Default = 20, Suffix = "%"}); self:AddDropdown(l, "Speed Type", {Items = {"WalkSpeed", "CFrame", "Velocity"}, Default = "WalkSpeed"}); self:AddToggle(l, "Fly", false); self:AddSlider(l, "Fly Speed", {Min = 0, Max = 100, Default = 45}); self:AddToggle(l, "No Clip", false)
		self:AddToggle(r, "Enabled", false); self:AddDropdown(r, "Mode", {Items = {"Auto Strafe", "Legit", "Rage"}, Default = "Auto Strafe"}); self:AddSlider(r, "Strafe Strength", {Min = 0, Max = 20, Default = 8, Suffix = "x"})
	else
		self:AddToggle(l, "No Recoil", false); self:AddToggle(l, "No Spread", false); self:AddToggle(l, "Infinite Ammo", false); self:AddToggle(l, "Rapid Fire", false); self:AddSlider(l, "Fire Rate Multiplier", {Min = 0, Max = 5, Default = 2, Suffix = "x"}); self:AddToggle(l, "No Muzzle Flash", true)
		self:AddToggle(r, "Hitbox Expander", false); self:AddSlider(r, "Hitbox Size", {Min = 0, Max = 5, Default = 2.5, Suffix = "x"}); self:AddToggle(r, "Grenade Teleport", false); self:AddDropdown(r, "Grenade Target", {Items = {"Silent Target", "Closest", "Crosshair"}, Default = "Silent Target"}); self:AddTextbox(r, "Killsay", {Default = "blossomed."})
	end
end

function Window:AddPage(name, iconText)
	if self._pages[name] then return self._pages[name].Page end
	local page = make("Frame", {Visible = false, BackgroundTransparency = 1, Position = ud(112, 0), Size = UDim2.new(1, -112, 1, 0), Name = "Page_" .. name}, self.Content)
	self._pages[name] = {Page = page, Icon = iconText or "●"}
	return page
end

function Window:SelectPage(name)
	local record = self._pages[name]
	if not record then return end
	for pageName, other in pairs(self._pages) do
		local selected = pageName == name
		other.Page.Visible = selected
		local nav = self._nav[pageName]
		if nav then
			tween(nav.Background, {BackgroundTransparency = selected and 0 or 1}, 0.25)
			self:_textStyle(nav.Text, selected and "Text" or "InactiveText")
		end
	end
	self.SelectedPage = name
	self:_closePopups()
end

function Window:_makeNavigation(name, iconText, group)
	local groupLabel = self._groups[group]
	if not groupLabel then
		groupLabel = label(self.Rail, group, 9, self.Theme.InactiveText, {Size = UDim2.new(1, -14, 0, 18), Position = ud(7, self._railY)})
		self._groups[group] = groupLabel; self._railY = self._railY + 19
	end
	local background = make("Frame", {BackgroundColor3 = self.Theme.Element, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 25), Position = ud(6, self._railY)}, self.Rail)
	corner(background, 5)
	local button = make("TextButton", {AutoButtonColor = false, BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1)}, background)
	label(background, iconText, 11, self.Theme.InactiveText, {Size = ud(24, 25), Position = ud(5, 0), TextXAlignment = Enum.TextXAlignment.Center})
	local text = label(background, name, 11, self.Theme.InactiveText, {Size = UDim2.new(1, -31, 1, 0), Position = ud(30, 0)})
	self._nav[name] = {Background = background, Button = button, Text = text}
	self:_track(button.MouseButton1Click:Connect(function() self:SelectPage(name) end))
	self._railY = self._railY + 28
end

function Window:ShowCompactCombat()
	self._detached = false
	for _, record in pairs(self._cards) do
		record.Frame.Parent = self._pages.Rage.Page:FindFirstChildWhichIsA("Frame") or record.Frame.Parent
		record.Frame.Position = UDim2.new()
		record.Frame.Size = UDim2.new(0.5, -4, 0, 300)
	end
	if self._cards.Targeting then self._cards.Targeting.Frame.Visible = false end
end

function Window:ShowDetachedCombat()
	self._detached = true
	local positions = {Ragebot = ud(350, 70), ["Silent Aim"] = ud(140, 245), Targeting = ud(570, 70)}
	for title, position in pairs(positions) do
		local record = self._cards[title]
		if record then
			record.Frame.Parent = self.Canvas; record.Frame.Visible = true; record.Frame.Size = ud(180, 300); record.Frame.Position = position; record.Frame.ZIndex = 20
			for _, object in ipairs(record.Frame:GetDescendants()) do if object:IsA("GuiObject") then object.ZIndex = math.max(object.ZIndex, 20) end end
		end
	end
	self:Notify({Title = "Detached cards", Text = "Ragebot, Silent Aim, and Targeting are draggable."})
end

function Window:Toggle()
	self.Gui.Enabled = not self.Gui.Enabled
end

function Window:Destroy()
	for _, connection in ipairs(self._connections) do connection:Disconnect() end
	self._connections = {}
	if self.Gui then self.Gui:Destroy() end
	if GlobalEnvironment[GLOBAL_STATE_KEY] and GlobalEnvironment[GLOBAL_STATE_KEY].App == self then
		GlobalEnvironment[GLOBAL_STATE_KEY] = nil
		if GlobalEnvironment.BlossomUIApp == self then GlobalEnvironment.BlossomUIApp = nil end
	end
end

function Blossom.new(options)
	local opts = options or {}
	destroyPreviousInstance()
	local self = setmetatable({}, Window)
	self.ThemeName = opts.Theme or "Blossom"
	self.Theme = normalizedTheme(self.ThemeName)
	self._connections = {}; self._styled = {}; self._textStyled = {}; self._imageStyled = {}; self._popups = {}; self._cards = {}; self._pages = {}; self._nav = {}; self._groups = {}; self._railY = 53
	local guiParent = safeParent(opts.Parent)
	local guiName = opts.Name or DEFAULT_GUI_NAME
	pcall(function()
		for _, child in ipairs(guiParent:GetChildren()) do
			if child:IsA("ScreenGui") and child.Name == guiName then child:Destroy() end
		end
	end)
	self.Gui = make("ScreenGui", {Name = guiName, ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Global, Parent = guiParent})
	protectGui(self.Gui)
	self.Canvas = make("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Active = true}, self.Gui)
	self.Main = make("Frame", {BackgroundColor3 = self.Theme.Background, BorderSizePixel = 0, Size = ud(476, 390), Position = UDim2.new(0.5, -238, 0.5, -195), Active = true, ClipsDescendants = false}, self.Canvas)
	corner(self.Main, 8); stroke(self.Main, self.Theme.Outline)
	self.Rail = make("Frame", {BackgroundColor3 = self.Theme.Tab, BorderSizePixel = 0, Size = ud(112, 390), Active = true}, self.Main)
	corner(self.Rail, 8)
	make("Frame", {BackgroundColor3 = self.Theme.Separator, BorderSizePixel = 0, Size = ud(1, 390), Position = ud(111, 0)}, self.Main)
	self.Header = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, -112, 0, 38), Position = ud(112, 0), Active = true}, self.Main)
	self.Content = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, -112, 1, -38), Position = ud(112, 38)}, self.Main)
	bindDrag(self.Header, self.Main, self.Canvas, self._connections)
	local brand = label(self.Rail, "◉", 14, self.Theme.Accent, {Size = ud(24, 28), Position = ud(8, 8), TextXAlignment = Enum.TextXAlignment.Center})
	self:_textStyle(brand, "Accent")
	label(self.Rail, "Blossom", 14, self.Theme.Text, {Size = ud(76, 28), Position = ud(31, 8), Font = Enum.Font.GothamSemibold})
	label(self.Header, "◈  Ragebot", 11, self.Theme.InactiveText, {Size = UDim2.new(1, -18, 0, 38), Position = ud(12, 0)})
	local search = make("TextBox", {ClearTextOnFocus = false, PlaceholderText = "Search...", Text = "", TextSize = 10, Font = Enum.Font.Gotham, TextColor3 = self.Theme.InactiveText, PlaceholderColor3 = self.Theme.InactiveText, BackgroundColor3 = self.Theme.Element, Size = ud(98, 24), Position = ud(7, 354)}, self.Rail)
	corner(search, 5); make("UIPadding", {PaddingLeft = UDim.new(0, 7)}, search)
	self:_makeNavigation("Rage", "◉", "Combat"); self:_makeNavigation("Legit", "◌", "Combat"); self:_makeNavigation("Players", "●", "Visuals"); self:_makeNavigation("Effects", "◈", "Visuals"); self:_makeNavigation("Movement", "●", "Player"); self:_makeNavigation("Exploits", "◆", "Player"); self:_makeNavigation("Settings", "⚙", "")
	local rage = self:AddPage("Rage", "◉"); self:_combatPage(rage, false)
	local legit = self:AddPage("Legit", "◌"); self:_combatPage(legit, true)
	local exploits = self:AddPage("Exploits", "◆"); self:_simplePage(exploits, "Exploits")
	local movement = self:AddPage("Movement", "●"); self:_simplePage(movement, "Movement")
	local settings = self:AddPage("Settings", "⚙"); self:_settingsPage(settings)
	for _, name in ipairs({"Players", "Effects"}) do local page = self:AddPage(name, "●"); local c = self:_makeContentPage(page, name); local card = self:AddCard(c, name, {Size = UDim2.new(1, -16, 0, 100)}); label(self._cards[name].Body, "No visual controls shown in the reference state.", 11, self.Theme.InactiveText, {Size = UDim2.new(1, 0, 0, 24)}) end
	local hotkey = make("TextButton", {AutoButtonColor = false, Text = "⌁  Hotkeys", TextSize = 10, Font = Enum.Font.Gotham, TextColor3 = self.Theme.Text, BackgroundColor3 = self.Theme.Element, Size = ud(72, 23), Position = ud(14, 210)}, self.Canvas)
	corner(hotkey, 5); stroke(hotkey, self.Theme.Outline)
	self:_track(hotkey.MouseButton1Click:Connect(function() self:Notify({Title = "Hotkeys", Text = "Menu bind: RightShift"}) end))
	self:SelectPage("Rage")
	GlobalEnvironment[GLOBAL_STATE_KEY] = {App = self, Gui = self.Gui, Library = Blossom}
	GlobalEnvironment.BlossomUIApp = self
	return self
end

function Blossom:SetTheme(name)
	if not Themes[name] then return false end
	local oldTheme = self.Theme
	local newTheme = normalizedTheme(name)
	local function remap(value)
		for token, oldValue in pairs(oldTheme) do
			if value == oldValue then return newTheme[token] end
		end
		return value
	end
	for _, object in ipairs(self.Gui:GetDescendants()) do
		if object:IsA("GuiObject") then
			object.BackgroundColor3 = remap(object.BackgroundColor3)
		end
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			object.TextColor3 = remap(object.TextColor3)
		end
		if object:IsA("TextBox") then object.PlaceholderColor3 = remap(object.PlaceholderColor3) end
		if object:IsA("ImageLabel") or object:IsA("ImageButton") then
			object.ImageColor3 = remap(object.ImageColor3)
		end
		if object:IsA("UIStroke") then object.Color = remap(object.Color) end
	end
	self.ThemeName = name; self.Theme = newTheme; self:_refreshTheme()
	return true
end

function Blossom:Notify(options)
	local title = options.Title or "Blossom"; local text = options.Text or ""
	local notifications = self._notifications or {}
	local notification = make("Frame", {BackgroundColor3 = self.Theme.Background, BorderSizePixel = 0, Size = ud(210, 50), Position = ud(14, 12 + #notifications * 58), ZIndex = 100}, self.Gui)
	corner(notification, 4); stroke(notification, self.Theme.Outline)
	label(notification, "✓  " .. title, 11, self.Theme.Text, {Position = ud(8, 3), Size = UDim2.new(1, -16, 0, 20), ZIndex = 101})
	label(notification, text, 10, self.Theme.InactiveText, {Position = ud(9, 23), Size = UDim2.new(1, -16, 0, 20), ZIndex = 101})
	local bar = make("Frame", {BackgroundColor3 = self.Theme.Accent, BorderSizePixel = 0, Position = UDim2.new(0, 8, 1, -5), Size = UDim2.new(1, -16, 0, 3), ZIndex = 101}, notification)
	corner(bar, 999)
	self._notifications = self._notifications or {}; table.insert(self._notifications, notification)
	local lifetime = options.Lifetime or 3
	tween(bar, {Size = UDim2.new(0, 0, 0, 3)}, lifetime, Enum.EasingStyle.Linear)
	spawn(function() wait(lifetime)
		local index = nil; for i, item in ipairs(self._notifications) do if item == notification then index = i; break end end; if index then table.remove(self._notifications, index) end
		if notification.Parent then tween(notification, {BackgroundTransparency = 1}, 0.4); spawn(function() wait(0.45) if notification.Parent then notification:Destroy() end end) end
	end)
end

-- The window returned by Blossom.new/mount is the application handle. These
-- methods are intentionally shared with the module facade for ergonomic use.
Window.SetTheme = Blossom.SetTheme
Window.Notify = Blossom.Notify

function Blossom.mount(options)
	local app = Blossom.new(options)
	app:Notify({Title = "Blossom", Text = "UI loaded."})
	return app
end

Blossom.Themes = Themes
Blossom.Version = "1.1.0-executor-ui"
Blossom.Executor = {
	Parent = "gethui -> CoreGui -> PlayerGui fallback",
	Protection = "syn.protect_gui/protect_gui/protectgui when available",
	Filesystem = "not required; config buttons are UI-only",
}
GlobalEnvironment.BlossomUI = Blossom

-- Standalone executor entry point. Re-running the file is safe: Blossom.new()
-- destroys the previous global instance before creating the replacement.
local BlossomUIApp
local startupOk, startupResult = pcall(function()
	return Blossom.mount()
end)
if startupOk then
	BlossomUIApp = startupResult
else
	local diagnostic = "[BlossomUI] startup failed: " .. tostring(startupResult)
	if type(warn) == "function" then
		pcall(warn, diagnostic)
	else
		pcall(print, diagnostic)
	end
end
return BlossomUIApp
