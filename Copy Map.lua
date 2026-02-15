local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nyemek Hub | Map Archiver",
   LoadingTitle = "Initializing Mobile Scanner...",
   LoadingSubtitle = "by Regal_NY",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Main Menu", 4483362458)

Tab:CreateButton({
   Name = "Execute Copy Map (Safe Mode)",
   Callback = function()
       -- Inisialisasi folder utama di Workspace
       local saveFolder = Instance.new("Folder")
       saveFolder.Name = "Archived_Map_" .. os.date("%H_%M_%S")
       saveFolder.Parent = game.Workspace

       local targets = {
           {game.Workspace, "Workspace_Building"},
           {game.ReplicatedStorage, "Replicated_Assets"},
           {game.StarterGui, "UI_Design"},
           {game.Lighting, "Environment_Lighting"},
           {game.StarterPack, "Tools_And_Items"}
       }

       Rayfield:Notify({
          Title = "Proses Dimulai",
          Content = "Menyalin aset... Mohon tunggu agar tidak crash.",
          Duration = 5
       })

       for _, data in pairs(targets) do
           local service = data[1]
           local folderName = data[2]
           
           local subFolder = Instance.new("Folder")
           subFolder.Name = folderName
           subFolder.Parent = saveFolder

           local children = service:GetChildren()
           for i, obj in pairs(children) do
               -- Menghindari folder penyimpan agar tidak terjadi duplikasi tak terbatas
               if obj.Name ~= saveFolder.Name then
                   pcall(function()
                       local clone = obj:Clone()
                       if clone then
                           clone.Parent = subFolder
                       end
                   end)
               end
               
               -- Anti-Lag untuk HP: Jeda setiap 15 objek
               if i % 15 == 0 then
                   task.wait(0.01)
               end
           end
       end

       Rayfield:Notify({
          Title = "Selesai!",
          Content = "Cek folder '" .. saveFolder.Name .. "' di Workspace menggunakan DEX.",
          Duration = 10
       })
   end,
})

Tab:CreateLabel("Penting: Gunakan DEX Explorer untuk melihat hasil copy di HP.")
