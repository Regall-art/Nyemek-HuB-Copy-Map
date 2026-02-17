-- ╔══════════════════════════════════════════════════════════════╗
-- ║          NYEMEK HUB - FULL MAP EXPORTER v5.0               ║
-- ║         Flux UI + Save RBXL + Upload to Web               ║
-- ╚══════════════════════════════════════════════════════════════╝
-- Loadstring:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Regall-art/Nyemek-HuB-Copy-Map/main/CopyMap.lua"))()

-- ═══════════════════════════════════════════════
-- LOAD FLUX UI
-- ═══════════════════════════════════════════════
local Flux
pcall(function()
    Flux = loadstring(game:HttpGet("https://raw.githubusercontent.com/Colorip/Flux/main/Source.lua"))()
end)

if not Flux then
    warn("[NYEMEK HUB] Flux UI failed to load!")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nyemek Hub",
        Text = "Flux UI failed! Press F8 to export.",
        Duration = 5
    })
    game:GetService("UserInputService").InputBegan:Connect(function(i, g)
        if not g and i.KeyCode == Enum.KeyCode.F8 then
            print("[NYEMEK HUB] F8 export triggered")
        end
    end)
    return
end

-- ═══════════════════════════════════════════════
-- CREATE FLUX WINDOW
-- ═══════════════════════════════════════════════
local Window = Flux:CreateWindow({
    Name = "Nyemek Hub",
    Subtitle = "Full Map Exporter v5.0",
})

local ExportTab  = Window:CreateTab("Export")
local ServiceTab = Window:CreateTab("Services")
local SettingTab = Window:CreateTab("Settings")
local InfoTab    = Window:CreateTab("Info")

-- ═══════════════════════════════════════════════
-- HTTP DETECT
-- ═══════════════════════════════════════════════
local httpRequest = syn and syn.request
    or (typeof(request) == "function" and request)
    or (http and http.request)
    or http_request
    or nil

local HttpService = game:GetService("HttpService")

-- ═══════════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════════
local config = {
    decompileScripts        = true,
    includeWorkspace        = true,
    includeLighting         = true,
    includeReplicatedStorage= true,
    includeReplicatedFirst  = true,
    includeStarterGui       = true,
    includeStarterPack      = true,
    includeStarterPlayer    = true,
    includeSoundService     = true,
    webhookUrl              = ""
}

-- ═══════════════════════════════════════════════
-- SERVICES TOGGLES
-- ═══════════════════════════════════════════════
ServiceTab:CreateToggle({
    Name = "Workspace",
    Default = true,
    Callback = function(v) config.includeWorkspace = v end
})
ServiceTab:CreateToggle({
    Name = "Lighting",
    Default = true,
    Callback = function(v) config.includeLighting = v end
})
ServiceTab:CreateToggle({
    Name = "ReplicatedStorage",
    Default = true,
    Callback = function(v) config.includeReplicatedStorage = v end
})
ServiceTab:CreateToggle({
    Name = "ReplicatedFirst",
    Default = true,
    Callback = function(v) config.includeReplicatedFirst = v end
})
ServiceTab:CreateToggle({
    Name = "StarterGui",
    Default = true,
    Callback = function(v) config.includeStarterGui = v end
})
ServiceTab:CreateToggle({
    Name = "StarterPack",
    Default = true,
    Callback = function(v) config.includeStarterPack = v end
})
ServiceTab:CreateToggle({
    Name = "StarterPlayer",
    Default = true,
    Callback = function(v) config.includeStarterPlayer = v end
})
ServiceTab:CreateToggle({
    Name = "SoundService",
    Default = true,
    Callback = function(v) config.includeSoundService = v end
})

-- ═══════════════════════════════════════════════
-- SETTINGS
-- ═══════════════════════════════════════════════
SettingTab:CreateToggle({
    Name = "Decompile Scripts",
    Default = true,
    Callback = function(v) config.decompileScripts = v end
})

SettingTab:CreateTextBox({
    Name = "Discord Webhook",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v) config.webhookUrl = v:match("^%s*(.-)%s*$") end
})

-- ═══════════════════════════════════════════════
-- SERIALIZATION
-- ═══════════════════════════════════════════════
local refCounter = 0
local refMap = {}

