-- NYEMEK HUB - WEB UPLOAD (FIXED)
-- Proper file download with correct headers

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Web Upload Fixed",
   LoadingTitle = "Loading Fixed Uploader...",
   LoadingSubtitle = "Proper Download Links",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("💾 Save", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

local webhookUrl = ""

SettingsTab:CreateInput({
   Name = "Discord Webhook (Optional)",
   PlaceholderText = "Untuk notifikasi...",
   Callback = function(text) webhookUrl = text:match("^%s*(.-)%s*$") end,
})

local httpRequest = nil
if syn and syn.request then httpRequest = syn.request
elseif request then httpRequest = request
elseif http and http.request then httpRequest = http.request
elseif http_request then httpRequest = http_request
end

local HttpService = game:GetService("HttpService")

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

local progressData = {
    currentService = "Idle",
    totalObjects = 0,
    processedObjects = 0,
    percentage = 0
}

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
    if not config.decompileScripts then return "-- Disabled" end
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
    
    return "-- Protected"
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
        print(string.format("[PROGRESS] %d%%", progressData.percentage))
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
        game.Workspace, game.ReplicatedStorage, game.StarterGui, game.Lighting
    }) do
        pcall(function()
            for _ in ipairs(service:GetDescendants()) do total = total + 1 end
        end)
    end
    return total
end

-- UPLOAD TO GOFILE (BEST OPTION - 1 YEAR STORAGE)
local function UploadToGoFile(fileName, fileData)
    print("[UPLOAD] Getting GoFile server...")
    
    -- Get server
    local ok1, resp1 = pcall(function()
        return httpRequest({
            Url = "https://api.gofile.io/servers",
            Method = "GET"
        })
    end)
    
    if not ok1 or not resp1.Body then 
        print("[ERROR] Cannot get server")
        return nil 
    end
    
    local serverData = HttpService:JSONDecode(resp1.Body)
    if serverData.status ~= "ok" or not serverData.data or not serverData.data.servers then
        print("[ERROR] Invalid server response")
        return nil
    end
    
    local server = serverData.data.servers[1].name
    print("[UPLOAD] Using server:", server)
    print("[UPLOAD] Uploading file...")
    
    -- Upload
    local boundary = "----GoFileBoundary" .. tostring(math.random(100000, 999999))
    
    local payload = "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="file"; filename="' .. fileName .. '"\r\n'
    payload = payload .. "Content-Type: application/octet-stream\r\n\r\n"
    payload = payload .. fileData .. "\r\n"
    payload = payload .. "--" .. boundary .. "--\r\n"
    
    local ok2, resp2 = pcall(function()
        return httpRequest({
            Url = "https://" .. server .. ".gofile.io/contents/uploadfile",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = payload
        })
    end)
    
    if ok2 and resp2.Body then
        local data = HttpService:JSONDecode(resp2.Body)
        if data.status == "ok" and data.data and data.data.downloadPage then
            return data.data.downloadPage
        end
    end
    
    return nil
end

-- ALTERNATIVE: ANONFILES
local function UploadToAnonFiles(fileName, fileData)
    print("[UPLOAD] Uploading to anonfiles.com...")
    
    local boundary = "----AnonBoundary" .. tostring(math.random(100000, 999999))
    
    local payload = "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="file"; filename="' .. fileName .. '"\r\n'
    payload = payload .. "Content-Type: application/octet-stream\r\n\r\n"
    payload = payload .. fileData .. "\r\n"
    payload = payload .. "--" .. boundary .. "--\r\n"
    
    local ok, resp = pcall(function()
        return httpRequest({
            Url = "https://api.anonfiles.com/upload",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = payload
        })
    end)
    
    if ok and resp.Body then
        local data = HttpService:JSONDecode(resp.Body)
        if data.status and data.data and data.data.file and data.data.file.url and data.data.file.url.full then
            return data.data.file.url.full
        end
    end
    
    return nil
end

local function SendToDiscord(fileName, downloadUrl, fileSize)
    if webhookUrl == "" then return end
    
    local embedData = {
        username = "Nyemek Hub",
        embeds = {{
            title = "📤 Map Ready to Download!",
            description = "**Click link below to download**",
            color = 5763719,
            fields = {
                {name = "📁 File", value = "`" .. fileName .. "`", inline = false},
                {name = "💾 Size", value = string.format("%.2f MB", fileSize/1024/1024), inline = true},
                {name = "📦 Objects", value = tostring(stats.objects), inline = true},
                {name = "🔗 DOWNLOAD", value = "[**>>> CLICK HERE <<<**](" .. downloadUrl .. ")\n\n**Right-click → Save Link As**\nSave as: `" .. fileName .. "`", inline = false},
                {name = "💡 How to Import", value = "1. Download file (right-click → save as)\n2. Open Roblox Studio\n3. File → Open from File\n4. Select downloaded file\n5. Done!", inline = false}
            }
        }}
    }
    
    pcall(function()
        httpRequest({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(embedData)
        })
    end)
