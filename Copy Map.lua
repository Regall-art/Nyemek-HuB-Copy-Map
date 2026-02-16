-- ╔═══════════════════════════════════════════════════════════════╗
-- ║           NYEMEK HUB - ULTIMATE MAP COPIER                   ║
-- ║     Upload to Web & Get Download Link (GoFile/AnonFiles)     ║
-- ║                    Version: 3.0 Final                        ║
-- ╚═══════════════════════════════════════════════════════════════╝

-- LOADSTRING:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Regall-art/Nyemek-HuB-Copy-Map/main/Copy%20Map.lua"))()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Ultimate Copier",
   LoadingTitle = "Loading Ultimate Map Copier...",
   LoadingSubtitle = "Upload to Web & Get Link",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("💾 Export", 4483362458)
local ProgressTab = Window:CreateTab("📊 Progress", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)
local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)

-- ═══════════════════════════════════════════════════════════════
--                         CONFIGURATION
-- ═══════════════════════════════════════════════════════════════

local webhookUrl = ""
local config = {
    fileFormat = "RBXL",
    decompileScripts = true,
    uploadMethod = "gofile" -- gofile or anonfiles
}

-- ═══════════════════════════════════════════════════════════════
--                         DETECT CAPABILITIES
-- ═══════════════════════════════════════════════════════════════

local httpRequest = nil
if syn and syn.request then 
    httpRequest = syn.request
elseif request then 
    httpRequest = request
elseif http and http.request then 
    httpRequest = http.request
elseif http_request then 
    httpRequest = http_request
end

local HttpService = game:GetService("HttpService")

-- ═══════════════════════════════════════════════════════════════
--                         SETTINGS UI
-- ═══════════════════════════════════════════════════════════════

SettingsTab:CreateInput({
   Name = "Discord Webhook (Optional)",
   PlaceholderText = "https://discord.com/api/webhooks/...",
   Callback = function(text) 
       webhookUrl = text:match("^%s*(.-)%s*$")
       if webhookUrl ~= "" then
           Rayfield:Notify({
               Title = "✅ Webhook Set", 
               Content = "Link akan dikirim ke Discord!",
               Duration = 2
           })
       end
   end,
})

SettingsTab:CreateDropdown({
   Name = "File Format",
   Options = {"RBXL (Recommended)", "RBXMX (XML)"},
   CurrentOption = "RBXL (Recommended)",
   Callback = function(option)
       config.fileFormat = option:match("RBXL") and "RBXL" or "RBXMX"
   end,
})

SettingsTab:CreateDropdown({
   Name = "Upload Service",
   Options = {"GoFile (1 year)", "AnonFiles (30 days)"},
   CurrentOption = "GoFile (1 year)",
   Callback = function(option)
       config.uploadMethod = option:match("GoFile") and "gofile" or "anonfiles"
   end,
})

SettingsTab:CreateToggle({
   Name = "Decompile Scripts",
   CurrentValue = true,
   Callback = function(val) 
       config.decompileScripts = val 
   end,
})

-- ═══════════════════════════════════════════════════════════════
--                         PROGRESS TRACKING
-- ═══════════════════════════════════════════════════════════════

local progressData = {
    currentService = "Idle",
    totalObjects = 0,
    processedObjects = 0,
    percentage = 0,
    status = "Ready",
    startTime = 0
}

local stats = {
    objects = 0,
    scripts = 0,
    decompiled = 0,
    localScripts = 0,
    serverScripts = 0,
    moduleScripts = 0
}

