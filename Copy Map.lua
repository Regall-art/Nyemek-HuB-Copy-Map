-- ROBLOX MAP EXPORTER - ULTIMATE FIX
-- Author: Nyemek Hub
-- Version: 3.0 - Maximum Compatibility

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Map Exporter",
   LoadingTitle = "Loading XML Serializer...",
   LoadingSubtitle = "Ultimate Fixed Version",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("📤 Export", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)
local webhookUrl = ""

-- DETEKSI SEMUA HTTP METHODS
local httpMethods = {}

if syn and syn.request then
    table.insert(httpMethods, {name = "syn.request", func = syn.request})
end
if request then
    table.insert(httpMethods, {name = "request", func = request})
end
if http and http.request then
    table.insert(httpMethods, {name = "http.request", func = http.request})
end
if http_request then
    table.insert(httpMethods, {name = "http_request", func = http_request})
end

-- Tambah HttpService sebagai fallback
local HttpService = game:GetService("HttpService")
table.insert(httpMethods, {
    name = "HttpService",
    func = function(options)
        return HttpService:RequestAsync({
            Url = options.Url,
            Method = options.Method,
            Headers = options.Headers,
            Body = options.Body
        })
    end
})

local hasWriteFile = (writefile and readfile and isfolder and makefolder) ~= nil

SettingsTab:CreateInput({
   Name = "Discord Webhook URL",
   PlaceholderText = "Paste webhook...",
   Callback = function(Text) 
       webhookUrl = Text:match("^%s*(.-)%s*$")
       if webhookUrl ~= "" then
           Rayfield:Notify({Title = "✅ Webhook Set", Content = "Ready to export!", Duration = 2})
       end
   end,
})

local refCounter = 0
local function GetRef()
    refCounter = refCounter + 1
    return string.format("RBX%08X", refCounter)
end

local function escapeXML(str)
    if type(str) ~= "string" then return tostring(str) end
    return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;")
end

