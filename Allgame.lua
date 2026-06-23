local PlaceId = game.PlaceId
local HttpService = game:GetService("HttpService")

local ScriptConfig = {
    {
        Name = "ReignPiece",
        Url = 'https://raw.githubusercontent.com/devkidlumedev-wq/voltz/main/Reignpiecez.lua',
        Ids = {
            78466992256287
        }
    },
  {
        Name = "Lineagepiece",
        Url = 'https://raw.githubusercontent.com/devkidlumedev-wq/voltz/main/LineagepieceZz.lua',
        Ids = {
            104761395312874,
            121357213553162
        }
    },
}

local MapScripts = {}

for _, config in pairs(ScriptConfig) do
    for _, mapId in pairs(config.Ids) do
        MapScripts[mapId] = function()
            print("Start In: " .. config.Name)
            loadstring(game:HttpGet(config.Url))()
        end
    end
end

local function RunScriptByMap()
    if MapScripts[PlaceId] then
        local success, err = pcall(MapScripts[PlaceId])
        if not success then
            warn("เกิดข้อผิดพลาดในการรันสคริปต์ (" .. PlaceId .. "): " .. tostring(err))
        end
    else
        print("Dont have Script: " .. PlaceId)
        print("Wait For Executes")
    end
end


RunScriptByMap()
