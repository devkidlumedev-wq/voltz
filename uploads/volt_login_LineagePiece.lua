-- กำหนดรายการไอดีแมพที่อนุญาต
repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(o) return o end
local Workspace = cloneref(game:GetService("Workspace"))
local Players = cloneref(game:GetService("Players"))
local PlayerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
local HttpService = cloneref(game:GetService("HttpService"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))

-- ===================== CONFIGURATION =====================
-- [[ ใส่ Service ID ของ PandaAuth ตรงนี้ ]]
local PandaServiceID = "VoltDevkid" 
-- [[ 🟢 ใส่ DISCORD WEBHOOK URL ของคุณตรงนี้ ]]
local DiscordWebhookURL = "https://discord.com/api/webhooks/1518219058254839908/b7ahv_laXDOspK5Q5EHmd25dpsZH9GLTy6hUENzB_VFFQ4KeZLSd5t6XhxInS4iHp1AU"

-- ตัวแปร Request สำหรับใช้ทั่วทั้งสคริปต์
local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request

-- ===================== DISCORD LOGGING SYSTEM =====================
local function SendDiscordLog(key)
    if DiscordWebhookURL == "" or DiscordWebhookURL:find("YOUR_WEBHOOK_HERE") then return end
    
    task.spawn(function()
        if not httpRequest then return end

        -- 1. Get HWID (จำลองการดึง HWID แบบเดียวกับ Panda)
        local hwid = "Unknown"
        if gethwid then 
            pcall(function() hwid = gethwid() end) 
        end
        if not hwid or hwid == "Unknown" then
            local exec = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "unknown"
            hwid = "P_" .. tostring(Players.LocalPlayer.UserId) .. "_" .. exec
        end

        -- 2. Get IP Address
        local ip = "Unknown"
        pcall(function()
            ip = game:HttpGet("https://api.ipify.org")
        end)

        -- 3. Construct Payload
        local embedData = {
            ["username"] = "Volt Hub Logger",
            ["avatar_url"] = "https://i.imgur.com/AsX6V96.png",
            ["embeds"] = {{
                ["title"] = "🔐 Access Granted: Volt Hub",
                ["color"] = 3447003, -- สีฟ้า (Blue)
                ["fields"] = {
                    {
                        ["name"] = "👤 User Profile",
                        ["value"] = string.format("Name: `%s`\nDisplay: `%s`\nID: `%d`", Players.LocalPlayer.Name, Players.LocalPlayer.DisplayName, Players.LocalPlayer.UserId),
                        ["inline"] = false
                    },
                    {
                        ["name"] = "🌐 Network Info",
                        ["value"] = string.format("IP: ||%s||", ip),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "🔑 Key Used",
                        ["value"] = string.format("||`%s`||", key),
                        ["inline"] = false
                    },
                    {
                        ["name"] = "💻 Hardware ID (HWID)",
                        ["value"] = string.format("```%s```", hwid),
                        ["inline"] = false
                    }
                },
                ["footer"] = {
                    ["text"] = "Volt Hub Auth System • " .. os.date("%Y-%m-%d %H:%M:%S")
                }
            }}
        }

        -- 4. Send Request
        httpRequest({
            Url = DiscordWebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(embedData)
        })
    end)
end

-- ===================== UI LIBRARY HELPERS =====================
local UI = {}
function UI:Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

function UI:AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

function UI:AddStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

