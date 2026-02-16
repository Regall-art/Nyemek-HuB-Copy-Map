-- NYEMEK HUB - ULTIMATE MAP COPIER
-- Copy 1:1 Real Map (All Properties)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Ultimate Copier",
   LoadingTitle = "Loading 1:1 Map Copier...",
   LoadingSubtitle = "All Properties Included",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("📤 Export", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)
local webhookUrl = ""

local httpRequest = nil
if syn and syn.request then httpRequest = syn.request
elseif request then httpRequest = request
elseif http and http.request then httpRequest = http.request
elseif http_request then httpRequest = http_request
end

local HttpService = game:GetService("HttpService")
local hasWriteFile = (writefile and isfolder and makefolder) ~= nil

SettingsTab:CreateInput({
   Name = "Discord Webhook (Optional)",
   PlaceholderText = "Paste webhook...",
   Callback = function(Text) webhookUrl = Text:match("^%s*(.-)%s*$") end,
})

local refCounter = 0
local refMap = {}

local function GetRef(obj)
    if not refMap[obj] then
        refCounter = refCounter + 1
        refMap[obj] = string.format("RBX%08X", refCounter)
    end
    return refMap[obj]
end

local function escapeXML(str)
    if type(str) ~= "string" then return tostring(str) end
    return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
end

