-- NYEMEK HUB - MULTI-UPLOAD WITH FALLBACK
-- Try multiple services until one works

print("Loading Multi-Upload Version...")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Multi-Upload",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "Multiple Upload Methods",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("💾 Export", 4483362458)

local httpRequest = syn and syn.request or request or http_request or http.request
local HttpService = game:GetService("HttpService")

local stats = {objects = 0, parts = 0, models = 0, scripts = 0}
local refCounter = 0
local refMap = {}

local function GetRef(obj)
    if not refMap[obj] then
        refCounter = refCounter + 1
        refMap[obj] = string.format("RBX%X", refCounter)
    end
    return refMap[obj]
end

local function EscapeXML(str)
    if type(str) ~= "string" then return tostring(str) end
    return str:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;"):gsub('"',"&quot;")
end

local function SerializeProperty(name, value)
    local valueType = typeof(value)
    
    if valueType == "CFrame" then
        local components = {value:GetComponents()}
        return string.format(
            '<CoordinateFrame name="%s">' ..
            '<X>%f</X><Y>%f</Y><Z>%f</Z>' ..
            '<R00>%f</R00><R01>%f</R01><R02>%f</R02>' ..
            '<R10>%f</R10><R11>%f</R11><R12>%f</R12>' ..
            '<R20>%f</R20><R21>%f</R21><R22>%f</R22>' ..
            '</CoordinateFrame>',
            name, unpack(components)
        )
    elseif valueType == "Vector3" then
        return string.format('<Vector3 name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z></Vector3>',
            name, value.X, value.Y, value.Z)
    elseif valueType == "Color3" then
        return string.format('<Color3 name="%s"><R>%f</R><G>%f</G><B>%f</B></Color3>',
            name, value.R, value.G, value.B)
    elseif valueType == "string" then
        return string.format('<string name="%s">%s</string>', name, EscapeXML(value))
    elseif valueType == "boolean" then
        return string.format('<bool name="%s">%s</bool>', name, tostring(value))
    elseif valueType == "number" then
        return string.format('<float name="%s">%f</float>', name, value)
    elseif valueType == "Instance" then
        return string.format('<Ref name="%s">%s</Ref>', name, GetRef(value))
    end
    return ""
end

local PROPERTIES = {
    "Name","CFrame","Size","Position","Orientation","Color","BrickColor",
    "Material","Transparency","Reflectance","CanCollide","Anchored",
    "Shape","MeshId","TextureID","MeshType","Scale","Offset"
}

local function GenerateXML(object, depth)
    depth = depth or 0
    if depth > 250 then return "" end
    if object:IsA("Terrain") or object:IsA("Camera") then return "" end
    
    stats.objects = stats.objects + 1
    if object:IsA("BasePart") then stats.parts = stats.parts + 1 end
    if object:IsA("Model") then stats.models = stats.models + 1 end
    if object:IsA("LuaSourceContainer") then stats.scripts = stats.scripts + 1 end
    
    if stats.objects % 50 == 0 then
        print(string.format("[PROGRESS] %d objects (%d parts, %d models)", stats.objects, stats.parts, stats.models))
        task.wait()
    end
    
    local xml = {}
    table.insert(xml, string.format('<Item class="%s" referent="%s">', object.ClassName, GetRef(object)))
    table.insert(xml, '<Properties>')
    
    for _, propName in ipairs(PROPERTIES) do
        local success, value = pcall(function() return object[propName] end)
        if success and value ~= nil then
            local propXML = SerializeProperty(propName, value)
            if propXML ~= "" then table.insert(xml, propXML) end
        end
    end
    
    if object:IsA("LuaSourceContainer") then
        local success, source = pcall(function() return object.Source end)
        if success and source then
            source = source:gsub("]]>", "]]]]><![CDATA[>")
            table.insert(xml, '<ProtectedString name="Source"><![CDATA[' .. source .. ']]></ProtectedString>')
        end
    end
    
    table.insert(xml, '</Properties>')
    
    local success, children = pcall(function() return object:GetChildren() end)
    if success and children then
        for _, child in ipairs(children) do
            table.insert(xml, GenerateXML(child, depth + 1))
        end
    end
    
    table.insert(xml, '</Item>')
    return table.concat(xml, '\n')