local function GetRef(obj)
    if not refMap[obj] then
        refCounter += 1
        refMap[obj] = ("RBX%08X"):format(refCounter)
    end
    return refMap[obj]
end

local function EscXML(s)
    if type(s) ~= "string" then s = tostring(s) end
    return s:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;"):gsub('"',"&quot;")
end

local function Prop(name, val)
    local t = typeof(val)
    if t == "CFrame" then
        local x,y,z,r00,r01,r02,r10,r11,r12,r20,r21,r22 = val:GetComponents()
        return ('<CoordinateFrame name="%s">'
            ..'<X>%g</X><Y>%g</Y><Z>%g</Z>'
            ..'<R00>%g</R00><R01>%g</R01><R02>%g</R02>'
            ..'<R10>%g</R10><R11>%g</R11><R12>%g</R12>'
            ..'<R20>%g</R20><R21>%g</R21><R22>%g</R22>'
            ..'</CoordinateFrame>'):format(name,x,y,z,r00,r01,r02,r10,r11,r12,r20,r21,r22)
    elseif t == "Vector3" then
        return ('<Vector3 name="%s"><X>%g</X><Y>%g</Y><Z>%g</Z></Vector3>'):format(name,val.X,val.Y,val.Z)
    elseif t == "Vector2" then
        return ('<Vector2 name="%s"><X>%g</X><Y>%g</Y></Vector2>'):format(name,val.X,val.Y)
    elseif t == "Color3" then
        return ('<Color3 name="%s"><R>%g</R><G>%g</G><B>%g</B></Color3>'):format(name,val.R,val.G,val.B)
    elseif t == "BrickColor" then
        return ('<int name="%s">%d</int>'):format(name,val.Number)
    elseif t == "UDim2" then
        return ('<UDim2 name="%s"><XS>%g</XS><XO>%d</XO><YS>%g</YS><YO>%d</YO></UDim2>'):format(
            name,val.X.Scale,val.X.Offset,val.Y.Scale,val.Y.Offset)
    elseif t == "UDim" then
        return ('<UDim name="%s"><S>%g</S><O>%d</O></UDim>'):format(name,val.Scale,val.Offset)
    elseif t == "Rect" then
        return ('<Rect2D name="%s"><min><X>%g</X><Y>%g</Y></min><max><X>%g</X><Y>%g</Y></max></Rect2D>'):format(
            name,val.Min.X,val.Min.Y,val.Max.X,val.Max.Y)
    elseif t == "EnumItem" then
        return ('<token name="%s">%d</token>'):format(name,val.Value)
    elseif t == "boolean" then
        return ('<bool name="%s">%s</bool>'):format(name,tostring(val))
    elseif t == "number" then
        if val == math.floor(val) and math.abs(val) < 2^31 then
            return ('<int name="%s">%d</int>'):format(name,val)
        else
            return ('<float name="%s">%g</float>'):format(name,val)
        end
    elseif t == "string" then
        return ('<string name="%s">%s</string>'):format(name,EscXML(val))
    elseif t == "Instance" then
        return ('<Ref name="%s">%s</Ref>'):format(name,GetRef(val))
    end
    return ""
end

