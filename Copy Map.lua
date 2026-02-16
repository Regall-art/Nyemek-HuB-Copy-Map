-- NYEMEK HUB - XENO COMPATIBLE SAVER
-- Auto-open folder after save

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Xeno Saver",
   LoadingTitle = "Loading Xeno Saver...",
   LoadingSubtitle = "With Auto-Open Folder",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("💾 Save", 4483362458)
local ProgressTab = Window:CreateTab("📊 Progress", 4483362458)

local progressData = {
    currentService = "Idle",
    totalObjects = 0,
    processedObjects = 0,
    percentage = 0,
    status = "Ready",
    startTime = 0,
    savedFileName = ""
}

local config = {
    fileFormat = "RBXL",
    decompileScripts = true
}

MainTab:CreateDropdown({
   Name = "File Format",
   Options = {"RBXL", "RBXMX"},
   CurrentOption = "RBXL",
   Callback = function(option) config.fileFormat = option end,
})

MainTab:CreateToggle({
   Name = "Decompile Scripts",
   CurrentValue = true,
   Callback = function(val) config.decompileScripts = val end,
})

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
    
    return "-- Protected: " .. script.Name
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
        return string.format('<float name="%s">%f</float>',name,val)
    elseif t == "string" then
        return string.format('<string name="%s">%s</string>',name,escapeXML(val))
    elseif t == "Instance" then
        return string.format('<Ref name="%s">%s</Ref>',name,GetRef(val))
    end
    return ""
end

local props = {
    "Name","CFrame","Size","Position","Orientation","Color","BrickColor",
    "Material","Transparency","Reflectance","CanCollide","Anchored",
    "Shape","MeshId","TextureID","MeshType","Scale","Offset","Visible",
    "BackgroundColor3","Text","TextColor3","TextSize","Font","Image",
    "SoundId","Volume","Value","Brightness","Range","C0","C1","Part0","Part1"
}

local function GetXML(obj, depth)
    depth = depth or 0
    if depth > 200 then return "" end
    if obj:IsA("Terrain") or obj:IsA("Camera") or obj.ClassName=="Player" then return "" end
    
    stats.objects = stats.objects + 1
    progressData.processedObjects = progressData.processedObjects + 1
    
    if progressData.processedObjects % 100 == 0 then
        progressData.percentage = math.floor((progressData.processedObjects / progressData.totalObjects) * 100)
        print(string.format("[PROGRESS] %d%% - %s", progressData.percentage, progressData.currentService))
        task.wait()
    end
    
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

local function CountObjects()
    local total = 0
    for _, service in ipairs({
        game.Workspace, game.ReplicatedStorage, game.ReplicatedFirst,
        game.StarterGui, game.StarterPack, game.StarterPlayer,
        game.Lighting, game.SoundService
    }) do
        pcall(function()
            for _ in ipairs(service:GetDescendants()) do
                total = total + 1
            end
        end)
    end
    return total
end

