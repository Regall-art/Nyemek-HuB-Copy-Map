-- NYEMEK HUB | MAP SAVER
-- Custom Full Map Saver with Nyemek Hub UI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

local Theme = {
	Background = Color3.fromRGB(25, 25, 25),
	Topbar = Color3.fromRGB(30, 30, 30),
	TabBackground = Color3.fromRGB(20, 20, 20),
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
	Quart  = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Quint  = TweenInfo.new(0.3,  Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Back   = TweenInfo.new(0.5,  Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
	Linear = TweenInfo.new(0.2,  Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
}

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
			Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, Animations.Linear)
		end
	end)
end

local function CreateNYLogo(parent)
	local LogoBg = Instance.new("Frame"); LogoBg.Size = UDim2.new(1,0,1,0); LogoBg.BackgroundColor3 = Color3.fromRGB(100,180,255); LogoBg.BorderSizePixel = 0; LogoBg.Parent = parent
	local BgCorner = Instance.new("UICorner"); BgCorner.CornerRadius = UDim.new(0,12); BgCorner.Parent = LogoBg
	local BgGradient = Instance.new("UIGradient")
	BgGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(100,180,255)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,160,100))})
	BgGradient.Rotation = 135; BgGradient.Parent = LogoBg
	local NLetter = Instance.new("TextLabel"); NLetter.Size = UDim2.new(0.5,0,0.8,0); NLetter.Position = UDim2.new(0.05,0,0.1,0); NLetter.BackgroundTransparency = 1; NLetter.Text = "N"; NLetter.TextColor3 = Color3.fromRGB(50,130,255); NLetter.TextSize = 40; NLetter.Font = Enum.Font.GothamBlack; NLetter.TextScaled = true; NLetter.Parent = LogoBg
	local YLetter = Instance.new("TextLabel"); YLetter.Size = UDim2.new(0.5,0,0.8,0); YLetter.Position = UDim2.new(0.45,0,0.1,0); YLetter.BackgroundTransparency = 1; YLetter.Text = "y"; YLetter.TextColor3 = Color3.fromRGB(255,140,80); YLetter.TextSize = 40; YLetter.Font = Enum.Font.GothamBlack; YLetter.TextScaled = true; YLetter.Parent = LogoBg
	return LogoBg
end

-- =============================================
-- BUILD UI
-- =============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NyemekMapSaverUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if ScreenGui.Parent ~= CoreGui then ScreenGui.Parent = player.PlayerGui end

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0,6); MainCorner.Parent = Main
local MainStroke = Instance.new("UIStroke"); MainStroke.Color = Color3.fromRGB(0,255,0); MainStroke.Thickness = 2; MainStroke.Parent = Main
local Shadow = Instance.new("ImageLabel"); Shadow.AnchorPoint = Vector2.new(0.5,0.5); Shadow.BackgroundTransparency = 1; Shadow.Position = UDim2.new(0.5,0,0.5,0); Shadow.Size = UDim2.new(1,47,1,47); Shadow.ZIndex = 0; Shadow.Image = "rbxassetid://5554236805"; Shadow.ImageColor3 = Color3.fromRGB(0,0,0); Shadow.ImageTransparency = 0.5; Shadow.ScaleType = Enum.ScaleType.Slice; Shadow.SliceCenter = Rect.new(23,23,277,277); Shadow.Parent = Main

-- Topbar
local Topbar = Instance.new("Frame"); Topbar.Size = UDim2.new(1,0,0,42); Topbar.BackgroundColor3 = Theme.Topbar; Topbar.BorderSizePixel = 0; Topbar.Parent = Main
local TopbarCorner = Instance.new("UICorner"); TopbarCorner.CornerRadius = UDim.new(0,6); TopbarCorner.Parent = Topbar
local TopbarCover = Instance.new("Frame"); TopbarCover.Size = UDim2.new(1,0,0,6); TopbarCover.Position = UDim2.new(0,0,1,-6); TopbarCover.BackgroundColor3 = Theme.Topbar; TopbarCover.BorderSizePixel = 0; TopbarCover.Parent = Topbar
local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1,-50,1,0); Title.Position = UDim2.new(0,12,0,0); Title.BackgroundTransparency = 1; Title.Text = "NYEMEK HUB | MAP SAVER"; Title.TextColor3 = Color3.fromRGB(0,255,0); Title.TextSize = 15; Title.Font = Enum.Font.GothamBold; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Topbar
local CloseButton = Instance.new("ImageButton"); CloseButton.Size = UDim2.new(0,18,0,18); CloseButton.Position = UDim2.new(1,-30,0.5,-9); CloseButton.BackgroundTransparency = 1; CloseButton.Image = "rbxassetid://7733717447"; CloseButton.ImageColor3 = Theme.TextColor; CloseButton.Parent = Topbar

