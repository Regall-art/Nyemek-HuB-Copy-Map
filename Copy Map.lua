local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Map Saver",
   LoadingTitle = "Loading Ultimate Map Saver...",
   LoadingSubtitle = "Save Maps Instantly",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("💾 Save Map", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)
local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)

-- SETTINGS
local config = {
    fileFormat = "RBXMX", -- RBXMX atau RBXL
    decompileScripts = true,
    saveWorkspace = true,
    saveReplicatedStorage = true,
    saveServerScriptService = false,
    saveServerStorage = false,
    saveLighting = false,
    autoOpenFolder = true
}

-- DETECT CAPABILITIES
local hasWrite = writefile and makefolder and isfolder and listfiles

-- UI CONFIGURATION
SettingsTab:CreateDropdown({
   Name = "File Format",
   Options = {"RBXMX (Recommended)", "RBXL (Studio Format)"},
   CurrentOption = "RBXMX (Recommended)",
   Callback = function(option)
       config.fileFormat = option:match("RBXL") and "RBXL" or "RBXMX"
       Rayfield:Notify({
           Title = "✅ Format Changed", 
           Content = "Save as: ." .. config.fileFormat:lower(),
           Duration = 2
       })
   end,
})

SettingsTab:CreateToggle({
   Name = "Decompile Scripts",
   CurrentValue = true,
   Callback = function(val) config.decompileScripts = val end,
})

SettingsTab:CreateToggle({
   Name = "Auto Open Folder",
   CurrentValue = true,
   Callback = function(val) config.autoOpenFolder = val end,
})

SettingsTab:CreateSection("📦 What to Save")

SettingsTab:CreateToggle({
   Name = "Workspace",
   CurrentValue = true,
   Callback = function(val) config.saveWorkspace = val end,
})

SettingsTab:CreateToggle({
   Name = "ReplicatedStorage",
   CurrentValue = true,
   Callback = function(val) config.saveReplicatedStorage = val end,
})

SettingsTab:CreateToggle({
   Name = "ServerScriptService",
   CurrentValue = false,
   Callback = function(val) config.saveServerScriptService = val end,
})

SettingsTab:CreateToggle({
   Name = "ServerStorage",
   CurrentValue = false,
   Callback = function(val) config.saveServerStorage = val end,
})

SettingsTab:CreateToggle({
   Name = "Lighting",
   CurrentValue = false,
   Callback = function(val) config.saveLighting = val end,
})

-- STATS
local stats = {
    totalObjects = 0,
    totalScripts = 0,
    scriptsDecompiled = 0,
    scriptsFailed = 0,
    localScripts = 0,
    serverScripts = 0,
    moduleScripts = 0
}

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
    return str:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;"):gsub('"',"&quot;")
end

-- DECOMPILER
local function DecompileScript(script)
    if not config.decompileScripts then
        return "-- Decompiling disabled in settings"
    end
    
    stats.totalScripts = stats.totalScripts + 1
    
    -- Track script types
    if script:IsA("LocalScript") then stats.localScripts = stats.localScripts + 1
    elseif script:IsA("Script") then stats.serverScripts = stats.serverScripts + 1
    elseif script:IsA("ModuleScript") then stats.moduleScripts = stats.moduleScripts + 1
    end
    
    -- Method 1: Direct source
    local ok, src = pcall(function() return script.Source end)
    if ok and src and src ~= "" then
        stats.scriptsDecompiled = stats.scriptsDecompiled + 1
        return "-- " .. script.ClassName .. ": " .. script.Name .. "\n" .. src
    end
    
    -- Method 2: Decompile
    if decompile then
        ok, src = pcall(decompile, script)
        if ok and src and src ~= "" then
            stats.scriptsDecompiled = stats.scriptsDecompiled + 1
            return "-- " .. script.ClassName .. ": " .. script.Name .. " (Decompiled)\n" .. src
        end
    end
    
    -- Method 3: Syn decompile
    if syn and syn.decompile then
        ok, src = pcall(syn.decompile, script)
        if ok and src and src ~= "" then
            stats.scriptsDecompiled = stats.scriptsDecompiled + 1
            return "-- " .. script.ClassName .. ": " .. script.Name .. " (Decompiled)\n" .. src
        end
    end
    
    stats.scriptsFailed = stats.scriptsFailed + 1
    return "-- " .. script.ClassName .. ": " .. script.Name .. "\n-- Failed to decompile (Protected)"