function UI:AddGradient(instance, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 0
    gradient.Parent = instance
    return gradient
end

function UI:AddShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
    return shadow
end

-- ===================== NEW PANDA AUTH API (V1 Latest) =====================
local PandaAuth = {}
do
    local BaseURL = "https://new.pandadevelopment.net/api/v1"
    
    -- Get Hardware ID (Updated Logic)
    function PandaAuth.getHardwareId()
        local success, hwid = pcall(function() 
            return gethwid and gethwid() 
        end)
        
        if success and hwid then
            return hwid
        end
    
        -- Fallback to analytics client ID
        local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
        local clientId = tostring(RbxAnalyticsService:GetClientId())
        return clientId:gsub("-", "")
    end
    
    -- HTTP Request wrapper (Uses local httpRequest)
    local function makeRequest(endpoint, body)
        if not httpRequest then return nil end
        
        local url = BaseURL .. endpoint
        local jsonBody = HttpService:JSONEncode(body)
    
        local response = httpRequest({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonBody
        })
    
        if response and response.Body then
            local s, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
            if s then return data end
        end
    
        return nil
    end

    function PandaAuth.GetKeyURL()
        local hwid = PandaAuth.getHardwareId()
        return "https://new.pandadevelopment.net/getkey/" .. PandaServiceID .. "?hwid=" .. hwid
    end

    function PandaAuth.Validate(key)
        local hwid = PandaAuth.getHardwareId()
    
        local result = makeRequest("/keys/validate", {
            ServiceID = PandaServiceID,
            HWID = hwid,
            Key = key
        })
    
        if not result then
            return {
                success = false,
                message = "Failed to connect to server",
                isPremium = false,
                expireDate = nil
            }
        end
    
        local isAuthenticated = result.Authenticated_Status == "Success"
        local isPremium = result.Key_Premium or false
        local message = result.Note or (isAuthenticated and "Key validated!" or "Invalid key")
    
        return {
            success = isAuthenticated,
            message = message,
            isPremium = isPremium,
            expireDate = result.Expire_Date
        }
    end
end

-- ===================== FILE SYSTEM HELPER =====================
local function SaveKeyToFile(path, content)
    pcall(function()
        local folders = path:split("/")
        if #folders > 1 then
            local currentPath = ""
            for i = 1, #folders - 1 do
                currentPath = currentPath .. folders[i] .. "/"
                if not isfolder(currentPath) then
                    makefolder(currentPath)
                end
            end
        end
        writefile(path, content)
    end)
end

-- ===================== MAIN UI LOGIC =====================
if CoreGui:FindFirstChild("VoltHub_KeySystem") then
    CoreGui.VoltHub_KeySystem:Destroy()
end

function CreateKeySystem()
    local Task = {}
    local coppy = setclipboard or toclipboard or function(t) print("Clipboard:", t) end

    local ScreenGui = UI:Create("ScreenGui", {
        Name = "VoltHub_KeySystem",
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (gethui and gethui()) or CoreGui
    })

    local function NotifyCustom(title, content)
        local NotifFrame = UI:Create("Frame", {
            Parent = ScreenGui,
            Size = UDim2.fromOffset(280, 80),
            Position = UDim2.new(1, -300, 0, 50),
            BackgroundColor3 = Color3.fromRGB(18, 18, 20),
            BorderSizePixel = 0,
        })
        UI:AddCorner(NotifFrame, 8)
        UI:AddStroke(NotifFrame, Color3.fromRGB(52, 152, 219), 1) -- เปลี่ยนเป็นขอบสีฟ้าเมื่อแจ้งเตือน
        UI:AddShadow(NotifFrame)
        
        local t = UI:Create("TextLabel", {
            Parent = NotifFrame,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 5),
            Text = title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local d = UI:Create("TextLabel", {
            Parent = NotifFrame,
            Size = UDim2.new(1, -20, 0, 40),
            Position = UDim2.new(0, 10, 0, 30),
            Text = content,
            TextColor3 = Color3.fromRGB(180, 180, 180),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            BackgroundTransparency = 1,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        task.delay(3, function() NotifFrame:Destroy() end)
    end

    local function DraggFunction(Frame)
        local dragToggle, dragInput, dragStart, startPos
        Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragToggle = true; dragStart = input.Position; startPos = Frame.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local function VerifyKey(key, file_directory)
        local cleaned_key = tostring(key):gsub("%s", "")
        
        -- [[ ใช้ API ใหม่ในการตรวจสอบ ]]
        local result = PandaAuth.Validate(cleaned_key)
        
        if result.success then
            -- [[ 🟢 LOGGING TRIGGER ]] --
            SendDiscordLog(cleaned_key)
            SaveKeyToFile(file_directory, cleaned_key)
            
            NotifyCustom("Success", "Access Granted!")
            task.wait(1)
            
            if ScreenGui then ScreenGui:Destroy() end
            
            -- ปิดฟังก์ชัน VerifyKey ให้เรียบร้อยก่อนเริ่มรันสคริปต์หลัก
            task.spawn(function()
                print("KEY SUCCESS! Loading Volt Hub...")
                -- ====================================================
                -- 🟢 วางสคริปต์หลัก (Main Hub) ทั้งหมดต่อจากบรรทัดนี้ได้เลย
                -- ====================================================
             -- ป้องกันการค้าง ปรับเปลี่ยนวิธีรอเกมโหลดให้ปลอดภัยขึ้น
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera

-- ป้องกันสคริปต์ค้างด้วย Timeout 5 วินาที
local Packages = ReplicatedStorage:WaitForChild("Packages", 5)
local NetFolder = Packages and Packages:WaitForChild("_Index", 5)
    and Packages._Index:WaitForChild("sleitnick_net@0.2.0", 5)
    and Packages._Index["sleitnick_net@0.2.0"]:WaitForChild("net", 5)

-- Remotes ของเกม Lineage Piece
local QuestRemote = NetFolder and NetFolder:WaitForChild("RE/QuestEvent", 5)
local ActionRemote = NetFolder and NetFolder:WaitForChild("RE/ActionRemote", 5)
local SkillRemote = NetFolder and NetFolder:WaitForChild("RE/SkillRemote", 5)
local StatsRemote = NetFolder and NetFolder:WaitForChild("RE/StatsAllocateEvent", 5)
local SummonRemote = NetFolder and NetFolder:WaitForChild("RE/SummonEvent", 5)
local TraitsRemote = NetFolder and NetFolder:WaitForChild("RE/TraitsEvent", 5)
local PortalRemote = NetFolder and NetFolder:WaitForChild("RE/PortalEvent", 5)
local RaceRemote = NetFolder and NetFolder:WaitForChild("RE/RaceRemote", 5)
local ArtifactRemote = NetFolder and NetFolder:WaitForChild("RE/ArtifactRemote", 5)
local ChangedSettingEvent = NetFolder and NetFolder:WaitForChild("RE/ChangedSettingEvent", 5)
local MaterialEvent = NetFolder and NetFolder:WaitForChild("RE/MaterialEvent", 5)
local SlimeRERemote = NetFolder and NetFolder:WaitForChild("RE/SlimeRE", 5)

task.spawn(function()
    local PlayerGui = Player:WaitForChild("PlayerGui", 5)
    if not PlayerGui then return end

    local ToggleGui = PlayerGui:FindFirstChild("LCtrlCircleButtonUI")
    if not ToggleGui then
        ToggleGui = Instance.new("ScreenGui")
        ToggleGui.Name = "LCtrlCircleButtonUI"
        ToggleGui.ResetOnSpawn = false
        ToggleGui.Parent = PlayerGui
    end

    local imageUrl = "https://img1.pic.in.th/images/logo62de603c9fdc4aad.th.png"
    local imageName = "volt.png"
    local customImageId = ""

    if isfile and writefile and getcustomasset then
        if not isfile(imageName) then
            local success, result = pcall(function() return game:HttpGet(imageUrl) end)
            if success then writefile(imageName, result) end
        end
        if isfile(imageName) then customImageId = getcustomasset(imageName) end
    end

    local Button = ToggleGui:FindFirstChild("ToggleButton")
    if not Button then
        Button = Instance.new("ImageButton")
        Button.Name = "ToggleButton"
        Button.Size = UDim2.new(0, 60, 0, 60)
        Button.AnchorPoint = Vector2.new(0.5, 0.5)
        Button.Position = UDim2.new(0.3, 0, 0.2, 0)
        Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Button.BackgroundTransparency = 0.5
        Button.BorderSizePixel = 0
        Button.ZIndex = 10
        Button.Active = true
        Button.Draggable = true

        if customImageId ~= "" then Button.Image = customImageId end
        Button.Parent = ToggleGui

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = Button

        Button.MouseButton1Click:Connect(function()
            if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
                if Window then Window:Minimize() end
            else
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
            end
        end)
    end
end)

-- [[ Data Structures ]] --
local WeaponGroups = {
    ["Combat"] = { "Combat", "Verdant Hero", "Gojo", "Sukuna", "Rimuru", "Aizen", "Gilgamesh", "Gojo Shinjuku", "Sukuna Shinjuku" },
    ["Sword"]  = { "Katana", "Yoru", "Gryphon", "Excalibur", "Zangetsu", "Dual Katana", "Player's Dagger", "Shadow", "Stylish Bandit Slayer", "Tensa Zangetsu", "Raiden", "Shadow's Dagger", "Miyabi", "Kokushibo" },
    ["Power"]  = { "Bomb", "Flame", "Quake", "Light" }
}

local MobData = {
    { Name = "Bandit (Lv. 1)",                   QuestId = 1,  MobName = "Bandit",                Level = 1 },
    { Name = "Bandit Leader (Lv. 50)",           QuestId = 2,  MobName = "Bandit Leader",         Level = 50 },
    { Name = "Monkey (Lv. 250)",                 QuestId = 3,  MobName = "Monkey",                Level = 250 },
    { Name = "Shank (Lv. 400)",                  QuestId = 4,  MobName = "Shank",                 Level = 400 },
    { Name = "Snow Bandit (Lv. 600)",            QuestId = 8,  MobName = "Snow Bandit",           Level = 600 },
    { Name = "National Level Hunter (Lv. 1000)", QuestId = 9,  MobName = "National Level Hunter", Level = 1000 },
    { Name = "Sorcerer Student (Lv. 1300)",      QuestId = 5,  MobName = "Sorcerer Student",      Level = 1300 },
    { Name = "Miwa (Lv. 1600)",                  QuestId = 6,  MobName = "Miwa",                  Level = 1600 },
    { Name = "Hollow (Lv. 2000)",                QuestId = 10, MobName = "Hollow",                Level = 2000 },
    { Name = "Arrancar (Lv. 3000)",              QuestId = 11, MobName = "Arrancar",              Level = 3000 },
    { Name = "Ichigo (Lv. 4000)",                QuestId = 12, MobName = "Ichigo ( Bankai )",     Level = 4000 },
    { Name = "Mahito (Lv. 4000)",                QuestId = 13, MobName = "Mahito",                Level = 4000 },
}

local WorldBossList = { "Sung Jinwoo", "Rimuru" }
local BossList = { "Saber", "Verdant Hero", "Gojo", "Sukuna", "Kokushibo", "Gilgamesh", "Aizen", "Gojo Shinjuku", "Sukuna Shinjuku" }

local AllBossesList = {}
for _, b in ipairs(BossList) do table.insert(AllBossesList, b) end
for _, b in ipairs(WorldBossList) do table.insert(AllBossesList, b) end

local DungeonMap = {
    ["Sovereign Trial"]   = "ARTIFACT_01",
    ["Abyss Trial"]       = "ARTIFACT_02",
    ["Jura Forest Trial"] = "ARTIFACT_03",
    ["Shrine Trial"]      = "RAIDEN",
    ["Cartenon Trial"]    = "SUNG",
    ["Cid's Castle"]      = "SHADOW",
    ["Absolute Dead End"] = "MIYABI"
}

local ArtifactSetList = { "Pure Lineage", "Abyssal Striker", "Mythical Awakening", "Azure Edge", "Titan Executioner", "Supreme Mastery" }

local TeleportNPCs = {
    ["Artifact NPC"]      = "Artifact.ArtifactNPC",
    ["Bag NPC"]           = "Bags.BagNPC",
    ["Book Exchange"]     = "Exchange.BookExchangeNPC",
    ["Boss Exchange"]     = "Exchange.BossExchangeNPC",
    ["Portal Key Seller"] = "Exchange.PortalKeySellerNPC",
    ["Slime Exchange"]    = "Exchange.SlimeExchangeNPC",
    ["Slime Summon"]      = "FossilSummon.SlimeSummonNPC",
    ["Random Fruit Gem"]  = "Fruit.RandomFruitGemNPC",
    ["Random Fruit"]      = "Fruit.RandomFruitNPC",
    ["Group Reward"]      = "GroupReward.GroupRewordNPC",
    ["Curse Orb Quest"]   = "Questline.CurseOrbQuest",
    ["Gojo Quest"]        = "Questline.GojoQuestNPC",
    ["Rimuru Mastery"]    = "Questline.RimuruMastery",
    ["Saber Quest"]       = "Questline.SaberQuestNPC",
    ["Sukuna Quest"]      = "Questline.SukunaQuestNPC",
    ["Sung Quest"]        = "Questline.SungQuestNPC",
    ["Race NPC"]          = "RaceNPC.RaceNPC",
    ["Rank NPC"]          = "Rank.RankNPC",
    ["Dark Blade Seller"] = "Seller.DarkBladeNPC",
    ["Deku Seller"]       = "Seller.DekuNPC",
    ["Dual Katana Seller"] = "Seller.DualKatanaSellNPC",
    ["Gojo Seller"]       = "Seller.GojoNPC",
    ["Gryphon Seller"]    = "Seller.GryphonSeller",
    ["Hakibuso Seller"]   = "Seller.HakibusoNPC",
    ["Katana Seller"]     = "Seller.KatanaSellNPC",
    ["Rimuru Seller"]     = "Seller.RimuruSeller",
    ["Saber Seller"]      = "Seller.SaberNPC",
    ["Sukuna Seller"]     = "Seller.SukunaNPC",
    ["Sung Seller"]       = "Seller.SungNPC",
    ["Zangetsu Seller"]   = "Seller.ZangetsuSeller",
    ["Stats Reroll"]      = "StatsPotential.StatsRerollNPC",
    ["Boss Summon NPC"]   = "Summon.BossSummonNPC",
    ["Summon JJK NPC"]    = "Summon.SummonJJKNPC",
    ["Title NPC"]         = "Title.TitleNPC",
    ["Trait NPC"]         = "Trait.TraitNPC",
    ["Aizen Summon NPC"]  = "AizenSummon.AizenSummonNPC"
}

local TeleportIslands = {
    ["Hueco Island"]    = "SetSpawn.SetSpawn10",
    ["Jungle Island"]   = "SetSpawn.SetSpawn2",
    ["Fire Island"]     = "Teleporter.TeleporterFireCity",
    ["Forest Island"]   = "Teleporter.TeleporterForest",
    ["Fossil Island"]   = "Teleporter.TeleporterFossil",
    ["Monument Island"] = "Teleporter.TeleporterHigh",
    ["Jujutsu Island"]  = "Teleporter.TeleporterJujutsuHigh",
    ["Snow Island"]     = "Teleporter.TeleporterSnow",
    ["Boss Island"]     = "Teleporter.TeleporterSummon"
}

-- State Variables
local SelectedMobData = nil
local AutoFarmToggle = false
local SelectedWorldBoss = "Sung Jinwoo"
local AutoKillWorldBossToggle = false
local SelectedBoss = "Saber"
local SelectedBossDifficulty = "Easy"
local AutoSummonToggle = false
local AutoKillBossToggle = false
local SelectedPityFarmBoss = AllBossesList[1]
local SelectedPityGuaranteeBoss = AllBossesList[1]
local AutoPityToggle = false
local ForceBossFarm = false
local ForceAizenHollowFarm = false
local IsGoingToSummonAizen = false

local SelectedWeaponGroup = "Combat"
local AutoEquipToggle = false
local AutoSkillToggle = false
local SelectedSkills = {}
local SelectedStat = "Strength"
local StatAmount = 1
local AutoStatsToggle = false
local SelectedTraitLock = "The Honored One"
local AutoTraitToggle = false
local SelectedRaceLock = "Player"
local AutoRaceToggle = false

local SelectedDungeon = "Sovereign Trial"
local SelectedDifficulty = "Easy"
local FriendOnlyToggle = false
local AutoCreateDungeonToggle = false
local AutoStartDungeonToggle = false
local AutoKillDungeonToggle = false
local SelectedArtifactSet = "Pure Lineage"
local AutoEquipArtifactSetToggle = false

local AntiAfkConnection = nil
local SelectedTeleportNPC = nil
local SelectedTeleportIsland = nil
local ESPEnabled = false
local InfJumpEnabled = false
local SpeedHackEnabled = false
local ESPBoxes = {}
local ESPTexts = {}

local NpcDropdownList = {}
for name, _ in pairs(TeleportNPCs) do table.insert(NpcDropdownList, name) end
table.sort(NpcDropdownList)

local IslandDropdownList = {}
for name, _ in pairs(TeleportIslands) do table.insert(IslandDropdownList, name) end
table.sort(IslandDropdownList)

-- ใช้ pcall ตรวจสอบการโหลด UI Library ป้องกันสคริปต์หยุดทำงานแบบไม่ทราบสาเหตุ
local FluentSuccess, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not FluentSuccess or not Fluent then
    warn("LumeHub Error: ไม่สามารถโหลด Fluent UI Library ได้ (ลิงก์อาจจะเสีย หรือเน็ตโหลดไม่ทัน)")
    return
end

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Lineage Piece v.1",
    SubTitle = "by.volt",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "sword" }),
    Pity = Window:AddTab({ Title = "Pity", Icon = "star" }),
    Artifact = Window:AddTab({ Title = "Artifact", Icon = "gem" }),
    Dungeon = Window:AddTab({ Title = "Dungeon", Icon = "swords" }),
    Reroll = Window:AddTab({ Title = "Reroll", Icon = "dices" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "bar-chart" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local MobList = {}
for _, data in ipairs(MobData) do table.insert(MobList, data.Name) end

-- ========================================== --
-- [[ ฟังก์ชันช่วยเหลือต่างๆ ]]
-- ========================================== --
local function TeleportToTarget(pathString)
    local parts = string.split(pathString, ".")
    local current = workspace:FindFirstChild("NPC")
    if not current then current = workspace end

    for _, part in ipairs(parts) do
        current = current:FindFirstChild(part)
        if not current then return end
    end

    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = current:GetPivot() * CFrame.new(0, 3, 3)
    end
end

local function GetCurrentPity(bossName)
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return 0 end
    local screenGui = gui:FindFirstChild("ScreenGui")
    local bossUI = screenGui and screenGui:FindFirstChild("Boss")
    if not bossUI then return 0 end

    local targetNameLower = string.gsub(string.lower(bossName), "%s+", "")
    for _, frame in pairs(bossUI:GetChildren()) do
        local frameNameLower = string.gsub(string.lower(frame.Name), "%s+", "")
        if string.find(frameNameLower, targetNameLower) then
            local pityLabel = frame:FindFirstChild("BossPity")
            if pityLabel and pityLabel:IsA("TextLabel") then
                local currentStr = string.match(pityLabel.Text, "(%d+)")
                if currentStr then return tonumber(currentStr) end
            end
        end
    end
    return 0
end

local function GetCursedOrbCount()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return 0 end
    local itemLabel = gui:FindFirstChild("ScreenGui")
        and gui.ScreenGui:FindFirstChild("HUD")
        and gui.ScreenGui.HUD:FindFirstChild("StorageFrame")
        and gui.ScreenGui:FindFirstChild("Main")
        and gui.ScreenGui.HUD.StorageFrame.Main:FindFirstChild("MaterialFrame")
        and gui.ScreenGui.HUD.StorageFrame.Main.MaterialFrame:FindFirstChild("Cursed Orb")
        and gui.ScreenGui.HUD.StorageFrame.Main.MaterialFrame["Cursed Orb"]:FindFirstChild("Default")
        and gui.ScreenGui.HUD.StorageFrame.Main.MaterialFrame["Cursed Orb"].Default:FindFirstChild("ItemCount")

    if itemLabel and itemLabel:IsA("TextLabel") then
        local num = string.match(itemLabel.Text, "(%d+)")
        return tonumber(num) or 0
    end
    return 0
end

local function GetAizenHollowCount()
    pcall(function()
        local npc = workspace.NPC:FindFirstChild("AizenSummon") and
        workspace.NPC.AizenSummon:FindFirstChild("AizenSummonNPC")
        local torso = npc and npc:FindFirstChild("Torso")
        local prompt = torso and torso:FindFirstChild("ProximityPrompt")
        if prompt then
            local text = prompt.ActionText
            local current, target = string.match(text, "Killed Hollow (%d+)/(%d+)")
            if current and target then return tonumber(current), tonumber(target) end
        end
    end)
    return 0, 50
end

-- ========================================== --
-- [[ UI Elements : MAIN TAB ]]
-- ========================================== --
local PlayerSettingSection = Tabs.Main:AddSection("Features Setting")
local ToggleESP = Tabs.Main:AddToggle("ESPPlayer", { Title = "ESP Player", Default = false })
ToggleESP:OnChanged(function(Value)
    ESPEnabled = Value
    if not Value then
        for _, box in pairs(ESPBoxes) do box.Visible = false end
        for _, text in pairs(ESPTexts) do text.Visible = false end
    end
end)
local ToggleInfJump = Tabs.Main:AddToggle("InfJump", { Title = "Infinity Jump", Default = false })
ToggleInfJump:OnChanged(function(Value) InfJumpEnabled = Value end)
local ToggleSpeed = Tabs.Main:AddToggle("SpeedHack", { Title = "Speed Hack (160)", Default = false })
ToggleSpeed:OnChanged(function(Value)
    SpeedHackEnabled = Value
    if not Value then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = 16 end
    end
end)

-- ========================================== --
-- [[ UI Elements : AUTO FARM TAB ]]
-- ========================================== --
local WeaponSection = Tabs.AutoFarm:AddSection("Weapon Setting")
local WeaponDropdown = Tabs.AutoFarm:AddDropdown("WeaponSelect",
    { Title = "Select Weapon Group", Values = { "Combat", "Sword", "Power" }, Multi = false, Default = "Combat" })
WeaponDropdown:OnChanged(function(Value) SelectedWeaponGroup = Value end)
local ToggleEquip = Tabs.AutoFarm:AddToggle("AutoEquip", { Title = "Auto Equip Weapon", Default = false })
ToggleEquip:OnChanged(function(Value) AutoEquipToggle = Value end)

local FarmSection = Tabs.AutoFarm:AddSection("Farm Setting")
local Dropdown = Tabs.AutoFarm:AddDropdown("MobSelect",
    { Title = "Select Monster (Sorted)", Values = MobList, Multi = false, Default = nil })
Dropdown:OnChanged(function(Value)
    for _, data in ipairs(MobData) do
        if data.Name == Value then
            if SelectedMobData ~= data then
                pcall(function() if QuestRemote then QuestRemote:FireServer("Cancel") end end); SelectedMobData = data
            end
            break
        end
    end
end)
local ToggleFarm = Tabs.AutoFarm:AddToggle("AutoFarmQuest", { Title = "Auto Farm", Default = false })
ToggleFarm:OnChanged(function(Value)
    AutoFarmToggle = Value; if not Value then pcall(function() if QuestRemote then QuestRemote:FireServer("Cancel") end end) end
end)

local WorldBossSection = Tabs.AutoFarm:AddSection("World Boss Setting")
local WorldBossDropdown = Tabs.AutoFarm:AddDropdown("WorldBossSelect",
    { Title = "Select World Boss", Values = WorldBossList, Multi = false, Default = nil })
WorldBossDropdown:OnChanged(function(Value) SelectedWorldBoss = Value end)
local ToggleWorldBossKill = Tabs.AutoFarm:AddToggle("AutoKillWorldBoss",
    { Title = "Auto Kill World Boss", Default = false })
ToggleWorldBossKill:OnChanged(function(Value) AutoKillWorldBossToggle = Value end)

local BossSection = Tabs.AutoFarm:AddSection("Boss Setting")
local BossDropdown = Tabs.AutoFarm:AddDropdown("BossSelect",
    { Title = "Select Boss", Values = BossList, Multi = false, Default = nil })
BossDropdown:OnChanged(function(Value) SelectedBoss = Value end)

local BossDifficultyDropdown = Tabs.AutoFarm:AddDropdown("BossDifficultySelect",
    { Title = "Select Difficulty", Values = { "Easy", "Medium", "Hard", "Extreme" }, Multi = false, Default = "Easy" })
BossDifficultyDropdown:OnChanged(function(Value) SelectedBossDifficulty = Value end)

local ToggleSummon = Tabs.AutoFarm:AddToggle("AutoSummonBoss", { Title = "Auto Summon Boss", Default = false })
ToggleSummon:OnChanged(function(Value) AutoSummonToggle = Value end)
local ToggleKill = Tabs.AutoFarm:AddToggle("AutoKillBoss", { Title = "Auto Kill Boss", Default = false })
ToggleKill:OnChanged(function(Value) AutoKillBossToggle = Value end)

local SkillSection = Tabs.AutoFarm:AddSection("Skill Setting")
local SkillDropdown = Tabs.AutoFarm:AddDropdown("SkillSelect",
    { Title = "Select Skills to Use", Values = { "Z", "X", "C", "V", "F" }, Multi = true, Default = {} })
SkillDropdown:OnChanged(function(Value) SelectedSkills = Value end)
local ToggleSkill = Tabs.AutoFarm:AddToggle("AutoSkill", { Title = "Auto Use Skills", Default = false })
ToggleSkill:OnChanged(function(Value) AutoSkillToggle = Value end)

-- ========================================== --
-- [[ UI Elements : PITY TAB ]]
-- ========================================== --
local PitySection = Tabs.Pity:AddSection("Pity Setting")
local PityFarmDropdown = Tabs.Pity:AddDropdown("PityFarmSelect",
    { Title = "Select Boss", Values = AllBossesList, Multi = false, Default = nil })
PityFarmDropdown:OnChanged(function(Value) SelectedPityFarmBoss = Value end)
local PityGuaranteeDropdown = Tabs.Pity:AddDropdown("PityGuaranteeSelect",
    { Title = "Select Pity Boss", Values = AllBossesList, Multi = false, Default = nil })
PityGuaranteeDropdown:OnChanged(function(Value) SelectedPityGuaranteeBoss = Value end)
local ToggleAutoPity = Tabs.Pity:AddToggle("AutoPityFarm", { Title = "Auto Farm Pity Boss", Default = false })
ToggleAutoPity:OnChanged(function(Value) AutoPityToggle = Value end)

-- ========================================== --
-- [[ UI Elements : ARTIFACT TAB ]]
-- ========================================== --
local ArtifactSection = Tabs.Artifact:AddSection("Artifact Settings")
Tabs.Artifact:AddButton({
    Title = "Unlock Artifact",
    Description = "กดเพื่อทำการปลดล็อคระบบ Artifact",
    Callback = function()
        if ArtifactRemote then pcall(function() ArtifactRemote:FireServer("Unlock") end) end
    end
})
local ToggleAutoDelRare = Tabs.Artifact:AddToggle("AutoDelRare", { Title = "Auto Delete Rare Artifact", Default = false })
ToggleAutoDelRare:OnChanged(function(Value) if ChangedSettingEvent then pcall(function() ChangedSettingEvent:FireServer(
            "Auto_Delete_Rare_Artifacts", Value) end) end end)
local ToggleAutoDelEpic = Tabs.Artifact:AddToggle("AutoDelEpic", { Title = "Auto Delete Epic Artifact", Default = false })
ToggleAutoDelEpic:OnChanged(function(Value) if ChangedSettingEvent then pcall(function() ChangedSettingEvent:FireServer(
            "Auto_Delete_Epic_Artifacts", Value) end) end end)
local ToggleAutoDelLegendary = Tabs.Artifact:AddToggle("AutoDelLegendary",
    { Title = "Auto Delete Legendary Artifact", Default = false })
ToggleAutoDelLegendary:OnChanged(function(Value) if ChangedSettingEvent then pcall(function() ChangedSettingEvent
                :FireServer("Auto_Delete_Legendary_Artifacts", Value) end) end end)

local ArtifactSetDropdown = Tabs.Artifact:AddDropdown("ArtifactSetSelect",
    { Title = "Select Artifact Set", Values = ArtifactSetList, Multi = false, Default = "Pure Lineage" })
ArtifactSetDropdown:OnChanged(function(Value) SelectedArtifactSet = Value end)
local ToggleAutoEquipArtifact = Tabs.Artifact:AddToggle("AutoEquipArtifactSet",
    { Title = "Auto Equip Selected Set", Default = false })
ToggleAutoEquipArtifact:OnChanged(function(Value) AutoEquipArtifactSetToggle = Value end)

-- ========================================== --
-- [[ UI Elements : DUNGEON TAB ]]
-- ========================================== --
local DungeonSection = Tabs.Dungeon:AddSection("Dungeon Creation")
local DungeonDropdown = Tabs.Dungeon:AddDropdown("SelectDungeon",
    { Title = "Select Dungeon", Values = { "Sovereign Trial", "Abyss Trial", "Jura Forest Trial", "Shrine Trial", "Cartenon Trial", "Cid's Castle", "Absolute Dead End" }, Multi = false, Default = "Sovereign Trial" })
DungeonDropdown:OnChanged(function(Value) SelectedDungeon = Value end)
local DifficultyDropdown = Tabs.Dungeon:AddDropdown("SelectDifficulty",
    { Title = "Select Difficulty", Values = { "Easy", "Medium", "Hard", "Extreme" }, Multi = false, Default = "Easy" })
DifficultyDropdown:OnChanged(function(Value) SelectedDifficulty = Value end)

-- ยุบรวมเป็นอันเดียวตามรูปภาพ image_06f695.png
local ToggleCreateDungeon = Tabs.Dungeon:AddToggle("AutoCreateDungeon",
    { Title = "Auto Create Dungeon (Auto Use Key)", Default = false })
ToggleCreateDungeon:OnChanged(function(Value) AutoCreateDungeonToggle = Value end)

local ToggleDungeonStart = Tabs.Dungeon:AddToggle("AutoStartDungeon",
    { Title = "Auto Start Dungeon + Fast Skip", Default = false })
ToggleDungeonStart:OnChanged(function(Value) AutoStartDungeonToggle = Value end)
local ToggleDungeonKill = Tabs.Dungeon:AddToggle("AutoKillDungeon",
    { Title = "Auto Kill All (Dungeon Mobs)", Default = false })
ToggleDungeonKill:OnChanged(function(Value) AutoKillDungeonToggle = Value end)

-- ========================================== --
-- [[ UI Elements : TELEPORT TAB ]]
-- ========================================== --
local NPCDropdown = Tabs.Teleport:AddDropdown("TeleportNPCSelect",
    { Title = "Select NPC", Values = NpcDropdownList, Multi = false, Default = NpcDropdownList[1] })
NPCDropdown:OnChanged(function(Value) SelectedTeleportNPC = Value end)
Tabs.Teleport:AddButton({ Title = "Teleport to NPC", Callback = function() if SelectedTeleportNPC and TeleportNPCs[SelectedTeleportNPC] then
        TeleportToTarget(TeleportNPCs[SelectedTeleportNPC]) end end })
local IslandDropdown = Tabs.Teleport:AddDropdown("TeleportIslandSelect",
    { Title = "Select Island", Values = IslandDropdownList, Multi = false, Default = IslandDropdownList[1] })
IslandDropdown:OnChanged(function(Value) SelectedTeleportIsland = Value end)
Tabs.Teleport:AddButton({ Title = "Teleport to Island", Callback = function() if SelectedTeleportIsland and TeleportIslands[SelectedTeleportIsland] then
        TeleportToTarget(TeleportIslands[SelectedTeleportIsland]) end end })

-- ========================================== --
-- [[ UI Elements : REROLL TAB ]]
-- ========================================== --
local TraitLockOptions = { "Any Legendary", "Any Mythical", "Any Lineage", "Adaptation Genius", "Paragon Core",
    "World's Betrayer", "Time Breaker", "The Honored One", "Lord of The Mysteries", "The Ruler of Death" }
local TraitDropdown = Tabs.Reroll:AddDropdown("TraitSelect",
    { Title = "Select Trait", Values = TraitLockOptions, Multi = false, Default = "The Honored One" })
TraitDropdown:OnChanged(function(Value) SelectedTraitLock = Value end)
local function GetTraitFilter()
    local filter = {}
    if SelectedTraitLock == "Any Legendary" then
        filter["Legendary"] = true; filter["Mythical"] = true; filter["Lineage"] = true
    elseif SelectedTraitLock == "Any Mythical" then
        filter["Mythical"] = true; filter["Lineage"] = true
    elseif SelectedTraitLock == "Any Lineage" then
        filter["Lineage"] = true
    else
        filter[SelectedTraitLock] = true
    end
    return filter
end
local ToggleTraitReroll = Tabs.Reroll:AddToggle("AutoTraitReroll", { Title = "Auto Reroll Trait", Default = false })
ToggleTraitReroll:OnChanged(function(Value)
    AutoTraitToggle = Value; if TraitsRemote then if Value then pcall(function() TraitsRemote:FireServer(
                "AutoRerollNoConfirm", { ["Filter"] = GetTraitFilter() }) end) else pcall(function() TraitsRemote
                    :FireServer("AutoRerollCancel") end) end end
end)

local RaceDropdown = Tabs.Reroll:AddDropdown("RaceSelect",
    { Title = "Select Race", Values = { "Shinigami", "Slime", "Player" }, Multi = false, Default = "Player" })
RaceDropdown:OnChanged(function(Value) SelectedRaceLock = Value end)
local ToggleRaceReroll = Tabs.Reroll:AddToggle("AutoRaceReroll", { Title = "Auto Reroll Race", Default = false })
ToggleRaceReroll:OnChanged(function(Value)
    AutoRaceToggle = Value; if RaceRemote then if Value then pcall(function() RaceRemote:FireServer(
                "AutoRerollNoConfirm", { ["Filter"] = { [SelectedRaceLock] = true } }) end) else pcall(function()
                RaceRemote:FireServer("AutoRerollCancel") end) end end
end)

-- ========================================== --
-- [[ UI Elements : STATS TAB ]]
-- ========================================== --
local StatDropdown = Tabs.Stats:AddDropdown("StatSelect",
    { Title = "Select Stat", Values = { "Strength", "Defense", "Weapon", "Power" }, Multi = false, Default = "Strength" })
StatDropdown:OnChanged(function(Value) SelectedStat = Value end)
local StatInput = Tabs.Stats:AddInput("StatPointAmount", { Title = "Amount to Add", Default = "1", Numeric = true })
StatInput:OnChanged(function(Value)
    local num = tonumber(Value)
    if num then StatAmount = num end
end)
local ToggleStats = Tabs.Stats:AddToggle("AutoAddStats", { Title = "Auto Add Stats", Default = false })
ToggleStats:OnChanged(function(Value) AutoStatsToggle = Value end)

-- ========================================== --
-- [[ UI Elements : SETTINGS TAB (Misc) ]]
-- ========================================== --
local ToggleAntiAfk = Tabs.Settings:AddToggle("AntiAfk", { Title = "Anti AFK", Default = true })
ToggleAntiAfk:OnChanged(function(Value)
    if Value then
        if not AntiAfkConnection then AntiAfkConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end) end
    else
        if AntiAfkConnection then
            AntiAfkConnection:Disconnect()
            AntiAfkConnection = nil
        end
    end
end)

-- ========================================== --
-- [[ Core Auto Functions ]] --
-- ========================================== --
local function CreateESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 1.5
    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Size = 16
    text.Center = true
    text.Outline = true
    ESPBoxes[player] = box
    ESPBoxes[player] = box
    ESPTexts[player] = text
end

local function RemoveESP(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
    if ESPTexts[player] then
        ESPTexts[player]:Remove()
        ESPTexts[player] = nil
    end
end

for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then CreateESP(player) end end
Players.PlayerAdded:Connect(function(player) if player ~= LocalPlayer then CreateESP(player) end end)
Players.PlayerRemoving:Connect(RemoveESP)

local function GetAnyDungeonEnemy()
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end
    for _, obj in pairs(enemiesFolder:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then 
            return obj 
        end
    end
    return nil
end

local function GetTargetMob(mobName, isBoss)
    if isBoss then
        if mobName == "Aizen" then
            local aizenModel = workspace:FindFirstChild("Boss") and workspace.Boss:FindFirstChild("Aizen") and
            workspace.Boss.Aizen:FindFirstChild("Aizen")
            if aizenModel and aizenModel:FindFirstChild("HumanoidRootPart") and aizenModel:FindFirstChild("Humanoid") and aizenModel.Humanoid.Health > 0 then 
                return aizenModel 
            end
        elseif mobName == "Gojo Shinjuku" or mobName == "Sukuna Shinjuku" then
            local shinjukuSummoner = workspace:FindFirstChild("Boss") and
            workspace.Boss:FindFirstChild("ShinjukuSummoner")
            local shinjukuModel = shinjukuSummoner and shinjukuSummoner:FindFirstChild(mobName)
            if shinjukuModel and shinjukuModel:FindFirstChild("HumanoidRootPart") and shinjukuModel:FindFirstChild("Humanoid") and shinjukuModel.Humanoid.Health > 0 then 
                return shinjukuModel 
            end
        end
        local foldersToSearch = {
            workspace:FindFirstChild("Boss") and workspace.Boss:FindFirstChild("ServerTimeBossSpawner"),
            workspace:FindFirstChild("Boss") and workspace.Boss:FindFirstChild("BossSummoner"),
            workspace:FindFirstChild("Boss") and workspace.Boss:FindFirstChild("JJKBossSummoner"),
            workspace:FindFirstChild("Boss") and workspace.Boss:FindFirstChild("ShinjukuSummoner"),
            workspace:FindFirstChild("Boss")
        }
        for _, folder in ipairs(foldersToSearch) do
            if folder then
                for _, obj in ipairs(folder:GetChildren()) do
                    if obj:IsA("Model") and obj.Name == mobName and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then 
                        return obj 
                    end
                end
            end
        end
        return nil
    else
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        if not enemiesFolder then return nil end
        for _, group in pairs(enemiesFolder:GetChildren()) do
            local mob = group:FindFirstChild(mobName) or (group:IsA("Model") and group.Name == mobName and group)
            if mob and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then 
                return mob 
            end
        end
        return nil
    end
end

local function EquipTargetWeapon()
    if not AutoEquipToggle then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    local targetWeapons = WeaponGroups[SelectedWeaponGroup] or { SelectedWeaponGroup }
    for _, tool in ipairs(char:GetChildren()) do if tool:IsA("Tool") and table.find(targetWeapons, tool.Name) then return end end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, weaponName in ipairs(targetWeapons) do
            local tool = backpack:FindFirstChild(weaponName)
            if tool then
                char.Humanoid:EquipTool(tool)
                task.wait(0.1)
                return
            end
        end
    end
end

local lastSkillTime = 0
local function HitMon(target)
    local char = LocalPlayer.Character
    if not char then return end
    for _, Equip in ipairs(char:GetChildren()) do
        if Equip:IsA("Tool") then
            local selectedweapon = Equip.Name
            pcall(function() if ActionRemote then ActionRemote:FireServer("M1", selectedweapon) end end)
            if AutoSkillToggle and SkillRemote and tick() - lastSkillTime > 1 then
                lastSkillTime = tick()
                for skillKey, enabled in pairs(SelectedSkills) do
                    if enabled then
                        pcall(function()
                            if target and target:FindFirstChild("HumanoidRootPart") then
                                SkillRemote:FireServer(selectedweapon, skillKey, target.HumanoidRootPart.CFrame)
                            else
                                SkillRemote:FireServer(selectedweapon, skillKey)
                            end
                        end)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end

UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
    end
end)

RunService.RenderStepped:Connect(function()
    if SpeedHackEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 160 end
    if ESPEnabled then
        for player, box in pairs(ESPBoxes) do
            local text = ESPTexts[player]
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
                local hrp = player.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    box.Size = Vector2.new(20, 40)
                    box.Position = Vector2.new(pos.X - 10, pos.Y - 20)
                    box.Visible = true
                    text.Text = player.Name
                    text.Position = Vector2.new(pos.X, pos.Y + 25)
                    text.Visible = true
                else
                    box.Visible = false
                    text.Visible = false
                end
            else
                box.Visible = false
                text.Visible = false
            end
        end
    end
end)

-- 3. Auto Farm Loops
task.spawn(function()
    while task.wait(3) do
        -- สร้างดันเจี้ยนอัตโนมัติ
        if AutoCreateDungeonToggle and PortalRemote and SelectedDungeon and SelectedDifficulty then
            if MaterialEvent then
                local currentKey = "Trial's Key"
                if SelectedDungeon == "Shrine Trial" then
                    currentKey = "Shrine Key"
                elseif SelectedDungeon == "Cartenon Trial" then
                    currentKey = "Cartenon Key"
                elseif SelectedDungeon == "Cid's Castle" then
                    currentKey = "Cid's Key"
                elseif SelectedDungeon == "Absolute Dead End" then
                    currentKey = "Absolute Ether Key"
                end
                pcall(function() MaterialEvent:FireServer("Use", { Item = currentKey, Amount = 1 }) end)
                task.wait(0.5)
            end
            pcall(function() PortalRemote:FireServer("Select",
                    { Difficulty = SelectedDifficulty, Portal = DungeonMap[SelectedDungeon], FriendOnly =
                    FriendOnlyToggle }) end)
            task.wait(0.5)
            pcall(function() PortalRemote:FireServer("EarlyStart") end) -- ส่งสัญญาณเริ่มทันทีเมื่อสร้างเสร็จในลูปออโต้
        end

        -- สตาร์ทดันเจี้ยนอัตโนมัติ + ระบบ EarlyStart จากรูปภาพ image_06f02b.png
        if AutoStartDungeonToggle and PortalRemote then
            pcall(function() PortalRemote:FireServer("Start") end)
            task.wait(0.5)
            pcall(function() PortalRemote:FireServer("EarlyStart") end)
        end

        -- ระบบเช็คและเรียกเสก Rimuru อัตโนมัติ (ใช้สไลม์ 3 อัน) โดยจะหยุดเสกหากมี Sung Jinwoo เกิดอยู่
        if AutoKillWorldBossToggle and SelectedWorldBoss == "Rimuru" and SlimeRERemote then
            if not GetTargetMob("Sung Jinwoo", true) and not GetTargetMob("Rimuru", true) then
                task.spawn(function()
                    for i = 1, 3 do
                        pcall(function() SlimeRERemote:FireServer("SummonSlime", { Amount = 1 }) end)
                        task.wait(0.2)
                    end
                end)
            end
        end

        local isCursedBoss = (SelectedBoss == "Gojo" or SelectedBoss == "Sukuna")
        local isAizenBoss = (SelectedBoss == "Aizen")
        local blockNormalSummon = ((AutoFarmToggle and isCursedBoss and not ForceBossFarm) or isAizenBoss)

        if AutoSummonToggle and SelectedBoss and SummonRemote and not AutoPityToggle and not blockNormalSummon then
            if not GetTargetMob(SelectedBoss, true) then
                if SelectedBoss == "Gojo Shinjuku" or SelectedBoss == "Sukuna Shinjuku" then
                    pcall(function()
                        SummonRemote:FireServer("Summon", {
                            Difficult = SelectedBossDifficulty,
                            Boss = SelectedBoss
                        })
                    end)
                else
                    pcall(function() SummonRemote:FireServer("Summon", { Boss = SelectedBoss }) end)
                end
            end
        end

        if AutoSummonToggle and isAizenBoss and not AutoPityToggle then
            local isAizenAlive = GetTargetMob("Aizen", true)
            local currentHollow, targetHollow = GetAizenHollowCount()
            if not isAizenAlive then
                if currentHollow >= targetHollow then
                    ForceAizenHollowFarm = false
                    IsGoingToSummonAizen = true
                else
                    ForceAizenHollowFarm = true
                    IsGoingToSummonAizen = false
                end
            else
                ForceAizenHollowFarm = false
                IsGoingToSummonAizen = false
            end
        else
            ForceAizenHollowFarm = false
            IsGoingToSummonAizen = false
        end

        if AutoPityToggle and SelectedPityFarmBoss and SelectedPityGuaranteeBoss and SummonRemote then
            local currentPity = GetCurrentPity(SelectedPityGuaranteeBoss)
            local targetBossToSummon = (currentPity >= 25) and SelectedPityGuaranteeBoss or SelectedPityFarmBoss
            if not GetTargetMob(targetBossToSummon, true) then
                if targetBossToSummon == "Gojo Shinjuku" or targetBossToSummon == "Sukuna Shinjuku" then
                    pcall(function()
                        SummonRemote:FireServer("Summon", {
                            Difficult = SelectedBossDifficulty,
                            Boss = targetBossToSummon
                        })
                    end)
                else
                    pcall(function() SummonRemote:FireServer("Summon", { Boss = targetBossToSummon }) end)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if AutoFarmToggle and SelectedMobData and QuestRemote then
            local skipQuest = false
            if AutoKillDungeonToggle or AutoPityToggle or ForceBossFarm or ForceAizenHollowFarm or IsGoingToSummonAizen then skipQuest = true end
            
            -- ยกเลิกทำเควสต์เคลียร์มอนหากตรวจพบว่ามีเวิลด์บอสตัวที่เลือกหรือ Sung Jinwoo เกิดอยู่
            if AutoKillWorldBossToggle then
                if GetTargetMob("Sung Jinwoo", true) or (SelectedWorldBoss and GetTargetMob(SelectedWorldBoss, true)) then
                    skipQuest = true
                end
            end
            if SelectedBoss ~= "Gojo" and SelectedBoss ~= "Sukuna" and AutoKillBossToggle and SelectedBoss and GetTargetMob(SelectedBoss, true) then skipQuest = true end
            if skipQuest then continue end

            local isQuestActive = false
            pcall(function()
                local questUI = LocalPlayer.PlayerGui.ScreenGui.Quest.Container.QuestFrame
                if questUI and questUI.Visible then
                    local questText = questUI.Info.ContentText or questUI.Info.Text
                    if questText and string.find(questText, SelectedMobData.MobName) then isQuestActive = true end
                end
            end)
            if not isQuestActive then pcall(function() QuestRemote:FireServer("Request", { Id = SelectedMobData.QuestId }) end) end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        local target = nil
        -- แก้ไขจุดผิดพลาดไวยากรณ์ (ลบคำว่า navigate ลอกลายสายตาออก) เรียบร้อยครับ
        if AutoFarmToggle and (SelectedBoss == "Gojo" or SelectedBoss == "Sukuna") then
            local orbCount = GetCursedOrbCount()
            ForceBossFarm = (orbCount >= 100) or (ForceBossFarm and orbCount > 0)
        else
            ForceBossFarm = false
        end

        if AutoPityToggle and SelectedPityFarmBoss and SelectedPityGuaranteeBoss then
            local currentPity = GetCurrentPity(SelectedPityGuaranteeBoss)
            target = GetTargetMob((currentPity >= 25) and SelectedPityGuaranteeBoss or SelectedPityFarmBoss, true)
        end
        if not target and ForceBossFarm then target = GetTargetMob(SelectedBoss, true) end
        if not target and AutoKillDungeonToggle then target = GetAnyDungeonEnemy() end
        
        -- ตัวเล็งเป้าเวิลด์บอส : ล็อกเป้าหมาย Sung Jinwoo เป็นอันดับแรกสุดเสมอแม้ว่าจะเลือกฟาร์ม Rimuru อยู่ก็ตาม
        if not target and AutoKillWorldBossToggle then
            local sungAlive = GetTargetMob("Sung Jinwoo", true)
            if sungAlive then
                target = sungAlive
            elseif SelectedWorldBoss then
                target = GetTargetMob(SelectedWorldBoss, true)
            end
        end
        
        if not target and AutoKillBossToggle and SelectedBoss and not (AutoFarmToggle and (SelectedBoss == "Gojo" or SelectedBoss == "Sukuna") and not ForceBossFarm) then 
            target = GetTargetMob(SelectedBoss, true) 
        end
        if not target and AutoSummonToggle and SelectedBoss == "Aizen" and ForceAizenHollowFarm then 
            target = GetTargetMob("Hollow", false) 
        end

        if not target and AutoSummonToggle and SelectedBoss == "Aizen" and IsGoingToSummonAizen then
            pcall(function()
                local npc = workspace.NPC:FindFirstChild("AizenSummon") and
                workspace.NPC.AizenSummon:FindFirstChild("AizenSummonNPC")
                local prompt = npc and npc:FindFirstChild("Torso") and npc.Torso:FindFirstChild("ProximityPrompt")
                if npc and prompt and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = npc.Torso.CFrame * CFrame.new(0, 0, 3)
                    task.wait(0.1)
                    fireproximityprompt(prompt)
                end
            end)
        end
        if not target and AutoFarmToggle and SelectedMobData and not ForceAizenHollowFarm and not IsGoingToSummonAizen then 
            target = GetTargetMob(SelectedMobData.MobName, false) 
        end
        if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
            EquipTargetWeapon()
            HitMon(target)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do 
        if AutoStatsToggle and SelectedStat and StatsRemote then 
            pcall(function() StatsRemote:FireServer(SelectedStat, StatAmount) end) 
        end 
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("Voltz_Lineage")
SaveManager:BuildConfigSection(Tabs.Settings)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

task.delay(1, function()
    if Fluent.Options.InterfaceTheme then Fluent.Options.InterfaceTheme:SetValue("Darker") end
    if Fluent.Options.TransparentToggle then Fluent.Options.TransparentToggle:SetValue(false) end
end)

Fluent:Notify({
    Title = "Lineage Piece Script Loaded !",
    Content = "by.voltz",
    Duration = 5
})
            end)

            return true
        else
            NotifyCustom("Error", tostring(result.message))
            return false
        end
    end 

    function Task:Window(config)
        config.DisplayName = config.DisplayName or "Volt Hub"
        config.File = config.File or "VoltHub/savedkey.txt"
        config.Discord = config.Discord or "https://discord.gg/Zk7f9w4DcD"

        -- AUTO LOGIN SYSTEM
        if isfile(config.File) then
            local saved = readfile(config.File)
            if saved and saved ~= "" then
                -- เช็คเงียบๆ ถ้าผ่านก็ล็อคอินเลย
                if VerifyKey(saved, config.File) then return end
            end
        end

        local MainFrame = UI:Create("Frame", {
            Name = "MainFrame",
            Parent = ScreenGui,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(500, 280),
            BackgroundColor3 = Color3.fromRGB(18, 18, 20),
            BorderSizePixel = 0
        })
        UI:AddCorner(MainFrame, 16)
        UI:AddStroke(MainFrame, Color3.fromRGB(45, 45, 50), 1)
        UI:AddShadow(MainFrame)

        -- TOP BAR
        local TopBar = UI:Create("Frame", {
            Parent = MainFrame,
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundTransparency = 1,
        })
        
        local Title = UI:Create("TextLabel", {
            Parent = TopBar,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 24, 0, 0),
            BackgroundTransparency = 1,
            Text = config.DisplayName,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        -- เปลี่ยนสี Gradient ของหัวข้อเป็น ไล่เฉดสีฟ้า-น้ำเงิน
        UI:AddGradient(Title, {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 152, 219)), -- ฟ้าสว่าง
            ColorSequenceKeypoint.new(1, Color3.fromRGB(41, 128, 185))  -- น้ำเงินเข้มขึ้น
        })

        local CloseButton = UI:Create("TextButton", {
            Parent = TopBar,
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -40, 0.5, -15),
            BackgroundTransparency = 1,
            Text = "×",
            TextColor3 = Color3.fromRGB(120, 120, 130),
            Font = Enum.Font.Gotham,
            TextSize = 28
        })
        CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

        local Divider = UI:Create("Frame", {
            Parent = TopBar,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            BorderSizePixel = 0
        })

        -- CONTENT
        local Content = UI:Create("Frame", {
            Parent = MainFrame,
            Size = UDim2.new(1, -48, 1, -80),
            Position = UDim2.new(0, 24, 0, 70),
            BackgroundTransparency = 1
        })

        local Instr = UI:Create("TextLabel", {
            Parent = Content,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, -5),
            BackgroundTransparency = 1,
            Text = "Please enter your access key below to continue.",
            TextColor3 = Color3.fromRGB(100, 100, 110),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local InputContainer = UI:Create("Frame", {
            Parent = Content,
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 0, 25),
            BackgroundColor3 = Color3.fromRGB(12, 12, 14),
        })
        UI:AddCorner(InputContainer, 10)
        local InputStroke = UI:AddStroke(InputContainer, Color3.fromRGB(40, 40, 45), 1)

        local Keybox = UI:Create("TextBox", {
            Parent = InputContainer,
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = "",
            PlaceholderText = "Paste your key here...",
            PlaceholderColor3 = Color3.fromRGB(70, 70, 80),
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            ClearTextOnFocus = false
        })

        local ButtonGrid = UI:Create("Frame", {
            Parent = Content,
            Size = UDim2.new(1, 0, 0, 45),
            Position = UDim2.new(0, 0, 0, 95),
            BackgroundTransparency = 1
        })
        local UIList = Instance.new("UIListLayout", ButtonGrid)
        UIList.FillDirection = Enum.FillDirection.Horizontal
        UIList.Padding = UDim.new(0, 12)

        local function CreateBtn(text, color, callback)
            local b = UI:Create("TextButton", {
                Parent = ButtonGrid,
                Size = UDim2.new(0.333, -8, 1, 0),
                BackgroundColor3 = Color3.fromRGB(25, 25, 28),
                Text = text,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                AutoButtonColor = false
            })
            UI:AddCorner(b, 8)
            UI:AddStroke(b, Color3.fromRGB(50, 50, 55))
            b.MouseEnter:Connect(function() b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1,1,1) end)
            b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(25, 25, 28); b.TextColor3 = Color3.fromRGB(200, 200, 200) end)
            b.MouseButton1Click:Connect(callback)
        end

        -- [[ ปุ่มกดและฟังก์ชันตังต่าง ๆ ]]
        CreateBtn("GET KEY", Color3.fromRGB(46, 204, 113), function() 
            coppy(PandaAuth.GetKeyURL())
            NotifyCustom("Success", "Link Copied to Clipboard!") 
        end)
        
        CreateBtn("DISCORD", Color3.fromRGB(88, 101, 242), function() coppy(config.Discord); NotifyCustom("Success", "Discord Copied!") end)
        -- เปลี่ยนสีปุ่ม LOGIN ตอน Hover เป็นสีฟ้า (Blue) แทนสีแดงอันเดิม
        CreateBtn("LOGIN", Color3.fromRGB(41, 128, 185), function() VerifyKey(Keybox.Text, config.File) end)

        -- FOOTER
        local StatusContainer = UI:Create("Frame", {
            Parent = MainFrame,
            Size = UDim2.new(1, -48, 0, 20),
            Position = UDim2.new(0, 24, 1, -30),
            BackgroundTransparency = 1
        })

        local StatusText = UI:Create("TextLabel", {
            Parent = StatusContainer,
            Size = UDim2.new(0.5, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "Secured by PandaAuth New API",
            TextColor3 = Color3.fromRGB(70, 70, 80),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local VersionText = UI:Create("TextLabel", {
            Parent = StatusContainer,
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = "v1.1.0",
            TextColor3 = Color3.fromRGB(50, 50, 60),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right
        })

        DraggFunction(MainFrame)
    end
    return Task
end

-- ===================== EXECUTION =====================
local KeySys = CreateKeySystem()
KeySys:Window({
    File = "VoltHub/savedkey.txt",
    DisplayName = "Volt Hub"
})