local ALL_PROPS = {
    "Name","Archivable",
    "CFrame","Position","Orientation","Rotation","Size","WorldPivot",
    "Color","BrickColor","Material","MaterialVariant","Transparency",
    "Reflectance","CastShadow","DoubleSided","RenderFidelity",
    "CanCollide","Anchored","Massless","CanTouch","CanQuery",
    "TopSurface","BottomSurface","LeftSurface","RightSurface","FrontSurface","BackSurface",
    "Shape","FormFactor",
    "MeshId","MeshType","TextureID","Scale","Offset","VertexColor",
    "PrimaryPart","LevelOfDetail",
    "C0","C1","Part0","Part1","Enabled","Visible",
    "Brightness","Range","Angle","Shadows","Face","LightInfluence","MaxDistance","AlwaysOnTop",
    "Texture","StudsPerTileU","StudsPerTileV","OffsetStudsU","OffsetStudsV",
    "SoundId","Volume","Looped","PlaybackSpeed","RollOffMaxDistance","RollOffMinDistance",
    "ZIndex","LayoutOrder","SizeConstraint","AnchorPoint",
    "BackgroundColor3","BackgroundTransparency","BorderColor3","BorderSizePixel",
    "ClipsDescendants","AutomaticSize","Active","Selectable",
    "Text","TextColor3","TextSize","Font",
    "TextWrapped","TextScaled","TextXAlignment","TextYAlignment",
    "TextStrokeTransparency","TextStrokeColor3","LineHeight",
    "PlaceholderText","PlaceholderColor3","MultiLine","ClearTextOnFocus",
    "Image","ImageColor3","ImageTransparency","ScaleType","SliceCenter",
    "ImageRectOffset","ImageRectSize",
    "ScrollBarThickness","CanvasSize","ScrollingEnabled",
    "AutoButtonColor","Modal","Selected",
    "Value",
    "WalkSpeed","JumpHeight","JumpPower","MaxSlopeAngle","AutoRotate",
    "NameDisplayDistance","HealthDisplayType",
    "DisplayOrder","ResetOnSpawn","IgnoreGuiInset",
    "Rate","EmissionDirection","LockedToPart",
    "Lifetime","Speed","SpreadAngle","RotSpeed",
    "LightEmission","SquaredFaceCamera",
}

-- ═══════════════════════════════════════════════
-- XML GENERATOR
-- ═══════════════════════════════════════════════
local stats = {objects=0, parts=0, models=0, scripts=0, decomp=0}

local function Decompile(sc)
    if not config.decompileScripts then return "-- decompile disabled" end
    stats.scripts += 1
    local ok, src = pcall(function() return sc.Source end)
    if ok and src ~= "" then stats.decomp += 1; return src end
    if decompile then
        ok, src = pcall(decompile, sc)
        if ok and src and src ~= "" then stats.decomp += 1; return src end
    end
    if syn and syn.decompile then
        ok, src = pcall(syn.decompile, sc)
        if ok and src and src ~= "" then stats.decomp += 1; return src end
    end
    return "-- [protected]"
end

