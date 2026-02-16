-- NYEMEK HUB - ULTIMATE MAP SAVER (FIXED)
-- Auto-create folder & Better error handling

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Map Saver",
   LoadingTitle = "Loading Map Saver...",
   LoadingSubtitle = "Auto-Create Folder",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("💾 Save", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

-- CHECK FUNCTIONS
local hasWriteFile = pcall(function() return writefile end) and writefile
local hasMakeFolder = pcall(function() return makefolder end) and makefolder
local hasIsFolder = pcall(function() return isfolder end) and isfolder
local hasListFiles = pcall(function() return listfiles end) and listfiles
local hasReadFile = pcall(function() return readfile end) and readfile

print("\n=== CAPABILITY CHECK ===")
print("writefile:", hasWriteFile and "✅" or "❌")
print("makefolder:", hasMakeFolder and "✅" or "❌")
print("isfolder:", hasIsFolder and "✅" or "❌")
print("listfiles:", hasListFiles and "✅" or "❌")
print("readfile:", hasReadFile and "✅" or "❌")
print("======================\n")

if not hasWriteFile or not hasMakeFolder or not hasIsFolder then
    Rayfield:Notify({
        Title = "❌ Executor Not Supported",
        Content = "Executor ini tidak support file writing!",
        Duration = 10
    })
end

-- SETTINGS
local config = {
    fileFormat = "RBXMX",
    decompileScripts = true,
    folderName = "NyemekMaps" -- Nama folder custom
}

SettingsTab:CreateInput({
   Name = "Folder Name",
   PlaceholderText = "NyemekMaps",
   CurrentValue = "NyemekMaps",
   Callback = function(text)
       config.folderName = text:match("^%s*(.-)%s*$")
       if config.folderName == "" then
           config.folderName = "NyemekMaps"
       end
   end,
})

SettingsTab:CreateDropdown({
   Name = "File Format",
   Options = {"RBXMX", "RBXL"},
   CurrentOption = "RBXMX",
   Callback = function(option)
       config.fileFormat = option
   end,
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

-- ENSURE FOLDER EXISTS
local function EnsureFolderExists(folderName)
    if not hasMakeFolder or not hasIsFolder then
        print("[ERROR] makefolder/isfolder not supported")
        return false
    end
    
    print("[FOLDER] Checking folder:", folderName)
    
    -- Check if folder exists
    local exists = pcall(function() return isfolder(folderName) end) and isfolder(folderName)
    
    if exists then
        print("[FOLDER] ✅ Folder exists:", folderName)
        return true
    end
    
    -- Create folder
    print("[FOLDER] Creating folder:", folderName)
    local success, err = pcall(function()
        makefolder(folderName)
    end)
    
    if success then
        print("[FOLDER] ✅ Folder created:", folderName)
        -- Verify it was created
        task.wait(0.1)
        local verified = pcall(function() return isfolder(folderName) end) and isfolder(folderName)
        if verified then
            print("[FOLDER] ✅ Folder verified:", folderName)
            return true
        else
            print("[FOLDER] ⚠️ Folder not verified")
            return false
        end
    else
        print("[FOLDER] ❌ Failed to create folder:", err)
        return false
    end
end

-- TEST WRITE
local function TestWrite(folderName)
    print("[TEST] Testing write to folder:", folderName)
    
    local testFile = folderName .. "/test.txt"
    local testContent = "Test file created at " .. os.date()
    
    local success, err = pcall(function()
        writefile(testFile, testContent)
    end)
    
    if success then
        print("[TEST] ✅ Test file written:", testFile)
        
        -- Try to read it back
        if hasReadFile then
            local readSuccess, content = pcall(function()
                return readfile(testFile)
            end)
            
            if readSuccess and content == testContent then
                print("[TEST] ✅ Test file verified!")
                return true
            else
                print("[TEST] ⚠️ Test file read failed")
            end
        end
        
        return true
    else
        print("[TEST] ❌ Test write failed:", err)
        return false
    end
end

-- MAIN SAVE
local function SaveMap()
    if not hasWriteFile or not hasMakeFolder or not hasIsFolder then
        Rayfield:Notify({
            Title = "❌ Error",
            Content = "Executor tidak support file operations!",
            Duration = 5
        })
        return
    end
    
    print("\n" .. string.rep("=", 60))
    print("🚀 STARTING MAP SAVE")
    print(string.rep("=", 60))
    
    -- Ensure folder exists
    local folderName = config.folderName
    print("[INFO] Target folder:", folderName)
    
    if not EnsureFolderExists(folderName) then
        Rayfield:Notify({
            Title = "❌ Folder Error",
            Content = "Tidak bisa buat folder!\nCek console (F9)",
            Duration = 5
        })
        print("[ERROR] Failed to create folder. Aborting.")
        return
    end
    
    -- Test write
    if not TestWrite(folderName) then
        Rayfield:Notify({
            Title = "⚠️ Write Test Failed",
            Content = "Test write gagal!\nTapi tetap lanjut...",
            Duration = 3
        })
    end
    
    Rayfield:Notify({Title = "⏳ Saving", Content = "Processing map...", Duration = 2})
    
    local startTime = tick()
    refCounter = 0
    refMap = {}
    stats = {objects=0, scripts=0, decompiled=0}
    
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local body = ""
    
    print("[EXPORT] Processing Workspace...")
    for _, child in ipairs(game.Workspace:GetChildren()) do
        body = body .. GetXML(child)
    end
    
    print("[EXPORT] Processing ReplicatedStorage...")
    for _, child in ipairs(game.ReplicatedStorage:GetChildren()) do
        body = body .. GetXML(child)
    end
    
    local data = header .. body .. "\n</roblox>"
    
    local gameName = "RobloxMap"
    local placeIdSuccess, placeId = pcall(function() return game.PlaceId end)
    if placeIdSuccess and placeId and placeId > 0 then
        local nameSuccess, info = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(placeId)
        end)
        if nameSuccess and info and info.Name then
            gameName = info.Name:gsub("[^%w%s%-]", ""):gsub("%s+", "_")
        end
    end
    
    local fileName = gameName .. "_" .. os.date("%Y%m%d_%H%M%S")
    local ext = config.fileFormat == "RBXL" and ".rbxl" or ".rbxmx"
    local fullFileName = fileName .. ext
    local filePath = folderName .. "/" .. fullFileName
    
    print("[SAVE] File name:", fullFileName)
    print("[SAVE] Full path:", filePath)
    print("[SAVE] File size:", string.format("%.2f KB", #data/1024))
    
    -- WRITE FILE
    local writeSuccess, writeErr = pcall(function()
        writefile(filePath, data)
    end)
    
    if not writeSuccess then
        print("[ERROR] Write failed:", writeErr)
        Rayfield:Notify({
            Title = "❌ Save Failed",
            Content = "Error: " .. tostring(writeErr) .. "\nCek console (F9)",
            Duration = 8
        })
        return
    end
    
    print("[SAVE] ✅ File written successfully!")
    
    -- VERIFY FILE
    task.wait(0.2)
    if hasReadFile then
        local verifySuccess, verifyContent = pcall(function()
            return readfile(filePath)
        end)
        
        if verifySuccess and #verifyContent == #data then
            print("[VERIFY] ✅ File verified! Size matches.")
        else
            print("[VERIFY] ⚠️ File verification failed")
        end
    end
    
    local timeTaken = math.floor((tick() - startTime) * 100) / 100
    
    print(string.rep("=", 60))
    print("✅ MAP SAVED!")
    print(string.rep("=", 60))
    print("📁 File:", fullFileName)
    print("📂 Folder:", folderName)
    print("💾 Size:", string.format("%.2f KB (%.2f MB)", #data/1024, #data/1024/1024))
    print("📦 Objects:", stats.objects)
    print("📜 Scripts:", stats.decompiled .. "/" .. stats.scripts)
    print("⏱️ Time:", timeTaken .. "s")
    print(string.rep("=", 60) .. "\n")
    
    local msg = string.format("✅ Saved!\n\n📁 %s\n💾 %.1f KB\n📦 %d objects\n📜 %d scripts\n\n📂 Folder: %s",
        fullFileName, #data/1024, stats.objects, stats.decompiled, folderName)
    
    Rayfield:Notify({
        Title = "✅ Success!",
        Content = msg,
        Duration = 10
    })
    
    if setclipboard then
        setclipboard(filePath)
        print("✅ Path copied to clipboard:", filePath)
    end
end

-- BUTTONS
MainTab:CreateButton({
    Name = "💾 SAVE MAP",
    Callback = SaveMap
})

MainTab:CreateButton({
    Name = "📂 Show Folder Path",
    Callback = function()
        local folder = config.folderName
        local msg = "📂 Folder: " .. folder .. "\n\n"
        
        if hasIsFolder and isfolder(folder) then
            msg = msg .. "✅ Folder exists!\n\n"
            
            if hasListFiles then
                local files = listfiles(folder)
                msg = msg .. "📋 Files: " .. #files
                
                print("\n=== FILES IN " .. folder .. " ===")
                for i, file in ipairs(files) do
                    local name = file:match("([^/\\]+)$")
                    print(i .. ". " .. name)
                end
                print("========================\n")
            end
        else
            msg = msg .. "❌ Folder doesn't exist yet.\nSave a map first!"
        end
        
        msg = msg .. "\n\n💡 Full path:\nworkspace/" .. folder .. "/"
        
        Rayfield:Notify({
            Title = "📂 Folder Info",
            Content = msg,
            Duration = 8
        })
        
        print("\n📂 FOLDER LOCATION:")
        print("Folder name:", folder)
        print("Relative path: workspace/" .. folder)
        print("\nCommon executor paths:")
        print("• Solara: C:\\Users\\[Name]\\AppData\\Local\\Solara\\workspace\\" .. folder)
        print("• Wave: C:\\Users\\[Name]\\AppData\\Local\\Wave\\workspace\\" .. folder)
        print("• Delta: C:\\Users\\[Name]\\AppData\\Local\\Delta\\workspace\\" .. folder)
        print("")
    end
})

MainTab:CreateButton({
    Name = "🧪 Test File System",
    Callback = function()
        print("\n=== FILE SYSTEM TEST ===")
        
        local folder = config.folderName
        
        print("1. Creating folder:", folder)
        local folderOk = EnsureFolderExists(folder)
        print("   Result:", folderOk and "✅ Success" or "❌ Failed")
        
        if folderOk then
            print("\n2. Testing write...")
            local writeOk = TestWrite(folder)
            print("   Result:", writeOk and "✅ Success" or "❌ Failed")
        end
        
        print("========================\n")
        
        if folderOk then
            Rayfield:Notify({
                Title = "✅ Test Passed",
                Content = "File system berfungsi!\nSiap save map.",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "❌ Test Failed",
                Content = "File system tidak support!\nGanti executor.",
                Duration = 5
            })
        end
    end
})

MainTab:CreateParagraph({
    Title = "💡 Instructions",
    Content = "1. Klik 'Test File System' dulu\n2. Kalau test pass, klik 'SAVE MAP'\n3. File tersimpan di workspace/" .. config.folderName .. "/\n4. Buka Roblox Studio\n5. Insert → Insert from File\n6. Pilih file dari folder"
})

local statusText = "🔍 System Check:\n\n"
statusText = statusText .. (hasWriteFile and "✅" or "❌") .. " writefile\n"
statusText = statusText .. (hasMakeFolder and "✅" or "❌") .. " makefolder\n"
statusText = statusText .. (hasIsFolder and "✅" or "❌") .. " isfolder\n"
statusText = statusText .. (hasListFiles and "✅" or "❌") .. " listfiles\n"
statusText = statusText .. (hasReadFile and "✅" or "❌") .. " readfile"

SettingsTab:CreateParagraph({Title = "Status", Content = statusText})

Rayfield:Notify({
    Title = "✅ Loaded",
    Content = "Test file system dulu!",
    Duration = 3
})
