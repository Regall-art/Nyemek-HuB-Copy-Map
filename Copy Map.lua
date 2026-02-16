-- NYEMEK HUB - WARPAH STYLE MAP COPIER
-- Save RBXL + Full Decompile

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Warpah Style",
   LoadingTitle = "Loading Map Copier...",
   LoadingSubtitle = "Save RBXL + Scripts",
   ConfigurationSaving = { Enabled = false }
})

local StatusTab = Window:CreateTab("📊 Status", 4483362458)
local OptionsTab = Window:CreateTab("⚙️ Options", 4483362458)
local SaveTab = Window:CreateTab("💾 Save", 4483362458)

-- DETECT CAPABILITIES
local hasWrite = writefile ~= nil
local hasMakeFolder = makefolder ~= nil
local hasIsFolder = isfolder ~= nil

-- CONFIG
local config = {
    includeTerrain = false,
    saveScripts = true,
    antiCopy = false,
    fileFormat = "RBXL" -- RBXL or RBXMX
}

-- STATS
local stats = {
    gameName = "Unknown",
    placeId = 0,
    totalObjects = 0,
    status = "Idle",
    progress = 0
}

-- UPDATE GAME INFO
local function UpdateGameInfo()
    pcall(function()
        stats.placeId = game.PlaceId
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        if info then
            stats.gameName = info.Name
        end
    end)
    
    -- Count objects
    stats.totalObjects = 0
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        stats.totalObjects = stats.totalObjects + 1
    end
end

UpdateGameInfo()

-- STATUS DISPLAY
StatusTab:CreateParagraph({
    Title = "📊 STATUS",
    Content = "Status: " .. stats.status
})

local gameInfoText = string.format("🎮 Game: %s\n🆔 PlaceID: %d\n📦 Objects: %d",
    stats.gameName, stats.placeId, stats.totalObjects)

StatusTab:CreateParagraph({
    Title = "🎮 GAME INFO",
    Content = gameInfoText
})

local execInfoText = string.format("✅ Executor: Xeno | saveinstance: ✅\n⚠️ Anti-Copy: %s",
    config.antiCopy and "Protected" or "Not Protected")

StatusTab:CreateParagraph({
    Title = "💻 EXECUTOR INFO",
    Content = execInfoText
})

-- OPTIONS
OptionsTab:CreateToggle({
   Name = "Include Terrain",
   CurrentValue = false,
   Callback = function(val) 
       config.includeTerrain = val
       Rayfield:Notify({
           Title = val and "✅ Terrain ON" or "⚠️ Terrain OFF",
           Content = val and "Terrain akan disimpan" or "Terrain tidak disimpan",
           Duration = 2
       })
   end,
})

OptionsTab:CreateToggle({
   Name = "Save Scripts (Decompile)",
   CurrentValue = true,
   Callback = function(val) config.saveScripts = val end,
})

OptionsTab:CreateToggle({
   Name = "Anti-Copy Protection",
   CurrentValue = false,
   Callback = function(val) config.antiCopy = val end,
})

OptionsTab:CreateDropdown({
   Name = "File Format",
   Options = {"RBXL (Recommended)", "RBXMX (XML)"},
   CurrentOption = "RBXL (Recommended)",
   Callback = function(option)
       config.fileFormat = option:match("RBXL") and "RBXL" or "RBXMX"
   end,
})

-- SERIALIZATION
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
    if not config.saveScripts then return "-- Scripts disabled" end
    
    local ok, src = pcall(function() return script.Source end)
    if ok and src and src ~= "" then return src end
    
    if decompile then
        ok, src = pcall(decompile, script)
        if ok and src then return src end
    end
    
    if syn and syn.decompile then
        ok, src = pcall(syn.decompile, script)
        if ok and src then return src end
    end
    
    return "-- Protected script: " .. script.Name
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

local processedCount = 0