-- ═══════════════════════════════════════════════════════════════
--                         XML SERIALIZATION
-- ═══════════════════════════════════════════════════════════════

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
    if not config.decompileScripts then 
        return "-- Script decompiling disabled in settings" 
    end
    
    stats.scripts = stats.scripts + 1
    
    -- Track script types
    if script:IsA("LocalScript") then 
        stats.localScripts = stats.localScripts + 1
    elseif script:IsA("Script") then 
        stats.serverScripts = stats.serverScripts + 1
    elseif script:IsA("ModuleScript") then 
        stats.moduleScripts = stats.moduleScripts + 1
    end
    
    -- Method 1: Direct source
    local ok, src = pcall(function() return script.Source end)
    if ok and src and src ~= "" then
        stats.decompiled = stats.decompiled + 1
        return "-- " .. script.ClassName .. ": " .. script.Name .. "\n" .. src
    end
    
    -- Method 2: Decompile function
    if decompile then
        ok, src = pcall(decompile, script)
        if ok and src and src ~= "" then
            stats.decompiled = stats.decompiled + 1
            return "-- " .. script.ClassName .. ": " .. script.Name .. " (Decompiled)\n" .. src
        end
    end
    
    -- Method 3: Syn decompile
    if syn and syn.decompile then
        ok, src = pcall(syn.decompile, script)
        if ok and src and src ~= "" then
            stats.decompiled = stats.decompiled + 1
            return "-- " .. script.ClassName .. ": " .. script.Name .. " (Decompiled)\n" .. src
        end
    end
    
    return "-- " .. script.ClassName .. ": " .. script.Name .. "\n-- Failed to decompile (Protected or executor limitation)"
end

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
    end
    return ""
end

local props = {
    "Name","CFrame","Size","Position","Orientation","Rotation","Color","BrickColor",
    "Material","Transparency","Reflectance","CanCollide","Anchored","Massless",
    "Shape","TopSurface","BottomSurface","LeftSurface","RightSurface","FrontSurface","BackSurface",
    "FormFactor","MeshId","TextureID","MeshType","Scale","Offset","VertexColor",
    "Visible","BackgroundColor3","BackgroundTransparency","BorderSizePixel","BorderColor3",
    "Text","TextColor3","TextSize","Font","TextWrapped","TextXAlignment","TextYAlignment",
    "TextStrokeTransparency","TextStrokeColor3","TextScaled",
    "Image","ImageColor3","ImageTransparency","ScaleType","ImageRectOffset","ImageRectSize",
    "CanvasSize","ScrollBarThickness","Texture","Face","SoundId","Volume","Looped",
    "PlaybackSpeed","TimePosition","Value","Brightness","Range","Angle","Shadows",
    "Health","MaxHealth","WalkSpeed","JumpPower","JumpHeight",
    "C0","C1","Part0","Part1","PrimaryPart","AnimationId","UsePartColor",
    "CastShadow","DoubleSided","LightInfluence","Enabled","Rate","Lifetime","Speed",
    "ZIndex","LayoutOrder","AutoButtonColor","RenderFidelity","AlwaysOnTop","MaxDistance",
    "DisplayOrder","ResetOnSpawn","IgnoreGuiInset","ClipsDescendants","AnchorPoint"
}

local function GetXML(obj, depth)
    depth = depth or 0
    if depth > 200 then return "" end
    
    if obj:IsA("Terrain") or obj:IsA("Camera") or obj.ClassName == "Player" then 
        return "" 
    end
    
    stats.objects = stats.objects + 1
    progressData.processedObjects = progressData.processedObjects + 1
    
    -- Update progress every 100 objects
    if progressData.processedObjects % 100 == 0 then
        progressData.percentage = math.floor((progressData.processedObjects / progressData.totalObjects) * 100)
        print(string.format("[PROGRESS] %d%% - %s", progressData.percentage, progressData.currentService))
        task.wait()
    end
    
    local xml = {}
    table.insert(xml, string.format('<Item class="%s" referent="%s">',obj.ClassName,GetRef(obj)))
    table.insert(xml, "<Properties>")
    
    -- Serialize all properties
    for _, pn in ipairs(props) do
        local ok, pv = pcall(function() return obj[pn] end)
        if ok and pv ~= nil then
            local px = SerializeProp(pn, pv)
            if px ~= "" then
                table.insert(xml, px)
            end
        end
    end
    
    -- Decompile scripts
    if obj:IsA("LuaSourceContainer") then
        local src = DecompileScript(obj)
        if src then
            src = src:gsub("]]>", "]]]]><![CDATA[>")
            table.insert(xml, '<ProtectedString name="Source"><![CDATA[' .. src .. ']]></ProtectedString>')
        end
    end
    
    table.insert(xml, "</Properties>")
    
    -- Process children
    local ok, children = pcall(function() return obj:GetChildren() end)
    if ok and children then
        for _, child in ipairs(children) do
            table.insert(xml, GetXML(child, depth + 1))
        end
    end
    
    table.insert(xml, "</Item>")
    return table.concat(xml, "\n")
