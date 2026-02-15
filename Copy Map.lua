-- NYEMEK HUB - WEB DOWNLOAD EXPORTER
-- Upload file ke website, dapat link download

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Web Exporter",
   LoadingTitle = "Loading Web Uploader...",
   LoadingSubtitle = "Download via Browser",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("📤 Export", 4483362458)
local webhookUrl = ""

-- DETEKSI HTTP
local httpRequest = nil
if syn and syn.request then httpRequest = syn.request
elseif request then httpRequest = request
elseif http and http.request then httpRequest = http.request
elseif http_request then httpRequest = http_request
end

local HttpService = game:GetService("HttpService")
local refCounter = 0

local function GetRef()
    refCounter = refCounter + 1
    return string.format("RBX%08X", refCounter)
end

local function escapeXML(str)
    if type(str) ~= "string" then return tostring(str) end
    return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

local function PropertyToXML(propName, propValue, propType)
    if propType == "CFrame" then
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = propValue:GetComponents()
        return string.format('<CoordinateFrame name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z><R00>%f</R00><R01>%f</R01><R02>%f</R02><R10>%f</R10><R11>%f</R11><R12>%f</R12><R20>%f</R20><R21>%f</R21><R22>%f</R22></CoordinateFrame>',
            propName, x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    elseif propType == "Vector3" then
        return string.format('<Vector3 name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z></Vector3>', propName, propValue.X, propValue.Y, propValue.Z)
    elseif propType == "Color3" then
        return string.format('<Color3 name="%s"><R>%f</R><G>%f</G><B>%f</B></Color3>', propName, propValue.R, propValue.G, propValue.B)
    elseif propType == "UDim2" then
        return string.format('<UDim2 name="%s"><XS>%f</XS><XO>%d</XO><YS>%f</YS><YO>%d</YO></UDim2>', 
            propName, propValue.X.Scale, propValue.X.Offset, propValue.Y.Scale, propValue.Y.Offset)
    elseif type(propValue) == "boolean" then
        return string.format('<bool name="%s">%s</bool>', propName, tostring(propValue))
    elseif type(propValue) == "number" then
        return string.format('<float name="%s">%f</float>', propName, propValue)
    elseif type(propValue) == "string" then
        return string.format('<string name="%s">%s</string>', propName, escapeXML(propValue))
    end
    return ""
end

local importantProps = {
    BasePart = {"CFrame", "Size", "Color", "Material", "Transparency", "CanCollide", "Anchored"},
    Part = {"Shape"},
    MeshPart = {"MeshId", "TextureID"},
    Model = {"PrimaryPart"},
    GuiObject = {"Size", "Position", "Visible", "BackgroundColor3"},
    TextLabel = {"Text", "TextColor3", "Font", "TextSize"},
}

local function GetXML(obj, depth)
    depth = depth or 0
    if depth > 150 then return "" end
    if obj:IsA("Terrain") or obj:IsA("Camera") or obj.ClassName == "Player" then return "" end
    
    local xml = {}
    table.insert(xml, string.format('<Item class="%s" referent="%s">', obj.ClassName, GetRef()))
    table.insert(xml, "<Properties>")
    table.insert(xml, string.format('<string name="Name">%s</string>', escapeXML(obj.Name)))
    
    if obj:IsA("LuaSourceContainer") then
        local success, src = pcall(function() return obj.Source end)
        if success and src and src ~= "" then
            src = src:gsub("]]>", "]]]]><![CDATA[>")
            table.insert(xml, '<ProtectedString name="Source"><![CDATA[' .. src .. ']]></ProtectedString>')
        end
    end
    
    for className, props in pairs(importantProps) do
        if obj:IsA(className) then
            for _, propName in ipairs(props) do
                local success, propValue = pcall(function() return obj[propName] end)
                if success and propValue then
                    local propXML = PropertyToXML(propName, propValue, typeof(propValue))
                    if propXML ~= "" then table.insert(xml, propXML) end
                end
            end
        end
    end
    
    table.insert(xml, "</Properties>")
    
    local success, children = pcall(function() return obj:GetChildren() end)
    if success and children then
        for _, child in ipairs(children) do
            table.insert(xml, GetXML(child, depth + 1))
        end
    end
    
    table.insert(xml, "</Item>")
    return table.concat(xml, "\n")
end

-- UPLOAD TO FILE.IO (Free temporary file host)
local function UploadToFileIO(fileName, fileData)
    print("[UPLOAD] Uploading to file.io...")
    
    local boundary = "----Boundary" .. tostring(math.random(100000, 999999))
    local payload = "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="file"; filename="' .. fileName .. '"\r\n'
    payload = payload .. "Content-Type: application/xml\r\n\r\n"
    payload = payload .. fileData .. "\r\n"
    payload = payload .. "--" .. boundary .. "--\r\n"
    
    if not httpRequest then return nil, "HTTP not supported" end
    
    local success, response = pcall(function()
        return httpRequest({
            Url = "https://file.io",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = payload
        })
    end)
    
    if success and response and response.Body then
        local data = HttpService:JSONDecode(response.Body)
        if data.success and data.link then
            return data.link, nil
        else
            return nil, "Upload failed"
        end
    end
    
    return nil, "Request failed"
end

-- UPLOAD TO GOFILE.IO (Alternative)
local function UploadToGoFile(fileName, fileData)
    print("[UPLOAD] Getting GoFile server...")
    
    -- Get server
    local serverSuccess, serverResponse = pcall(function()
        return httpRequest({
            Url = "https://api.gofile.io/getServer",
            Method = "GET"
        })
    end)
    
    if not serverSuccess or not serverResponse.Body then return nil, "Server fetch failed" end
    
    local serverData = HttpService:JSONDecode(serverResponse.Body)
    if serverData.status ~= "ok" then return nil, "No server available" end
    
    local server = serverData.data.server
    print("[UPLOAD] Uploading to " .. server .. "...")
    
    -- Upload file
    local boundary = "----Boundary" .. tostring(math.random(100000, 999999))
    local payload = "--" .. boundary .. "\r\n"
    payload = payload .. 'Content-Disposition: form-data; name="file"; filename="' .. fileName .. '"\r\n'
    payload = payload .. "Content-Type: application/xml\r\n\r\n"
    payload = payload .. fileData .. "\r\n"
    payload = payload .. "--" .. boundary .. "--\r\n"
    
    local uploadSuccess, uploadResponse = pcall(function()
        return httpRequest({
            Url = "https://" .. server .. ".gofile.io/uploadFile",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = payload
        })
    end)
    
    if uploadSuccess and uploadResponse.Body then
        local data = HttpService:JSONDecode(uploadResponse.Body)
        if data.status == "ok" and data.data.downloadPage then
            return data.data.downloadPage, nil
        end
    end
    
    return nil, "Upload failed"
end

-- MAIN EXPORT
local function SendExport(serviceName)
    Rayfield:Notify({Title = "⏳ Processing", Content = "Generating XML...", Duration = 2})
    
    refCounter = 0
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local service = game:GetService(serviceName)
    local body = ""
    
    for _, child in ipairs(service:GetChildren()) do
        body = body .. GetXML(child)
    end
    
    local finalData = header .. body .. "\n</roblox>"
    local fileName = serviceName .. "_" .. os.date("%Y%m%d_%H%M%S") .. ".rbxmx"
    
    print("[INFO] XML size:", string.format("%.2f KB", #finalData/1024))
    
    -- Try file.io first
    Rayfield:Notify({Title = "📤 Uploading", Content = "Uploading to web...", Duration = 3})
    
    local link, err = UploadToFileIO(fileName, finalData)
    
    -- Try GoFile if file.io fails
    if not link then
        print("[WARN] file.io failed, trying GoFile...")
        link, err = UploadToGoFile(fileName, finalData)
    end
    
    if link then
        print("[SUCCESS] Download link:", link)
        
        -- Copy to clipboard if supported
        if setclipboard then
            setclipboard(link)
            Rayfield:Notify({
                Title = "✅ Upload Success!", 
                Content = "Link copied to clipboard!\n" .. link, 
                Duration = 10
            })
        else
            Rayfield:Notify({
                Title = "✅ Upload Success!", 
                Content = "Check console (F9) for link!", 
                Duration = 8
            })
        end
        
        -- Send to Discord if webhook set
        if webhookUrl ~= "" and httpRequest then
            local discordPayload = HttpService:JSONEncode({
                embeds = {{
                    title = "📤 Map Export - Web Download",
                    description = "Click the link below to download:",
                    color = 5763719,
                    fields = {
                        {name = "📦 Service", value = "`" .. serviceName .. "`", inline = true},
                        {name = "📊 Size", value = string.format("%.2f KB", #finalData/1024), inline = true},
                        {name = "🔗 Download Link", value = "[Click Here](" .. link .. ")", inline = false}
                    }
                }}
            })
            
            pcall(function()
                httpRequest({
                    Url = webhookUrl,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = discordPayload
                })
            end)
        end
    else
        print("[ERROR] Upload failed:", err)
        Rayfield:Notify({
            Title = "❌ Upload Failed", 
            Content = "Error: " .. tostring(err), 
            Duration = 5
        })
    end
end

-- BUTTONS
Tab:CreateButton({Name = "📤 Export Workspace", Callback = function() SendExport("Workspace") end})
Tab:CreateButton({Name = "🎨 Export StarterGui", Callback = function() SendExport("StarterGui") end})
Tab:CreateButton({Name = "📦 Export ReplicatedStorage", Callback = function() SendExport("ReplicatedStorage") end})
Tab:CreateButton({Name = "🎮 Export ServerScriptService", Callback = function() SendExport("ServerScriptService") end})

-- WEBHOOK (OPTIONAL)
Tab:CreateInput({
   Name = "Discord Webhook (Optional)",
   PlaceholderText = "For notifications...",
   Callback = function(Text) webhookUrl = Text:match("^%s*(.-)%s*$") end,
})

Tab:CreateParagraph({
    Title = "💡 How it works", 
    Content = "1. Export map\n2. Get download link\n3. Open link in browser\n4. Download .rbxmx file\n5. Import to Roblox Studio\n\nLink expires after 1 download!"
})

Rayfield:Notify({Title = "✅ Ready!", Content = "Export to get download link!", Duration = 3})
