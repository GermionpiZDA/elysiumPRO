-- Основной файл Elysium PROJECT
-- Автор: L

local function loadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("Ошибка загрузки модуля: " .. url)
        warn(result)
    end
    return result
end

-- Загрузка модулей
local AntiBan = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/BP/AntiBan.lua")
local Menu = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/GUI/Menu.lua")
local Button = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/GUI/Button.lua")

-- Загрузка функций
local AimBot = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Aim/AimBot.lua")
local PlayerESP = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Esp/PlayerESP.lua")
local HighJump = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Extra/HighJump.lua")
local NoClip = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Extra/NoClip.lua")
local SpeedHack = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Extra/SpeedHack.lua")

-- Инициализация
if AntiBan then
    AntiBan.init()
end

if Menu then
    Menu.init()
end

print("Elysium PROJECT успешно загружен!")