local function GenXML(obj, depth)
    depth = depth or 0
    if depth > 300 then return "" end
    if obj:IsA("Terrain") or obj:IsA("Camera") then return "" end
    stats.objects += 1
    if obj:IsA("BasePart") then stats.parts  += 1 end
    if obj:IsA("Model")    then stats.models += 1 end
    if stats.objects % 100 == 0 then
        print(("[PROGRESS] %d objects | %d parts | %d models"):format(
            stats.objects, stats.parts, stats.models))
        task.wait()
    end
    local out = {}
    out[#out+1] = ('<Item class="%s" referent="%s">'):format(obj.ClassName, GetRef(obj))
    out[#out+1] = "<Properties>"
    for _, p in ipairs(ALL_PROPS) do
        local ok, v = pcall(function() return obj[p] end)
        if ok and v ~= nil then
            local x = Prop(p, v)
            if x ~= "" then out[#out+1] = x end
        end
    end
    if obj:IsA("LuaSourceContainer") then
        local src = Decompile(obj)
        src = src:gsub("]]>","]]]]><![CDATA[>")
        out[#out+1] = '<ProtectedString name="Source"><![CDATA['..src..']]></ProtectedString>'
    end
    out[#out+1] = "</Properties>"
    local ok, children = pcall(function() return obj:GetChildren() end)
    if ok then
        for _, child in ipairs(children) do
            out[#out+1] = GenXML(child, depth+1)
        end
    end
    out[#out+1] = "</Item>"
    return table.concat(out,"\n")
end

-- ═══════════════════════════════════════════════
-- UPLOAD FUNCTIONS
-- ═══════════════════════════════════════════════
local function MakeMultipart(fn, fd)
    local b = "----NyemekBound"..tostring(math.random(100000,999999))
    local body = "--"..b.."\r\n"
        ..'Content-Disposition: form-data; name="file"; filename="'..fn..'"\r\n'
        .."Content-Type: application/octet-stream\r\n\r\n"
        ..fd.."\r\n--"..b.."--\r\n"
    return body, "multipart/form-data; boundary="..b
end

local function UploadPixelDrain(fn, fd)
    print("[UPLOAD] Trying Pixeldrain...")
    local body, ct = MakeMultipart(fn, fd)
    local ok, r = pcall(httpRequest,{Url="https://pixeldrain.com/api/file",Method="POST",
        Headers={["Content-Type"]=ct},Body=body})
    if ok and r and r.Body then
        local d = HttpService:JSONDecode(r.Body)
        if d.success and d.id then
            print("[UPLOAD] ✅ Pixeldrain OK")
            return "https://pixeldrain.com/api/file/"..d.id.."?download",
                   "https://pixeldrain.com/u/"..d.id
        end
    end
    print("[UPLOAD] ❌ Pixeldrain failed"); return nil,nil
end

local function UploadFileIO(fn, fd)
    print("[UPLOAD] Trying file.io...")
    local body, ct = MakeMultipart(fn, fd)
    local ok, r = pcall(httpRequest,{Url="https://file.io",Method="POST",
        Headers={["Content-Type"]=ct},Body=body})
    if ok and r and r.Body then
        local ok2, d = pcall(HttpService.JSONDecode, HttpService, r.Body)
        if ok2 and d and d.success and d.link then
            print("[UPLOAD] ✅ file.io OK"); return d.link,d.link
        end
    end
    print("[UPLOAD] ❌ file.io failed"); return nil,nil
end

local function UploadLitterBox(fn, fd)
    print("[UPLOAD] Trying Litterbox...")
    local b = "----LB"..tostring(math.random(100000,999999))
    local body = "--"..b.."\r\nContent-Disposition: form-data; name=\"time\"\r\n\r\n72h\r\n"
        .."--"..b.."\r\nContent-Disposition: form-data; name=\"fileToUpload\"; filename=\""..fn.."\"\r\n"
        .."Content-Type: application/octet-stream\r\n\r\n"..fd.."\r\n--"..b.."--\r\n"
    local ok, r = pcall(httpRequest,{
        Url="https://litterbox.catbox.moe/resources/internals/api.php",Method="POST",
        Headers={["Content-Type"]="multipart/form-data; boundary="..b},Body=body})
    if ok and r and r.Body then
        local url = r.Body:match("https://[%w%.%-_/]+")
        if url then print("[UPLOAD] ✅ Litterbox OK"); return url,url end
    end
    print("[UPLOAD] ❌ Litterbox failed"); return nil,nil
end

local function UploadGoFile(fn, fd)
    print("[UPLOAD] Trying GoFile...")
    local ok1, r1 = pcall(httpRequest,{Url="https://api.gofile.io/servers",Method="GET"})
    if not ok1 or not r1 or not r1.Body then print("[UPLOAD] ❌ GoFile fail"); return nil,nil end
    local sd = HttpService:JSONDecode(r1.Body)
    if not (sd.data and sd.data.servers and sd.data.servers[1]) then return nil,nil end
    local srv = sd.data.servers[1].name
    local body, ct = MakeMultipart(fn, fd)
    local ok2, r2 = pcall(httpRequest,{
        Url="https://"..srv..".gofile.io/contents/uploadfile",Method="POST",
        Headers={["Content-Type"]=ct},Body=body})
    if ok2 and r2 and r2.Body then
        local d = HttpService:JSONDecode(r2.Body)
        if d.status=="ok" and d.data and d.data.downloadPage then
            print("[UPLOAD] ✅ GoFile OK"); return d.data.downloadPage,d.data.downloadPage
        end
    end
    print("[UPLOAD] ❌ GoFile failed"); return nil,nil
end

local function UploadAll(fn, fd)
    local methods = {
        {name="Pixeldrain", fn=UploadPixelDrain},
        {name="file.io",    fn=UploadFileIO},
        {name="Litterbox",  fn=UploadLitterBox},
        {name="GoFile",     fn=UploadGoFile},
    }
    for _, m in ipairs(methods) do
        local dl, view = m.fn(fn, fd)
        if dl then return dl, view, m.name end
        task.wait(1)
    end
    return nil, nil, nil
end

-- ═══════════════════════════════════════════════
-- DISCORD
-- ═══════════════════════════════════════════════
local function SendDiscord(fileName, dlUrl, viewUrl, fileSize)
    if config.webhookUrl == "" then return end
    local embed = {
        username = "Nyemek Hub v5.0",
        embeds = {{
            title = "📤 Map Upload Complete!",
            color = 5763719,
            fields = {
                {name="📁 File",    value="`"..fileName.."`",                     inline=false},
                {name="💾 Size",    value=("%.2f MB"):format(fileSize/1024/1024), inline=true},
                {name="📦 Objects", value=tostring(stats.objects),                inline=true},
                {name="📜 Scripts", value=stats.decomp.."/"..stats.scripts,       inline=true},
                {name="🔗 DOWNLOAD",
                 value="[**>>> CLICK TO DOWNLOAD <<<**]("..dlUrl..")\n[View Page]("..(viewUrl or dlUrl)..")",
                 inline=false},
                {name="💡 Import to Studio",
                 value="1. Click download\n2. Open Roblox Studio\n3. File → Open from File\n4. Select .rbxl\n5. Done!",
                 inline=false},
            },
            footer={text="Nyemek Hub | Full Map Exporter v5.0"},
        }}
    }
    pcall(httpRequest,{
        Url=config.webhookUrl,Method="POST",
        Headers={["Content-Type"]="application/json"},
        Body=HttpService:JSONEncode(embed)
    })
end

-- ═══════════════════════════════════════════════
-- MAIN EXPORT
-- ═══════════════════════════════════════════════
local function ExportMap()
    if not httpRequest then
        Window:Notify("❌ HTTP Not Supported","Your executor doesn't support HTTP!",5)
        return
    end

    print("\n"..("="):rep(70))
    print("  NYEMEK HUB v5.0 — FULL MAP EXPORT (RBXL)")
    print(("="):rep(70))

    refCounter=0; refMap={}
    stats={objects=0,parts=0,models=0,scripts=0,decomp=0}

    Window:Notify("⏳ Starting","Building map XML...",2)

    local xml = {
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime"'
            ..' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
            ..' xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">',
        "<External>null</External>",
        "<External>nil</External>",
    }

    local services = {
        {name="Workspace",         key="includeWorkspace",          svc="Workspace"},
        {name="Lighting",          key="includeLighting",           svc="Lighting"},
        {name="ReplicatedStorage", key="includeReplicatedStorage",  svc="ReplicatedStorage"},
        {name="ReplicatedFirst",   key="includeReplicatedFirst",    svc="ReplicatedFirst"},
        {name="StarterGui",        key="includeStarterGui",         svc="StarterGui"},
        {name="StarterPack",       key="includeStarterPack",        svc="StarterPack"},
        {name="StarterPlayer",     key="includeStarterPlayer",      svc="StarterPlayer"},
        {name="SoundService",      key="includeSoundService",       svc="SoundService"},
    }

    for _, svc in ipairs(services) do
        if config[svc.key] then
            print("[EXPORT] Processing "..svc.name.."...")
            Window:Notify("📦 Processing", svc.name, 1)
            pcall(function()
                local s = game:GetService(svc.svc)
                for _, child in ipairs(s:GetChildren()) do
                    xml[#xml+1] = GenXML(child)
                end
            end)
        end
    end

    xml[#xml+1] = "</roblox>"
    local fileData = table.concat(xml,"\n")

    print(("="):rep(70))
    print("✅ EXPORT DONE!")
    print(("Objects: %d | Parts: %d | Models: %d | Scripts: %d/%d"):format(
        stats.objects, stats.parts, stats.models, stats.decomp, stats.scripts))
    print(("File Size: %.2f MB"):format(#fileData/1024/1024))
    print(("="):rep(70))

    local gameName = "RobloxMap"
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        if info and info.Name then
            gameName = info.Name:gsub("[^%w%s%-]",""):gsub("%s+","_")
        end
    end)

    local fileName = gameName.."_"..os.date("%Y%m%d_%H%M%S")..".rbxl"

    -- Local backup
    pcall(function()
        if writefile then
            writefile(fileName, fileData)
            print("[LOCAL] ✅ Saved: "..fileName)
        end
    end)

    -- Upload
    Window:Notify("📤 Uploading...","Trying all services...",3)
    local dlUrl, viewUrl, service = UploadAll(fileName, fileData)

    print(("="):rep(70))

    if dlUrl then
        print("✅ UPLOAD SUCCESS via "..service)
        print("🔗 DOWNLOAD:\n"..dlUrl)
        print(("="):rep(70).."\n")

        if setclipboard then
            setclipboard(dlUrl)
            print("✅ Link copied!")
        end

        SendDiscord(fileName, dlUrl, viewUrl, #fileData)

        Window:Notify(
            "✅ Success! Via "..service,
            ("📁 %s\n💾 %.1f MB | %d obj | %d scripts\n\n🔗 Link copied!\nPaste in browser → Click Download!"):format(
                fileName, #fileData/1024/1024, stats.objects, stats.decomp),
            15
        )
    else
        print("❌ ALL UPLOADS FAILED")
        print("File saved locally: "..fileName)
        print(("="):rep(70).."\n")
        Window:Notify(
            "❌ Upload Failed",
            "All 4 services failed!\nFile saved locally:\n"..fileName,
            10
        )
    end
end

-- ═══════════════════════════════════════════════
-- EXPORT TAB UI
-- ═══════════════════════════════════════════════
ExportTab:CreateButton({
    Name = "🚀 EXPORT FULL MAP & UPLOAD",
    Callback = function() pcall(ExportMap) end
})

ExportTab:CreateSection("📤 Upload Methods (Auto Fallback)")
ExportTab:CreateLabel("1️⃣  Pixeldrain  — Direct download (MediaFire style)")
ExportTab:CreateLabel("2️⃣  file.io     — Fast & reliable")
ExportTab:CreateLabel("3️⃣  Litterbox   — 72 hour storage")
ExportTab:CreateLabel("4️⃣  GoFile      — 1 year storage")

ExportTab:CreateSection("📦 Services Exported")
ExportTab:CreateLabel("Workspace • Lighting • ReplicatedStorage")
ExportTab:CreateLabel("ReplicatedFirst • StarterGui • StarterPack")
ExportTab:CreateLabel("StarterPlayer • SoundService")

-- ═══════════════════════════════════════════════
-- INFO TAB UI
-- ═══════════════════════════════════════════════
InfoTab:CreateSection("📥 How to Download")
InfoTab:CreateLabel("1. Wait for upload to complete")
InfoTab:CreateLabel("2. Link is auto-copied to clipboard")
InfoTab:CreateLabel("3. Paste in Chrome / Firefox / Edge")
InfoTab:CreateLabel("4. Click the DOWNLOAD button on the page")
InfoTab:CreateLabel("5. Save the .rbxl file to your computer")

InfoTab:CreateSection("🎮 Import to Roblox Studio")
InfoTab:CreateLabel("1. Open Roblox Studio")
InfoTab:CreateLabel("2. File → Open from File")
InfoTab:CreateLabel("3. Navigate to Downloads folder")
InfoTab:CreateLabel("4. Select the .rbxl file")
InfoTab:CreateLabel("5. Map will fully load with all content!")

InfoTab:CreateSection("🔍 System Status")
InfoTab:CreateLabel("HTTP:      "..(httpRequest  and "✅ Supported" or "❌ Not Supported"))
InfoTab:CreateLabel("writefile: "..(writefile    and "✅ Supported" or "❌ Not Supported"))
InfoTab:CreateLabel("clipboard: "..(setclipboard and "✅ Supported" or "❌ Not Supported"))
InfoTab:CreateLabel("decompile: "..(decompile    and "✅ Available"  or "⚠️  Limited"))

-- ═══════════════════════════════════════════════
-- READY
-- ═══════════════════════════════════════════════
Window:Notify("✅ Nyemek Hub v5.0 Loaded!", "Flux UI | Full RBXL Exporter ready!", 5)

print("✅ Nyemek Hub v5.0 loaded! (Flux UI + RBXL)")
print("💡 Click 'EXPORT FULL MAP & UPLOAD' to start")
print("📤 4 upload services with auto-fallback")
print("💾 Saves as .rbxl — open directly with Roblox Studio!")