end

-- METHOD 1: File.io (Best for small files)
local function UploadToFileIO(fileName, fileData)
    print("[UPLOAD] Method 1: Trying file.io...")
    
    local boundary = "----FileIO" .. tostring(math.random(100000, 999999))
    local payload = "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="file"; filename="' .. fileName .. '"\r\n'
    payload = payload .. "Content-Type: application/octet-stream\r\n\r\n"
    payload = payload .. fileData .. "\r\n"
    payload = payload .. "--" .. boundary .. "--\r\n"
    
    local ok, resp = pcall(function()
        return httpRequest({
            Url = "https://file.io",
            Method = "POST",
            Headers = {["Content-Type"] = "multipart/form-data; boundary=" .. boundary},
            Body = payload
        })
    end)
    
    if ok and resp and resp.Body then
        local data = HttpService:JSONDecode(resp.Body)
        if data.success and data.link then
            print("[UPLOAD] ✅ file.io success!")
            return data.link
        end
    end
    print("[UPLOAD] ❌ file.io failed")
    return nil
end

-- METHOD 2: 0x0.st (Anonymous, simple)
local function UploadTo0x0(fileName, fileData)
    print("[UPLOAD] Method 2: Trying 0x0.st...")
    
    local boundary = "----0x0" .. tostring(math.random(100000, 999999))
    local payload = "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="file"; filename="' .. fileName .. '"\r\n'
    payload = payload .. "Content-Type: application/octet-stream\r\n\r\n"
    payload = payload .. fileData .. "\r\n"
    payload = payload .. "--" .. boundary .. "--\r\n"
    
    local ok, resp = pcall(function()
        return httpRequest({
            Url = "https://0x0.st",
            Method = "POST",
            Headers = {["Content-Type"] = "multipart/form-data; boundary=" .. boundary},
            Body = payload
        })
    end)
    
    if ok and resp and resp.Body then
        local url = resp.Body:match("https://[%w%.%-_/]+")
        if url then
            print("[UPLOAD] ✅ 0x0.st success!")
            return url
        end
    end
    print("[UPLOAD] ❌ 0x0.st failed")
    return nil
end

-- METHOD 3: Litterbox (temp storage)
local function UploadToLitterBox(fileName, fileData)
    print("[UPLOAD] Method 3: Trying LitterBox...")
    
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
            Headers = {["Content-Type"] = "multipart/form-data; boundary=" .. boundary},
            Body = payload
        })
    end)
    
    if ok and resp and resp.Body then
        local url = resp.Body:match("https://[%w%.%-_/]+")
        if url then
            print("[UPLOAD] ✅ LitterBox success!")
            return url
        end
    end
    print("[UPLOAD] ❌ LitterBox failed")
    return nil
end

-- METHOD 4: GoFile
local function UploadToGoFile(fileName, fileData)
    print("[UPLOAD] Method 4: Trying GoFile...")
    
    local ok1, resp1 = pcall(function()
        return httpRequest({Url = "https://api.gofile.io/servers", Method = "GET"})
    end)
    
    if not ok1 or not resp1.Body then 
        print("[UPLOAD] ❌ GoFile server fetch failed")
        return nil 
    end
    
    local serverData = HttpService:JSONDecode(resp1.Body)
    if not serverData.data or not serverData.data.servers then return nil end
    
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
            Headers = {["Content-Type"] = "multipart/form-data; boundary=" .. boundary},
            Body = payload
        })
    end)
    
    if ok2 and resp2 and resp2.Body then
        local data = HttpService:JSONDecode(resp2.Body)
        if data.status == "ok" and data.data and data.data.downloadPage then
            print("[UPLOAD] ✅ GoFile success!")
            return data.data.downloadPage
        end
    end
    print("[UPLOAD] ❌ GoFile failed")
    return nil
end

