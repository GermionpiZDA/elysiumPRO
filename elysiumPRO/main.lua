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

-- Загрузка всех модулей
local AntiBan = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/BP/AntiBAN.lua")
local MenuSystem = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/GUI/menu.lua")

-- Инициализация
if AntiBan then
    AntiBan.init()
end

if MenuSystem then
    MenuSystem.init()
end

print("Elysium PROJECT успешно загружен! Нажмите на кнопку L в правой части экрана.")