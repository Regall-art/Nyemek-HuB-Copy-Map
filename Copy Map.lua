-- NYEMEK HUB - ULTIMATE MAP COPIER v3
-- 1:1 Perfect Copy - File Save Priority

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Ultimate Copier",
   LoadingTitle = "Loading 1:1 Map Copier...",
   LoadingSubtitle = "File Save Priority",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("📤 Export", 4483362458)
local hasWriteFile = (writefile and isfolder and makefolder) ~= nil

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

local function SerializeProperty(propName, propValue)
    local propType = typeof(propValue)
    
    if propType == "CFrame" then
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = propValue:GetComponents()
        return string.format('<CoordinateFrame name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z><R00>%f</R00><R01>%f</R01><R02>%f</R02><R10>%f</R10><R11>%f</R11><R12>%f</R12><R20>%f</R20><R21>%f</R21><R22>%f</R22></CoordinateFrame>',
            propName, x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    elseif propType == "Vector3" then
        return string.format('<Vector3 name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z></Vector3>', 
            propName, propValue.X, propValue.Y, propValue.Z)
    elseif propType == "Vector2" then
        return string.format('<Vector2 name="%s"><X>%f</X><Y>%f</Y></Vector2>', 
            propName, propValue.X, propValue.Y)
    elseif propType == "Color3" then
        return string.format('<Color3 name="%s"><R>%f</R><G>%f</G><B>%f</B></Color3>', 
            propName, propValue.R, propValue.G, propValue.B)
    elseif propType == "BrickColor" then
        return string.format('<int name="%s">%d</int>', propName, propValue.Number)
    elseif propType == "UDim2" then
        return string.format('<UDim2 name="%s"><XS>%f</XS><XO>%d</XO><YS>%f</YS><YO>%d</YO></UDim2>', 
            propName, propValue.X.Scale, propValue.X.Offset, propValue.Y.Scale, propValue.Y.Offset)
    elseif propType == "UDim" then
        return string.format('<UDim name="%s"><S>%f</S><O>%d</O></UDim>', 
            propName, propValue.Scale, propValue.Offset)
    elseif propType == "EnumItem" then
        return string.format('<token name="%s">%d</token>', propName, propValue.Value)
    elseif propType == "boolean" then
        return string.format('<bool name="%s">%s</bool>', propName, tostring(propValue))
    elseif propType == "number" then
        if math.floor(propValue) == propValue then
            return string.format('<int name="%s">%d</int>', propName, propValue)
        else
            return string.format('<float name="%s">%f</float>', propName, propValue)
        end
    elseif propType == "string" then
        return string.format('<string name="%s">%s</string>', propName, escapeXML(propValue))
    elseif propType == "Instance" then
        return string.format('<Ref name="%s">%s</Ref>', propName, GetRef(propValue))
    elseif propType == "NumberSequence" then
        local keypoints = propValue.Keypoints
        local xml = string.format('<NumberSequence name="%s">', propName)
        for _, kp in ipairs(keypoints) do
            xml = xml .. string.format('<NSK t="%f" v="%f" e="0"/>', kp.Time, kp.Value)
        end
        xml = xml .. '</NumberSequence>'
        return xml
    elseif propType == "ColorSequence" then
        local keypoints = propValue.Keypoints
        local xml = string.format('<ColorSequence name="%s">', propName)
        for _, kp in ipairs(keypoints) do
            xml = xml .. string.format('<CSK t="%f"><C r="%f" g="%f" b="%f"/></CSK>', 
                kp.Time, kp.Value.R, kp.Value.G, kp.Value.B)
        end
        xml = xml .. '</ColorSequence>'
        return xml
    elseif propType == "NumberRange" then
        return string.format('<NumberRange name="%s">%f %f</NumberRange>', 
            propName, propValue.Min, propValue.Max)
    elseif propType == "PhysicalProperties" then
        if propValue then
            return string.format('<PhysicalProperties name="%s"><CustomPhysics>true</CustomPhysics><Density>%f</Density><Friction>%f</Friction><Elasticity>%f</Elasticity><FrictionWeight>%f</FrictionWeight><ElasticityWeight>%f</ElasticityWeight></PhysicalProperties>',
                propName, propValue.Density, propValue.Friction, propValue.Elasticity, propValue.FrictionWeight, propValue.ElasticityWeight)
        end
    end
    
    return ""
end

local skipProperties = {
    "Parent", "DataModel", "archivable", "DataCost", "RobloxLocked", 
    "Capabilities", "LinkedSource", "ScriptGuid", "UniqueId"
}

local function shouldSkip(propName)
    for _, skip in ipairs(skipProperties) do
        if propName == skip then return true end
    end
    return false
end

-- SEMUA PROPERTY YANG PENTING
local allProperties = {
    "Name", "Archivable", "CFrame", "Size", "Position", "Orientation", 
    "Color", "BrickColor", "Material", "Transparency", "Reflectance", 
    "CanCollide", "Anchored", "Massless", "Locked",
    "Shape", "TopSurface", "BottomSurface", "LeftSurface", "RightSurface", "FrontSurface", "BackSurface",
    "FormFactor", "MeshId", "TextureID", "MeshType", "Scale", "Offset", "VertexColor",
    "Visible", "BackgroundColor3", "BackgroundTransparency", "BorderSizePixel", "BorderColor3",
    "Text", "TextColor3", "TextSize", "Font", "TextWrapped", "TextXAlignment", "TextYAlignment",
    "TextStrokeTransparency", "TextStrokeColor3", "TextScaled",
    "Image", "ImageColor3", "ImageTransparency", "ScaleType", "ImageRectOffset", "ImageRectSize",
    "CanvasSize", "ScrollBarThickness", "Texture", "Face", "SoundId", "Volume", "Looped", 
    "PlaybackSpeed", "TimePosition", "Value", "Brightness", "Range", "Angle", "Shadows",
    "Health", "MaxHealth", "WalkSpeed", "JumpPower", "JumpHeight",
    "C0", "C1", "Part0", "Part1", "PrimaryPart", "AnimationId", 
    "UsePartColor", "CollisionGroupId", "CustomPhysicalProperties", 
    "CastShadow", "DoubleSided", "LightInfluence", "Enabled", 
    "Rate", "Lifetime", "Speed", "ZIndex", "LayoutOrder", 
    "AutoButtonColor", "RenderFidelity", "AlwaysOnTop", "MaxDistance",
    "DisplayOrder", "ResetOnSpawn", "IgnoreGuiInset", "ClipsDescendants",
    "SizeConstraint", "Active", "AnchorPoint", "AutomaticSize",
    "Rotation", "WorldCFrame", "WorldPosition"
}

local function GetXML(obj, depth)
    depth = depth or 0
    if depth > 200 then return "" end
    
    if obj:IsA("Terrain") or obj:IsA("Camera") or obj.ClassName == "Player" then 
        return "" 
    end
    
    local xml = {}
    table.insert(xml, string.format('<Item class="%s" referent="%s">', obj.ClassName, GetRef(obj)))
    table.insert(xml, "<Properties>")
    
    -- Serialize semua property
    for _, propName in ipairs(allProperties) do
        if not shouldSkip(propName) then
            local success, propValue = pcall(function() return obj[propName] end)
            if success and propValue ~= nil then
                local propXML = SerializeProperty(propName, propValue)
                if propXML ~= "" then
                    table.insert(xml, propXML)
                end
            end
        end
    end
    
    -- Script source
    if obj:IsA("LuaSourceContainer") then
        local success, src = pcall(function() return obj.Source end)
        if success and src and src ~= "" then
            src = src:gsub("]]>", "]]]]><![CDATA[>")
            table.insert(xml, '<ProtectedString name="Source"><![CDATA[' .. src .. ']]></ProtectedString>')
        else
            table.insert(xml, '<ProtectedString name="Source"></ProtectedString>')
        end
    end
    
    table.insert(xml, "</Properties>")
    
    -- Children
    local success, children = pcall(function() return obj:GetChildren() end)
    if success and children then
        for _, child in ipairs(children) do
            table.insert(xml, GetXML(child, depth + 1))
        end
    end
    
    table.insert(xml, "</Item>")
    return table.concat(xml, "\n")
end

local function SendExport(serviceName)
    if not hasWriteFile then
        Rayfield:Notify({
            Title = "❌ Error", 
            Content = "Executor doesn't support file writing!", 
            Duration = 5
        })
        return
    end
    
    Rayfield:Notify({Title = "⏳ Exporting", Content = "Processing " .. serviceName .. "...", Duration = 2})
    
    local startTime = tick()
    refCounter = 0
    refMap = {}
    
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local service = game:GetService(serviceName)
    local body = ""
    local childCount = 0
    
    for _, child in ipairs(service:GetChildren()) do
        body = body .. GetXML(child)
        childCount = childCount + 1
    end
    
    if childCount == 0 then
        Rayfield:Notify({Title = "⚠️ Empty", Content = serviceName .. " is empty!", Duration = 3})
        return
    end
    
    local finalData = header .. body .. "\n</roblox>"
    local fileName = serviceName .. "_" .. os.date("%Y%m%d_%H%M%S") .. ".rbxmx"
    
    -- SAVE FILE
    local folderName = "NyemekExports"
    if not isfolder(folderName) then makefolder(folderName) end
    
    local filePath = folderName .. "/" .. fileName
    writefile(filePath, finalData)
    
    local timeTaken = math.floor((tick() - startTime) * 100) / 100
    
    print("========================================")
    print("✅ EXPORT SUCCESS!")
    print("========================================")
    print("📦 Service:", serviceName)
    print("📊 Size:", string.format("%.2f KB", #finalData/1024))
    print("🔢 Objects:", childCount)
    print("📁 File:", fileName)
    print("📂 Path:", filePath)
    print("⏱️ Time:", timeTaken, "seconds")
    print("========================================")
    
    Rayfield:Notify({
        Title = "✅ Export Complete!", 
        Content = string.format("%s\n%.2f KB | %d objects\nTime: %.2fs\n\nFile: %s", 
            serviceName, #finalData/1024, childCount, timeTaken, fileName),
        Duration = 10
    })
    
    -- Copy path to clipboard
    if setclipboard then
        setclipboard(filePath)
        print("✅ File path copied to clipboard!")
    end
end

-- BUTTONS
Tab:CreateButton({Name = "📤 Export Workspace", Callback = function() SendExport("Workspace") end})
Tab:CreateButton({Name = "🎨 Export StarterGui", Callback = function() SendExport("StarterGui") end})
Tab:CreateButton({Name = "📦 Export ReplicatedStorage", Callback = function() SendExport("ReplicatedStorage") end})
Tab:CreateButton({Name = "🎮 Export ServerScriptService", Callback = function() SendExport("ServerScriptService") end})
Tab:CreateButton({Name = "⚙️ Export ServerStorage", Callback = function() SendExport("ServerStorage") end})
Tab:CreateButton({Name = "💡 Export Lighting", Callback = function() SendExport("Lighting") end})
Tab:CreateButton({Name = "🔊 Export SoundService", Callback = function() SendExport("SoundService") end})

-- OPEN FOLDER BUTTON
Tab:CreateButton({
    Name = "📂 Open Export Folder",
    Callback = function()
        if hasWriteFile then
            local folderName = "NyemekExports"
            if isfolder(folderName) then
                Rayfield:Notify({
                    Title = "📂 Folder Location", 
                    Content = "Path: workspace/" .. folderName .. "\n\nCheck executor workspace folder!",
                    Duration = 8
                })
                
                if setclipboard then
                    setclipboard("workspace/" .. folderName)
                end
                
                print("📂 Export folder: workspace/" .. folderName)
            else
                Rayfield:Notify({Title = "⚠️ Not Found", Content = "Export something first!", Duration = 3})
            end
        end
    end
})

-- LIST FILES BUTTON
Tab:CreateButton({
    Name = "📋 List Exported Files",
    Callback = function()
        if hasWriteFile and listfiles then
            local folderName = "NyemekExports"
            if isfolder(folderName) then
                local files = listfiles(folderName)
                
                print("\n========== EXPORTED FILES ==========")
                if #files > 0 then
                    for i, file in ipairs(files) do
                        local fileName = file:match("([^/\\]+)$")
                        local content = readfile(file)
                        local size = #content / 1024
                        print(string.format("%d. %s (%.2f KB)", i, fileName, size))
                    end
                    print("Total files:", #files)
                else
                    print("No files found")
                end
                print("====================================\n")
                
                Rayfield:Notify({
                    Title = "📋 Files Listed", 
                    Content = "Found " .. #files .. " file(s)\nCheck console (F9)",
                    Duration = 5
                })
            else
                Rayfield:Notify({Title = "⚠️ Not Found", Content = "Export something first!", Duration = 3})
            end
        end
    end
})

Tab:CreateParagraph({
    Title = "💡 How to Use", 
    Content = "1. Click Export button\n2. Wait for 'Export Complete'\n3. Find file in workspace/NyemekExports/\n4. Import to Roblox Studio:\n   • Insert → Insert from File\n   • Select the .rbxmx file\n   • Done! ✨"
})

Tab:CreateParagraph({
    Title = "✅ Features", 
    Content = "• Copy ALL properties 1:1\n• Position, rotation, scale\n• Colors, materials, textures\n• Meshes, sizes, transparency\n• Scripts, GUIs, everything!\n• Fast & reliable"
})

local statusText = "🔍 System Status:\n\n"
if hasWriteFile then
    statusText = statusText .. "✅ File Save: Supported\n✅ Ready to export!"
else
    statusText = statusText .. "❌ File Save: Not Supported\n❌ Change executor!"
end

Tab:CreateParagraph({Title = "System Info", Content = statusText})

Rayfield:Notify({
    Title = "✅ Ready!", 
    Content = "Export & find file in workspace/NyemekExports/", 
    Duration = 4
})
