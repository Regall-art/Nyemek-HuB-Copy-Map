-- FPS OPTIMIZER - RAYFIELD STYLE
-- With Built-in Logo (No Upload Needed!)
-- Logo embedded using Roblox rendering

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

print("\n" .. string.rep("=", 70))
print("FPS OPTIMIZER - RAYFIELD STYLE")
print("With Custom NY Logo")
print(string.rep("=", 70) .. "\n")

-- Rayfield Colors
local Theme = {
   Background = Color3.fromRGB(25, 25, 25),
   Topbar = Color3.fromRGB(30, 30, 30),
   TabBackground = Color3.fromRGB(20, 20, 20),
   ElementBackground = Color3.fromRGB(35, 35, 35),
   ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
   ElementStroke = Color3.fromRGB(50, 50, 50),
   ToggleBackground = Color3.fromRGB(30, 30, 30),
   ToggleEnabled = Color3.fromRGB(0, 125, 255),
   ToggleDisabled = Color3.fromRGB(180, 180, 180),
   ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
   ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
   TextColor = Color3.fromRGB(240, 240, 240),
   TextDark = Color3.fromRGB(150, 150, 150)
}

local Animations = {
   Quart = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
   Quint = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
   Back = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
   Linear = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
}

local function Tween(obj, props, info)
   TweenService:Create(obj, info or Animations.Quart, props):Play()
end

local function MakeDraggable(frame, handle)
   local dragging, dragInput, dragStart, startPos
   handle = handle or frame
   
   handle.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
         dragging = true
         dragStart = input.Position
         startPos = frame.Position
         
         input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
               dragging = false
            end
         end)
      end
   end)
   
   UserInputService.InputChanged:Connect(function(input)
      if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
         local delta = input.Position - dragStart
         Tween(frame, {
            Position = UDim2.new(
               startPos.X.Scale,
               startPos.X.Offset + delta.X,
               startPos.Y.Scale,
               startPos.Y.Offset + delta.Y
            )
         }, Animations.Linear)
      end
   end)
end

-- Create Custom NY Logo
local function CreateNYLogo(parent)
   -- Background gradient
   local LogoBg = Instance.new("Frame")
   LogoBg.Size = UDim2.new(1, 0, 1, 0)
   LogoBg.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
   LogoBg.BorderSizePixel = 0
   LogoBg.Parent = parent
   
   local BgCorner = Instance.new("UICorner")
   BgCorner.CornerRadius = UDim.new(0, 12)
   BgCorner.Parent = LogoBg
   
   local BgGradient = Instance.new("UIGradient")
   BgGradient.Color = ColorSequence.new({
      ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 180, 255)),
      ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
      ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 160, 100))
   })
   BgGradient.Rotation = 135
   BgGradient.Parent = LogoBg
   
   -- N letter
   local NLetter = Instance.new("TextLabel")
   NLetter.Size = UDim2.new(0.5, 0, 0.8, 0)
   NLetter.Position = UDim2.new(0.05, 0, 0.1, 0)
   NLetter.BackgroundTransparency = 1
   NLetter.Text = "N"
   NLetter.TextColor3 = Color3.fromRGB(50, 130, 255)
   NLetter.TextSize = 40
   NLetter.Font = Enum.Font.GothamBlack
   NLetter.TextScaled = true
   NLetter.Parent = LogoBg
   
   -- Y letter
   local YLetter = Instance.new("TextLabel")
   YLetter.Size = UDim2.new(0.5, 0, 0.8, 0)
   YLetter.Position = UDim2.new(0.45, 0, 0.1, 0)
   YLetter.BackgroundTransparency = 1
   YLetter.Text = "y"
   YLetter.TextColor3 = Color3.fromRGB(255, 140, 80)
   YLetter.TextSize = 40
   YLetter.Font = Enum.Font.GothamBlack
   YLetter.TextScaled = true
   YLetter.Parent = LogoBg
   
   return LogoBg
end

-- UI Library
local Rayfield = {}

