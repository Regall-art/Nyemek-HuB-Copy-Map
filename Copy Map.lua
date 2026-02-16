-- NYEMEK HUB - MEDIAFIRE STYLE UPLOADER
-- Direct download links (no captcha, no waiting)

print("Loading Nyemek Hub MediaFire Style...")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | MediaFire Style",
   LoadingTitle = "Loading MediaFire Uploader...",
   LoadingSubtitle = "Direct Download Links",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("💾 Export", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

-- Detect HTTP
local httpRequest = nil
if syn and syn.request then httpRequest = syn.request
elseif request then httpRequest = request
elseif http and http.request then httpRequest = http.request
elseif http_request then httpRequest = http_request
end

local HttpService = game:GetService("HttpService")

local config = {
    fileFormat = "RBXL",
    decompileScripts = true,
    webhookUrl = ""
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

SettingsTab:CreateInput({
   Name = "Discord Webhook (Optional)",
   PlaceholderText = "https://discord.com/api/webhooks/...",
   Callback = function(text) config.webhookUrl = text:match("^%s*(.-)%s*$") end,
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
    elseif t == "string" then
        return string.format('<string name="%s">%s</string>',name,escapeXML(val))
    elseif t == "boolean" then
        return string.format('<bool name="%s">%s</bool>',name,tostring(val))
    elseif t == "number" then
        return string.format('<float name="%s">%f</float>',name,val)
    elseif t == "Instance" then
        return string.format('<Ref name="%s">%s</Ref>',name,GetRef(val))
    end
    return ""
end

local function GetXML(obj, depth)
    depth = depth or 0
    if depth > 150 then return "" end
    if obj:IsA("Terrain") or obj:IsA("Camera") then return "" end
    
    stats.objects = stats.objects + 1
    
    if stats.objects % 100 == 0 then
        print(string.format("[PROGRESS] %d objects processed", stats.objects))
        task.wait()
    end
    
    local xml = '<Item class="' .. obj.ClassName .. '" referent="' .. GetRef(obj) .. '">'
    xml = xml .. '<Properties>'
    
    local props = {"Name","CFrame","Size","Position","Color","Material","Transparency","CanCollide","Anchored","MeshId","TextureID"}
    
    for _, pn in ipairs(props) do
        local ok, pv = pcall(function() return obj[pn] end)
        if ok and pv ~= nil then
            xml = xml .. SerializeProp(pn, pv)
        end
    end
    
    if obj:IsA("LuaSourceContainer") then
        local src = DecompileScript(obj)
        if src then
            src = src:gsub("]]>", "]]]]><![CDATA[>")
            xml = xml .. '<ProtectedString name="Source"><![CDATA[' .. src .. ']]></ProtectedString>'
        end
    end
    
    xml = xml .. '</Properties>'
    
    local ok, children = pcall(function() return obj:GetChildren() end)
    if ok and children then
        for _, child in ipairs(children) do
            xml = xml .. GetXML(child, depth + 1)
        end
    end
    
    xml = xml .. '</Item>'
    return xml
end

-- UPLOAD TO PIXELDRAIN (MEDIAFIRE-LIKE, FREE, NO LIMIT)
local function UploadToPixelDrain(fileName, fileData)
    print("[UPLOAD] Uploading to PixelDrain (MediaFire alternative)...")
    
    local boundary = "----PixelDrain" .. tostring(math.random(100000, 999999))
    
    local payload = "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="file"; filename="' .. fileName .. '"\r\n'
    payload = payload .. "Content-Type: application/octet-stream\r\n\r\n"
    payload = payload .. fileData .. "\r\n"
    payload = payload .. "--" .. boundary .. "--\r\n"
    
    local ok, resp = pcall(function()
        return httpRequest({
            Url = "https://pixeldrain.com/api/file",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = payload
        })
    end)
    
    if ok and resp and resp.Body then
        local data = HttpService:JSONDecode(resp.Body)
        if data.success and data.id then
            local downloadUrl = "https://pixeldrain.com/api/file/" .. data.id .. "?download"
            local viewUrl = "https://pixeldrain.com/u/" .. data.id
            print("[UPLOAD] ✅ PixelDrain success!")
            return downloadUrl, viewUrl
        end
    end
    
    print("[ERROR] PixelDrain upload failed")
    return nil, nil
end

-- UPLOAD TO GOFILE (BEST ALTERNATIVE)
local function UploadToGoFile(fileName, fileData)
    print("[UPLOAD] Uploading to GoFile...")
    
    local ok1, resp1 = pcall(function()
        return httpRequest({
            Url = "https://api.gofile.io/servers",
            Method = "GET"
        })
    end)
    
    if not ok1 or not resp1.Body then return nil, nil end
    
    local serverData = HttpService:JSONDecode(resp1.Body)
    if not serverData.data or not serverData.data.servers then return nil, nil end
    
    local server = serverData.data.servers[1].name
    
    local boundary = "----GoFile" .. tostring(math.random(100000, 999999))
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
    
    if ok2 and resp2 and resp2.Body then
        local data = HttpService:JSONDecode(resp2.Body)
        if data.status == "ok" and data.data and data.data.downloadPage then
            print("[UPLOAD] ✅ GoFile success!")
            return data.data.downloadPage, data.data.downloadPage
        end
    end
    
    return nil, nil
end

-- UPLOAD TO LITTERBOX (TEMPORARY, FREE)
local function UploadToLitterBox(fileName, fileData)
    print("[UPLOAD] Uploading to LitterBox (temp file host)...")
    
    local boundary = "----LitterBox" .. tostring(math.random(100000, 999999))
    
    local payload = "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="time"\r\n\r\n72h\r\n'
    payload = payload .. "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="fileToUpload"; filename="' .. fileName .. '"\r\n'
    payload = payload .. "Content-Type: application/octet-stream\r\n\r\n"
    payload = payload .. fileData .. "\r\n"
    payload = payload .. "--" .. boundary .. "--\r\n"
    
    local ok, resp = pcall(function()
        return httpRequest({
            Url = "https://litterbox.catbox.moe/resources/internals/api.php",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = payload
        })
    end)
    
    if ok and resp and resp.Body then
        local url = resp.Body:match("https://[%w%.%-_/]+")
        if url then
            print("[UPLOAD] ✅ LitterBox success!")
            return url, url
        end
    end
    
    return nil, nil
end

-- SEND TO DISCORD
local function SendToDiscord(fileName, downloadUrl, viewUrl, fileSize)
    if config.webhookUrl == "" then return end
    
    local embedData = {
        username = "Nyemek Hub - MediaFire Style",
        embeds = {{
            title = "📤 Map Ready to Download!",
            description = "**Your map has been uploaded!**\n\nDirect download link below (MediaFire style - no ads, no wait)",
            color = 5763719,
            fields = {
                {name = "📁 File", value = "`" .. fileName .. "`", inline = false},
                {name = "💾 Size", value = string.format("%.2f MB", fileSize/1024/1024), inline = true},
                {name = "📦 Objects", value = tostring(stats.objects), inline = true},
                {name = "📜 Scripts", value = stats.decompiled .. "/" .. stats.scripts, inline = true},
                {name = "🔗 DIRECT DOWNLOAD", value = "[**>>> CLICK TO DOWNLOAD <<<**](" .. downloadUrl .. ")\n\n✅ Direct download (no waiting)\n✅ No ads or captcha\n✅ Click link = instant download", inline = false},
                {name = "🌐 View Online", value = "[Click Here](" .. (viewUrl or downloadUrl) .. ")", inline = false},
                {name = "💡 Import to Studio", value = "1. Click download link above\n2. File will download automatically\n3. Open Roblox Studio\n4. File → Open from File\n5. Select downloaded file\n6. Done!", inline = false}
            },
            footer = {text = "Nyemek Hub | MediaFire Style Uploader"},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }
    
    pcall(function()
        httpRequest({
            Url = config.webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(embedData)
        })
    end)
end

-- MAIN EXPORT
local function ExportMap()
    if not httpRequest then
        Rayfield:Notify({
            Title = "❌ HTTP Not Supported",
            Content = "Executor tidak support HTTP!",
            Duration = 5
        })
        return
    end
    
    print("\n" .. string.rep("=", 70))
    print("🚀 STARTING EXPORT")
    print(string.rep("=", 70))
    
    Rayfield:Notify({
        Title = "⏳ Exporting",
        Content = "Processing map...",
        Duration = 2
    })
    
    refCounter = 0
    refMap = {}
    stats = {objects=0, scripts=0, decompiled=0}
    
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox version="4">\n<External>null</External>\n<External>nil</External>\n'
    local body = ""
    
    -- Export services
    local services = {
        {name = "Workspace", obj = game.Workspace},
        {name = "ReplicatedStorage", obj = game.ReplicatedStorage},
        {name = "StarterGui", obj = game.StarterGui},
        {name = "Lighting", obj = game.Lighting}
    }
    
    for _, service in ipairs(services) do
        print("[EXPORT] Processing " .. service.name .. "...")
        Rayfield:Notify({
            Title = "📦 Processing",
            Content = service.name,
            Duration = 1
        })
        
        pcall(function()
            for _, child in ipairs(service.obj:GetChildren()) do
                body = body .. GetXML(child)
            end
        end)
    end
    
    local data = header .. body .. '\n</roblox>'
    
    print(string.format("[COMPLETE] Size: %.2f MB", #data/1024/1024))
    
    local gameName = "RobloxMap"
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        if info and info.Name then
            gameName = info.Name:gsub("[^%w%s%-]", ""):gsub("%s+", "_")
        end
    end)
    
    local fileName = gameName .. "_" .. os.date("%Y%m%d_%H%M%S") .. "." .. config.fileFormat:lower()
    
    Rayfield:Notify({
        Title = "📤 Uploading",
        Content = "Uploading to web (MediaFire style)...",
        Duration = 3
    })
    
    -- Try multiple services
    local downloadUrl, viewUrl
    
    print("[UPLOAD] Trying PixelDrain (direct download)...")
    downloadUrl, viewUrl = UploadToPixelDrain(fileName, data)
    
    if not downloadUrl then
        print("[UPLOAD] Trying GoFile...")
        downloadUrl, viewUrl = UploadToGoFile(fileName, data)
    end
    
    if not downloadUrl then
        print("[UPLOAD] Trying LitterBox...")
        downloadUrl, viewUrl = UploadToLitterBox(fileName, data)
    end
    
    print(string.rep("=", 70))
    
    if downloadUrl then
        print("✅ UPLOAD SUCCESS!")
        print(string.rep("=", 70))
        print("📁 File:", fileName)
        print("💾 Size:", string.format("%.2f MB", #data/1024/1024))
        print("📦 Objects:", stats.objects)
        print("📜 Scripts:", stats.decompiled .. "/" .. stats.scripts)
        print("")
        print("🔗 DIRECT DOWNLOAD LINK (MediaFire Style):")
        print(downloadUrl)
        print("")
        print("🌐 VIEW/SHARE LINK:")
        print(viewUrl or downloadUrl)
        print("")
        print("💡 CARA DOWNLOAD:")
        print("1. Copy link di atas (sudah auto-copied)")
        print("2. Paste di browser (Chrome/Firefox/Edge)")
        print("3. File akan LANGSUNG download (no ads/waiting)")
        print("4. Save file ke Downloads folder")
        print("5. Import ke Roblox Studio")
        print(string.rep("=", 70) .. "\n")
        
        if setclipboard then
            setclipboard(downloadUrl)
            print("✅ Download link copied to clipboard!")
        end
        
        SendToDiscord(fileName, downloadUrl, viewUrl, #data)
        
        Rayfield:Notify({
            Title = "✅ UPLOAD SUCCESS!",
            Content = string.format(
                "📁 %s\n💾 %.1f MB | %d obj\n\n🔗 DIRECT DOWNLOAD\n(Link copied!)\n\nClick link = instant download!\nNo ads, no waiting!",
                fileName, #data/1024/1024, stats.objects
            ),
            Duration = 20
        })
    else
        print("❌ ALL UPLOADS FAILED")
        print(string.rep("=", 70) .. "\n")
        
        Rayfield:Notify({
            Title = "❌ Upload Failed",
            Content = "All upload methods failed!\nCheck F9 console",
            Duration = 8
        })
    end
end

-- UI
MainTab:CreateButton({
    Name = "🌐 EXPORT & UPLOAD (MediaFire Style)",
    Callback = ExportMap
})

MainTab:CreateParagraph({
    Title = "📥 MediaFire Style Features",
    Content = "✅ Direct download (no ads)\n✅ No waiting/captcha\n✅ Click link = instant download\n✅ Free & fast\n✅ Multiple backup hosts\n\nServices used:\n• PixelDrain (best)\n• GoFile (1 year storage)\n• LitterBox (72 hour storage)"
})

MainTab:CreateParagraph({
    Title = "💡 How to Download",
    Content = "1. Click 'EXPORT & UPLOAD'\n2. Wait for upload to complete\n3. Link is auto-copied\n4. Paste link in browser\n5. File downloads INSTANTLY\n6. No ads, no waiting!\n7. Import to Roblox Studio"
})

SettingsTab:CreateParagraph({
    Title = "🔍 System Status",
    Content = "HTTP: " .. (httpRequest and "✅ Supported" or "❌ Not Supported") .. "\nClipboard: " .. (setclipboard and "✅ Supported" or "❌ Not Supported") .. "\n\nExecutor: " .. (syn and "Synapse" or request and "Standard" or "Unknown")
})

Rayfield:Notify({
    Title = "✅ Loaded!",
    Content = "MediaFire Style Uploader\nDirect download - no ads!",
    Duration = 4
})

print("✅ Nyemek Hub MediaFire Style loaded!")
print("💡 Direct download links (no ads, no waiting)")