end

-- PROPERTY SERIALIZER
local function SerializeProp(name, val)
    local t = typeof(val)
    
    if t == "CFrame" then
        local x,y,z,r00,r01,r02,r10,r11,r12,r20,r21,r22 = val:GetComponents()
        return string.format('<CoordinateFrame name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z><R00>%f</R00><R01>%f</R01><R02>%f</R02><R10>%f</R10><R11>%f</R11><R12>%f</R12><R20>%f</R20><R21>%f</R21><R22>%f</R22></CoordinateFrame>',
            name,x,y,z,r00,r01,r02,r10,r11,r12,r20,r21,r22)
    elseif t == "Vector3" then
        return string.format('<Vector3 name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z></Vector3>',name,val.X,val.Y,val.Z)
    elseif t == "Vector2" then
        return string.format('<Vector2 name="%s"><X>%f</X><Y>%f</Y></Vector2>',name,val.X,val.Y)
    elseif t == "Color3" then
        return string.format('<Color3 name="%s"><R>%f</R><G>%f</G><B>%f</B></Color3>',name,val.R,val.G,val.B)
    elseif t == "BrickColor" then
        return string.format('<int name="%s">%d</int>',name,val.Number)
    elseif t == "UDim2" then
        return string.format('<UDim2 name="%s"><XS>%f</XS><XO>%d</XO><YS>%f</YS><YO>%d</YO></UDim2>',
            name,val.X.Scale,val.X.Offset,val.Y.Scale,val.Y.Offset)
    elseif t == "UDim" then
        return string.format('<UDim name="%s"><S>%f</S><O>%d</O></UDim>',name,val.Scale,val.Offset)
    elseif t == "EnumItem" then
        return string.format('<token name="%s">%d</token>',name,val.Value)
    elseif t == "boolean" then
        return string.format('<bool name="%s">%s</bool>',name,tostring(val))
    elseif t == "number" then
        if math.floor(val) == val then
            return string.format('<int name="%s">%d</int>',name,val)
        else
            return string.format('<float name="%s">%f</float>',name,val)
        end
    elseif t == "string" then
        return string.format('<string name="%s">%s</string>',name,escapeXML(val))
    elseif t == "Instance" then
        return string.format('<Ref name="%s">%s</Ref>',name,GetRef(val))
    elseif t == "NumberSequence" then
        local kps = val.Keypoints
        local xml = string.format('<NumberSequence name="%s">',name)
        for _, kp in ipairs(kps) do
            xml = xml .. string.format('<NSK t="%f" v="%f" e="0"/>',kp.Time,kp.Value)
        end
        return xml .. '</NumberSequence>'
    elseif t == "ColorSequence" then
        local kps = val.Keypoints
        local xml = string.format('<ColorSequence name="%s">',name)
        for _, kp in ipairs(kps) do
            xml = xml .. string.format('<CSK t="%f"><C r="%f" g="%f" b="%f"/></CSK>',
                kp.Time,kp.Value.R,kp.Value.G,kp.Value.B)
        end
        return xml .. '</ColorSequence>'
    end
    return ""
end

-- ALL IMPORTANT PROPERTIES
local allProps = {
    "Name","Archivable","CFrame","Size","Position","Orientation","Rotation",
    "Color","BrickColor","Material","Transparency","Reflectance","CanCollide",
    "Anchored","Massless","Locked","CollisionGroupId","CustomPhysicalProperties",
    "Shape","TopSurface","BottomSurface","LeftSurface","RightSurface","FrontSurface","BackSurface",
    "FormFactor","MeshId","TextureID","MeshType","Scale","Offset","VertexColor",
    "Visible","BackgroundColor3","BackgroundTransparency","BorderSizePixel","BorderColor3",
    "Text","TextColor3","TextSize","Font","TextWrapped","TextXAlignment","TextYAlignment",
    "TextStrokeTransparency","TextStrokeColor3","TextScaled","TextTransparency",
    "Image","ImageColor3","ImageTransparency","ScaleType","ImageRectOffset","ImageRectSize",
    "CanvasSize","ScrollBarThickness","ScrollingDirection","Texture","Face",
    "SoundId","Volume","Looped","PlaybackSpeed","TimePosition","Playing",
    "Value","Brightness","Range","Angle","Shadows","Color","Enabled",
    "Health","MaxHealth","WalkSpeed","JumpPower","JumpHeight","HipHeight",
    "C0","C1","Part0","Part1","D","MaxForce","MaxTorque","P","PrimaryPart",
    "AnimationId","UsePartColor","CastShadow","DoubleSided","LightInfluence",
    "Rate","Lifetime","Speed","Acceleration","Drag","VelocityInheritance",
    "ZIndex","LayoutOrder","AutoButtonColor","Modal","RenderFidelity",
    "AlwaysOnTop","MaxDistance","StudsOffset","DisplayOrder","ResetOnSpawn",
    "IgnoreGuiInset","ClipsDescendants","SizeConstraint","Active","AnchorPoint",
    "AutomaticSize","BackgroundColor3","BorderMode","Position","Size"
}