function Rayfield:CreateWindow(config)
   local WindowName = config.Name or "Rayfield UI"
   
   local ScreenGui = Instance.new("ScreenGui")
   ScreenGui.Name = "RayfieldUI"
   ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
   ScreenGui.ResetOnSpawn = false
   
   pcall(function()
      ScreenGui.Parent = CoreGui
   end)
   
   if ScreenGui.Parent ~= CoreGui then
      ScreenGui.Parent = player.PlayerGui
   end
   
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
   
   local MainCorner = Instance.new("UICorner")
   MainCorner.CornerRadius = UDim.new(0, 6)
   MainCorner.Parent = Main
   
   local MainStroke = Instance.new("UIStroke")
   MainStroke.Color = Color3.fromRGB(60, 60, 60)
   MainStroke.Thickness = 1
   MainStroke.Parent = Main
   
   -- Shadow
   local Shadow = Instance.new("ImageLabel")
   Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
   Shadow.BackgroundTransparency = 1
   Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
   Shadow.Size = UDim2.new(1, 47, 1, 47)
   Shadow.ZIndex = 0
   Shadow.Image = "rbxassetid://5554236805"
   Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
   Shadow.ImageTransparency = 0.5
   Shadow.ScaleType = Enum.ScaleType.Slice
   Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
   Shadow.Parent = Main
   
   -- Topbar
   local Topbar = Instance.new("Frame")
   Topbar.Size = UDim2.new(1, 0, 0, 42)
   Topbar.BackgroundColor3 = Theme.Topbar
   Topbar.BorderSizePixel = 0
   Topbar.Parent = Main
   
   local TopbarCorner = Instance.new("UICorner")
   TopbarCorner.CornerRadius = UDim.new(0, 6)
   TopbarCorner.Parent = Topbar
   
   local TopbarCover = Instance.new("Frame")
   TopbarCover.Size = UDim2.new(1, 0, 0, 6)
   TopbarCover.Position = UDim2.new(0, 0, 1, -6)
   TopbarCover.BackgroundColor3 = Theme.Topbar
   TopbarCover.BorderSizePixel = 0
   TopbarCover.Parent = Topbar
   
   -- Title
   local Title = Instance.new("TextLabel")
   Title.Size = UDim2.new(1, -50, 1, 0)
   Title.Position = UDim2.new(0, 12, 0, 0)
   Title.BackgroundTransparency = 1
   Title.Text = WindowName
   Title.TextColor3 = Theme.TextColor
   Title.TextSize = 15
   Title.Font = Enum.Font.GothamBold
   Title.TextXAlignment = Enum.TextXAlignment.Left
   Title.Parent = Topbar
   
   -- Close Button
   local CloseButton = Instance.new("ImageButton")
   CloseButton.Size = UDim2.new(0, 18, 0, 18)
   CloseButton.Position = UDim2.new(1, -30, 0.5, -9)
   CloseButton.BackgroundTransparency = 1
   CloseButton.Image = "rbxassetid://7733717447"
   CloseButton.ImageColor3 = Theme.TextColor
   CloseButton.Parent = Topbar
   
   -- Tab Container
   local TabContainer = Instance.new("ScrollingFrame")
   TabContainer.Size = UDim2.new(0, 155, 1, -52)
   TabContainer.Position = UDim2.new(0, 5, 0, 47)
   TabContainer.BackgroundColor3 = Theme.TabBackground
   TabContainer.BorderSizePixel = 0
   TabContainer.ScrollBarThickness = 0
   TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
   TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
   TabContainer.Parent = Main
   
   local TabContainerCorner = Instance.new("UICorner")
   TabContainerCorner.CornerRadius = UDim.new(0, 6)
   TabContainerCorner.Parent = TabContainer
   
   local TabList = Instance.new("UIListLayout")
   TabList.Padding = UDim.new(0, 3)
   TabList.Parent = TabContainer
   
   local TabPadding = Instance.new("UIPadding")
   TabPadding.PaddingTop = UDim.new(0, 5)
   TabPadding.PaddingLeft = UDim.new(0, 5)
   TabPadding.PaddingRight = UDim.new(0, 5)
   TabPadding.Parent = TabContainer
   
   -- Content Container
   local ContentContainer = Instance.new("Frame")
   ContentContainer.Size = UDim2.new(1, -170, 1, -52)
   ContentContainer.Position = UDim2.new(0, 165, 0, 47)
   ContentContainer.BackgroundTransparency = 1
   ContentContainer.Parent = Main
   
   -- Mini Button with NY LOGO
   local MiniButton = Instance.new("TextButton")
   MiniButton.Size = UDim2.new(0, 60, 0, 60)
   MiniButton.Position = UDim2.new(1, -70, 0.95, -70)
   MiniButton.BackgroundTransparency = 1
   MiniButton.Text = ""
   MiniButton.Visible = false
   MiniButton.AutoButtonColor = false
   MiniButton.Parent = ScreenGui
   
   -- Create NY Logo inside mini button
   CreateNYLogo(MiniButton)
   
   local MiniStroke = Instance.new("UIStroke")
   MiniStroke.Color = Color3.fromRGB(0, 170, 255)
   MiniStroke.Thickness = 3
   MiniStroke.Parent = MiniButton
   
   -- Close Button
   CloseButton.MouseButton1Click:Connect(function()
      Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, Animations.Back)
      task.wait(0.5)
      Main.Visible = false
      
      MiniButton.Visible = true
      MiniButton.Size = UDim2.new(0, 0, 0, 0)
      Tween(MiniButton, {Size = UDim2.new(0, 60, 0, 60)}, Animations.Back)
      
      task.spawn(function()
         while MiniButton.Visible do
            Tween(MiniButton, {Size = UDim2.new(0, 65, 0, 65)}, Animations.Quart)
            task.wait(1)
            Tween(MiniButton, {Size = UDim2.new(0, 60, 0, 60)}, Animations.Quart)
            task.wait(1)
         end
      end)
   end)
   
   -- Mini Button Click
   MiniButton.MouseButton1Click:Connect(function()
      Tween(MiniButton, {Size = UDim2.new(0, 0, 0, 0)}, Animations.Quart)
      task.wait(0.3)
      MiniButton.Visible = false
      
      Main.Visible = true
      Tween(Main, {Size = UDim2.new(0, 500, 0, 475)}, Animations.Back)
   end)
   
   -- Mini Button Hover
   MiniButton.MouseEnter:Connect(function()
      Tween(MiniButton, {Size = UDim2.new(0, 68, 0, 68)}, Animations.Quart)
   end)
   
   MiniButton.MouseLeave:Connect(function()
      Tween(MiniButton, {Size = UDim2.new(0, 60, 0, 60)}, Animations.Quart)
   end)
   
   -- Draggable
   MakeDraggable(Main, Topbar)
   MakeDraggable(MiniButton)
   
   -- Entrance
   Tween(Main, {Size = UDim2.new(0, 500, 0, 475)}, Animations.Back)
   
   task.wait(0.6)
   Rayfield:Notify({
      Title = "Welcome!",
      Content = WindowName .. " loaded successfully",
      Duration = 3
   })
   
   return {
      Main = Main,
      ContentContainer = ContentContainer,
      TabContainer = TabContainer,
      Tabs = {},
      CurrentTab = nil
   }