-- Content Area (no tabs needed, simple layout)
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -52)
Content.Position = UDim2.new(0, 10, 0, 47)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(0,255,0)
Content.CanvasSize = UDim2.new(0,0,0,0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main

local ContentList = Instance.new("UIListLayout"); ContentList.Padding = UDim.new(0,8); ContentList.Parent = Content
local ContentPad = Instance.new("UIPadding"); ContentPad.PaddingTop = UDim.new(0,8); ContentPad.PaddingBottom = UDim.new(0,8); ContentPad.Parent = Content

-- Mini Button
local MiniButton = Instance.new("TextButton"); MiniButton.Size = UDim2.new(0,60,0,60); MiniButton.Position = UDim2.new(1,-70,0.95,-70); MiniButton.BackgroundTransparency = 1; MiniButton.Text = ""; MiniButton.Visible = false; MiniButton.AutoButtonColor = false; MiniButton.Parent = ScreenGui
CreateNYLogo(MiniButton)
local MiniStroke = Instance.new("UIStroke"); MiniStroke.Color = Color3.fromRGB(0,255,0); MiniStroke.Thickness = 3; MiniStroke.Parent = MiniButton

CloseButton.MouseButton1Click:Connect(function()
	Tween(Main,{Size=UDim2.new(0,0,0,0)},Animations.Back); task.wait(0.5); Main.Visible = false
	MiniButton.Visible = true; MiniButton.Size = UDim2.new(0,0,0,0); Tween(MiniButton,{Size=UDim2.new(0,60,0,60)},Animations.Back)
	task.spawn(function() while MiniButton.Visible do Tween(MiniButton,{Size=UDim2.new(0,65,0,65)},Animations.Quart); task.wait(1); Tween(MiniButton,{Size=UDim2.new(0,60,0,60)},Animations.Quart); task.wait(1) end end)
end)
MiniButton.MouseButton1Click:Connect(function()
	Tween(MiniButton,{Size=UDim2.new(0,0,0,0)},Animations.Quart); task.wait(0.3); MiniButton.Visible = false
	Main.Visible = true; Tween(Main,{Size=UDim2.new(0,420,0,480)},Animations.Back)
end)
MiniButton.MouseEnter:Connect(function() Tween(MiniButton,{Size=UDim2.new(0,68,0,68)},Animations.Quart) end)
MiniButton.MouseLeave:Connect(function() Tween(MiniButton,{Size=UDim2.new(0,60,0,60)},Animations.Quart) end)

MakeDraggable(Main, Topbar)
MakeDraggable(MiniButton)

-- =============================================
-- HELPER: CREATE ELEMENT
-- =============================================

local function CreateParagraph(title, content)
	local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1,0,0,0); Frame.AutomaticSize = Enum.AutomaticSize.Y; Frame.BackgroundColor3 = Theme.ElementBackground; Frame.BorderSizePixel = 0; Frame.Parent = Content
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0,5); Corner.Parent = Frame
	local Stroke = Instance.new("UIStroke"); Stroke.Color = Theme.ElementStroke; Stroke.Thickness = 1; Stroke.Parent = Frame
	local Padding = Instance.new("UIPadding"); Padding.PaddingTop = UDim.new(0,10); Padding.PaddingBottom = UDim.new(0,10); Padding.PaddingLeft = UDim.new(0,10); Padding.PaddingRight = UDim.new(0,10); Padding.Parent = Frame
	local T = Instance.new("TextLabel"); T.Size = UDim2.new(1,0,0,16); T.BackgroundTransparency = 1; T.Text = title; T.TextColor3 = Color3.fromRGB(0,255,0); T.TextSize = 13; T.Font = Enum.Font.GothamBold; T.TextXAlignment = Enum.TextXAlignment.Left; T.Parent = Frame
	local C = Instance.new("TextLabel"); C.Size = UDim2.new(1,0,0,0); C.Position = UDim2.new(0,0,0,20); C.AutomaticSize = Enum.AutomaticSize.Y; C.BackgroundTransparency = 1; C.Text = content; C.TextColor3 = Theme.TextDark; C.TextSize = 12; C.Font = Enum.Font.Gotham; C.TextXAlignment = Enum.TextXAlignment.Left; C.TextWrapped = true; C.Parent = Frame
	return Frame