end

local function SaveAndUpload()
    if not httpRequest then
        Rayfield:Notify({Title = "❌ Error", Content = "HTTP not supported!", Duration = 5})
        return
    end
    
    print("\n" .. string.rep("=", 70))
    print("🚀 STARTING")
    print(string.rep("=", 70))
    
    progressData.processedObjects = 0
    refCounter = 0
    refMap = {}
    stats = {objects=0, scripts=0, decompiled=0}
    
    Rayfield:Notify({Title = "⏳ Counting", Content = "Please wait...", Duration = 2})
    
    progressData.totalObjects = CountObjects()
    
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local body = ""
    
    for _, service in ipairs({
        {name = "Workspace", obj = game.Workspace},
        {name = "ReplicatedStorage", obj = game.ReplicatedStorage},
        {name = "StarterGui", obj = game.StarterGui},
        {name = "Lighting", obj = game.Lighting}
    }) do
        progressData.currentService = service.name
        print("[EXPORT]", service.name)
        Rayfield:Notify({Title = "📦 " .. service.name, Content = "Processing...", Duration = 1})
        
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
    
    Rayfield:Notify({Title = "📤 Uploading", Content = "Please wait...", Duration = 3})
    
    local downloadUrl = UploadToGoFile(fullFileName, data)
    
    if not downloadUrl then
        print("[RETRY] Trying anonfiles...")
        downloadUrl = UploadToAnonFiles(fullFileName, data)
    end
    
    if downloadUrl then
        print(string.rep("=", 70))
        print("✅ UPLOAD SUCCESS!")
        print(string.rep("=", 70))
        print("📁 File:", fullFileName)
        print("💾 Size:", string.format("%.2f MB", #data/1024/1024))
        print("📦 Objects:", stats.objects)
        print("")
        print("🔗 DOWNLOAD LINK:")
        print(downloadUrl)
        print("")
        print("💡 HOW TO DOWNLOAD:")
        print("1. Open link in browser")
        print("2. Click download button")
        print("3. OR Right-click link → Save As")
        print("4. Save as:", fullFileName)
        print(string.rep("=", 70) .. "\n")
        
        if setclipboard then
            setclipboard(downloadUrl)
            print("✅ Link copied!")
        end
        
        SendToDiscord(fullFileName, downloadUrl, #data)
        
        Rayfield:Notify({
            Title = "✅ UPLOAD SUCCESS!",
            Content = string.format(
                "%s\n\n💾 %.1f MB | %d obj\n\n🔗 Link copied!\n\nOpen in browser & download!",
                fullFileName, #data/1024/1024, stats.objects
            ),
            Duration = 20
        })
    else
        print("❌ ALL UPLOAD METHODS FAILED")
        Rayfield:Notify({
            Title = "❌ Upload Failed",
            Content = "All methods failed!\nCheck F9 console",
            Duration = 8
        })
    end
end

MainTab:CreateButton({
    Name = "🌐 SAVE & UPLOAD",
    Callback = SaveAndUpload
})

MainTab:CreateParagraph({
    Title = "💡 How to Download",
    Content = "1. Klik SAVE & UPLOAD\n2. Wait for upload\n3. Link akan di-copy\n4. Paste link di browser\n5. KLIK DOWNLOAD button di website\n6. OR Right-click → Save Link As\n7. Save file\n8. Import to Roblox Studio"
})

MainTab:CreateParagraph({
    Title = "📥 Important!",
    Content = "⚠️ JANGAN BUKA LINK LANGSUNG!\n\nCara yang benar:\n1. Paste link di browser\n2. Tunggu halaman load\n3. KLIK tombol DOWNLOAD\n4. OR Right-click link → Save As\n5. Pilih lokasi save\n6. Save dengan extension .rbxl atau .rbxmx"
})

Rayfield:Notify({
    Title = "✅ Ready!",
    Content = "Upload uses GoFile (1 year storage)\nLink will be copied!",
    Duration = 4
})