end

-- ═══════════════════════════════════════════════════════════════
--                         COUNT OBJECTS
-- ═══════════════════════════════════════════════════════════════

local function CountObjects()
    local total = 0
    local services = {
        game.Workspace,
        game.ReplicatedStorage,
        game.ReplicatedFirst,
        game.StarterGui,
        game.StarterPack,
        game.StarterPlayer,
        game.Lighting,
        game.SoundService
    }
    
    for _, service in ipairs(services) do
        pcall(function()
            for _ in ipairs(service:GetDescendants()) do
                total = total + 1
            end
        end)
    end
    
    return total
end

-- ═══════════════════════════════════════════════════════════════
--                         UPLOAD TO GOFILE
-- ═══════════════════════════════════════════════════════════════

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
        print("[ERROR] Cannot get GoFile server")
        return nil 
    end
    
    local serverData = HttpService:JSONDecode(resp1.Body)
    if serverData.status ~= "ok" or not serverData.data or not serverData.data.servers then
        print("[ERROR] Invalid server response")
        return nil
    end
    
    local server = serverData.data.servers[1].name
    print("[UPLOAD] Using server:", server)
    print("[UPLOAD] Uploading to GoFile...")
    
    -- Upload file
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
            print("[UPLOAD] ✅ GoFile upload success!")
            return data.data.downloadPage
        end
    end
    
    print("[ERROR] GoFile upload failed")
    return nil
end

-- ═══════════════════════════════════════════════════════════════
--                         UPLOAD TO ANONFILES
-- ═══════════════════════════════════════════════════════════════

local function UploadToAnonFiles(fileName, fileData)
    print("[UPLOAD] Uploading to AnonFiles...")
    
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
            print("[UPLOAD] ✅ AnonFiles upload success!")
            return data.data.file.url.full
        end
    end
    
    print("[ERROR] AnonFiles upload failed")
    return nil
end

-- ═══════════════════════════════════════════════════════════════
--                         SEND TO DISCORD
-- ═══════════════════════════════════════════════════════════════

