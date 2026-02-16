-- NYEMEK HUB - UPLOAD TO FILE HOSTING
-- Get direct download link (MediaFire style)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Web Upload",
   LoadingTitle = "Loading Web Uploader...",
   LoadingSubtitle = "Upload & Get Download Link",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("💾 Save", 4483362458)
local ProgressTab = Window:CreateTab("📊 Progress", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

local webhookUrl = ""

SettingsTab:CreateInput({
   Name = "Discord Webhook (Optional)",
   PlaceholderText = "Untuk notifikasi link download...",
   Callback = function(text) webhookUrl = text:match("^%s*(.-)%s*$") end,
})

-- DETECT HTTP
local httpRequest = nil
if syn and syn.request then httpRequest = syn.request
elseif request then httpRequest = request
elseif http and http.request then httpRequest = http.request
elseif http_request then httpRequest = http_request
end

local HttpService = game:GetService("HttpService")

-- PROGRESS
local progressData = {
    currentService = "Idle",
    totalObjects = 0,
    processedObjects = 0,
    percentage = 0,
    status = "Ready"
}

-- CONFIG
local config = {
    fileFormat = "RBXL",
    decompileScripts = true,
    uploadMethod = "tmpfiles" -- tmpfiles, fileio, or catbox
}

SettingsTab:CreateDropdown({
   Name = "File Format",
   Options = {"RBXL", "RBXMX"},
   CurrentOption = "RBXL",
   Callback = function(option) config.fileFormat = option end,
})

SettingsTab:CreateDropdown({
   Name = "Upload Service",
   Options = {"tmpfiles.org (24h)", "file.io (1 download)", "catbox.moe (1 year)"},
   CurrentOption = "tmpfiles.org (24h)",
   Callback = function(option)
       if option:match("tmpfiles") then config.uploadMethod = "tmpfiles"
       elseif option:match("file.io") then config.uploadMethod = "fileio"
       elseif option:match("catbox") then config.uploadMethod = "catbox"
       end
   end,
})

SettingsTab:CreateToggle({
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
            for _ in ipairs(service:GetDescendants()) do total = total + 1 end
        end)
    end
    return total
end

-- UPLOAD TO TMPFILES.ORG
local function UploadToTmpFiles(fileName, fileData)
    print("[UPLOAD] Uploading to tmpfiles.org...")
    
    local boundary = "----WebKitFormBoundary" .. tostring(math.random(100000000, 999999999))
    
    local payload = "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="file"; filename="' .. fileName .. '"\r\n'
    payload = payload .. "Content-Type: application/octet-stream\r\n\r\n"
    payload = payload .. fileData .. "\r\n"
    payload = payload .. "--" .. boundary .. "--\r\n"
    
    local ok, response = pcall(function()
        return httpRequest({
            Url = "https://tmpfiles.org/api/v1/upload",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = payload
        })
    end)
    
    if ok and response and response.Body then
        local data = HttpService:JSONDecode(response.Body)
        if data.status == "success" and data.data and data.data.url then
            local url = data.data.url
            -- Convert to direct download
            local downloadUrl = url:gsub("tmpfiles.org/", "tmpfiles.org/dl/")
            return downloadUrl, url
        end
    end
    
    return nil, nil
end

-- UPLOAD TO FILE.IO
local function UploadToFileIO(fileName, fileData)
    print("[UPLOAD] Uploading to file.io...")
    
    local boundary = "----Boundary" .. tostring(math.random(100000, 999999))
    
    local payload = "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="file"; filename="' .. fileName .. '"\r\n'
    payload = payload .. "Content-Type: application/octet-stream\r\n\r\n"
    payload = payload .. fileData .. "\r\n"
    payload = payload .. "--" .. boundary .. "--\r\n"
    
    local ok, response = pcall(function()
        return httpRequest({
            Url = "https://file.io",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = payload
        })
    end)
    
    if ok and response and response.Body then
        local data = HttpService:JSONDecode(response.Body)
        if data.success and data.link then
            return data.link, data.link
        end
    end
    
    return nil, nil
end

-- UPLOAD TO CATBOX.MOE
local function UploadToCatbox(fileName, fileData)
    print("[UPLOAD] Uploading to catbox.moe...")
    
    local boundary = "----CatboxBoundary" .. tostring(math.random(100000, 999999))
    
    local payload = "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="reqtype"\r\n\r\nfileupload\r\n'
    payload = payload .. "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="fileToUpload"; filename="' .. fileName .. '"\r\n'
    payload = payload .. "Content-Type: application/octet-stream\r\n\r\n"
    payload = payload .. fileData .. "\r\n"
    payload = payload .. "--" .. boundary .. "--\r\n"
    
    local ok, response = pcall(function()
        return httpRequest({
            Url = "https://catbox.moe/user/api.php",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = payload
        })
    end)
    
    if ok and response and response.Body then
        local url = response.Body:match("https://[%w%.%-_/]+")
        if url then
            return url, url
        end
    end
    
    return nil, nil
end

-- SEND TO DISCORD
local function SendToDiscord(fileName, downloadUrl, viewUrl, fileSize)
    if webhookUrl == "" then return end
    
    local embedData = {
        username = "Nyemek Hub - Web Upload",
        embeds = {{
            title = "📤 Map Uploaded Successfully!",
            description = "**Your map is ready to download!**\n\nClick the link below to download the file.",
            color = 5763719,
            fields = {
                {name = "📁 File", value = "`" .. fileName .. "`", inline = false},
                {name = "💾 Size", value = string.format("%.2f MB", fileSize/1024/1024), inline = true},
                {name = "📦 Objects", value = tostring(stats.objects), inline = true},
                {name = "📜 Scripts", value = stats.decompiled .. "/" .. stats.scripts, inline = true},
                {name = "🔗 DOWNLOAD LINK", value = "[**>>> CLICK HERE TO DOWNLOAD <<<**](" .. downloadUrl .. ")", inline = false},
                {name = "🌐 View Page", value = "[Click Here](" .. viewUrl .. ")", inline = false},
                {name = "💡 How to Use", value = "1. Click download link\n2. Save the file\n3. Open Roblox Studio\n4. File → Open from File (RBXL)\n   OR Insert → Insert from File (RBXMX)\n5. Done!", inline = false}
            },
            footer = {text = "Nyemek Hub | Web Uploader"},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
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

-- MAIN SAVE & UPLOAD
local function SaveAndUpload()
    if not httpRequest then
        Rayfield:Notify({Title = "❌ Error", Content = "HTTP tidak support!", Duration = 5})
        return
    end
    
    print("\n" .. string.rep("=", 70))
    print("🚀 STARTING PROCESS")
    print(string.rep("=", 70))
    
    progressData.processedObjects = 0
    refCounter = 0
    refMap = {}
    stats = {objects=0, scripts=0, decompiled=0}
    
    Rayfield:Notify({Title = "⏳ Counting", Content = "Counting objects...", Duration = 2})
    
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
    
    print(string.format("[COMPLETE] XML generated: %.2f MB", #data/1024/1024))
    
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
    
    Rayfield:Notify({Title = "📤 Uploading", Content = "Uploading to web...", Duration = 3})
    
    local downloadUrl, viewUrl
    
    if config.uploadMethod == "tmpfiles" then
        downloadUrl, viewUrl = UploadToTmpFiles(fullFileName, data)
    elseif config.uploadMethod == "fileio" then
        downloadUrl, viewUrl = UploadToFileIO(fullFileName, data)
    elseif config.uploadMethod == "catbox" then
        downloadUrl, viewUrl = UploadToCatbox(fullFileName, data)
    end
    
    if not downloadUrl then
        print("[WARN] Primary upload failed, trying alternatives...")
        downloadUrl, viewUrl = UploadToTmpFiles(fullFileName, data)
        if not downloadUrl then
            downloadUrl, viewUrl = UploadToFileIO(fullFileName, data)
        end
        if not downloadUrl then
            downloadUrl, viewUrl = UploadToCatbox(fullFileName, data)
        end
    end
    
    print(string.rep("=", 70))
    
    if downloadUrl then
        print("✅ UPLOAD SUCCESS!")
        print(string.rep("=", 70))
        print("📁 File:", fullFileName)
        print("💾 Size:", string.format("%.2f MB", #data/1024/1024))
        print("📦 Objects:", stats.objects)
        print("📜 Scripts:", stats.decompiled .. "/" .. stats.scripts)
        print("")
        print("🔗 DOWNLOAD LINK:")
        print(downloadUrl)
        print("")
        print("🌐 VIEW PAGE:")
        print(viewUrl or downloadUrl)
        print(string.rep("=", 70) .. "\n")
        
        if setclipboard then
            setclipboard(downloadUrl)
            print("✅ Download link copied to clipboard!")
        end
        
        SendToDiscord(fullFileName, downloadUrl, viewUrl or downloadUrl, #data)
        
        local msg = string.format(
            "✅ UPLOAD SUCCESS!\n\n" ..
            "📁 %s\n" ..
            "💾 %.1f MB\n" ..
            "📦 %d obj | %d scripts\n\n" ..
            "🔗 Link copied to clipboard!\n" ..
            "%s\n\n" ..
            "Download dan import ke Studio!",
            fullFileName, #data/1024/1024, stats.objects, stats.decompiled,
            downloadUrl:sub(1, 50) .. "..."
        )
        
        Rayfield:Notify({Title = "✅ Upload Success!", Content = msg, Duration = 20})
    else
        print("❌ UPLOAD FAILED!")
        print(string.rep("=", 70) .. "\n")
        Rayfield:Notify({
            Title = "❌ Upload Failed",
            Content = "Semua upload method gagal!\nCek console (F9)",
            Duration = 8
        })
    end
end

MainTab:CreateButton({
    Name = "🌐 SAVE & UPLOAD TO WEB",
    Callback = SaveAndUpload
})

MainTab:CreateParagraph({
    Title = "🌐 How It Works",
    Content = "1. Script generate map file\n2. Upload ke web hosting\n3. Dapat link download\n4. Link auto-copied\n5. Link dikirim ke Discord (optional)\n6. Download dari browser\n7. Import ke Studio"
})

MainTab:CreateParagraph({
    Title = "💡 Upload Services",
    Content = "📌 tmpfiles.org:\n• File expire: 24 hours\n• No registration\n• Fast upload\n\n📌 file.io:\n• File expire: 1 download only\n• More private\n\n📌 catbox.moe:\n• File expire: 1 year\n• Best for long-term"
})

ProgressTab:CreateParagraph({
    Title = "📊 Progress",
    Content = "Progress ditampilkan di console (F9)\n\nTekan F9 untuk lihat:\n• Service yang diproses\n• Percentage\n• Object count\n• Upload progress"
})

Rayfield:Notify({
    Title = "✅ Ready!",
    Content = "File akan di-upload ke web!\nLink download akan auto-copied!",
    Duration = 5
})
