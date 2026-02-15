-- [[ NYEMEK HUB - MOBILE MAP ARCHIVER 2026 ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Mobile Archiver",
   LoadingTitle = "Memuat Scanner Map...",
   LoadingSubtitle = "by Regal-NY",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Main Menu", 4483362458)

local webhookUrl = "" -- Variabel untuk menyimpan link webhook

Tab:CreateInput({
   Name = "Input Webhook Discord",
   PlaceholderText = "Tempel Link Webhook Disini",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       webhookUrl = Text
   end,
})

Tab:CreateButton({
   Name = "Copy Map & Kirim ke Discord",
   Callback = function()
       if webhookUrl == "" or not string.find(webhookUrl, "discord.com/api/webhooks") then
           Rayfield:Notify({
               Title = "Error!",
               Content = "Masukkan Link Webhook Discord yang valid dulu!",
               Duration = 5
           })
           return
       end

       Rayfield:Notify({
          Title = "Proses Dimulai",
          Content = "Sedang memindai Workspace... Harap tunggu.",
          Duration = 5
       })

       -- Proses Scanning Map
       local mapData = "--- NYEMEK HUB EXPORT DATA ---\n"
       local count = 0
       for _, obj in pairs(game.Workspace:GetChildren()) do
           if obj:IsA("BasePart") or obj:IsA("Model") then
               count = count + 1
               mapData = mapData .. "[" .. count .. "] " .. obj.Name .. " (" .. obj.ClassName .. ")\n"
           end
       end

       -- Mengirim data ke Webhook
       local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
       if request then
           request({
               Url = webhookUrl,
               Method = "POST",
               Headers = {["Content-Type"] = "application/json"},
               Body = game:GetService("HttpService"):JSONEncode({
                   content = "✅ **Map Berhasil Dicopy!**",
                   embeds = {{
                       title = "Hasil Scan Workspace",
                       description = "Ditemukan **" .. count .. "** objek.\n\nData objek sudah muncul di Console/Log Executor kamu.",
                       color = 65280
                   }}
               })
           })
           
           print(mapData) 
           Rayfield:Notify({
               Title = "Berhasil!",
               Content = "Cek Discord dan Console/Log Executor kamu!",
               Duration = 10
           })
       else
           Rayfield:Notify({
               Title = "Error!",
               Content = "Executor kamu tidak mendukung HTTP Request.",
               Duration = 5
           })
       end
   end,
})

Tab:CreateLabel("Gunakan Webhook agar tidak perlu buka ZArchiver")

Rayfield:Notify({
   Title = "Nyemek Hub Ready",
   Content = "Silakan masukkan webhook dan mulai menyalin!",
   Duration = 5
})