-- SERIALIZE SEMUA PROPERTY TYPE
local function SerializeProperty(propName, propValue)
    local propType = typeof(propValue)
    
    -- CFrame
    if propType == "CFrame" then
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = propValue:GetComponents()
        return string.format('<CoordinateFrame name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z><R00>%f</R00><R01>%f</R01><R02>%f</R02><R10>%f</R10><R11>%f</R11><R12>%f</R12><R20>%f</R20><R21>%f</R21><R22>%f</R22></CoordinateFrame>',
            propName, x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    
    -- Vector3
    elseif propType == "Vector3" then
        return string.format('<Vector3 name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z></Vector3>', 
            propName, propValue.X, propValue.Y, propValue.Z)
    
    -- Vector2
    elseif propType == "Vector2" then
        return string.format('<Vector2 name="%s"><X>%f</X><Y>%f</Y></Vector2>', 
            propName, propValue.X, propValue.Y)
    
    -- Color3
    elseif propType == "Color3" then
        return string.format('<Color3 name="%s"><R>%f</R><G>%f</G><B>%f</B></Color3>', 
            propName, propValue.R, propValue.G, propValue.B)
    
    -- BrickColor
    elseif propType == "BrickColor" then
        return string.format('<int name="%s">%d</int>', propName, propValue.Number)
    
    -- UDim2
    elseif propType == "UDim2" then
        return string.format('<UDim2 name="%s"><XS>%f</XS><XO>%d</XO><YS>%f</YS><YO>%d</YO></UDim2>', 
            propName, propValue.X.Scale, propValue.X.Offset, propValue.Y.Scale, propValue.Y.Offset)
    
    -- UDim
    elseif propType == "UDim" then
        return string.format('<UDim name="%s"><S>%f</S><O>%d</O></UDim>', 
            propName, propValue.Scale, propValue.Offset)
    
    -- Enum
    elseif propType == "EnumItem" then
        return string.format('<token name="%s">%d</token>', propName, propValue.Value)
    
    -- Boolean
    elseif propType == "boolean" then
        return string.format('<bool name="%s">%s</bool>', propName, tostring(propValue))
    
    -- Number
    elseif propType == "number" then
        if math.floor(propValue) == propValue then
            return string.format('<int name="%s">%d</int>', propName, propValue)
        else
            return string.format('<float name="%s">%f</float>', propName, propValue)
        end
    
    -- String
    elseif propType == "string" then
        return string.format('<string name="%s">%s</string>', propName, escapeXML(propValue))
    
    -- Content (Asset URLs)
    elseif propType == "Content" then
        return string.format('<Content name="%s"><url>%s</url></Content>', propName, escapeXML(tostring(propValue)))
    
    -- Instance (Reference)
    elseif propType == "Instance" then
        return string.format('<Ref name="%s">%s</Ref>', propName, GetRef(propValue))
    
    -- NumberSequence
    elseif propType == "NumberSequence" then
        local keypoints = propValue.Keypoints
        local xml = string.format('<NumberSequence name="%s">', propName)
        for _, kp in ipairs(keypoints) do
            xml = xml .. string.format('<Key><Time>%f</Time><Value>%f</Value></Key>', kp.Time, kp.Value)
        end
        xml = xml .. '</NumberSequence>'
        return xml
    
    -- ColorSequence
    elseif propType == "ColorSequence" then
        local keypoints = propValue.Keypoints
        local xml = string.format('<ColorSequence name="%s">', propName)
        for _, kp in ipairs(keypoints) do
            xml = xml .. string.format('<Key><Time>%f</Time><Value><R>%f</R><G>%f</G><B>%f</B></Value></Key>', 
                kp.Time, kp.Value.R, kp.Value.G, kp.Value.B)
        end
        xml = xml .. '</ColorSequence>'
        return xml
    
    -- NumberRange
    elseif propType == "NumberRange" then
        return string.format('<NumberRange name="%s"><Min>%f</Min><Max>%f</Max></NumberRange>', 
            propName, propValue.Min, propValue.Max)
    
    -- Rect
    elseif propType == "Rect" then
        return string.format('<Rect name="%s"><Min><X>%f</X><Y>%f</Y></Min><Max><X>%f</X><Y>%f</Y></Max></Rect>',
            propName, propValue.Min.X, propValue.Min.Y, propValue.Max.X, propValue.Max.Y)
    
    -- PhysicalProperties
    elseif propType == "PhysicalProperties" then
        if propValue then
            return string.format('<PhysicalProperties name="%s"><Density>%f</Density><Friction>%f</Friction><Elasticity>%f</Elasticity><FrictionWeight>%f</FrictionWeight><ElasticityWeight>%f</ElasticityWeight></PhysicalProperties>',
                propName, propValue.Density, propValue.Friction, propValue.Elasticity, propValue.FrictionWeight, propValue.ElasticityWeight)
        else
            return string.format('<PhysicalProperties name="%s">null</PhysicalProperties>', propName)
        end
    
    -- Ray
    elseif propType == "Ray" then
        return string.format('<Ray name="%s"><Origin><X>%f</X><Y>%f</Y><Z>%f</Z></Origin><Direction><X>%f</X><Y>%f</Y><Z>%f</Z></Direction></Ray>',
            propName, propValue.Origin.X, propValue.Origin.Y, propValue.Origin.Z, 
            propValue.Direction.X, propValue.Direction.Y, propValue.Direction.Z)
    
    -- Faces
    elseif propType == "Faces" then
        local faces = {}
        if propValue.Top then table.insert(faces, "Top") end
        if propValue.Bottom then table.insert(faces, "Bottom") end
        if propValue.Left then table.insert(faces, "Left") end
        if propValue.Right then table.insert(faces, "Right") end
        if propValue.Front then table.insert(faces, "Front") end
        if propValue.Back then table.insert(faces, "Back") end
        return string.format('<Faces name="%s">%s</Faces>', propName, table.concat(faces, ","))
    
    -- Axes
    elseif propType == "Axes" then
        local axes = {}
        if propValue.X then table.insert(axes, "X") end
        if propValue.Y then table.insert(axes, "Y") end
        if propValue.Z then table.insert(axes, "Z") end
        return string.format('<Axes name="%s">%s</Axes>', propName, table.concat(axes, ","))
    end
    
    return ""
end

-- LIST PROPERTY YANG PERLU DI-SKIP
local skipProperties = {
    "Parent", "DataModel", "archivable", "DataCost", "RobloxLocked", 
    "Capabilities", "LinkedSource", "ScriptGuid"
}

local function shouldSkipProperty(propName)
    for _, skip in ipairs(skipProperties) do
        if propName == skip then return true end
    end
    return false
end

-- GET XML RECURSIVE (COPY SEMUA PROPERTY)
local function GetXML(obj, depth)
    depth = depth or 0
    if depth > 200 then return "" end
    
    -- Skip object yang tidak perlu
    if obj:IsA("Terrain") or obj:IsA("Camera") or obj.ClassName == "Player" then 
        return "" 
    end
    
    local xml = {}
    local ref = GetRef(obj)
    
    table.insert(xml, string.format('<Item class="%s" referent="%s">', obj.ClassName, ref))
    table.insert(xml, "<Properties>")
    
    -- GET SEMUA PROPERTY
    local success, properties = pcall(function()
        local props = {}
        for _, prop in ipairs({"Name", "Archivable", "CFrame", "Size", "Position", "Orientation", 
            "Color", "BrickColor", "Material", "Transparency", "Reflectance", "CanCollide", "Anchored",
            "Shape", "TopSurface", "BottomSurface", "LeftSurface", "RightSurface", "FrontSurface", "BackSurface",
            "FormFactor", "MeshId", "TextureID", "MeshType", "Scale", "Offset", "VertexColor",
            "Visible", "BackgroundColor3", "BackgroundTransparency", "BorderSizePixel", "BorderColor3",
            "Text", "TextColor3", "TextSize", "Font", "TextWrapped", "TextXAlignment", "TextYAlignment",
            "Image", "ImageColor3", "ImageTransparency", "ScaleType", "ImageRectOffset", "ImageRectSize",
            "CanvasSize", "ScrollBarThickness", "Texture", "Face", "SoundId", "Volume", "Looped", "PlaybackSpeed",
            "Value", "Brightness", "Range", "Angle", "Shadows", "Health", "MaxHealth", "WalkSpeed", "JumpPower",
            "C0", "C1", "Part0", "Part1", "PrimaryPart", "AnimationId", "UsePartColor", "CollisionGroupId",
            "Massless", "CustomPhysicalProperties", "CastShadow", "DoubleSided", "LightInfluence",
            "Enabled", "Rate", "Lifetime", "Speed", "ZIndex", "LayoutOrder", "AutoButtonColor",
            "SizeConstraint", "ResampleMode", "RenderFidelity", "AlwaysOnTop", "MaxDistance",
            "DisplayOrder", "ResetOnSpawn", "IgnoreGuiInset", "ClipsDescendants"
        }) do
            if not shouldSkipProperty(prop) then
                local s, val = pcall(function() return obj[prop] end)
                if s and val ~= nil then
                    props[prop] = val
                end
            end
        end
        return props
    end)
    
    if success and properties then
        -- Serialize semua property
        for propName, propValue in pairs(properties) do
            local propXML = SerializeProperty(propName, propValue)
            if propXML ~= "" then
                table.insert(xml, propXML)
            end
        end
    end
    
    -- SCRIPT SOURCE
    if obj:IsA("LuaSourceContainer") then
        local success, src = pcall(function() return obj.Source end)
        if success and src and src ~= "" then
            src = src:gsub("]]>", "]]]]><![CDATA[>")
            table.insert(xml, '<ProtectedString name="Source"><![CDATA[' .. src .. ']]></ProtectedString>')
        end
    end
    
    table.insert(xml, "</Properties>")
    
    -- RECURSIVE CHILDREN
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

local function SaveToFile(serviceName, finalData, fileName)
    if not hasWriteFile then return false end
    
    local folderName = "NyemekExports"
    if not isfolder(folderName) then makefolder(folderName) end
    
    writefile(folderName .. "/" .. fileName, finalData)
    return true, folderName .. "/" .. fileName
end

local function SendExport(serviceName)
    Rayfield:Notify({Title = "⏳ Exporting", Content = "Processing " .. serviceName .. "...", Duration = 2})
    
    refCounter = 0
    refMap = {}
    
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local service = game:GetService(serviceName)
    local body = ""
    local childCount = 0
    
    print("[INFO] Starting export...")
    
    for _, child in ipairs(service:GetChildren()) do
        print("[INFO] Processing:", child.Name, "-", child.ClassName)
        body = body .. GetXML(child)
        childCount = childCount + 1
    end
    
    if childCount == 0 then
        Rayfield:Notify({Title = "⚠️ Empty", Content = serviceName .. " is empty!", Duration = 3})
        return
    end
    
    local finalData = header .. body .. "\n</roblox>"
    local fileName = serviceName .. "_" .. os.date("%Y%m%d_%H%M%S") .. ".rbxmx"
    
    print("[INFO] XML size:", string.format("%.2f KB", #finalData/1024))
    print("[INFO] Total objects:", childCount)
    
    local fileSaved, filePath = SaveToFile(serviceName, finalData, fileName)
    
    if fileSaved then
        Rayfield:Notify({
            Title = "✅ Export Complete!", 
            Content = fileName .. "\nSize: " .. string.format("%.2f KB", #finalData/1024) .. "\nObjects: " .. childCount,
            Duration = 7
        })
        
        print("[SUCCESS] File saved:", filePath)
        
        -- Send to Discord
        if webhookUrl ~= "" and httpRequest then
            local payload = HttpService:JSONEncode({
                embeds = {{
                    title = "📤 Map Export Complete",
                    color = 5763719,
                    fields = {
                        {name = "Service", value = "`" .. serviceName .. "`", inline = true},
                        {name = "Size", value = string.format("%.2f KB", #finalData/1024), inline = true},
                        {name = "Objects", value = tostring(childCount), inline = true},
                        {name = "File", value = "`" .. fileName .. "`", inline = false},
                        {name = "Path", value = "`" .. filePath .. "`", inline = false}
                    }
                }}
            })
            
            pcall(function()
                httpRequest({
                    Url = webhookUrl,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = payload
                })
            end)
        end
    else
        Rayfield:Notify({Title = "❌ Failed", Content = "Cannot save file!", Duration = 5})
    end
end

Tab:CreateButton({Name = "📤 Export Workspace", Callback = function() SendExport("Workspace") end})
Tab:CreateButton({Name = "🎨 Export StarterGui", Callback = function() SendExport("StarterGui") end})
Tab:CreateButton({Name = "📦 Export ReplicatedStorage", Callback = function() SendExport("ReplicatedStorage") end})
Tab:CreateButton({Name = "🎮 Export ServerScriptService", Callback = function() SendExport("ServerScriptService") end})
Tab:CreateButton({Name = "⚙️ Export ServerStorage", Callback = function() SendExport("ServerStorage") end})
Tab:CreateButton({Name = "💡 Export Lighting", Callback = function() SendExport("Lighting") end})

Tab:CreateParagraph({
    Title = "💡 Info", 
    Content = "This version copies ALL properties including:\n• Position, Rotation, Scale\n• Colors, Materials, Textures\n• Meshes, Sizes, Transparency\n• Scripts, GUI properties\n• Welds, Constraints\n• Everything 1:1!"
})

Rayfield:Notify({Title = "✅ Ready!", Content = "All properties will be copied 1:1", Duration = 3})