end

function Rayfield:CreateTab(Window, config)
   local TabName = config.Name or "Tab"
   
   local TabButton = Instance.new("TextButton")
   TabButton.Size = UDim2.new(1, 0, 0, 32)
   TabButton.BackgroundColor3 = Theme.ElementBackground
   TabButton.BackgroundTransparency = 1
   TabButton.BorderSizePixel = 0
   TabButton.Text = ""
   TabButton.AutoButtonColor = false
   TabButton.Parent = Window.TabContainer
   
   local TabCorner = Instance.new("UICorner")
   TabCorner.CornerRadius = UDim.new(0, 5)
   TabCorner.Parent = TabButton
   
   local TabTitle = Instance.new("TextLabel")
   TabTitle.Size = UDim2.new(1, -20, 1, 0)
   TabTitle.Position = UDim2.new(0, 10, 0, 0)
   TabTitle.BackgroundTransparency = 1
   TabTitle.Text = TabName
   TabTitle.TextColor3 = Theme.TextDark
   TabTitle.TextSize = 13
   TabTitle.Font = Enum.Font.GothamMedium
   TabTitle.TextXAlignment = Enum.TextXAlignment.Left
   TabTitle.Parent = TabButton
   
   local TabContent = Instance.new("ScrollingFrame")
   TabContent.Size = UDim2.new(1, -10, 1, -10)
   TabContent.Position = UDim2.new(0, 5, 0, 5)
   TabContent.BackgroundTransparency = 1
   TabContent.BorderSizePixel = 0
   TabContent.ScrollBarThickness = 3
   TabContent.ScrollBarImageColor3 = Color3.fromRGB(0, 125, 255)
   TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
   TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
   TabContent.Visible = false
   TabContent.Parent = Window.ContentContainer
   
   local ContentList = Instance.new("UIListLayout")
   ContentList.Padding = UDim.new(0, 8)
   ContentList.Parent = TabContent
   
   local ContentPadding = Instance.new("UIPadding")
   ContentPadding.PaddingLeft = UDim.new(0, 5)
   ContentPadding.PaddingRight = UDim.new(0, 5)
   ContentPadding.PaddingTop = UDim.new(0, 5)
   ContentPadding.Parent = TabContent
   
   local function SelectTab()
      for _, tab in pairs(Window.Tabs) do
         tab.Button.BackgroundTransparency = 1
         tab.Title.TextColor3 = Theme.TextDark
         tab.Content.Visible = false
      end
      
      Tween(TabButton, {BackgroundTransparency = 0}, Animations.Quart)
      Tween(TabTitle, {TextColor3 = Theme.TextColor}, Animations.Quart)
      TabContent.Visible = true
      Window.CurrentTab = TabName
   end
   
   TabButton.MouseButton1Click:Connect(SelectTab)
   
   TabButton.MouseEnter:Connect(function()
      if Window.CurrentTab ~= TabName then
         Tween(TabButton, {BackgroundTransparency = 0.5}, Animations.Quart)
      end
   end)
   
   TabButton.MouseLeave:Connect(function()
      if Window.CurrentTab ~= TabName then
         Tween(TabButton, {BackgroundTransparency = 1}, Animations.Quart)
      end
   end)
   
   local Tab = {
      Button = TabButton,
      Title = TabTitle,
      Content = TabContent,
      Select = SelectTab
   }
   
   Window.Tabs[TabName] = Tab
   
   if not Window.CurrentTab then
      SelectTab()
   end
   
   return Tab
