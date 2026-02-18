-- NYEMEK HUB | MAP SAVER V2 (AUTO SCAN + DISTANCE SETTINGS)
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
	ToggleEnabled = Color3.fromRGB(0, 255, 0),
	ToggleDisabled = Color3.fromRGB(180, 180, 180),
	TextColor = Color3.fromRGB(240, 240, 240),
	TextDark = Color3.fromRGB(150, 150, 150)
}

-- Global Settings
local FlyEnabled = false
local FlySpeed = 50
local RenderDistance = 5000 -- Default rekomendasi
local Params = {RepoID = 1, Decompile = true, NoScripts = false, Timeout = 900}

local function Tween(obj, props)
	TweenService:Create(obj, TweenInfo.new(0.3, Enum.EasingStyle.Quart), props):Play()
end

-- =============================================
-- LOGIC: AUTO RENDER BYPASS
-- =============================================

local function StartAutoScan(statusObj)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart
	local originalPos = root.CFrame
	
	root.Anchored = true
	
	-- Grid Scanning
	local step = 800 -- Jarak antar lompatan (optimal untuk streaming)
	local totalSteps = (RenderDistance * 2 / step)^2
	local currentStep = 0
	
	for x = -RenderDistance, RenderDistance, step do
		for z = -RenderDistance, RenderDistance, step do
			currentStep = currentStep + 1
			statusObj.Text = "🌀 Scanning: " .. math.floor((currentStep/totalSteps)*100) .. "% (" .. x .. ", " .. z .. ")"
			root.CFrame = CFrame.new(x, 500, z) -- Terbang di ketinggian 500 agar tidak nyangkut
			task.wait(0.12) -- Jeda agar engine sempat me-load part
		end
	end
	
	root.CFrame = originalPos
	root.Anchored = false
	statusObj.Text = "✅ Scan Selesai! Memulai proses saving..."
end

-- =============================================
-- BUILD UI
-- =============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NyemekMapSaverV2"
pcall(function() ScreenGui.Parent = CoreGui end)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 500)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(0,255,0)

local Topbar = Instance.new("Frame", Main)
Topbar.Size = UDim2.new(1,0,0,42); Topbar.BackgroundColor3 = Theme.Topbar
local Title = Instance.new("TextLabel", Topbar)
Title.Size = UDim2.new(1,-10,1,0); Title.Position = UDim2.new(0,12,0,0); Title.Text = "NYEMEK HUB | FULL MAP SAVER"; Title.TextColor3 = Color3.fromRGB(0,255,0); Title.Font = "GothamBold"; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1,-20, 1,-52); Content.Position = UDim2.new(0,10,0,47); Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 2; Content.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", Content).Padding = UDim.new(0,8)

-- Helper UI Functions
local function CreateParagraph(t, c)
	local f = Instance.new("Frame", Content); f.Size = UDim2.new(1,0,0,0); f.AutomaticSize = "Y"; f.BackgroundColor3 = Theme.ElementBackground; Instance.new("UICorner", f)
	local tl = Instance.new("TextLabel", f); tl.Size = UDim2.new(1,0,0,18); tl.Text = " " .. t; tl.TextColor3 = Color3.fromRGB(0,255,0); tl.Font = "GothamBold"; tl.BackgroundTransparency = 1; tl.TextXAlignment = "Left"
	local cl = Instance.new("TextLabel", f); cl.Size = UDim2.new(1,0,0,0); cl.Position = UDim2.new(0,8,0,20); cl.AutomaticSize = "Y"; cl.Text = c; cl.TextColor3 = Theme.TextDark; cl.Font = "Gotham"; cl.BackgroundTransparency = 1; cl.TextWrapped = true; cl.TextXAlignment = "Left"
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
	local box = Instance.new("TextBox", f); box.Size = UDim2.new(0,70,0,22); box.Position = UDim2.new(1,-80,0.5,-11); box.Text = tostring(default); box.BackgroundColor3 = Color3.new(0,0,0); box.TextColor3 = Color3.new(0,255,0); Instance.new("UICorner", box)
	box.FocusLost:Connect(function() callback(tonumber(box.Text) or default) end)
end

-- =============================================
-- MAIN INTERFACE
-- =============================================

CreateParagraph("⚙️ Render Settings", "Atur seberapa jauh scan map dilakukan.\n- 5000: Map Kecil/Sedang (Rekomendasi)\n- 10000: Map Besar (Blox Fruits/Adopt Me)\n- 20000: Map Sangat Luas")

CreateInput("Render Distance", 5000, function(v)
	RenderDistance = v
end)

local Status = Instance.new("TextLabel", Content)
Status.Size = UDim2.new(1,0,0,30); Status.Text = "Status: Siap Scan"; Status.TextColor3 = Color3.fromRGB(200,200,200); Status.BackgroundTransparency = 1; Status.Font = "GothamBold"

CreateParagraph("🏃 Movement", "Gunakan Fly untuk render manual jika perlu.")
CreateToggle("Enable Fly", false, function(v) FlyEnabled = v; --[[ Fly logic here --]] end)

CreateParagraph("💾 Save Configuration", "Pastikan executor anda mendukung 'saveinstance'.")
CreateToggle("Decompile Scripts", true, function(v) Params.Decompile = v end)
CreateToggle("No Scripts", false, function(v) Params.NoScripts = v end)

local SaveBtn = Instance.new("TextButton", Content)
SaveBtn.Size = UDim2.new(1,0,0,40); SaveBtn.BackgroundColor3 = Color3.fromRGB(0,120,0); SaveBtn.Text = "MULAI AUTO-SCAN & SAVE"; SaveBtn.TextColor3 = Color3.new(1,1,1); SaveBtn.Font = "GothamBold"; Instance.new("UICorner", SaveBtn)

SaveBtn.MouseButton1Click:Connect(function()
	if not saveinstance then Status.Text = "❌ Executor tidak support!"; return end
	
	task.spawn(function()
		SaveBtn.Active = false; SaveBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
		
		-- Tahap 1: Scan
		StartAutoScan(Status)
		
		-- Tahap 2: Save
		Status.Text = "⏳ Menyimpan ke file... (Game akan Freeze)"
		task.wait(1)
		
		local success, err = pcall(function()
			saveinstance({
				RepoID = 1,
				Decompile = Params.Decompile,
				NoScripts = Params.NoScripts,
				Timeout = 1200
			})
		end)
		
		Status.Text = success and "✅ BERHASIL! Cek folder workspace." or "❌ Gagal: " .. tostring(err)
		SaveBtn.Active = true; SaveBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
	end)
end)

-- Dragging
local function Drag() -- Simple drag logic
	local dragging, dragStart, startPos
	Topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = input.Position; startPos = Main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end
Drag()
