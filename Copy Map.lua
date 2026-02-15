-- ROBLOX MAP EXPORTER - UNIVERSAL
-- Author: Nyemek Hub
-- Support: All Executors
-- Github: [Your Repo URL]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Map Exporter",
   LoadingTitle = "Loading XML Serializer...",
   LoadingSubtitle = "Universal Export System",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("📤 Export", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)
local webhookUrl = ""

-- DETEKSI HTTP REQUEST
local httpRequest = nil
if syn and syn.request then
    httpRequest = syn.request
elseif request then
    httpRequest = request
elseif http and http.request then
    httpRequest = http.request
elseif http_request then
    httpRequest = http_request
end

-- DETEKSI WRITEFILE
local hasWriteFile = (writefile and readfile and isfolder and makefolder) ~= nil

SettingsTab:CreateInput({
   Name = "Discord Webhook URL",
   PlaceholderText = "Paste your webhook here...",
   Callback = function(Text) webhookUrl = Text end,
})

-- COUNTER REFERENT
local refCounter = 0
local function GetRef()
    refCounter = refCounter + 1
    return string.format("RBX%08X", refCounter)
end

-- ESCAPE XML
local function escapeXML(str)
    if type(str) ~= "string" then return tostring(str) end
    return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;")
end

-- PROPERTY TO XML
local function PropertyToXML(propName, propValue, propType)
    if propType == "CFrame" then
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = propValue:GetComponents()
        return string.format('<CoordinateFrame name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z><R00>%f</R00><R01>%f</R01><R02>%f</R02><R10>%f</R10><R11>%f</R11><R12>%f</R12><R20>%f</R20><R21>%f</R21><R22>%f</R22></CoordinateFrame>',
            propName, x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    elseif propType == "Vector3" then
        return string.format('<Vector3 name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z></Vector3>', propName, propValue.X, propValue.Y, propValue.Z)
    elseif propType == "Vector2" then
        return string.format('<Vector2 name="%s"><X>%f</X><Y>%f</Y></Vector2>', propName, propValue.X, propValue.Y)
    elseif propType == "Color3" then
        return string.format('<Color3 name="%s"><R>%f</R><G>%f</G><B>%f</B></Color3>', propName, propValue.R, propValue.G, propValue.B)
    elseif propType == "BrickColor" then
        return string.format('<int name="%s">%d</int>', propName, propValue.Number)
    elseif propType == "UDim2" then
        return string.format('<UDim2 name="%s"><XS>%f</XS><XO>%d</XO><YS>%f</YS><YO>%d</YO></UDim2>', 
            propName, propValue.X.Scale, propValue.X.Offset, propValue.Y.Scale, propValue.Y.Offset)
    elseif propType == "UDim" then
        return string.format('<UDim name="%s"><S>%f</S><O>%d</O></UDim>', propName, propValue.Scale, propValue.Offset)
    elseif propType == "Enum" or propType == "EnumItem" then
        return string.format('<token name="%s">%d</token>', propName, propValue.Value)
    elseif type(propValue) == "boolean" then
        return string.format('<bool name="%s">%s</bool>', propName, tostring(propValue))
    elseif type(propValue) == "number" then
        if math.floor(propValue) == propValue then
            return string.format('<int name="%s">%d</int>', propName, propValue)
        else
            return string.format('<float name="%s">%f</float>', propName, propValue)
        end
    elseif type(propValue) == "string" then
        return string.format('<string name="%s">%s</string>', propName, escapeXML(propValue))
    end
    return ""
end

-- IMPORTANT PROPERTIES
local importantProps = {
    BasePart = {"CFrame", "Size", "Color", "Material", "Transparency", "CanCollide", "Anchored", "BrickColor", "Reflectance", "TopSurface", "BottomSurface", "LeftSurface", "RightSurface", "FrontSurface", "BackSurface"},
    Model = {"PrimaryPart"},
    Part = {"Shape", "FormFactor"},
    MeshPart = {"MeshId", "TextureID"},
    UnionOperation = {"UsePartColor"},
    SpecialMesh = {"MeshType", "MeshId", "TextureId", "Scale", "Offset"},
    BlockMesh = {"Scale", "Offset"},
    CylinderMesh = {"Scale", "Offset"},
    Decal = {"Texture", "Face", "Transparency", "Color3"},
    Texture = {"Texture", "Face", "Transparency", "Color3", "StudsPerTileU", "StudsPerTileV"},
    SurfaceGui = {"Face", "CanvasSize", "LightInfluence", "AlwaysOnTop"},
    BillboardGui = {"Size", "ExtentsOffset", "AlwaysOnTop", "MaxDistance"},
    ScreenGui = {"ResetOnSpawn", "DisplayOrder", "IgnoreGuiInset"},
    GuiObject = {"Size", "Position", "Visible", "BackgroundColor3", "BackgroundTransparency", "BorderSizePixel", "ZIndex", "LayoutOrder"},
    TextLabel = {"Text", "TextColor3", "Font", "TextSize", "TextWrapped", "TextXAlignment", "TextYAlignment", "TextStrokeTransparency", "TextStrokeColor3"},
    TextButton = {"Text", "TextColor3", "Font", "TextSize", "AutoButtonColor"},
    TextBox = {"Text", "TextColor3", "Font", "TextSize", "PlaceholderText", "ClearTextOnFocus"},
    ImageLabel = {"Image", "ImageColor3", "ImageTransparency", "ScaleType", "ImageRectOffset", "ImageRectSize"},
    ImageButton = {"Image", "ImageColor3", "ImageTransparency", "ScaleType"},
    Frame = {"BackgroundColor3", "BackgroundTransparency", "BorderColor3"},
    ScrollingFrame = {"CanvasSize", "ScrollBarThickness", "ScrollingDirection", "ScrollBarImageColor3"},
    ViewportFrame = {"LightDirection", "LightColor", "Ambient"},
    Light = {"Brightness", "Range", "Color", "Shadows"},
    PointLight = {"Brightness", "Range", "Color"},
    SpotLight = {"Brightness", "Range", "Color", "Angle", "Face"},
    SurfaceLight = {"Brightness", "Range", "Color", "Angle", "Face"},
    Fire = {"Size", "Heat", "Color", "SecondaryColor", "Enabled"},
    Smoke = {"Size", "Opacity", "RiseVelocity", "Color", "Enabled"},
    Sparkles = {"SparkleColor", "Enabled"},
    ParticleEmitter = {"Rate", "Lifetime", "Speed", "Color", "Size", "Texture", "Transparency", "LightEmission", "Enabled"},
    Trail = {"Attachment0", "Attachment1", "Color", "Lifetime", "MinLength", "Transparency", "Width"},
    Beam = {"Attachment0", "Attachment1", "Width0", "Width1", "Color", "Transparency", "LightEmission", "Texture"},
    Attachment = {"CFrame", "Visible"},
    Weld = {"Part0", "Part1", "C0", "C1"},
    WeldConstraint = {"Part0", "Part1"},
    Motor6D = {"Part0", "Part1", "C0", "C1"},
    Humanoid = {"MaxHealth", "Health", "WalkSpeed", "JumpPower", "DisplayDistanceType"},
    Animation = {"AnimationId"},
    Sound = {"SoundId", "Volume", "Looped", "PlaybackSpeed", "TimePosition"},
    Sky = {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"},
    Atmosphere = {"Density", "Offset", "Color", "Decay", "Glare", "Haze"},
    BloomEffect = {"Intensity", "Size", "Threshold"},
    BlurEffect = {"Size"},
    ColorCorrectionEffect = {"Brightness", "Contrast", "Saturation", "TintColor"},
    SunRaysEffect = {"Intensity", "Spread"},
}

-- GET XML RECURSIVE
local function GetXML(obj, depth)
    depth = depth or 0
    if depth > 150 then return "" end
    
    if obj:IsA("Terrain") or obj:IsA("Camera") or obj.ClassName == "Player" or obj.ClassName == "PlayerGui" then 
        return "" 
    end
    
    local xml = {}
    local ref = GetRef()
    
    table.insert(xml, string.format('<Item class="%s" referent="%s">', obj.ClassName, ref))
    table.insert(xml, "<Properties>")
    
    table.insert(xml, string.format('<string name="Name">%s</string>', escapeXML(obj.Name)))
    
    if obj:IsA("LuaSourceContainer") then
        local success, src = pcall(function() return obj.Source end)
        if success and src and src ~= "" then
            src = src:gsub("]]>", "]]]]><![CDATA[>")
            table.insert(xml, '<ProtectedString name="Source"><![CDATA[' .. src .. ']]></ProtectedString>')
        else
            table.insert(xml, '<ProtectedString name="Source"></ProtectedString>')
        end
    end
    
    for className, props in pairs(importantProps) do
        if obj:IsA(className) then
            for _, propName in ipairs(props) do
                local success, propValue = pcall(function() return obj[propName] end)
                if success and propValue ~= nil then
                    local propType = typeof(propValue)
                    local propXML = PropertyToXML(propName, propValue, propType)
                    if propXML ~= "" then
                        table.insert(xml, propXML)
                    end
                end
            end
        end
    end
    
    table.insert(xml, "</Properties>")
    
    local success, children = pcall(function() return obj:GetChildren() end)
    if success and children then
        for _, child in ipairs(children) do
            local childXML = GetXML(child, depth + 1)
            if childXML ~= "" then
                table.insert(xml, childXML)
            end
        end
    end
    
    table.insert(xml, "</Item>")
    
    return table.concat(xml, "\n")
end

-- SEND VIA HTTP
local function SendViaHTTP(serviceName, finalData, fileName)
    local boundary = "----NyemekBoundary" .. tostring(tick()):gsub("%.", "")
    
    local payload = "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="content"\r\n\r\n'
    payload = payload .. '✅ **Export Success!**\n📦 **Service:** `' .. serviceName .. '`\n📊 **Size:** ' .. string.format("%.2f", #finalData/1024) .. ' KB\n⏰ **Time:** ' .. os.date("%H:%M:%S") .. '\n\n**How to import:**\n1. Download `.rbxmx` file\n2. Open Roblox Studio\n3. `Insert → Insert from File`\n4. Select the file\n5. Done! ✨\r\n'
    payload = payload .. "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="file"; filename="' .. fileName .. '"\r\n'
    payload = payload .. "Content-Type: application/xml\r\n\r\n"
    payload = payload .. finalData .. "\r\n"
    payload = payload .. "--" .. boundary .. "--\r\n"
    
    local success, response = pcall(function()
        return httpRequest({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = payload
        })
    end)
    
    return success and response and (response.Success or response.StatusCode == 200 or response.StatusCode == 204)
end

-- SAVE TO FILE
local function SaveToFile(serviceName, finalData, fileName)
    if not hasWriteFile then return false end
    
    local folderName = "NyemekExports"
    if not isfolder(folderName) then
        makefolder(folderName)
    end
    
    local filePath = folderName .. "/" .. fileName
    writefile(filePath, finalData)
    
    return true, filePath
end

-- MAIN EXPORT
local function SendExport(serviceName)
    if webhookUrl == "" and not hasWriteFile then 
        Rayfield:Notify({
            Title = "❌ Error", 
            Content = "Set webhook first or use executor with writefile!", 
            Duration = 5
        })
        return 
    end
    
    Rayfield:Notify({
        Title = "⏳ Exporting", 
        Content = "Processing " .. serviceName .. "...", 
        Duration = 2
    })
    
    refCounter = 0
    
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local service = game:GetService(serviceName)
    local body = ""
    local childCount = 0
    
    for _, child in ipairs(service:GetChildren()) do
        body = body .. GetXML(child)
        childCount = childCount + 1
    end
    
    if childCount == 0 then
        Rayfield:Notify({
            Title = "⚠️ Empty", 
            Content = serviceName .. " is empty!", 
            Duration = 3
        })
        return
    end
    
    local footer = "\n</roblox>"
    local finalData = header .. body .. footer
    local fileName = serviceName .. "_" .. os.date("%Y%m%d_%H%M%S") .. ".rbxmx"
    
    if webhookUrl ~= "" and httpRequest then
        local success = SendViaHTTP(serviceName, finalData, fileName)
        if success then
            Rayfield:Notify({
                Title = "✅ Sent to Discord!", 
                Content = fileName .. "\nCheck your webhook!", 
                Duration = 6
            })
            return
        else
            Rayfield:Notify({
                Title = "⚠️ HTTP Failed", 
                Content = "Trying file save...", 
                Duration = 2
            })
        end
    end
    
    if hasWriteFile then
        local success, filePath = SaveToFile(serviceName, finalData, fileName)
        if success then
            Rayfield:Notify({
                Title = "✅ File Saved!", 
                Content = "Path: " .. filePath, 
                Duration = 6
            })
            return
        end
    end
    
    Rayfield:Notify({
        Title = "❌ Export Failed", 
        Content = "Executor not supported!", 
        Duration = 5
    })
end

-- EXPORT BUTTONS
Tab:CreateButton({
    Name = "📤 Export Workspace",
    Callback = function() SendExport("Workspace") end
})

Tab:CreateButton({
    Name = "🎨 Export StarterGui",
    Callback = function() SendExport("StarterGui") end
})

Tab:CreateButton({
    Name = "📦 Export ReplicatedStorage",
    Callback = function() SendExport("ReplicatedStorage") end
})

Tab:CreateButton({
    Name = "🎮 Export ServerScriptService",
    Callback = function() SendExport("ServerScriptService") end
})

Tab:CreateButton({
    Name = "⚙️ Export ServerStorage",
    Callback = function() SendExport("ServerStorage") end
})

Tab:CreateButton({
    Name = "💡 Export Lighting",
    Callback = function() SendExport("Lighting") end
})

Tab:CreateButton({
    Name = "🔊 Export SoundService",
    Callback = function() SendExport("SoundService") end
})

-- STATUS
local statusText = "🔍 Executor Status:\n\n"
if httpRequest then
    statusText = statusText .. "✅ HTTP: Supported\n"
else
    statusText = statusText .. "❌ HTTP: Not Supported\n"
end
if hasWriteFile then
    statusText = statusText .. "✅ WriteFile: Supported\n"
else
    statusText = statusText .. "❌ WriteFile: Not Supported\n"
end
statusText = statusText .. "\n📝 Export Format: .rbxmx (XML)\n"
statusText = statusText .. "📥 Import via: Insert from File"

SettingsTab:CreateParagraph({Title = "System Info", Content = statusText})

-- CREDITS
SettingsTab:CreateParagraph({
    Title = "📌 Credits", 
    Content = "Created by: Nyemek Hub\nVersion: 2.0 Universal\nSupport: All Executors\n\n⭐ Star on GitHub!"
})

Rayfield:Notify({
    Title = "✅ Loaded Successfully", 
    Content = "Nyemek Hub Map Exporter Ready!", 
    Duration = 4
})