end

function Rayfield:CreateButton(Tab, config)
   local ButtonFrame = Instance.new("Frame")
   ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
   ButtonFrame.BackgroundColor3 = Theme.ElementBackground
   ButtonFrame.BorderSizePixel = 0
   ButtonFrame.Parent = Tab.Content
   
   local ButtonCorner = Instance.new("UICorner")
   ButtonCorner.CornerRadius = UDim.new(0, 5)
   ButtonCorner.Parent = ButtonFrame
   
   local ButtonStroke = Instance.new("UIStroke")
   ButtonStroke.Color = Theme.ElementStroke
   ButtonStroke.Thickness = 1
   ButtonStroke.Parent = ButtonFrame
   
   local Button = Instance.new("TextButton")
   Button.Size = UDim2.new(1, 0, 1, 0)
   Button.BackgroundTransparency = 1
   Button.Text = ""
   Button.Parent = ButtonFrame
   
   local ButtonTitle = Instance.new("TextLabel")
   ButtonTitle.Size = UDim2.new(1, -20, 1, 0)
   ButtonTitle.Position = UDim2.new(0, 10, 0, 0)
   ButtonTitle.BackgroundTransparency = 1
   ButtonTitle.Text = config.Name or "Button"
   ButtonTitle.TextColor3 = Theme.TextColor
   ButtonTitle.TextSize = 13
   ButtonTitle.Font = Enum.Font.Gotham
   ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left
   ButtonTitle.Parent = ButtonFrame
   
   Button.MouseEnter:Connect(function()
      Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementBackgroundHover}, Animations.Quart)
   end)
   
   Button.MouseLeave:Connect(function()
      Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementBackground}, Animations.Quart)
   end)
   
   Button.MouseButton1Click:Connect(function()
      local Size = ButtonFrame.Size
      Tween(ButtonFrame, {Size = UDim2.new(Size.X.Scale, Size.X.Offset, 0, 32)}, Animations.Quart)
      task.wait(0.1)
      Tween(ButtonFrame, {Size = Size}, Animations.Quart)
      
      if config.Callback then
         pcall(config.Callback)
      end
   end)
end