local function SendToDiscord(fileName, downloadUrl, fileSize)
    if webhookUrl == "" then return end
    
    print("[DISCORD] Sending notification...")
    
    local embedData = {
        username = "Nyemek Hub - Map Exporter",
        embeds = {{
            title = "📤 Map Upload Complete!",
            description = "**Your map is ready to download!**",
            color = 5763719,
            fields = {
                {name = "📁 File Name", value = "`" .. fileName .. "`", inline = false},
                {name = "💾 File Size", value = string.format("%.2f MB", fileSize/1024/1024), inline = true},
                {name = "📦 Total Objects", value = tostring(stats.objects), inline = true},
                {name = "📜 Scripts Decompiled", value = string.format("%d/%d (%.0f%%)", stats.decompiled, stats.scripts, (stats.scripts > 0 and (stats.decompiled/stats.scripts)*100 or 0)), inline = true},
                {name = "🔵 LocalScripts", value = tostring(stats.localScripts), inline = true},
                {name = "🟢 ServerScripts", value = tostring(stats.serverScripts), inline = true},
                {name = "🟡 ModuleScripts", value = tostring(stats.moduleScripts), inline = true},
                {name = "🔗 DOWNLOAD LINK", value = "[**>>> CLICK HERE TO DOWNLOAD <<<**](" .. downloadUrl .. ")\n\n⚠️ **How to download:**\n1. Click link above\n2. Wait for page to load\n3. Click the **Download** button\n4. Save the file", inline = false},
                {name = "💡 How to Import", value = "1. Download the file\n2. Open Roblox Studio\n3. **File → Open from File**\n4. Select downloaded file\n5. Done! ✨", inline = false}
            },
            footer = {text = "Nyemek Hub | Ultimate Map Copier v3.0"},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }
    
    local ok = pcall(function()
        httpRequest({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(embedData)
        })
    end)
    
    if ok then
        print("[DISCORD] ✅ Notification sent!")
    else
        print("[DISCORD] ⚠️ Failed to send notification")
    end
end

-- ═══════════════════════════════════════════════════════════════
--                         MAIN EXPORT & UPLOAD
-- ═══════════════════════════════════════════════════════════════

local function ExportAndUpload()
    if not httpRequest then
        Rayfield:Notify({
            Title = "❌ HTTP Not Supported",
            Content = "Your executor doesn't support HTTP requests!",
            Duration = 8
        })
        return
    end
    
    print("\n" .. string.rep("=", 70))
    print("🚀 NYEMEK HUB - ULTIMATE MAP COPIER")
    print(string.rep("=", 70))
    
    -- Initialize
    progressData.startTime = tick()
    progressData.processedObjects = 0
    progressData.status = "Counting objects..."
    refCounter = 0
    refMap = {}
    stats = {objects=0, scripts=0, decompiled=0, localScripts=0, serverScripts=0, moduleScripts=0}
    
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
    
    -- Generate XML
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local body = ""
    
    -- Export all services
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
        progressData.status = "Processing " .. service.name
        
        print(string.format("[EXPORT] Processing %s...", service.name))
        
        Rayfield:Notify({
            Title = "📦 Processing",
            Content = service.name .. "...",
            Duration = 1
        })
        
        pcall(function()
            for _, child in ipairs(service.obj:GetChildren()) do
                body = body .. GetXML(child)
            end
        end)
    end
    
    local data = header .. body .. "\n</roblox>"
    
    print(string.format("[COMPLETE] XML generated: %.2f MB", #data/1024/1024))
    
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
    
    -- Upload to web
    progressData.status = "Uploading to web..."
    
    Rayfield:Notify({
        Title = "📤 Uploading",
        Content = "Uploading to " .. (config.uploadMethod == "gofile" and "GoFile" or "AnonFiles") .. "...",
        Duration = 3
    })
    
    local downloadUrl
    
    if config.uploadMethod == "gofile" then
        downloadUrl = UploadToGoFile(fullFileName, data)
    else
        downloadUrl = UploadToAnonFiles(fullFileName, data)
    end
    
    -- Try alternative if primary fails
    if not downloadUrl then
        print("[RETRY] Primary upload failed, trying alternative...")
        Rayfield:Notify({
            Title = "⚠️ Retrying",
            Content = "Primary upload failed, trying alternative...",
            Duration = 2
        })
        
        if config.uploadMethod == "gofile" then
            downloadUrl = UploadToAnonFiles(fullFileName, data)
        else
            downloadUrl = UploadToGoFile(fullFileName, data)
        end
    end
    
    local timeTaken = tick() - progressData.startTime
    
    print(string.rep("=", 70))
    
    if downloadUrl then
        print("✅ EXPORT & UPLOAD SUCCESS!")
        print(string.rep("=", 70))
        print("📁 File:", fullFileName)
        print("💾 Size:", string.format("%.2f MB (%.0f KB)", #data/1024/1024, #data/1024))
        print("📦 Objects:", stats.objects)
        print("📜 Scripts:", stats.decompiled .. "/" .. stats.scripts)
        print("   🔵 LocalScripts:", stats.localScripts)
        print("   🟢 ServerScripts:", stats.serverScripts)
        print("   🟡 ModuleScripts:", stats.moduleScripts)
        print("⏱️  Time:", string.format("%.2fs", timeTaken))
        print("")
        print("🔗 DOWNLOAD LINK:")
        print(downloadUrl)
        print("")
        print("💡 HOW TO DOWNLOAD:")
        print("1. Copy link above (auto-copied to clipboard)")
        print("2. Open link in browser")
        print("3. Click the DOWNLOAD button on the page")
        print("4. Save the file to your computer")
        print("5. Import to Roblox Studio (File → Open from File)")
        print(string.rep("=", 70) .. "\n")
        
        -- Copy to clipboard
        if setclipboard then
            setclipboard(downloadUrl)
            print("✅ Download link copied to clipboard!")
        end
        
        -- Send to Discord
        SendToDiscord(fullFileName, downloadUrl, #data)
        
        -- Success notification
        local successMsg = string.format(
            "✅ UPLOAD SUCCESS!\n\n" ..
            "📁 %s\n" ..
            "💾 %.1f MB\n" ..
            "📦 %d objects\n" ..
            "📜 %d/%d scripts\n" ..
            "⏱️ %.1fs\n\n" ..
            "🔗 Link copied to clipboard!\n\n" ..
            "Open in browser & click Download!",
            fullFileName,
            #data/1024/1024,
            stats.objects,
            stats.decompiled,
            stats.scripts,
            timeTaken
        )
        
        Rayfield:Notify({
            Title = "✅ SUCCESS!",
            Content = successMsg,
            Duration = 20
        })
        
        progressData.status = "Upload complete!"
        progressData.percentage = 100
        
    else
        print("❌ UPLOAD FAILED!")
        print(string.rep("=", 70))
        print("All upload methods failed.")
        print("Check console (F9) for error details.")
        print(string.rep("=", 70) .. "\n")
        
        Rayfield:Notify({
            Title = "❌ Upload Failed",
            Content = "All upload methods failed!\nCheck console (F9) for details.",
            Duration = 10
        })
        
        progressData.status = "Upload failed"
    end
end

-- ═══════════════════════════════════════════════════════════════
--                         UI BUTTONS
-- ═══════════════════════════════════════════════════════════════

MainTab:CreateButton({
    Name = "🌐 EXPORT & UPLOAD TO WEB",
    Callback = ExportAndUpload
})

MainTab:CreateSection("📋 What Will Be Exported")

MainTab:CreateParagraph({
    Title = "📦 Services Included",
    Content = "✅ Workspace\n✅ ReplicatedStorage\n✅ ReplicatedFirst\n✅ StarterGui\n✅ StarterPack\n✅ StarterPlayer\n✅ Lighting\n✅ SoundService\n\nAll services will be exported!"
})

MainTab:CreateParagraph({
    Title = "💡 How It Works",
    Content = "1. Click 'EXPORT & UPLOAD'\n2. Script processes all services\n3. File uploaded to web hosting\n4. Download link auto-copied\n5. Link sent to Discord (if set)\n6. Open link in browser\n7. Click Download button\n8. Import to Roblox Studio"
})

-- ═══════════════════════════════════════════════════════════════
--                         PROGRESS TAB
-- ═══════════════════════════════════════════════════════════════

ProgressTab:CreateParagraph({
    Title = "📊 Progress Tracking",
    Content = "Progress is displayed in console (F9)\n\nPress F9 to see:\n• Current service being processed\n• Progress percentage\n• Objects processed\n• Upload status\n\nReal-time updates every 100 objects!"
})

-- ═══════════════════════════════════════════════════════════════
--                         INFO TAB
-- ═══════════════════════════════════════════════════════════════

InfoTab:CreateParagraph({
    Title = "📥 Download Instructions",
    Content = "⚠️ IMPORTANT - How to download:\n\n1. Link will be auto-copied\n2. Paste in browser\n3. Wait for page to load\n4. CLICK the Download button\n5. Save the file\n\nDO NOT open link directly!\nYou must click Download on the page!"
})

InfoTab:CreateParagraph({
    Title = "📂 Import to Studio",
    Content = "After downloading:\n\n1. Open Roblox Studio\n2. File → Open from File\n3. Navigate to Downloads\n4. Select the .rbxl file\n5. Click Open\n\nThe map will load completely with all scripts!"
})

InfoTab:CreateParagraph({
    Title = "🌐 Upload Services",
    Content = "GoFile (Recommended):\n• Storage: 1 year\n• Speed: Fast\n• Reliability: High\n\nAnonFiles (Alternative):\n• Storage: 30 days\n• Speed: Medium\n• Reliability: Good\n\nBoth services are free and anonymous!"
})

InfoTab:CreateParagraph({
    Title = "📜 About Script Decompiling",
    Content = "Script quality depends on executor:\n\n🥇 Best: Synapse X, Script-Ware\n🥈 Good: Solara, Wave\n🥉 Limited: Others\n\nProtected scripts will show as comments.\nDecompiling success rate is shown after export."
})

-- ═══════════════════════════════════════════════════════════════
--                         SYSTEM STATUS
-- ═══════════════════════════════════════════════════════════════

local statusText = "🔍 System Check:\n\n"
statusText = statusText .. (httpRequest and "✅" or "❌") .. " HTTP Request\n"
statusText = statusText .. (setclipboard and "✅" or "❌") .. " Clipboard\n"
statusText = statusText .. (decompile and "✅" or "⚠️") .. " Decompiler\n\n"
statusText = statusText .. "Upload: " .. (config.uploadMethod == "gofile" and "GoFile" or "AnonFiles") .. "\n"
statusText = statusText .. "Format: " .. config.fileFormat

SettingsTab:CreateParagraph({
    Title = "System Status",
    Content = statusText
})

-- ═══════════════════════════════════════════════════════════════
--                         CREDITS
-- ═══════════════════════════════════════════════════════════════

InfoTab:CreateParagraph({
    Title = "📌 Credits",
    Content = "Created by: Nyemek Hub\nVersion: 3.0 Final\n\nFeatures:\n✅ All services exported\n✅ Script decompiling\n✅ Web upload (GoFile/AnonFiles)\n✅ Discord notifications\n✅ Progress tracking\n✅ Auto-clipboard\n\nThank you for using!"
})
-- ═══════════════════════════════════════════════════════════════
--                         FINAL INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

-- Welcome notification
Rayfield:Notify({
    Title = "✅ Nyemek Hub Loaded!",
    Content = "Ultimate Map Copier v3.0\n\nReady to export & upload!\nAll services will be included.",
    Duration = 5
})

print("\n" .. string.rep("=", 70))
print("╔═══════════════════════════════════════════════════════════════╗")
print("║           NYEMEK HUB - ULTIMATE MAP COPIER v3.0              ║")
print("╚═══════════════════════════════════════════════════════════════╝")
print("")
print("✅ Script loaded successfully!")
print("📦 Features:")
print("   • Export all services to RBXL/RBXMX")
print("   • Upload to web (GoFile/AnonFiles)")
print("   • Script decompiling")
print("   • Discord webhook notifications")
print("   • Real-time progress tracking")
print("")
print("💡 How to use:")
print("   1. Configure settings (optional)")
print("   2. Click 'EXPORT & UPLOAD TO WEB'")
print("   3. Wait for upload to complete")
print("   4. Download link will be copied")
print("   5. Open link in browser & download")
print("   6. Import to Roblox Studio")
print("")
print("🔍 System Status:")
print("   HTTP Request:", httpRequest and "✅ Supported" or "❌ Not Supported")
print("   Clipboard:", setclipboard and "✅ Supported" or "❌ Not Supported")
print("   Decompiler:", decompile and "✅ Available" or "⚠️ Limited")
print("")
print(string.rep("=", 70) .. "\n")

-- ═══════════════════════════════════════════════════════════════
--                         END OF SCRIPT
-- ═══════════════════════════════════════════════════════════════

--[[
