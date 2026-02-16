-- NYEMEK HUB - SAVE TO DOWNLOADS FOLDER
-- File langsung masuk ke C:\Users\[Name]\Downloads\

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Save to Downloads",
   LoadingTitle = "Loading Map Saver...",
   LoadingSubtitle = "Direct to Downloads Folder",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("💾 Save", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

-- DETECT CAPABILITIES
local hasWrite = writefile ~= nil

-- SETTINGS
local config = {
    fileFormat = "RBXL",
    decompileScripts = true,
    saveWorkspace = true,
    saveReplicatedStorage = true
}

SettingsTab:CreateDropdown({
   Name = "File Format",
   Options = {"RBXL", "RBXMX"},
   CurrentOption = "RBXL",
   Callback = function(option) config.fileFormat = option end,
})

SettingsTab:CreateToggle({
   Name = "Decompile Scripts",
   CurrentValue = true,
   Callback = function(val) config.decompileScripts = val end,
})

SettingsTab:CreateToggle({
   Name = "Save Workspace",
   CurrentValue = true,
   Callback = function(val) config.saveWorkspace = val end,
})

SettingsTab:CreateToggle({
   Name = "Save ReplicatedStorage",
   CurrentValue = true,
   Callback = function(val) config.saveReplicatedStorage = val end,
})

-- STATS
local stats = {objects=0, scripts=0, decompiled=0}
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

local function DecompileScript(script)
    if not config.decompileScripts then return "-- Decompiling disabled" end
    stats.scripts = stats.scripts + 1
    
    local ok, src = pcall(function() return script.Source end)
    if ok and src and src ~= "" then
        stats.decompiled = stats.decompiled + 1
        return src
    end
    
    if decompile then
        ok, src = pcall(decompile, script)
        if ok and src then
            stats.decompiled = stats.decompiled + 1
            return src
        end
    end
    
    if syn and syn.decompile then
        ok, src = pcall(syn.decompile, script)
        if ok and src then
            stats.decompiled = stats.decompiled + 1
            return src
        end
    end
    
    return "-- Failed to decompile: " .. script.Name
end

local function SerializeProp(name, val)
    local t = typeof(val)
    
    if t == "CFrame" then
        local x,y,z,r00,r01,r02,r10,r11,r12,r20,r21,r22 = val:GetComponents()
        return string.format('<CoordinateFrame name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z><R00>%f</R00><R01>%f</R01><R02>%f</R02><R10>%f</R10><R11>%f</R11><R12>%f</R12><R20>%f</R20><R21>%f</R21><R22>%f</R22></CoordinateFrame>',
            name,x,y,z,r00,r01,r02,r10,r11,r12,r20,r21,r22)
    elseif t == "Vector3" then
        return string.format('<Vector3 name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z></Vector3>',name,val.X,val.Y,val.Z)
    elseif t == "Color3" then
        return string.format('<Color3 name="%s"><R>%f</R><G>%f</G><B>%f</B></Color3>',name,val.R,val.G,val.B)
    elseif t == "BrickColor" then
        return string.format('<int name="%s">%d</int>',name,val.Number)
    elseif t == "UDim2" then
        return string.format('<UDim2 name="%s"><XS>%f</XS><XO>%d</XO><YS>%f</YS><YO>%d</YO></UDim2>',
            name,val.X.Scale,val.X.Offset,val.Y.Scale,val.Y.Offset)
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
    end
    return ""
end

local props = {
    "Name","CFrame","Size","Position","Orientation","Color","BrickColor",
    "Material","Transparency","Reflectance","CanCollide","Anchored","Massless",
    "Shape","TopSurface","BottomSurface","MeshId","TextureID","MeshType",
    "Scale","Offset","Visible","BackgroundColor3","BackgroundTransparency",
    "BorderSizePixel","Text","TextColor3","TextSize","Font","TextWrapped",
    "Image","ImageColor3","ImageTransparency","SoundId","Volume","Looped",
    "Value","Brightness","Range","C0","C1","Part0","Part1","Enabled"
}

local function GetXML(obj, depth)
    depth = depth or 0
    if depth > 200 then return "" end
    if obj:IsA("Terrain") or obj:IsA("Camera") or obj.ClassName=="Player" then return "" end
    
    stats.objects = stats.objects + 1
    
    local xml = {}
    table.insert(xml, string.format('<Item class="%s" referent="%s">',obj.ClassName,GetRef(obj)))
    table.insert(xml, "<Properties>")
    
    for _, pn in ipairs(props) do
        local ok, pv = pcall(function() return obj[pn] end)
        if ok and pv ~= nil then
            local px = SerializeProp(pn, pv)
            if px ~= "" then table.insert(xml, px) end
        end
    end
    
    if obj:IsA("LuaSourceContainer") then
        local src = DecompileScript(obj)
        if src then
            src = src:gsub("]]>", "]]]]><![CDATA[>")
            table.insert(xml, '<ProtectedString name="Source"><![CDATA[' .. src .. ']]></ProtectedString>')
        end
    end
    
    table.insert(xml, "</Properties>")
    
    local ok, children = pcall(function() return obj:GetChildren() end)
    if ok and children then
        for _, child in ipairs(children) do
            table.insert(xml, GetXML(child, depth + 1))
        end
    end
    
    table.insert(xml, "</Item>")
    return table.concat(xml, "\n")
end

-- GET DOWNLOADS PATH
local function GetDownloadsPath()
    -- Method 1: Direct path
    local username = os.getenv("USERNAME") or os.getenv("USER")
    if username then
        return "C:/Users/" .. username .. "/Downloads/"
    end
    
    -- Method 2: USERPROFILE
    local userprofile = os.getenv("USERPROFILE")
    if userprofile then
        return userprofile .. "/Downloads/"
    end
    
    -- Fallback: relative path
    return "../Downloads/"
end

local function SaveMap()
    if not hasWrite then
        Rayfield:Notify({
            Title = "❌ Error",
            Content = "Executor tidak support writefile!",
            Duration = 5
        })
        return
    end
    
    Rayfield:Notify({Title = "⏳ Saving", Content = "Processing map...", Duration = 2})
    
    local startTime = tick()
    refCounter = 0
    refMap = {}
    stats = {objects=0, scripts=0, decompiled=0}
    
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local body = ""
    
    if config.saveWorkspace then
        print("[EXPORT] Processing Workspace...")
        for _, child in ipairs(game.Workspace:GetChildren()) do
            body = body .. GetXML(child)
        end
    end
    
    if config.saveReplicatedStorage then
        print("[EXPORT] Processing ReplicatedStorage...")
        for _, child in ipairs(game.ReplicatedStorage:GetChildren()) do
            body = body .. GetXML(child)
        end
    end
    
    local data = header .. body .. "\n</roblox>"
    
    -- Get game name
    local gameName = "RobloxMap"
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        if info and info.Name then
            gameName = info.Name:gsub("[^%w%s%-]", ""):gsub("%s+", "_")
        end
    end)
    
    local fileName = gameName .. "_" .. os.date("%Y%m%d_%H%M%S")
    local ext = config.fileFormat == "RBXL" and ".rbxl" or ".rbxmx"
    local fullFileName = fileName .. ext
    
    -- Try to save to Downloads
    local downloadsPath = GetDownloadsPath()
    local filePath = downloadsPath .. fullFileName
    
    print("[SAVE] Attempting to save to:", filePath)
    print("[SAVE] File size:", string.format("%.2f KB", #data/1024))
    
    local success, err = pcall(function()
        writefile(filePath, data)
    end)
    
    if not success then
        -- Fallback: save to current directory
        print("[WARN] Failed to save to Downloads, trying current directory...")
        filePath = fullFileName
        
        success, err = pcall(function()
            writefile(filePath, data)
        end)
    end
    
    local timeTaken = tick() - startTime
    
    if success then
        print("\n" .. string.rep("=", 70))
        print("✅ MAP SAVED!")
        print(string.rep("=", 70))
        print("📁 File:", fullFileName)
        print("📂 Location:", filePath)
        print("💾 Size:", string.format("%.2f KB (%.2f MB)", #data/1024, #data/1024/1024))
        print("📦 Objects:", stats.objects)
        print("📜 Scripts:", stats.decompiled .. "/" .. stats.scripts)
        print("⏱️ Time:", string.format("%.2fs", timeTaken))
        print("")
        print("💡 HOW TO OPEN:")
        if config.fileFormat == "RBXL" then
            print("  1. Go to Downloads folder")
            print("  2. Double-click the .rbxl file")
            print("     OR")
            print("  1. Open Roblox Studio")
            print("  2. File → Open from File")
            print("  3. Select the .rbxl file from Downloads")
        else
            print("  1. Open Roblox Studio")
            print("  2. Insert → Insert from File")
            print("  3. Navigate to Downloads folder")
            print("  4. Select the .rbxmx file")
        end
        print(string.rep("=", 70) .. "\n")
        
        Rayfield:Notify({
            Title = "✅ Saved to Downloads!",
            Content = string.format("%s\n\n💾 %.1f KB\n📦 %d objects\n📜 %d/%d scripts\n⏱️ %.1fs\n\n📂 Check Downloads folder!",
                fullFileName, #data/1024, stats.objects, stats.decompiled, stats.scripts, timeTaken),
            Duration = 12
        })
        
        if setclipboard then
            setclipboard(filePath)
            print("✅ Full path copied to clipboard!")
        end
    else
        print("[ERROR] Save failed:", err)
        Rayfield:Notify({
            Title = "❌ Save Failed",
            Content = "Error: " .. tostring(err) .. "\n\nCek console (F9)",
            Duration = 8
        })
    end
end

-- BUTTONS
MainTab:CreateButton({
    Name = "💾 SAVE TO DOWNLOADS",
    Callback = SaveMap
})

MainTab:CreateParagraph({
    Title = "📂 Save Location",
    Content = "File akan disimpan ke:\nC:\\Users\\[YourName]\\Downloads\\\n\nFile format: " .. config.fileFormat .. "\n\nLangsung bisa dibuka dari folder Downloads!"
})

MainTab:CreateParagraph({
    Title = "💡 How to Open",
    Content = "Untuk RBXL:\n• Double-click file di Downloads\n  OR\n• Studio → File → Open from File\n\nUntuk RBXMX:\n• Studio → Insert → Insert from File\n• Navigate to Downloads\n• Select file"
})

local statusText = "🔍 System Status:\n\n"
statusText = statusText .. (hasWrite and "✅ writefile: Supported\n" or "❌ writefile: NOT Supported\n")
statusText = statusText .. "\n📂 Target: Downloads folder\n"
statusText = statusText .. "📝 Format: " .. config.fileFormat

SettingsTab:CreateParagraph({Title = "Status", Content = statusText})

Rayfield:Notify({
    Title = "✅ Ready!",
    Content = "File akan tersimpan langsung di Downloads!",
    Duration = 4
})