local skipProps = {"Parent","DataModel","RobloxLocked","UniqueId","ScriptGuid","DataCost"}

local function shouldSkip(name)
    for _,v in ipairs(skipProps) do if name==v then return true end end
    return false
end

-- RECURSIVE XML GENERATOR
local function GetXML(obj, depth)
    depth = depth or 0
    if depth > 250 then return "" end
    
    if obj:IsA("Terrain") or obj:IsA("Camera") or obj.ClassName=="Player" then 
        return "" 
    end
    
    stats.totalObjects = stats.totalObjects + 1
    
    local xml = {}
    table.insert(xml, string.format('<Item class="%s" referent="%s">',obj.ClassName,GetRef(obj)))
    table.insert(xml, "<Properties>")
    
    -- Serialize all properties
    for _, pn in ipairs(allProps) do
        if not shouldSkip(pn) then
            local ok, pv = pcall(function() return obj[pn] end)
            if ok and pv ~= nil then
                local px = SerializeProp(pn, pv)
                if px ~= "" then
                    table.insert(xml, px)
                end
            end
        end
    end
    
    -- Scripts
    if obj:IsA("LuaSourceContainer") then
        local src = DecompileScript(obj)
        if src then
            src = src:gsub("]]>", "]]]]><![CDATA[>")
            table.insert(xml, '<ProtectedString name="Source"><![CDATA[' .. src .. ']]></ProtectedString>')
        end
    end
    
    table.insert(xml, "</Properties>")
    
    -- Children
    local ok, children = pcall(function() return obj:GetChildren() end)
    if ok and children then
        for _, child in ipairs(children) do
            table.insert(xml, GetXML(child, depth + 1))
        end
    end
    
    table.insert(xml, "</Item>")
    return table.concat(xml, "\n")
end