end

local function CreateToggle(name, default, callback)
	local ToggleFrame = Instance.new("Frame"); ToggleFrame.Size = UDim2.new(1,0,0,35); ToggleFrame.BackgroundColor3 = Theme.ElementBackground; ToggleFrame.BorderSizePixel = 0; ToggleFrame.Parent = Content
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0,5); Corner.Parent = ToggleFrame
	local Stroke = Instance.new("UIStroke"); Stroke.Color = Theme.ElementStroke; Stroke.Thickness = 1; Stroke.Parent = ToggleFrame
	local ToggleTitle = Instance.new("TextLabel"); ToggleTitle.Size = UDim2.new(1,-60,1,0); ToggleTitle.Position = UDim2.new(0,10,0,0); ToggleTitle.BackgroundTransparency = 1; ToggleTitle.Text = name; ToggleTitle.TextColor3 = Theme.TextColor; ToggleTitle.TextSize = 13; ToggleTitle.Font = Enum.Font.Gotham; ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left; ToggleTitle.Parent = ToggleFrame
	local StatusLabel = Instance.new("TextLabel"); StatusLabel.Size = UDim2.new(0,40,1,0); StatusLabel.Position = UDim2.new(1,-95,0,0); StatusLabel.BackgroundTransparency = 1; StatusLabel.Text = default and "[ON]" or "[OFF]"; StatusLabel.TextColor3 = default and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0); StatusLabel.TextSize = 11; StatusLabel.Font = Enum.Font.GothamBold; StatusLabel.Parent = ToggleFrame
	local ToggleButton = Instance.new("TextButton"); ToggleButton.Size = UDim2.new(0,40,0,20); ToggleButton.Position = UDim2.new(1,-45,0.5,-10); ToggleButton.BackgroundColor3 = Theme.ToggleBackground; ToggleButton.BorderSizePixel = 0; ToggleButton.Text = ""; ToggleButton.AutoButtonColor = false; ToggleButton.Parent = ToggleFrame
	local TC2 = Instance.new("UICorner"); TC2.CornerRadius = UDim.new(1,0); TC2.Parent = ToggleButton
	local TS2 = Instance.new("UIStroke"); TS2.Color = default and Theme.ToggleEnabledStroke or Theme.ToggleDisabledStroke; TS2.Thickness = 1; TS2.Parent = ToggleButton
	local Indicator = Instance.new("Frame"); Indicator.Size = UDim2.new(0,16,0,16); Indicator.Position = default and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8); Indicator.BackgroundColor3 = default and Theme.ToggleEnabled or Theme.ToggleDisabled; Indicator.BorderSizePixel = 0; Indicator.Parent = ToggleButton
	local IC = Instance.new("UICorner"); IC.CornerRadius = UDim.new(1,0); IC.Parent = Indicator

	local toggled = default or false
	local function Update()
		if toggled then
			StatusLabel.Text="[ON]"; StatusLabel.TextColor3=Color3.fromRGB(0,255,0)
			Tween(Indicator,{Position=UDim2.new(1,-18,0.5,-8),BackgroundColor3=Theme.ToggleEnabled},Animations.Quart)
			Tween(TS2,{Color=Theme.ToggleEnabledStroke},Animations.Quart)
		else
			StatusLabel.Text="[OFF]"; StatusLabel.TextColor3=Color3.fromRGB(255,0,0)
			Tween(Indicator,{Position=UDim2.new(0,2,0.5,-8),BackgroundColor3=Theme.ToggleDisabled},Animations.Quart)
			Tween(TS2,{Color=Theme.ToggleDisabledStroke},Animations.Quart)
		end
	end
	ToggleButton.MouseButton1Click:Connect(function()
		toggled = not toggled; Update()
		if callback then callback(toggled) end
	end)
	return {GetValue = function() return toggled end}
end