-- TRY ALL METHODS
local function UploadWithFallback(fileName, fileData)
    local methods = {
        {name = "file.io", func = UploadToFileIO},
        {name = "0x0.st", func = UploadTo0x0},
        {name = "LitterBox", func = UploadToLitterBox},
        {name = "GoFile", func = UploadToGoFile}
    }
    
    for i, method in ipairs(methods) do
        Rayfield:Notify({
            Title = "📤 Upload Attempt " .. i,
            Content = "Trying " .. method.name .. "...",
            Duration = 2
        })
        
        local url = method.func(fileName, fileData)
        if url then
            return url, method.name
        end
        
        task.wait(1) -- Wait between attempts
    end
    
    return nil, nil
end

-- MAIN EXPORT
local function ExportMap()
    print("\n" .. string.rep("=", 70))
    print("STARTING FULL MAP EXPORT")
    print(string.rep("=", 70))
    
    Rayfield:Notify({Title = "⏳ Exporting", Content = "Processing...", Duration = 2})
    
    refCounter = 0
    refMap = {}
    stats = {objects = 0, parts = 0, models = 0, scripts = 0}
    
    local xml = {
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<roblox version="4">',
        '<External>null</External>',
        '<External>nil</External>'
    }
    
    local services = {"Workspace", "Lighting", "ReplicatedStorage", "StarterGui"}
    
    for _, serviceName in ipairs(services) do
        print(string.format("[EXPORT] Processing %s...", serviceName))
        Rayfield:Notify({Title = "📦 Processing", Content = serviceName, Duration = 1})
        
        local service = game:GetService(serviceName)
        pcall(function()
            for _, child in ipairs(service:GetChildren()) do
                table.insert(xml, GenerateXML(child))
            end
        end)
    end
    
    table.insert(xml, '</roblox>')
    local fileData = table.concat(xml, '\n')
    
    print(string.rep("=", 70))
    print("EXPORT COMPLETE!")
    print("Total Objects:", stats.objects)
    print("Parts:", stats.parts)
    print("Models:", stats.models)
    print("Scripts:", stats.scripts)
    print("File Size:", string.format("%.2f MB", #fileData / 1024 / 1024))
    print(string.rep("=", 70))
    
    local gameName = "RobloxMap"
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        if info and info.Name then
            gameName = info.Name:gsub("[^%w%s%-]", ""):gsub("%s+", "_")
        end
    end)
    
    local fileName = gameName .. "_" .. os.date("%Y%m%d_%H%M%S") .. ".rbxmx"
    
    print("[UPLOAD] Trying multiple upload services...")
    
    local downloadUrl, serviceName = UploadWithFallback(fileName, fileData)
    
    if downloadUrl then
        print("\n" .. string.rep("=", 70))
        print("UPLOAD SUCCESS!")
        print("Service:", serviceName)
        print("Download URL:")
        print(downloadUrl)
        print(string.rep("=", 70) .. "\n")
        
        if setclipboard then
            setclipboard(downloadUrl)
        end
        
        Rayfield:Notify({
            Title = "✅ SUCCESS!",
            Content = string.format(
                "Uploaded via %s!\n\n%.1f MB | %d objects\n\nLink copied!\nDirect download ready!",
                serviceName, #fileData/1024/1024, stats.objects
            ),
            Duration = 20
        })
    else
        print("\n" .. string.rep("=", 70))
        print("ALL UPLOADS FAILED!")
        print("Tried: file.io, 0x0.st, LitterBox, GoFile")
        print(string.rep("=", 70) .. "\n")
        
        Rayfield:Notify({
            Title = "❌ All Methods Failed",
            Content = "All 4 upload services failed!\nCheck your internet or try again.",
            Duration = 10
        })
    end
end

MainTab:CreateButton({
    Name = "🚀 EXPORT & UPLOAD (4 Methods)",
    Callback = ExportMap
})

MainTab:CreateParagraph({
    Title = "📤 Multi-Upload System",
    Content = "Tries 4 different upload services:\n\n1️⃣ file.io (fast)\n2️⃣ 0x0.st (anonymous)\n3️⃣ LitterBox (72h storage)\n4️⃣ GoFile (1 year storage)\n\nIf one fails, tries next automatically!"
})

Rayfield:Notify({
    Title = "✅ Loaded!",
    Content = "Multi-Upload System Ready!\n4 backup methods!",
    Duration = 4
})

print("✅ Multi-Upload System loaded!")
print("💡 Will try 4 different services until one works!")