local function SaveMap()
    if not writefile then
        Rayfield:Notify({Title = "❌ Error", Content = "writefile not supported!", Duration = 5})
        return
    end
    
    print("\n" .. string.rep("=", 70))
    print("🚀 STARTING SAVE")
    print(string.rep("=", 70))
    
    progressData.startTime = tick()
    progressData.processedObjects = 0
    refCounter = 0
    refMap = {}
    stats = {objects=0, scripts=0, decompiled=0}
    
    Rayfield:Notify({Title = "⏳ Counting", Content = "Please wait...", Duration = 2})
    
    progressData.totalObjects = CountObjects()
    print("[INIT] Total objects:", progressData.totalObjects)
    
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local body = ""
    
    local services = {
        {name = "Workspace", obj = game.Workspace},
        {name = "ReplicatedStorage", obj = game.ReplicatedStorage},
        {name = "ReplicatedFirst", obj = game.ReplicatedFirst},
        {name = "StarterGui", obj = game.StarterGui},
        {name = "StarterPack", obj = game.StarterPack},
        {name = "StarterPlayer", obj = game.StarterPlayer},
        {name = "Lighting", obj = game.Lighting},
        {name = "SoundService", obj = game.SoundService}
    }
    
    for _, service in ipairs(services) do
        progressData.currentService = service.name
        print(string.format("[EXPORT] Processing %s...", service.name))
        Rayfield:Notify({Title = "📦 Processing", Content = service.name, Duration = 1})
        
        pcall(function()
            for _, child in ipairs(service.obj:GetChildren()) do
                body = body .. GetXML(child)
            end
        end)
    end
    
    local data = header .. body .. "\n</roblox>"
    
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
    
    progressData.savedFileName = fullFileName
    
    Rayfield:Notify({Title = "💾 Saving", Content = "Writing file...", Duration = 2})
    
    local ok, err = pcall(function()
        writefile(fullFileName, data)
    end)
    
    local timeTaken = tick() - progressData.startTime
    
    if ok then
        print(string.rep("=", 70))
        print("✅ SAVE SUCCESS!")
        print(string.rep("=", 70))
        print("📁 File:", fullFileName)
        print("💾 Size:", string.format("%.2f KB (%.2f MB)", #data/1024, #data/1024/1024))
        print("📦 Objects:", stats.objects)
        print("📜 Scripts:", stats.decompiled .. "/" .. stats.scripts)
        print("⏱️ Time:", string.format("%.2fs", timeTaken))
        print("")
        print("📂 LOKASI FILE:")
        print("File tersimpan di folder Xeno:")
        print("C:\\Users\\[YourName]\\Downloads\\Xeno-v1.3.25b\\" .. fullFileName)
        print(string.rep("=", 70) .. "\n")
        
        Rayfield:Notify({
            Title = "✅ SAVE SUCCESS!",
            Content = string.format(
                "%s\n\n💾 %.1f MB | %d obj | %d scripts\n⏱️ %.1fs\n\n🔽 Klik 'OPEN FOLDER' button!",
                fullFileName, #data/1024/1024, stats.objects, stats.decompiled, timeTaken
            ),
            Duration = 15
        })
        
        if setclipboard then
            setclipboard(fullFileName)
            print("✅ Filename copied!")
        end
    else
        print("❌ SAVE FAILED:", err)
        Rayfield:Notify({Title = "❌ Failed", Content = tostring(err), Duration = 5})
    end
end

-- BUTTONS
MainTab:CreateButton({
    Name = "💾 SAVE MAP (ALL SERVICES)",
    Callback = SaveMap
})

MainTab:CreateButton({
    Name = "📂 OPEN XENO FOLDER",
    Callback = function()
        Rayfield:Notify({
            Title = "📂 Opening Folder",
            Content = "Opening Windows Explorer...",
            Duration = 3
        })
        
        -- Try to open folder
        local opened = false
        
        -- Method 1: shell command
        pcall(function()
            local cmd = 'explorer "' .. os.getenv("USERPROFILE") .. '\\Downloads\\Xeno-v1.3.25b"'
            os.execute(cmd)
            opened = true
        end)
        
        if opened then
            print("✅ Folder opened!")
            Rayfield:Notify({
                Title = "✅ Folder Opened",
                Content = "Check Windows Explorer!\n\nFile: " .. (progressData.savedFileName ~= "" and progressData.savedFileName or "Not saved yet"),
                Duration = 8
            })
        else
            Rayfield:Notify({
                Title = "⚠️ Manual Navigation",
                Content = "Go to:\nC:\\Users\\[YourName]\\Downloads\\Xeno-v1.3.25b\\\n\nFile: " .. (progressData.savedFileName ~= "" and progressData.savedFileName or "Not saved yet"),
                Duration = 10
            })
            
            print("\n📂 MANUAL NAVIGATION:")
            print("1. Open File Explorer")
            print("2. Go to: Downloads")
            print("3. Open folder: Xeno-v1.3.25b")
            print("4. Look for:", progressData.savedFileName ~= "" and progressData.savedFileName or "[YourFile].rbxl")
        end
    end
})

MainTab:CreateParagraph({
    Title = "📂 File Location (XENO)",
    Content = "⚠️ PENTING!\n\nFile TIDAK disave ke Downloads folder!\n\nFile disave ke FOLDER XENO:\nC:\\Users\\[Name]\\Downloads\\Xeno-v1.3.25b\\\n\nSetelah save, klik button 'OPEN XENO FOLDER' untuk buka folder!"
})

MainTab:CreateParagraph({
    Title = "💡 Cara Pakai",
    Content = "1. Klik 'SAVE MAP'\n2. Tunggu proses selesai\n3. Klik 'OPEN XENO FOLDER'\n4. File .rbxl ada disana!\n5. Double-click file atau drag ke Studio"
})

ProgressTab:CreateParagraph({
    Title = "📊 Progress Tracking",
    Content = "Tekan F9 untuk lihat progress detail!\n\nProgress akan ditampilkan di console dengan:\n• Service yang sedang diproses\n• Percentage completion\n• Object count\n• Estimated time"
})

Rayfield:Notify({
    Title = "✅ Ready!",
    Content = "File akan disave di FOLDER XENO!\nBUKAN di Downloads folder!",
    Duration = 5
})