local function CreateButton(name, callback)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1,0,0,35)
	Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
	Btn.BorderSizePixel = 0
	Btn.Text = name
	Btn.TextColor3 = Color3.fromRGB(255,255,255)
	Btn.TextSize = 13
	Btn.Font = Enum.Font.GothamBold
	Btn.AutoButtonColor = false
	Btn.Parent = Content
	local BtnCorner = Instance.new("UICorner"); BtnCorner.CornerRadius = UDim.new(0,5); BtnCorner.Parent = Btn
	local BtnStroke = Instance.new("UIStroke"); BtnStroke.Color = Color3.fromRGB(0,255,0); BtnStroke.Thickness = 1; BtnStroke.Parent = Btn

	Btn.MouseEnter:Connect(function() Tween(Btn,{BackgroundColor3=Color3.fromRGB(0,140,0)},Animations.Quart) end)
	Btn.MouseLeave:Connect(function() Tween(Btn,{BackgroundColor3=Color3.fromRGB(0,100,0)},Animations.Quart) end)
	Btn.MouseButton1Click:Connect(function()
		Tween(Btn,{BackgroundColor3=Color3.fromRGB(0,60,0)},Animations.Quart)
		task.wait(0.1)
		Tween(Btn,{BackgroundColor3=Color3.fromRGB(0,100,0)},Animations.Quart)
		if callback then callback() end
	end)
	return Btn
end

-- Status label
local function CreateStatusBar(defaultText)
	local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1,0,0,30); Frame.BackgroundColor3 = Theme.ElementBackground; Frame.BorderSizePixel = 0; Frame.Parent = Content
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0,5); Corner.Parent = Frame
	local Stroke = Instance.new("UIStroke"); Stroke.Color = Theme.ElementStroke; Stroke.Thickness = 1; Stroke.Parent = Frame
	local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1,-10,1,0); Label.Position = UDim2.new(0,10,0,0); Label.BackgroundTransparency = 1; Label.Text = defaultText or "Status: Ready"; Label.TextColor3 = Theme.TextDark; Label.TextSize = 12; Label.Font = Enum.Font.Gotham; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Frame
	return Label
end

-- =============================================
-- SAVE PARAMS (dengan toggle)
-- =============================================

local Params = {
	RepoID = 1,
	Decompile = true,
	NoScripts = false,
	Timeout = 900,
}

-- Build UI Elements
CreateParagraph("🗺️ Nyemek Hub | Map Saver", "Save full map game ke file .rbxl di folder executor kamu. Pastikan executor support saveinstance!")

local statusLabel = CreateStatusBar("Status: Siap")

CreateParagraph("⚙️ Pengaturan Save", "Konfigurasi sebelum mulai save map.")

local decompileToggle = CreateToggle("Decompile Scripts (LocalScript & ModuleScript)", true, function(val)
	Params.Decompile = val
end)

local noscriptToggle = CreateToggle("No Scripts (Jangan save script)", false, function(val)
	Params.NoScripts = val
end)

CreateParagraph("💡 Tips", "Terbang keliling seluruh map dulu sebelum save agar semua part ter-render (penting untuk game dengan StreamingEnabled). Proses bisa memakan waktu 1-15 menit tergantung ukuran map.")

CreateParagraph("⚠️ Warning", "Game mungkin akan freeze sejenak saat proses save berlangsung. Jangan close executor atau game selama proses berlangsung!")

-- TOMBOL SAVE
CreateButton("💾 SAVE MAP SEKARANG", function()
	if not saveinstance then
		statusLabel.Text = "❌ Error: Executor tidak support saveinstance!"
		statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		print("[MapSaver] Error: saveinstance tidak tersedia di executor ini.")
		return
	end

	statusLabel.Text = "⏳ Sedang menyimpan map... Harap tunggu!"
	statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	print("[MapSaver] Memulai proses save map...")
	print("[MapSaver] Decompile: " .. tostring(Params.Decompile))
	print("[MapSaver] NoScripts: " .. tostring(Params.NoScripts))
	print("[MapSaver] Timeout: " .. tostring(Params.Timeout) .. " detik")

	task.spawn(function()
		local success, err = pcall(function()
			saveinstance({
				RepoID = Params.RepoID,
				Decompile = Params.Decompile,
				NoScripts = Params.NoScripts,
				Timeout = Params.Timeout,
			})
		end)

		if success then
			statusLabel.Text = "✅ Map berhasil disimpan! Cek folder executor."
			statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
			print("[MapSaver] ✅ Selesai! Cek folder 'workspace' di executor kamu.")
		else
			statusLabel.Text = "❌ Gagal: " .. tostring(err)
			statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			print("[MapSaver] ❌ Error: " .. tostring(err))
		end
	end)
end)

-- Open main window
Tween(Main, {Size = UDim2.new(0, 420, 0, 480)}, Animations.Back)
print("[MapSaver] UI Loaded!")
