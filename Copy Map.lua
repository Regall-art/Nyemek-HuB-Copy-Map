-- NYEMEK HUB - ULTIMATE SAVER WITH PROGRESS
-- GUARANTEED WORK + Real-time Progress

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Ultimate Saver",
   LoadingTitle = "Loading Ultimate Saver...",
   LoadingSubtitle = "With Progress Bar",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("💾 Save", 4483362458)
local ProgressTab = Window:CreateTab("📊 Progress", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

-- PROGRESS TRACKING
local progressData = {
    currentService = "Idle",
    currentObject = "",
    totalObjects = 0,
    processedObjects = 0,
    percentage = 0,
    status = "Ready",
    startTime = 0
}

-- CREATE PROGRESS DISPLAY
local progressParagraph = ProgressTab:CreateParagraph({
    Title = "📊 Progress",
    Content = "Status: Ready\n\nWaiting to start..."
})

local function UpdateProgress()
    local elapsed = math.floor(tick() - progressData.startTime)
    local content = string.format(
        "Status: %s\n\n" ..
        "Service: %s\n" ..
        "Progress: %d / %d objects (%d%%)\n" ..
        "Current: %s\n" ..
        "Time: %ds",
        progressData.status,
        progressData.currentService,
        progressData.processedObjects,
        progressData.totalObjects,
        progressData.percentage,
        progressData.currentObject,
        elapsed
    )
    
    -- Update paragraph (Rayfield doesn't support dynamic updates well, so we print)
    print(string.format("[PROGRESS] %d%% - %s", progressData.percentage, progressData.currentService))
end

-- CONFIG
local config = {
    fileFormat = "RBXL",
    decompileScripts = true
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
    progressData.currentObject = obj.Name
    
    -- Update progress every 50 objects
    if progressData.processedObjects % 50 == 0 then
        progressData.percentage = math.floor((progressData.processedObjects / progressData.totalObjects) * 100)
        UpdateProgress()
        task.wait() -- Yield to update UI
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

-- COUNT TOTAL OBJECTS
local function CountObjects()
    local total = 0
    
    for _, service in ipairs({
        game.Workspace,
        game.ReplicatedStorage,
        game.ReplicatedFirst,
        game.StarterGui,
        game.StarterPack,
        game.StarterPlayer,
        game.Lighting,
        game.SoundService,
        game.Chat,
        game.LocalizationService,
        game.TestService
    }) do
        pcall(function()
            for _, obj in ipairs(service:GetDescendants()) do
                total = total + 1
            end
        end)
    end
    
    return total
end

-- MAIN SAVE WITH PROGRESS
local function SaveMap()
    if not writefile then
        Rayfield:Notify({
            Title = "❌ Error",
            Content = "Executor tidak support writefile!",
            Duration = 5
        })
        return
    end
    
    print("\n" .. string.rep("=", 70))
    print("🚀 STARTING SAVE PROCESS")
    print(string.rep("=", 70))
    
    -- Initialize
    progressData.startTime = tick()
    progressData.status = "Counting objects..."
    progressData.processedObjects = 0
    refCounter = 0
    refMap = {}
    stats = {objects=0, scripts=0, decompiled=0}
    
    Rayfield:Notify({
        Title = "⏳ Counting Objects",
        Content = "Please wait...",
        Duration = 2
    })
    
    print("[INIT] Counting total objects...")
    progressData.totalObjects = CountObjects()
    print("[INIT] Total objects found:", progressData.totalObjects)
    
    Rayfield:Notify({
        Title = "📊 Found " .. progressData.totalObjects .. " objects",
        Content = "Starting export...",
        Duration = 2
    })
    
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local body = ""
    
    -- Process all services
    local services = {
        {name = "Workspace", obj = game.Workspace},
        {name = "ReplicatedStorage", obj = game.ReplicatedStorage},
        {name = "ReplicatedFirst", obj = game.ReplicatedFirst},
        {name = "StarterGui", obj = game.StarterGui},
        {name = "StarterPack", obj = game.StarterPack},
        {name = "StarterPlayer", obj = game.StarterPlayer},
        {name = "Lighting", obj = game.Lighting},
        {name = "SoundService", obj = game.SoundService},
        {name = "Chat", obj = game.Chat},
        {name = "LocalizationService", obj = game.LocalizationService},
        {name = "TestService", obj = game.TestService}
    }
    
    for _, service in ipairs(services) do
        progressData.currentService = service.name
        progressData.status = "Processing " .. service.name
        
        print(string.format("[EXPORT] Processing %s...", service.name))
        
        Rayfield:Notify({
            Title = "📦 Processing",
            Content = service.name .. "...",
            Duration = 1
        })
        
        local ok = pcall(function()
            for _, child in ipairs(service.obj:GetChildren()) do
                body = body .. GetXML(child)
            end
        end)
        
        if not ok then
            print(string.format("[WARN] Failed to process %s", service.name))
        end
    end
    
    local data = header .. body .. "\n</roblox>"
    
    print(string.format("[COMPLETE] Generated XML: %.2f MB", #data/1024/1024))
    
    progressData.status = "Saving file..."
    progressData.percentage = 95
    
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
    
    Rayfield:Notify({
        Title = "💾 Saving File",
        Content = "Writing to disk...",
        Duration = 2
    })
    
    -- TRY MULTIPLE SAVE METHODS
    local savedPath = nil
    local saveSuccess = false
    
    -- Method 1: Direct to filename
    print("[SAVE] Method 1: Direct filename")
    local ok1, err1 = pcall(function()
        writefile(fullFileName, data)
    end)
    
    if ok1 then
        savedPath = fullFileName
        saveSuccess = true
        print("[SAVE] ✅ Method 1 SUCCESS")
    else
        print("[SAVE] ❌ Method 1 failed:", err1)
        
        -- Method 2: Create folder first
        print("[SAVE] Method 2: With folder")
        if makefolder and isfolder then
            pcall(function() makefolder("SavedMaps") end)
            
            local ok2, err2 = pcall(function()
                writefile("SavedMaps/" .. fullFileName, data)
            end)
            
            if ok2 then
                savedPath = "SavedMaps/" .. fullFileName
                saveSuccess = true
                print("[SAVE] ✅ Method 2 SUCCESS")
            else
                print("[SAVE] ❌ Method 2 failed:", err2)
                
                -- Method 3: Workspace folder
                print("[SAVE] Method 3: workspace/ folder")
                pcall(function() makefolder("workspace") end)
                
                local ok3, err3 = pcall(function()
                    writefile("workspace/" .. fullFileName, data)
                end)
                
                if ok3 then
                    savedPath = "workspace/" .. fullFileName
                    saveSuccess = true
                    print("[SAVE] ✅ Method 3 SUCCESS")
                else
                    print("[SAVE] ❌ Method 3 failed:", err3)
                end
            end
        end
    end
    
    local timeTaken = tick() - progressData.startTime
    
    progressData.status = saveSuccess and "Completed!" or "Failed"
    progressData.percentage = 100
    
    print(string.rep("=", 70))
    
    if saveSuccess then
        print("✅ SAVE SUCCESS!")
        print(string.rep("=", 70))
        print("📁 File:", fullFileName)
        print("📂 Path:", savedPath)
        print("💾 Size:", string.format("%.2f KB (%.2f MB)", #data/1024, #data/1024/1024))
        print("📦 Objects:", stats.objects)
        print("📜 Scripts:", stats.decompiled .. "/" .. stats.scripts)
        print("⏱️ Time:", string.format("%.2fs", timeTaken))
        print(string.rep("=", 70) .. "\n")
        
        Rayfield:Notify({
            Title = "✅ SAVE SUCCESS!",
            Content = string.format(
                "%s\n\n" ..
                "💾 %.1f MB\n" ..
                "📦 %d objects\n" ..
                "📜 %d scripts\n" ..
                "⏱️ %.1fs\n\n" ..
                "📂 Path: %s",
                fullFileName,
                #data/1024/1024,
                stats.objects,
                stats.decompiled,
                timeTaken,
                savedPath
            ),
            Duration = 15
        })
        
        if setclipboard then
            setclipboard(savedPath)
            print("✅ Path copied to clipboard!")
        end
    else
        print("❌ SAVE FAILED!")
        print(string.rep("=", 70) .. "\n")
        
        Rayfield:Notify({
            Title = "❌ Save Failed",
            Content = "Tidak bisa save file!\nCek console (F9) untuk detail error.",
            Duration = 10
        })
    end
end

-- BUTTONS
MainTab:CreateButton({
    Name = "💾 SAVE MAP (ALL SERVICES)",
    Callback = SaveMap
})

MainTab:CreateParagraph({
    Title = "📦 What Will Be Saved",
    Content = "✅ Workspace\n✅ ReplicatedStorage\n✅ ReplicatedFirst\n✅ StarterGui\n✅ StarterPack\n✅ StarterPlayer\n✅ Lighting\n✅ SoundService\n✅ Chat\n✅ LocalizationService\n✅ TestService\n\nSemua service akan di-export!"
})

MainTab:CreateParagraph({
    Title = "💡 Features",
    Content = "✅ Real-time progress tracking\n✅ All services exported\n✅ Script decompiling\n✅ Multiple save methods\n✅ Auto error handling\n✅ Progress notifications"
})

ProgressTab:CreateParagraph({
    Title = "📊 Info",
    Content = "Progress akan ditampilkan di console (F9)\n\nTekan F9 untuk melihat detail progress real-time!"
})

local statusText = "🔍 System Check:\n\n"
statusText = statusText .. (writefile and "✅" or "❌") .. " writefile\n"
statusText = statusText .. (makefolder and "✅" or "❌") .. " makefolder\n"
statusText = statusText .. (isfolder and "✅" or "❌") .. " isfolder\n\n"
statusText = statusText .. "💡 Multiple save methods will be tried\nto ensure file is saved!"

SettingsTab:CreateParagraph({Title = "Status", Content = statusText})

Rayfield:Notify({
    Title = "✅ Ready!",
    Content = "All services akan di-export!\nTekan F9 untuk lihat progress.",
    Duration = 4
})