function Rayfield:CreateToggle(Tab, config)
   local ToggleFrame = Instance.new("Frame")
   ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
   ToggleFrame.BackgroundColor3 = Theme.ElementBackground
   ToggleFrame.BorderSizePixel = 0
   ToggleFrame.Parent = Tab.Content
   
   local ToggleCorner = Instance.new("UICorner")
   ToggleCorner.CornerRadius = UDim.new(0, 5)
   ToggleCorner.Parent = ToggleFrame
   
   local ToggleStroke = Instance.new("UIStroke")
   ToggleStroke.Color = Theme.ElementStroke
   ToggleStroke.Thickness = 1
   ToggleStroke.Parent = ToggleFrame
   
   local ToggleTitle = Instance.new("TextLabel")
   ToggleTitle.Size = UDim2.new(1, -60, 1, 0)
   ToggleTitle.Position = UDim2.new(0, 10, 0, 0)
   ToggleTitle.BackgroundTransparency = 1
   ToggleTitle.Text = config.Name or "Toggle"
   ToggleTitle.TextColor3 = Theme.TextColor
   ToggleTitle.TextSize = 13
   ToggleTitle.Font = Enum.Font.Gotham
   ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
   ToggleTitle.Parent = ToggleFrame
   
   local ToggleButton = Instance.new("TextButton")
   ToggleButton.Size = UDim2.new(0, 40, 0, 20)
   ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
   ToggleButton.BackgroundColor3 = Theme.ToggleBackground
   ToggleButton.BorderSizePixel = 0
   ToggleButton.Text = ""
   ToggleButton.AutoButtonColor = false
   ToggleButton.Parent = ToggleFrame
   
   local ToggleCorner2 = Instance.new("UICorner")
   ToggleCorner2.CornerRadius = UDim.new(1, 0)
   ToggleCorner2.Parent = ToggleButton
   
   local ToggleStroke2 = Instance.new("UIStroke")
   ToggleStroke2.Color = Theme.ToggleDisabledStroke
   ToggleStroke2.Thickness = 1
   ToggleStroke2.Parent = ToggleButton
   
   local Indicator = Instance.new("Frame")
   Indicator.Size = UDim2.new(0, 16, 0, 16)
   Indicator.Position = UDim2.new(0, 2, 0.5, -8)
   Indicator.BackgroundColor3 = Theme.ToggleDisabled
   Indicator.BorderSizePixel = 0
   Indicator.Parent = ToggleButton
   
   local IndicatorCorner = Instance.new("UICorner")
   IndicatorCorner.CornerRadius = UDim.new(1, 0)
   IndicatorCorner.Parent = Indicator
   
   local toggled = config.CurrentValue or false
   
   local function Update()
      if toggled then
         Tween(Indicator, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.ToggleEnabled}, Animations.Quart)
         Tween(ToggleStroke2, {Color = Theme.ToggleEnabledStroke}, Animations.Quart)
      else
         Tween(Indicator, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.ToggleDisabled}, Animations.Quart)
         Tween(ToggleStroke2, {Color = Theme.ToggleDisabledStroke}, Animations.Quart)
      end
   end
   
   Update()
   
   ToggleButton.MouseButton1Click:Connect(function()
      toggled = not toggled
      Update()
      if config.Callback then
         pcall(config.Callback, toggled)
      end
   end)
end

