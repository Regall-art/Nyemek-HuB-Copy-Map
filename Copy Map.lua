-- NYEMEK HUB | ULTIMATE MAP SAVER (AUTO RENDER VERSION)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Theme = {
	Background = Color3.fromRGB(25, 25, 25),
	Topbar = Color3.fromRGB(30, 30, 30),
	ElementBackground = Color3.fromRGB(35, 35, 35),
	ElementStroke = Color3.fromRGB(50, 50, 50),
	ToggleBackground = Color3.fromRGB(30, 30, 30),
	ToggleEnabled = Color3.fromRGB(0, 255, 0),
	ToggleDisabled = Color3.fromRGB(180, 180, 180),
	ToggleEnabledStroke = Color3.fromRGB(0, 200, 0),
	ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
	TextColor = Color3.fromRGB(240, 240, 240),
	TextDark = Color3.fromRGB(150, 150, 150)
}

local Animations = {
	Quart = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Back = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Linear = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
}

-- Global Variables for Features
local FlyEnabled = false
local FlySpeed = 50
local flyConn
local Params = {RepoID = 1, Decompile = true, NoScripts = false, Timeout = 900}

local function Tween(obj, props, info)
	TweenService:Create(obj, info or Animations.Quart, props):Play()
end

local function MakeDraggable(frame, handle)
	local dragging, dragStart, startPos
	handle = handle or frame
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = input.Position; startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- =============================================
-- LOGIC: FLY & AUTO RENDER
-- =============================================

local function toggleFly()
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	if FlyEnabled then
		local bv = Instance.new("BodyVelocity", root)
		bv.Name = "NyFlyBV"; bv.MaxForce = Vector3.new(1e9, 1e9, 1e9); bv.Velocity = Vector3.new(0,0,0)
		local bg = Instance.new("BodyGyro", root)
		bg.Name = "NyFlyBG"; bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9); bg.CFrame = root.CFrame
		char.Humanoid.PlatformStand = true
		flyConn = RunService.RenderStepped:Connect(function()
			local look = workspace.CurrentCamera.CFrame.LookVector
			local move = Vector3.new(0,0,0)
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + look end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - look end
			bv.Velocity = move * FlySpeed
			bg.CFrame = workspace.CurrentCamera.CFrame
		end)
	else
		if flyConn then flyConn:Disconnect() end
		char.Humanoid.PlatformStand = false
		if root:FindFirstChild("NyFlyBV") then root.NyFlyBV:Destroy() end
		if root:FindFirstChild("NyFlyBG") then root.NyFlyBG:Destroy() end
	end
end

local function AutoRender(statusObj)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart
	local originalPos = root.CFrame
	root.Anchored = true
	
	local range = 4000 
	local step = 800
	statusObj.Text = "🌀 Rendering Map (Bypassing Streaming)..."
	
	for x = -range, range, step do
		for z = -range, range, step do
			root.CFrame = CFrame.new(x, 300, z)
			task.wait(0.15)
		end
	end
	root.CFrame = originalPos
	root.Anchored = false
end

-- =============================================
-- BUILD UI (MATCHING ORIGINAL)
-- =============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NyemekMapSaverUI"
pcall(function() ScreenGui.Parent = CoreGui end)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,6)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(0,255,0)

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1,0,0,42); Topbar.BackgroundColor3 = Theme.Topbar; Topbar.Parent = Main
local Title = Instance.new("TextLabel", Topbar)
Title.Size = UDim2.new(1,-50,1,0); Title.Position = UDim2.new(0,12,0,0); Title.BackgroundTransparency = 1
Title.Text = "NYEMEK HUB | MAP SAVER V2"; Title.TextColor3 = Color3.fromRGB(0,255,0); Title.Font = "GothamBold"; Title.TextXAlignment = "Left"

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1,-20, 1,-52); Content.Position = UDim2.new(0,10,0,47); Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 2; Content.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", Content).Padding = UDim.new(0,8)

-- Components (Matching your style)
local function CreateParagraph(t, c)
	local f = Instance.new("Frame", Content); f.Size = UDim2.new(1,0,0,0); f.AutomaticSize = "Y"; f.BackgroundColor3 = Theme.ElementBackground
	Instance.new("UICorner", f); local p = Instance.new("UIPadding", f); p.PaddingTop = UDim.new(0,8); p.PaddingBottom = UDim.new(0,8); p.PaddingLeft = UDim.new(0,8)
	local tl = Instance.new("TextLabel", f); tl.Size = UDim2.new(1,0,0,16); tl.Text = t; tl.TextColor3 = Color3.fromRGB(0,255,0); tl.Font = "GothamBold"; tl.BackgroundTransparency = 1; tl.TextXAlignment = "Left"
	local cl = Instance.new("TextLabel", f); cl.Size = UDim2.new(1,0,0,0); cl.Position = UDim2.new(0,0,0,18); cl.AutomaticSize = "Y"; cl.Text = c; cl.TextColor3 = Theme.TextDark; cl.Font = "Gotham"; cl.BackgroundTransparency = 1; cl.TextWrapped = true; cl.TextXAlignment = "Left"