local function GetXML(obj, depth)
    depth = depth or 0
    if depth > 200 then return "" end
    
    if obj:IsA("Terrain") and not config.includeTerrain then return "" end
    if obj:IsA("Camera") or obj.ClassName=="Player" then return "" end
    
    processedCount = processedCount + 1
    if processedCount % 100 == 0 then
        stats.progress = math.floor((processedCount / stats.totalObjects) * 100)
        stats.status = string.format("Saving... %d%%", stats.progress)
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

local function SaveRBXL()
    if not hasWrite then
        Rayfield:Notify({
            Title = "❌ Error",
            Content = "Executor tidak support writefile!",
            Duration = 5
        })
        return
    end
    
    stats.status = "Saving with scripts..."
    stats.progress = 0
    processedCount = 0
    
    Rayfield:Notify({
        Title = "⏳ Saving",
        Content = "Processing map...",
        Duration = 2
    })
    
    local startTime = tick()
    refCounter = 0
    refMap = {}
    
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local body = ""
    
    for _, child in ipairs(game.Workspace:GetChildren()) do
        body = body .. GetXML(child)
    end
    
    for _, child in ipairs(game.ReplicatedStorage:GetChildren()) do
        body = body .. GetXML(child)
    end
    
    local data = header .. body .. "\n</roblox>"
    
    local fileName = stats.gameName:gsub("[^%w%s%-]", ""):gsub("%s+", "_") .. "_" .. os.date("%Y%m%d_%H%M%S")
    local ext = config.fileFormat == "RBXL" and ".rbxl" or ".rbxmx"
    local fullFileName = fileName .. ext
    
    local success, err = pcall(function()
        writefile(fullFileName, data)
    end)
    
    local timeTaken = tick() - startTime
    
    if success then
        stats.status = "Saved successfully!"
        stats.progress = 100
        
        print("\n" .. string.rep("=", 60))
        print("✅ MAP SAVED AS " .. config.fileFormat)
        print(string.rep("=", 60))
        print("📁 File:", fullFileName)
        print("💾 Size:", string.format("%.2f KB", #data/1024))
        print("📦 Objects:", stats.totalObjects)
        print("⏱️ Time:", string.format("%.2fs", timeTaken))
        print("📂 Location: Xeno root folder")
        print(string.rep("=", 60) .. "\n")
        
        Rayfield:Notify({
            Title = "✅ Saved!",
            Content = string.format("%s\n\n💾 %.1f KB\n📦 %d objects\n⏱️ %.1fs\n\n📂 Check Xeno folder!",
                fullFileName, #data/1024, stats.totalObjects, timeTaken),
            Duration = 10
        })
        
        if setclipboard then
            setclipboard(fullFileName)
        end
    else
        stats.status = "Save failed!"
        Rayfield:Notify({
            Title = "❌ Failed",
            Content = tostring(err),
            Duration = 5
        })
    end
end

local function QuickSave()
    config.includeTerrain = false
    config.saveScripts = false
    SaveRBXL()
end

-- SAVE BUTTONS
SaveTab:CreateButton({
    Name = "💾 SAVE RBXL + LOCALSCRIPT",
    Callback = SaveRBXL
})

SaveTab:CreateButton({
    Name = "⚡ QUICK SAVE (No Options)",
    Callback = QuickSave
})

SaveTab:CreateParagraph({
    Title = "💡 How to Use",
    Content = "1. Configure options (optional)\n2. Click 'SAVE RBXL + LOCALSCRIPT'\n3. Wait for completion\n4. File saved to Xeno root folder\n5. Import to Roblox Studio:\n   • File → Open from File\n   • Select the .rbxl file"
})

SaveTab:CreateParagraph({
    Title = "📂 File Location",
    Content = "Files saved to:\nC:\\Users\\[Name]\\Downloads\\Xeno-v1.3.25b\\\n\nFile format: " .. config.fileFormat .. "\n\nScripts: " .. (config.saveScripts and "Included" or "Not Included")
})

Rayfield:Notify({
    Title = "✅ Ready!",
    Content = "Warpah Style Map Copier\nClick SAVE to start!",
    Duration = 4
})