function Rayfield:CreateParagraph(Tab, config)
   local Frame = Instance.new("Frame")
   Frame.Size = UDim2.new(1, 0, 0, 0)
   Frame.AutomaticSize = Enum.AutomaticSize.Y
   Frame.BackgroundColor3 = Theme.ElementBackground
   Frame.BorderSizePixel = 0
   Frame.Parent = Tab.Content
   
   local Corner = Instance.new("UICorner")
   Corner.CornerRadius = UDim.new(0, 5)
   Corner.Parent = Frame
   
   local Stroke = Instance.new("UIStroke")
   Stroke.Color = Theme.ElementStroke
   Stroke.Thickness = 1
   Stroke.Parent = Frame
   
   local Padding = Instance.new("UIPadding")
   Padding.PaddingTop = UDim.new(0, 10)
   Padding.PaddingBottom = UDim.new(0, 10)
   Padding.PaddingLeft = UDim.new(0, 10)
   Padding.PaddingRight = UDim.new(0, 10)
   Padding.Parent = Frame
   
   local Title = Instance.new("TextLabel")
   Title.Size = UDim2.new(1, 0, 0, 16)
   Title.BackgroundTransparency = 1
   Title.Text = config.Title or "Title"
   Title.TextColor3 = Theme.TextColor
   Title.TextSize = 13
   Title.Font = Enum.Font.GothamBold
   Title.TextXAlignment = Enum.TextXAlignment.Left
   Title.Parent = Frame
   
   local Content = Instance.new("TextLabel")
   Content.Size = UDim2.new(1, 0, 0, 0)
   Content.Position = UDim2.new(0, 0, 0, 20)
   Content.AutomaticSize = Enum.AutomaticSize.Y
   Content.BackgroundTransparency = 1
   Content.Text = config.Content or "Content"
   Content.TextColor3 = Theme.TextDark
   Content.TextSize = 12
   Content.Font = Enum.Font.Gotham
   Content.TextXAlignment = Enum.TextXAlignment.Left
   Content.TextWrapped = true
   Content.Parent = Frame
end

function Rayfield:Notify(config)
   local Notif = Instance.new("Frame")
   Notif.Size = UDim2.new(0, 300, 0, 75)
   Notif.Position = UDim2.new(1, 310, 1, -85)
   Notif.BackgroundColor3 = Theme.ElementBackground
   Notif.BorderSizePixel = 0
   
   pcall(function()
      Notif.Parent = CoreGui:FindFirstChild("RayfieldUI")
   end)
   
   if not Notif.Parent then
      Notif.Parent = player.PlayerGui:FindFirstChild("RayfieldUI") or player.PlayerGui
   end
   
   local Corner = Instance.new("UICorner")
   Corner.CornerRadius = UDim.new(0, 6)
   Corner.Parent = Notif
   
   local Stroke = Instance.new("UIStroke")
   Stroke.Color = Color3.fromRGB(0, 125, 255)
   Stroke.Thickness = 1
   Stroke.Parent = Notif
   
   local Title = Instance.new("TextLabel")
   Title.Size = UDim2.new(1, -20, 0, 18)
   Title.Position = UDim2.new(0, 10, 0, 10)
   Title.BackgroundTransparency = 1
   Title.Text = config.Title or "Notification"
   Title.TextColor3 = Theme.TextColor
   Title.TextSize = 14
   Title.Font = Enum.Font.GothamBold
   Title.TextXAlignment = Enum.TextXAlignment.Left
   Title.Parent = Notif
   
   local Content = Instance.new("TextLabel")
   Content.Size = UDim2.new(1, -20, 0, 37)
   Content.Position = UDim2.new(0, 10, 0, 33)
   Content.BackgroundTransparency = 1
   Content.Text = config.Content or "Content"
   Content.TextColor3 = Theme.TextDark
   Content.TextSize = 12
   Content.Font = Enum.Font.Gotham
   Content.TextXAlignment = Enum.TextXAlignment.Left
   Content.TextWrapped = true
   Content.Parent = Notif
   
   Tween(Notif, {Position = UDim2.new(1, -310, 1, -85)}, Animations.Quint)
   task.wait(config.Duration or 3)
   Tween(Notif, {Position = UDim2.new(1, 310, 1, -85)}, Animations.Quint)
   task.wait(0.3)
   Notif:Destroy()
end

-- FPS OPTIMIZER (Continuing in next part due to length...)
-- [INSERT REST OF FPS OPTIMIZER CODE HERE - Same as before]

local Window = Rayfield:CreateWindow({Name = "FPS Optimizer Pro"})
local BoostTab = Rayfield:CreateTab(Window, {Name = "⚡ Boost"})
local GraphicsTab = Rayfield:CreateTab(Window, {Name = "🎨 Graphics"})
local SystemTab = Rayfield:CreateTab(Window, {Name = "🛠️ System"})
local InfoTab = Rayfield:CreateTab(Window, {Name = "ℹ️ Info"})