-- MAIN SAVE FUNCTION
local function SaveMap()
    if not hasWrite then
        Rayfield:Notify({
            Title = "❌ Error", 
            Content = "Executor tidak support file writing!",
            Duration = 5
        })
        return
    end
    
    Rayfield:Notify({
        Title = "⏳ Saving Map", 
        Content = "Processing all services...",
        Duration = 2
    })
    
    local startTime = tick()
    refCounter = 0
    refMap = {}
    stats = {totalObjects=0,totalScripts=0,scriptsDecompiled=0,scriptsFailed=0,localScripts=0,serverScripts=0,moduleScripts=0}
    
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local body = ""
    local servicesProcessed = {}
    
    -- Process services based on config
    if config.saveWorkspace then
        Rayfield:Notify({Title = "📦 Processing", Content = "Workspace...", Duration = 1})
        for _, child in ipairs(game.Workspace:GetChildren()) do
            body = body .. GetXML(child)
        end
        table.insert(servicesProcessed, "Workspace")
    end
    
    if config.saveReplicatedStorage then
        Rayfield:Notify({Title = "📦 Processing", Content = "ReplicatedStorage...", Duration = 1})
        for _, child in ipairs(game.ReplicatedStorage:GetChildren()) do
            body = body .. GetXML(child)
        end
        table.insert(servicesProcessed, "ReplicatedStorage")
    end
    
    if config.saveServerScriptService then
        Rayfield:Notify({Title = "📦 Processing", Content = "ServerScriptService...", Duration = 1})
        for _, child in ipairs(game.ServerScriptService:GetChildren()) do
            body = body .. GetXML(child)
        end
        table.insert(servicesProcessed, "ServerScriptService")
    end
    
    if config.saveServerStorage then
        Rayfield:Notify({Title = "📦 Processing", Content = "ServerStorage...", Duration = 1})
        for _, child in ipairs(game.ServerStorage:GetChildren()) do
            body = body .. GetXML(child)
        end
        table.insert(servicesProcessed, "ServerStorage")
    end
    
    if config.saveLighting then
        Rayfield:Notify({Title = "📦 Processing", Content = "Lighting...", Duration = 1})
        for _, child in ipairs(game.Lighting:GetChildren()) do
            body = body .. GetXML(child)
        end
        table.insert(servicesProcessed, "Lighting")
    end
    
    if stats.totalObjects == 0 then
        Rayfield:Notify({
            Title = "⚠️ Nothing to Save", 
            Content = "Enable at least one service in Settings!",
            Duration = 5
        })
        return
    end
    
    local data = header .. body .. "\n</roblox>"
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown"
    gameName = gameName:gsub("[^%w%s%-]", ""):gsub("%s+", "_") -- Clean name
    
    local fileName = gameName .. "_" .. os.date("%Y%m%d_%H%M%S")
    local ext = config.fileFormat == "RBXL" and ".rbxl" or ".rbxmx"
    local fullFileName = fileName .. ext
    
    -- Create folder
    local folder = "SavedMaps"
    if not isfolder(folder) then makefolder(folder) end
    
    -- Save file
    local filePath = folder .. "/" .. fullFileName
    writefile(filePath, data)
    
    local timeTaken = math.floor((tick() - startTime) * 100) / 100
    
    -- DETAILED CONSOLE OUTPUT
    print("\n" .. string.rep("=", 70))
    print("💾 MAP SAVED SUCCESSFULLY!")
    print(string.rep("=", 70))
    print("📁 File Name:", fullFileName)
    print("📂 Location: workspace/" .. folder .. "/")
    print("💾 File Size:", string.format("%.2f KB (%.2f MB)", #data/1024, #data/1024/1024))
    print("⏱️  Time Taken:", timeTaken, "seconds")
    print("")
    print("📦 STATISTICS:")
    print("  Total Objects:", stats.totalObjects)
    print("  Total Scripts:", stats.totalScripts)
    print("    🔵 LocalScripts:", stats.localScripts)
    print("    🟢 ServerScripts:", stats.serverScripts)
    print("    🟡 ModuleScripts:", stats.moduleScripts)
    print("")
    print("📜 DECOMPILE RESULTS:")
    print("  ✅ Successfully Decompiled:", stats.scriptsDecompiled)
    print("  ❌ Failed:", stats.scriptsFailed)
    if stats.totalScripts > 0 then
        local rate = math.floor((stats.scriptsDecompiled / stats.totalScripts) * 100)
        print("  📈 Success Rate:", rate .. "%")
    end
    print("")
    print("📦 SERVICES SAVED:")
    for i, service in ipairs(servicesProcessed) do
        print("  " .. i .. ". " .. service)
    end
    print("")
    print("💡 HOW TO OPEN:")
    print("  1. Open Roblox Studio")
    if config.fileFormat == "RBXL" then
        print("  2. File → Open from File")
        print("  3. Select:", filePath)
    else
        print("  2. Insert → Insert from File")
        print("  3. Select:", filePath)
    end
    print(string.rep("=", 70) .. "\n")
    
    -- Copy path to clipboard
    if setclipboard then
        setclipboard(filePath)
        print("✅ File path copied to clipboard!")
    end
    
    -- Success notification
    local notifMsg = string.format("💾 %s\n\n📊 %d objects | %d scripts\n⏱️ %ds\n\n📂 Saved to:\nworkspace/%s/",
        fullFileName, stats.totalObjects, stats.scriptsDecompiled, timeTaken, folder)
    
    if setclipboard then
        notifMsg = notifMsg .. "\n\n✅ Path copied!"
    end
    
    Rayfield:Notify({
        Title = "✅ Map Saved!", 
        Content = notifMsg,
        Duration = 12
    })
    
    -- Auto open folder (if supported)
    if config.autoOpenFolder then
        task.wait(1)
        Rayfield:Notify({
            Title = "📂 Opening Folder", 
            Content = "Check workspace/" .. folder .. "/",
            Duration = 5
        })
    end
end

-- QUICK SAVE PRESETS
MainTab:CreateSection("🚀 Quick Save")

MainTab:CreateButton({
    Name = "💾 Save Full Map",
    Callback = SaveMap
})

MainTab:CreateButton({
    Name = "📦 Save Workspace Only",
    Callback = function()
        config.saveWorkspace = true
        config.saveReplicatedStorage = false
        config.saveServerScriptService = false
        config.saveServerStorage = false
        config.saveLighting = false
        SaveMap()
    end
})

MainTab:CreateButton({
    Name = "🎮 Save Workspace + Scripts",
    Callback = function()
        config.saveWorkspace = true
        config.saveReplicatedStorage = true
        config.saveServerScriptService = true
        config.saveServerStorage = false
        config.saveLighting = false
        SaveMap()
    end
})

-- FOLDER MANAGEMENT
MainTab:CreateSection("📂 Folder Management")

MainTab:CreateButton({
    Name = "📂 Open Saved Maps Folder",
    Callback = function()
        local folder = "SavedMaps"
        if isfolder and isfolder(folder) then
            Rayfield:Notify({
                Title = "📂 Folder Location", 
                Content = "Path: workspace/" .. folder .. "/\n\nGo to your executor's workspace folder!",
                Duration = 8
            })
            print("\n📂 FOLDER LOCATION:")
            print("Path: workspace/" .. folder .. "/")
            print("\nFull path examples:")
            print("• Solara: C:\\Users\\[Name]\\AppData\\Local\\Solara\\workspace\\" .. folder)
            print("• Wave: C:\\Users\\[Name]\\AppData\\Local\\Wave\\workspace\\" .. folder)
            print("• Delta: C:\\Users\\[Name]\\AppData\\Local\\Delta\\workspace\\" .. folder)
        else
            Rayfield:Notify({
                Title = "⚠️ Folder Empty", 
                Content = "Save a map first!",
                Duration = 3
            })
        end
    end
})

MainTab:CreateButton({
    Name = "📋 List Saved Maps",
    Callback = function()
        local folder = "SavedMaps"
        if isfolder and isfolder(folder) and listfiles then
            local files = listfiles(folder)
            
            print("\n" .. string.rep("=", 60))
            print("📋 SAVED MAPS (" .. #files .. " files)")
            print(string.rep("=", 60))
            
            if #files > 0 then
                for i, file in ipairs(files) do
                    local name = file:match("([^/\\]+)$")
                    local content = readfile(file)
                    local size = #content / 1024
                    print(string.format("%d. %s (%.2f KB)", i, name, size))
                end
            else
                print("No files found. Save a map first!")
            end
            
            print(string.rep("=", 60) .. "\n")
            
            Rayfield:Notify({
                Title = "📋 Files Listed", 
                Content = "Found " .. #files .. " saved map(s)\nCheck console (F9)",
                Duration = 5
            })
        end
    end
})

-- INFO TAB
InfoTab:CreateParagraph({
    Title = "💡 How to Use", 
    Content = "1. Configure settings (optional)\n2. Click 'Save Full Map'\n3. Wait for process to complete\n4. File saved to workspace/SavedMaps/\n5. Open in Roblox Studio:\n   • RBXL: File → Open from File\n   • RBXMX: Insert → Insert from File"
})

InfoTab:CreateParagraph({
    Title = "📁 File Formats", 
    Content = "RBXMX (Recommended):\n• XML text format\n• Easy to edit\n• Works everywhere\n• Larger file size\n\nRBXL (Studio Format):\n• Binary format\n• Smaller file size\n• Direct open in Studio\n• Cannot edit manually"
})

InfoTab:CreateParagraph({
    Title = "📂 File Location", 
    Content = "Files are saved to:\nworkspace/SavedMaps/\n\nFull path:\nC:\\Users\\[YourName]\\AppData\\Local\\[Executor]\\workspace\\SavedMaps\\"
})

local statusText = "🔍 System Status:\n\n"
statusText = statusText .. (hasWrite and "✅ File Writing: Supported\n" or "❌ File Writing: NOT Supported\n")
statusText = statusText .. (decompile and "✅ Decompiler: Available\n" or "⚠️ Decompiler: Limited\n")
statusText = statusText .. (setclipboard and "✅ Clipboard: Supported" or "⚠️ Clipboard: Not Supported")

InfoTab:CreateParagraph({Title = "System Info", Content = statusText})

Rayfield:Notify({
    Title = "✅ Ready to Save!", 
    Content = "Maps will be saved to workspace/SavedMaps/",
    Duration = 4
})
