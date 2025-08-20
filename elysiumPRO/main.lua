-- Основной файл Elysium PROJECT
-- Автор: L

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local function loadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("Ошибка загрузки модуля: " .. url)
        warn(result)
        return nil
    end
    return result
end

-- Загрузка модулей
local AntiBan = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/BP/AntiBAN.lua")
local Menu = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/GUI/menu.lua")
local Button = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/GUI/Button.lua")

-- Загрузка функций
local AimBot = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Aim/AimBot.lua")
local PlayerESP = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Esp/PlayerESP.lua")
local HighJump = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Extra/HighJump.lua")
local NoClip = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Extra/NoClip.lua")
local SpeedHack = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Extra/Speedhack.lua")

-- Инициализация
if AntiBan then
    AntiBan.init()
end

local screenGui, menuFrame

if Menu then
    Menu.init()
    screenGui = Menu.getScreenGui()
    menuFrame = Menu.getMenuFrame()
end

if Button and screenGui then
    Button.init(screenGui)
    Button.setClickCallback(function()
        if menuFrame then
            menuFrame.Visible = not menuFrame.Visible
        end
    end)
end

-- Функция для создания UI элементов
local function createUIElements()
    if not menuFrame then return end
    
    local contentContainer = menuFrame:FindFirstChild("ContentContainer")
    local tabsContainer = menuFrame:FindFirstChild("TabsContainer")
    
    if not contentContainer or not tabsContainer then return end
    
    -- Функция для создания вкладки
    local function createTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "TabButton"
        tabButton.Size = UDim2.new(1, 0, 0, 30)
        tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        tabButton.Text = name
        tabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.Gotham
        tabButton.AutoButtonColor = false
        tabButton.ZIndex = 7
        tabButton.Parent = tabsContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = tabButton
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(60, 60, 60)
        stroke.Thickness = 1
        stroke.Parent = tabButton
        
        return tabButton
    end
    
    -- Создаем вкладки
    local farmTab = createTab("Farm")
    local espTab = createTab("ESP")
    local aimTab = createTab("Aim")
    local extraTab = createTab("Extra")
    
    -- Активируем ESP вкладку по умолчанию
    if espTab then
        espTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Создаем UI элементы
createUIElements()

print("Elysium PROJECT успешно загружен! Нажмите на кнопку L в правой части экрана.")