Rayfield:CreateParagraph(BoostTab, {Title = "Quick Boost Modes", Content = "Select a preset to instantly boost your FPS. All modes are collision-safe!"})
Rayfield:CreateButton(BoostTab, {Name = "🚀 Ultra Boost", Callback = function() ApplyUltraBoost() Rayfield:Notify({Title = "Ultra Boost", Content = "Applied!", Duration = 3}) end})
Rayfield:CreateButton(BoostTab, {Name = "🥔 Potato Mode", Callback = function() ApplyPotatoMode() Rayfield:Notify({Title = "Potato Mode", Content = "Activated!", Duration = 3}) end})
Rayfield:CreateButton(BoostTab, {Name = "⚡ Performance Mode", Callback = function() ApplyPerformanceMode() Rayfield:Notify({Title = "Performance", Content = "Applied!", Duration = 3}) end})
Rayfield:CreateToggle(BoostTab, {Name = "Show FPS Counter", CurrentValue = false, Callback = function(value) ShowFPSCounter(value) end})

Rayfield:CreateParagraph(GraphicsTab, {Title = "Visual Optimization", Content = "Toggle individual graphics optimizations."})
Rayfield:CreateToggle(GraphicsTab, {Name = "Remove Textures", CurrentValue = false, Callback = function(value) if value then RemoveTextures() Rayfield:Notify({Title = "Textures", Content = "Removed!", Duration = 2}) end end})
Rayfield:CreateToggle(GraphicsTab, {Name = "Remove Particles", CurrentValue = false, Callback = function(value) if value then RemoveParticles() Rayfield:Notify({Title = "Particles", Content = "Removed!", Duration = 2}) end end})
Rayfield:CreateToggle(GraphicsTab, {Name = "Remove Shadows", CurrentValue = false, Callback = function(value) RemoveShadows(value) if value then Rayfield:Notify({Title = "Shadows", Content = "Disabled!", Duration = 2}) end end})
Rayfield:CreateToggle(GraphicsTab, {Name = "Remove Fog", CurrentValue = false, Callback = function(value) RemoveFog(value) if value then Rayfield:Notify({Title = "Fog", Content = "Removed!", Duration = 2}) end end})

Rayfield:CreateParagraph(SystemTab, {Title = "Memory & Performance", Content = "Optimize system resources."})
Rayfield:CreateButton(SystemTab, {Name = "🧹 Clear Memory", Callback = function() ClearMemory() Rayfield:Notify({Title = "Memory", Content = "Cleared!", Duration = 2}) end})
Rayfield:CreateButton(SystemTab, {Name = "🗑️ Remove Assets", Callback = function() RemoveUnusedAssets() Rayfield:Notify({Title = "Assets", Content = "Removed!", Duration = 2}) end})
Rayfield:CreateButton(SystemTab, {Name = "⚙️ Optimize Workspace", Callback = function() OptimizeWorkspace() Rayfield:Notify({Title = "Workspace", Content = "Optimized!", Duration = 2}) end})
Rayfield:CreateButton(SystemTab, {Name = "🔧 Fix Physics", Callback = function() FixPhysics() Rayfield:Notify({Title = "Physics", Content = "Fixed!", Duration = 2}) end})

Rayfield:CreateParagraph(InfoTab, {Title = "About", Content = "Universal FPS Optimizer for all Roblox games."})
Rayfield:CreateParagraph(InfoTab, {Title = "🎮 Low-End PC", Content = "Use Potato Mode for maximum FPS."})
Rayfield:CreateParagraph(InfoTab, {Title = "💻 Mid-Range PC", Content = "Use Performance Mode for balance."})
Rayfield:CreateParagraph(InfoTab, {Title = "🖥️ High-End PC", Content = "Remove shadows only."})