local function PropertyToXML(propName, propValue, propType)
    if propType == "CFrame" then
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = propValue:GetComponents()
        return string.format('<CoordinateFrame name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z><R00>%f</R00><R01>%f</R01><R02>%f</R02><R10>%f</R10><R11>%f</R11><R12>%f</R12><R20>%f</R20><R21>%f</R21><R22>%f</R22></CoordinateFrame>',
            propName, x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    elseif propType == "Vector3" then
        return string.format('<Vector3 name="%s"><X>%f</X><Y>%f</Y><Z>%f</Z></Vector3>', propName, propValue.X, propValue.Y, propValue.Z)
    elseif propType == "Vector2" then
        return string.format('<Vector2 name="%s"><X>%f</X><Y>%f</Y></Vector2>', propName, propValue.X, propValue.Y)
    elseif propType == "Color3" then
        return string.format('<Color3 name="%s"><R>%f</R><G>%f</G><B>%f</B></Color3>', propName, propValue.R, propValue.G, propValue.B)
    elseif propType == "BrickColor" then
        return string.format('<int name="%s">%d</int>', propName, propValue.Number)
    elseif propType == "UDim2" then
        return string.format('<UDim2 name="%s"><XS>%f</XS><XO>%d</XO><YS>%f</YS><YO>%d</YO></UDim2>', 
            propName, propValue.X.Scale, propValue.X.Offset, propValue.Y.Scale, propValue.Y.Offset)
    elseif propType == "Enum" or propType == "EnumItem" then
        return string.format('<token name="%s">%d</token>', propName, propValue.Value)
    elseif type(propValue) == "boolean" then
        return string.format('<bool name="%s">%s</bool>', propName, tostring(propValue))
    elseif type(propValue) == "number" then
        if math.floor(propValue) == propValue then
            return string.format('<int name="%s">%d</int>', propName, propValue)
        else
            return string.format('<float name="%s">%f</float>', propName, propValue)
        end
    elseif type(propValue) == "string" then
        return string.format('<string name="%s">%s</string>', propName, escapeXML(propValue))
    end
    return ""
end

local importantProps = {
    BasePart = {"CFrame", "Size", "Color", "Material", "Transparency", "CanCollide", "Anchored", "BrickColor"},
    Model = {"PrimaryPart"},
    Part = {"Shape"},
    MeshPart = {"MeshId", "TextureID"},
    SpecialMesh = {"MeshType", "MeshId", "TextureId", "Scale"},
    Decal = {"Texture", "Face"},
    GuiObject = {"Size", "Position", "Visible", "BackgroundColor3", "BackgroundTransparency"},
    TextLabel = {"Text", "TextColor3", "Font", "TextSize"},
    ImageLabel = {"Image", "ImageColor3"},
    Sound = {"SoundId", "Volume", "Looped"},
}

local function GetXML(obj, depth)
    depth = depth or 0
    if depth > 150 then return "" end
    
    if obj:IsA("Terrain") or obj:IsA("Camera") or obj.ClassName == "Player" then 
        return "" 
    end
    
    local xml = {}
    table.insert(xml, string.format('<Item class="%s" referent="%s">', obj.ClassName, GetRef()))
    table.insert(xml, "<Properties>")
    table.insert(xml, string.format('<string name="Name">%s</string>', escapeXML(obj.Name)))
    
    if obj:IsA("LuaSourceContainer") then
        local success, src = pcall(function() return obj.Source end)
        if success and src and src ~= "" then
            src = src:gsub("]]>", "]]]]><![CDATA[>")
            table.insert(xml, '<ProtectedString name="Source"><![CDATA[' .. src .. ']]></ProtectedString>')
        else
            table.insert(xml, '<ProtectedString name="Source"></ProtectedString>')
        end
    end
    
    for className, props in pairs(importantProps) do
        if obj:IsA(className) then
            for _, propName in ipairs(props) do
                local success, propValue = pcall(function() return obj[propName] end)
                if success and propValue ~= nil then
                    local propXML = PropertyToXML(propName, propValue, typeof(propValue))
                    if propXML ~= "" then
                        table.insert(xml, propXML)
                    end
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

-- METHOD 1: SIMPLE JSON (PALING RELIABLE)
local function SendMethod1(serviceName, fileName, fileSize)
    print("[METHOD 1] Trying simple JSON...")
    
    local payload = HttpService:JSONEncode({
        username = "Nyemek Hub Exporter",
        content = "✅ **Export Complete!**\n\n📦 **Service:** `" .. serviceName .. "`\n📊 **Size:** " .. string.format("%.2f KB", fileSize/1024) .. "\n⏰ **Time:** " .. os.date("%H:%M:%S") .. "\n\n**Note:** File saved locally due to Discord size limits.\n**Path:** `workspace/NyemekExports/" .. fileName .. "`"
    })
    
    for i, method in ipairs(httpMethods) do
        local success, response = pcall(function()
            return method.func({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = payload
            })
        end)
        
        if success and response then
            local statusOk = response.Success or response.StatusCode == 200 or response.StatusCode == 204
            print("[METHOD 1] " .. method.name .. ":", statusOk and "SUCCESS" or "FAILED")
            if statusOk then return true end
        else
            print("[METHOD 1] " .. method.name .. ": ERROR", tostring(response))
        end
    end
    
    return false
end

-- METHOD 2: EMBED (LEBIH FANCY)
local function SendMethod2(serviceName, fileName, fileSize)
    print("[METHOD 2] Trying embed...")
    
    local payload = HttpService:JSONEncode({
        username = "Nyemek Hub",
        embeds = {{
            title = "📤 Map Export Success",
            description = "Your map has been exported successfully!",
            color = 5763719,
            fields = {
                {name = "📦 Service", value = "`" .. serviceName .. "`", inline = true},
                {name = "📊 Size", value = string.format("%.2f KB", fileSize/1024), inline = true},
                {name = "📁 File", value = "`" .. fileName .. "`", inline = false},
                {name = "💡 How to Import", value = "1. Open Roblox Studio\n2. Insert → Insert from File\n3. Select: `workspace/NyemekExports/" .. fileName .. "`", inline = false}
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    })
    
    for i, method in ipairs(httpMethods) do
        local success, response = pcall(function()
            return method.func({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = payload
            })
        end)
        
        if success and response then
            local statusOk = response.Success or response.StatusCode == 200 or response.StatusCode == 204
            print("[METHOD 2] " .. method.name .. ":", statusOk and "SUCCESS" or "FAILED")
            if statusOk then return true end
        end
    end
    
    return false
end

-- SAVE FILE
local function SaveToFile(serviceName, finalData, fileName)
    if not hasWriteFile then 
        print("[FILE] WriteFile not supported")
        return false 
    end
    
    local folderName = "NyemekExports"
    if not isfolder(folderName) then
        makefolder(folderName)
    end
    
    local filePath = folderName .. "/" .. fileName
    writefile(filePath, finalData)
    print("[FILE] Saved:", filePath)
    
    return true, filePath
end

-- MAIN EXPORT
local function SendExport(serviceName)
    print("\n========== EXPORT START ==========")
    print("[INFO] Service:", serviceName)
    print("[INFO] Webhook set:", webhookUrl ~= "")
    print("[INFO] Available HTTP methods:", #httpMethods)
    
    if webhookUrl == "" and not hasWriteFile then 
        Rayfield:Notify({
            Title = "❌ Error", 
            Content = "Set webhook or use executor with writefile!", 
            Duration = 5
        })
        return 
    end
    
    Rayfield:Notify({
        Title = "⏳ Exporting", 
        Content = "Processing " .. serviceName .. "...", 
        Duration = 2
    })
    
    refCounter = 0
    local header = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n<External>null</External>\n<External>nil</External>\n'
    
    local service = game:GetService(serviceName)
    local body = ""
    local childCount = 0
    
    for _, child in ipairs(service:GetChildren()) do
        body = body .. GetXML(child)
        childCount = childCount + 1
    end
    
    if childCount == 0 then
        print("[WARN] Service is empty")
        Rayfield:Notify({Title = "⚠️ Empty", Content = serviceName .. " is empty!", Duration = 3})
        return
    end
    
    local finalData = header .. body .. "\n</roblox>"
    local fileName = serviceName .. "_" .. os.date("%Y%m%d_%H%M%S") .. ".rbxmx"
    local fileSize = #finalData
    
    print("[INFO] XML generated:", fileSize, "bytes")
    
    -- SAVE FILE FIRST (ALWAYS)
    local fileSaved = false
    if hasWriteFile then
        local success, filePath = SaveToFile(serviceName, finalData, fileName)
        if success then
            fileSaved = true
            print("[FILE] Save success:", filePath)
        end
    end
    
    -- TRY WEBHOOK NOTIFICATION
    local webhookSent = false
    if webhookUrl ~= "" then
        print("[WEBHOOK] Attempting to send notification...")
        
        -- Try Method 1
        if SendMethod1(serviceName, fileName, fileSize) then
            webhookSent = true
            print("[WEBHOOK] Method 1 success!")
        -- Try Method 2 if Method 1 fails
        elseif SendMethod2(serviceName, fileName, fileSize) then
            webhookSent = true
            print("[WEBHOOK] Method 2 success!")
        else
            print("[WEBHOOK] All methods failed")
        end
    end
    
    print("========== EXPORT END ==========\n")
    
    -- SHOW RESULT
    if fileSaved and webhookSent then
        Rayfield:Notify({
            Title = "✅ Complete!", 
            Content = "File saved & Discord notified!\n" .. fileName, 
            Duration = 6
        })
    elseif fileSaved then
        Rayfield:Notify({
            Title = "✅ File Saved!", 
            Content = "Path: workspace/NyemekExports/" .. fileName .. "\n(Webhook failed, but file is safe!)", 
            Duration = 7
        })
    elseif webhookSent then
        Rayfield:Notify({
            Title = "✅ Discord Notified!", 
            Content = "Check webhook!\n(File save failed)", 
            Duration = 6
        })
    else
        Rayfield:Notify({
            Title = "❌ Failed", 
            Content = "Check console (F9) for details", 
            Duration = 5
        })
    end
end

-- BUTTONS
Tab:CreateButton({Name = "📤 Export Workspace", Callback = function() SendExport("Workspace") end})
Tab:CreateButton({Name = "🎨 Export StarterGui", Callback = function() SendExport("StarterGui") end})
Tab:CreateButton({Name = "📦 Export ReplicatedStorage", Callback = function() SendExport("ReplicatedStorage") end})
Tab:CreateButton({Name = "🎮 Export ServerScriptService", Callback = function() SendExport("ServerScriptService") end})
Tab:CreateButton({Name = "⚙️ Export ServerStorage", Callback = function() SendExport("ServerStorage") end})
Tab:CreateButton({Name = "💡 Export Lighting", Callback = function() SendExport("Lighting") end})

-- WEBHOOK TEST
SettingsTab:CreateButton({
    Name = "🧪 Test Webhook",
    Callback = function()
        if webhookUrl == "" then
            Rayfield:Notify({Title = "❌ Error", Content = "Set webhook first!", Duration = 3})
            return
        end
        
        print("\n========== WEBHOOK TEST ==========")
        
        local testPayload = HttpService:JSONEncode({
            username = "Nyemek Hub Test",
            content = "✅ **Webhook Test**\n\nYour webhook is working correctly!"
        })
        
        local anySuccess = false
        
        for i, method in ipairs(httpMethods) do
            local success, response = pcall(function()
                return method.func({
                    Url = webhookUrl,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = testPayload
                })
            end)
            
            if success and response then
                local statusOk = response.Success or response.StatusCode == 200 or response.StatusCode == 204
                print("[TEST] " .. method.name .. ":", statusOk and "✅ SUCCESS" or "❌ FAILED")
                if statusOk then anySuccess = true end
            else
                print("[TEST] " .. method.name .. ": ❌ ERROR")
            end
        end
        
        print("========== TEST END ==========\n")
        
        if anySuccess then
            Rayfield:Notify({Title = "✅ Success!", Content = "Webhook working! Check Discord", Duration = 4})
        else
            Rayfield:Notify({Title = "❌ All Failed", Content = "Check F9 console", Duration = 4})
        end
    end
})

-- STATUS
local statusText = "🔍 System Status:\n\n"
statusText = statusText .. "🌐 HTTP Methods: " .. #httpMethods .. " available\n"
statusText = statusText .. (hasWriteFile and "✅ File Save: Supported\n" or "❌ File Save: Not Supported\n")
statusText = statusText .. "\n💡 Tips:\n- Always save file locally\n- Webhook is for notification only\n- Check F9 for detailed logs"

SettingsTab:CreateParagraph({Title = "System Info", Content = statusText})

SettingsTab:CreateParagraph({
    Title = "📌 Info", 
    Content = "Version 3.0\nBy: Nyemek Hub\n\nFile will ALWAYS save locally.\nWebhook is just for notification!"
})

-- SHOW AVAILABLE METHODS
print("\n========== NYEMEK HUB EXPORTER ==========")
print("Available HTTP methods:")
for i, method in ipairs(httpMethods) do
    print("  " .. i .. ". " .. method.name)
end
print("WriteFile support:", hasWriteFile)
print("==========================================\n")

Rayfield:Notify({
    Title = "✅ Ready!", 
    Content = "Press F9 to see detailed logs", 
    Duration = 3
})