end

local function CreateToggle(name, default, callback)
	local f = Instance.new("Frame", Content); f.Size = UDim2.new(1,0,0,35); f.BackgroundColor3 = Theme.ElementBackground; Instance.new("UICorner", f)
	local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1,-60,1,0); t.Position = UDim2.new(0,10,0,0); t.Text = name; t.TextColor3 = Theme.TextColor; t.BackgroundTransparency = 1; t.TextXAlignment = "Left"; t.Font = "Gotham"
	local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(0,35,0,18); btn.Position = UDim2.new(1,-45,0.5,-9); btn.Text = ""; Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
	local toggled = default
	local function up() btn.BackgroundColor3 = toggled and Color3.fromRGB(0,255,0) or Color3.fromRGB(100,100,100); callback(toggled) end
	btn.MouseButton1Click:Connect(function() toggled = not toggled; up() end); up()
end

local function CreateInput(name, default, callback)
	local f = Instance.new("Frame", Content); f.Size = UDim2.new(1,0,0,35); f.BackgroundColor3 = Theme.ElementBackground; Instance.new("UICorner", f)
	local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1,-100,1,0); t.Position = UDim2.new(0,10,0,0); t.Text = name; t.TextColor3 = Theme.TextColor; t.BackgroundTransparency = 1; t.TextXAlignment = "Left"; t.Font = "Gotham"
	local box = Instance.new("TextBox", f); box.Size = UDim2.new(0,60,0,22); box.Position = UDim2.new(1,-70,0.5,-11); box.Text = tostring(default); box.BackgroundColor3 = Color3.new(0,0,0); box.TextColor3 = Color3.new(0,255,0); Instance.new("UICorner", box)
	box.FocusLost:Connect(function() callback(tonumber(box.Text) or default) end)
end

local function CreateButton(name, callback)
	local btn = Instance.new("TextButton", Content); btn.Size = UDim2.new(1,0,0,38); btn.BackgroundColor3 = Color3.fromRGB(0,100,0); btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = "GothamBold"; Instance.new("UICorner", btn)
	btn.MouseButton1Click:Connect(callback)
end

-- =============================================
-- INTERFACE SETUP
-- =============================================

CreateParagraph("🗺️ Nyemek Auto-Saver", "Script ini akan otomatis keliling map untuk render semua part sebelum menyimpan.")
local Status = Instance.new("TextLabel", Content); Status.Size = UDim2.new(1,0,0,25); Status.Text = "Status: Ready"; Status.TextColor3 = Theme.TextDark; Status.BackgroundTransparency = 1; Status.Font = "Gotham"

CreateParagraph("🏃 Movement", "Gunakan Fly untuk melihat render secara manual.")
CreateToggle("Enable Fly", false, function(v) FlyEnabled = v; toggleFly() end)
CreateInput("WalkSpeed", 16, function(v) if player.Character then player.Character.Humanoid.WalkSpeed = v end end)
CreateInput("Fly Speed", 50, function(v) FlySpeed = v end)

CreateParagraph("⚙️ Settings", "Konfigurasi SaveInstance.")
CreateToggle("Decompile Scripts", true, function(v) Params.Decompile = v end)
CreateToggle("No Scripts", false, function(v) Params.NoScripts = v end)

CreateButton("💾 SAVE MAP SEKARANG (AUTO RENDER)", function()
	if not saveinstance then Status.Text = "❌ Executor tidak support saveinstance"; return end
	task.spawn(function()
		AutoRender(Status)
		Status.Text = "⏳ Saving... Game akan Freeze sebentar."
		task.wait(0.5)
		local success, err = pcall(function()
			saveinstance({RepoID = 1, Decompile = Params.Decompile, NoScripts = Params.NoScripts, Timeout = 900})
		end)
		Status.Text = success and "✅ Berhasil disimpan!" or "❌ Gagal: "..tostring(err)
	end)
end)

MakeDraggable(Main, Topbar)
Tween(Main, {Size = UDim2.new(0, 420, 0, 480)}, Animations.Back)