function ApplyUltraBoost() print("⚡ Ultra") RemoveTextures() RemoveParticles() RemoveShadows(true) RemoveFog(true) OptimizeWorkspace() print("✅ Done") end
function ApplyPotatoMode() print("🥔 Potato") for _, obj in pairs(Workspace:GetDescendants()) do pcall(function() if obj:IsA("Texture") then obj:Destroy() end if obj:IsA("Decal") then obj:Destroy() end if obj:IsA("ParticleEmitter") then obj:Destroy() end if obj:IsA("Trail") then obj:Destroy() end if obj:IsA("MeshPart") then obj.TextureID = "" end end) end Lighting.GlobalShadows = false Lighting.FogEnd = 100000 settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 print("✅ Done") end
function ApplyPerformanceMode() print("⚡ Perf") RemoveShadows(true) RemoveFog(true) RemoveParticles() Lighting.Brightness = 2 print("✅ Done") end
function RemoveTextures() local c = 0 for _, obj in pairs(Workspace:GetDescendants()) do pcall(function() if obj:IsA("Texture") then obj:Destroy() c = c + 1 elseif obj:IsA("MeshPart") then obj.TextureID = "" c = c + 1 end end) end print("✅ Removed " .. c .. " textures") end
function RemoveParticles() local c = 0 for _, obj in pairs(Workspace:GetDescendants()) do pcall(function() if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then obj:Destroy() c = c + 1 end end) end print("✅ Removed " .. c .. " particles") end
function RemoveShadows(e) if e then Lighting.GlobalShadows = false for _, obj in pairs(Workspace:GetDescendants()) do pcall(function() if obj:IsA("BasePart") then obj.CastShadow = false end end) end print("✅ Shadows off") else Lighting.GlobalShadows = true end end
function RemoveFog(e) Lighting.FogEnd = e and 100000 or 500 print("✅ Fog " .. (e and "off" or "on")) end
function ClearMemory() for i = 1, 10 do wait() collectgarbage("collect") end print("✅ Memory cleared") end
function RemoveUnusedAssets() local c = 0 for _, obj in pairs(Workspace:GetDescendants()) do pcall(function() if obj:IsA("Sound") and not obj.IsPlaying then obj:Destroy() c = c + 1 end end) end print("✅ Removed " .. c .. " assets") end
function OptimizeWorkspace() for _, obj in pairs(Workspace:GetDescendants()) do pcall(function() if obj:IsA("BasePart") and obj.Transparency >= 0.98 then obj.Material = Enum.Material.SmoothPlastic end end) end print("✅ Workspace OK") end
function FixPhysics() for _, obj in pairs(Workspace:GetDescendants()) do pcall(function() if obj:IsA("BasePart") then obj.Massless = true end end) end print("✅ Physics OK") end
function ShowFPSCounter(e) if e then if player.PlayerGui:FindFirstChild("FPSCounter") then player.PlayerGui.FPSCounter:Destroy() end local g = Instance.new("ScreenGui") g.Name = "FPSCounter" g.ResetOnSpawn = false g.Parent = player.PlayerGui local f = Instance.new("Frame") f.Size = UDim2.new(0, 90, 0, 55) f.Position = UDim2.new(1, -100, 0, 10) f.BackgroundColor3 = Color3.fromRGB(25, 25, 25) f.BorderSizePixel = 0 f.Parent = g local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = f local s = Instance.new("UIStroke") s.Color = Color3.fromRGB(0, 125, 255) s.Thickness = 1 s.Parent = f local l = Instance.new("TextLabel") l.Size = UDim2.new(1, 0, 0, 18) l.Position = UDim2.new(0, 0, 0, 6) l.BackgroundTransparency = 1 l.Text = "FPS" l.TextColor3 = Color3.fromRGB(150, 150, 150) l.TextSize = 10 l.Font = Enum.Font.GothamBold l.Parent = f local v = Instance.new("TextLabel") v.Size = UDim2.new(1, 0, 0, 28) v.Position = UDim2.new(0, 0, 0, 22) v.BackgroundTransparency = 1 v.Text = "60" v.TextColor3 = Color3.fromRGB(0, 200, 255) v.TextSize = 24 v.Font = Enum.Font.GothamBold v.Parent = f task.spawn(function() while v.Parent do pcall(function() local fps = math.floor(1 / RunService.RenderStepped:Wait()) v.Text = tostring(fps) if fps >= 60 then v.TextColor3 = Color3.fromRGB(0, 200, 255) elseif fps >= 30 then v.TextColor3 = Color3.fromRGB(255, 200, 0) else v.TextColor3 = Color3.fromRGB(255, 50, 50) end end) wait(0.5) end end) else if player.PlayerGui:FindFirstChild("FPSCounter") then player.PlayerGui.FPSCounter:Destroy() end end end

print("\n✅ FPS OPTIMIZER LOADED!")
print("🎨 Rayfield Style with NY Logo")
print("💡 Logo built-in, no upload needed!")
print(string.rep("=", 70) .. "\n")
