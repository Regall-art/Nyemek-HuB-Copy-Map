--[[
    NYEMEK HUB | ULTIMATE MAP SAVER
    Fitur: 
    - Auto Render (Bypass StreamingEnabled)
    - Fly & Speed Control
    - Full Map SaveInstance
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Theme Configuration
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

local Animations = {
	Quart = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Linear = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	Back = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
}

-- Movement Variables
local FlyEnabled = false
local WalkSpeedValue = 16
local FlySpeedValue = 50
local flyConnection

-- Utility Functions
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

-- Fly Logic
local function toggleFly()
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local hum = char:WaitForChild("Humanoid")

	if FlyEnabled then
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		bv.Velocity = Vector3.new(0,0,0)
		bv.Name = "NyFlyBV"
		bv.Parent = root
		
		local bg = Instance.new("BodyGyro")
		bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
		bg.CFrame = root.CFrame
		bg.Name = "NyFlyBG"
		bg.Parent = root
		
		hum.PlatformStand = true
		
		flyConnection = RunService.RenderStepped:Connect(function()
			local look = workspace.CurrentCamera.CFrame.LookVector
			local right = workspace.CurrentCamera.CFrame.RightVector
			local move = Vector3.new(0,0,0)
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + look end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - look end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - right end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + right end
			
			bv.Velocity = move * FlySpeedValue
			bg.CFrame = workspace.CurrentCamera.CFrame
		end)
	else
		if flyConnection then flyConnection:Disconnect() end
		hum.PlatformStand = false
		if root:FindFirstChild("NyFlyBV") then root.NyFlyBV:Destroy() end
		if root:FindFirstChild("NyFlyBG") then root.NyFlyBG:Destroy() end
	end
end

-- Build UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NyemekMapSaver"
pcall(function() ScreenGui.Parent = CoreGui end)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 500)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(0, 255, 0); Stroke.Thickness = 2

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 40)
Topbar.BackgroundColor3 = Theme.Topbar
Topbar.BorderSizePixel = 0
Topbar.Parent = Main
local Title = Instance.new("TextLabel", Topbar)
Title.Size = UDim2.new(1, -10, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "NYEMEK HUB | MAP SAVER V2"; Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.TextXAlignment = "Left"; Title.BackgroundTransparency = 1

MakeDraggable(Main, Topbar)

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -60); Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 2; Content.AutomaticCanvasSize = "Y"
local Layout = Instance.new("UIListLayout", Content); Layout.Padding = UDim.new(0, 8)

-- Components
local function CreateButton(text, callback)
	local btn = Instance.new("TextButton", Content)
	btn.Size = UDim2.new(1, 0, 0, 35); btn.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
	btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.Font = "GothamBold"; btn.TextSize = 13
	Instance.new("UICorner", btn)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function CreateToggle(text, default, callback)
	local frame = Instance.new("Frame", Content)
	frame.Size = UDim2.new(1, 0, 0, 35); frame.BackgroundColor3 = Theme.ElementBackground
	local l = Instance.new("TextLabel", frame)
	l.Size = UDim2.new(1, -50, 1, 0); l.Position = UDim2.new(0, 10, 0, 0); l.BackgroundTransparency = 1
	l.Text = text; l.TextColor3 = Theme.TextColor; l.Font = "Gotham"; l.TextSize = 12; l.TextXAlignment = "Left"
	
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0, 40, 0, 20); btn.Position = UDim2.new(1, -45, 0.5, -10)
	btn.Text = ""; Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
	
	local state = default
	local function update()
		btn.BackgroundColor3 = state and Theme.ToggleEnabled or Theme.ToggleDisabled
		callback(state)
	end
	btn.MouseButton1Click:Connect(function() state = not state; update() end)
	update()
	Instance.new("UICorner", frame)
end

local function CreateInput(text, default, callback)
	local frame = Instance.new("Frame", Content)
	frame.Size = UDim2.new(1, 0, 0, 35); frame.BackgroundColor3 = Theme.ElementBackground
	local l = Instance.new("TextLabel", frame)
	l.Size = UDim2.new(1, -100, 1, 0); l.Position = UDim2.new(0, 10, 0, 0); l.BackgroundTransparency = 1
	l.Text = text; l.TextColor3 = Theme.TextColor; l.Font = "Gotham"; l.TextSize = 12; l.TextXAlignment = "Left"
	
	local box = Instance.new("TextBox", frame)
	box.Size = UDim2.new(0, 80, 0, 25); box.Position = UDim2.new(1, -90, 0.5, -12.5)
	box.BackgroundColor3 = Color3.new(0,0,0); box.TextColor3 = Color3.new(0,1,0); box.Text = tostring(default)
	box.FocusLost:Connect(function() callback(tonumber(box.Text) or default) end)
	Instance.new("UICorner", frame)
end

-- UI Setup
local Status = Instance.new("TextLabel", Content)
Status.Size = UDim2.new(1, 0, 0, 30); Status.Text = "Status: Ready"; Status.TextColor3 = Theme.TextDark
Status.BackgroundTransparency = 1; Status.Font = "Gotham"; Status.TextSize = 12

-- Movement
CreateToggle("Enable Fly (Noclip)", false, function(v) FlyEnabled = v; toggleFly() end)
CreateInput("WalkSpeed", 16, function(v) if player.Character then player.Character.Humanoid.WalkSpeed = v end end)
CreateInput("Fly Speed", 50, function(v) FlySpeedValue = v end)

-- Save Settings
local Params = {Decompile = true, NoScripts = false}
CreateToggle("Decompile Scripts", true, function(v) Params.Decompile = v end)
CreateToggle("No Scripts", false, function(v) Params.NoScripts = v end)

-- AUTO RENDER & SAVE LOGIC
local function AutoRender()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart
	local originalPos = root.CFrame
	
	Status.Text = "🌀 Status: Scanning Map (Bypassing Streaming)..."
	root.Anchored = true
	
	-- Scan grid (Radius 4000 studs)
	local size = 4000
	local step = 800 
	for x = -size, size, step do
		for z = -size, size, step do
			root.CFrame = CFrame.new(x, 300, z)
			task.wait(0.15) -- Delay agar server sempat kirim data part
		end
	end
	
	root.CFrame = originalPos
	root.Anchored = false
end

CreateButton("💾 SAVE FULL MAP (AUTO RENDER)", function()
	if not saveinstance then 
		Status.Text = "❌ Error: Executor tidak support saveinstance!"
		return 
	end
	
	task.spawn(function()
		AutoRender()
		Status.Text = "⏳ Status: Saving to File... (Game akan Freeze)"
		task.wait(0.5)
		
		local success, err = pcall(function()
			saveinstance({
				RepoID = 1,
				Decompile = Params.Decompile,
				NoScripts = Params.NoScripts,
				Timeout = 900
			})
		end)
		
		if success then
			Status.Text = "✅ Berhasil! Cek folder 'workspace' executor."
		else
			Status.Text = "❌ Gagal: " .. tostring(err)
		end
	end)
end)

print("Nyemek Hub Loaded!")
