-- Основное меню GUI
local Menu = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local ScreenGui = nil
local menuFrame = nil

-- Вспомогательные функции
local function safeCreate(instanceType, properties)
    local success, result = pcall(function()
        local instance = Instance.new(instanceType)
        for property, value in pairs(properties) do
            pcall(function()
                instance[property] = value
            end)
        end
        return instance
    end)
    return success and result or nil
end

local function createRoundedCorner(radius)
    local corner = safeCreate("UICorner", {
        CornerRadius = UDim.new(0, radius)
    })
    return corner
end

local function createStroke(thickness, color, transparency)
    local stroke = safeCreate("UIStroke", {
        Thickness = thickness,
        Color = color,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    return stroke
end

function Menu.init()
    -- Создание основного GUI
    ScreenGui = safeCreate("ScreenGui", {
        Name = "LMenuGui_" .. tostring(math.random(10000, 99999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 10
    })
    
    if ScreenGui then
        ScreenGui.Parent = CoreGui
    else
        return false
    end
    
    -- Создание меню
    menuFrame = safeCreate("Frame", {
        Name = "LMenuFrame",
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250, 0.5, -175),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        Visible = false,
        ZIndex = 5,
        ClipsDescendants = true
    })
    
    if menuFrame then
        menuFrame.Parent = ScreenGui
        createRoundedCorner(6).Parent = menuFrame
        createStroke(1, Color3.fromRGB(50, 50, 50)).Parent = menuFrame
        
        -- Верхняя панель
        local topBar = safeCreate("Frame", {
            Name = "TopBar",
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            BorderSizePixel = 0,
            ZIndex = 6
        })
        
        if topBar then
            topBar.Parent = menuFrame
            createRoundedCorner(6).Parent = topBar
            
            local title = safeCreate("TextLabel", {
                Name = "Title",
                Size = UDim2.new(0, 200, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = "Elysium PROJECT",
                TextColor3 = Color3.fromRGB(220, 220, 220),
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 7
            })
            
            if title then title.Parent = topBar end
            
            local keyTime = safeCreate("TextLabel", {
                Name = "KeyTime",
                Size = UDim2.new(0, 150, 1, 0),
                Position = UDim2.new(1, -180, 0, 0),
                BackgroundTransparency = 1,
                Text = "Key Time: 00:00:00",
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 7
            })
            
            if keyTime then
                keyTime.Parent = topBar
            end
        end
        
        -- Разделитель
        safeCreate("Frame", {
            Name = "Separator",
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            BorderSizePixel = 0,
            ZIndex = 6
        }).Parent = menuFrame
        
        -- Нижняя панель
        local bottomBar = safeCreate("Frame", {
            Name = "BottomBar",
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 1, -20),
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            BorderSizePixel = 0,
            ZIndex = 6
        })
        
        if bottomBar then
            bottomBar.Parent = menuFrame
            createRoundedCorner(6).Parent = bottomBar
            
            safeCreate("TextLabel", {
                Name = "Status",
                Size = UDim2.new(0, 100, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = "Avstrial",
                TextColor3 = Color3.fromRGB(100, 200, 100),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 7
            }).Parent = bottomBar
        end
        
        -- Контейнер вкладок
        local tabsContainer = safeCreate("Frame", {
            Name = "TabsContainer",
            Size = UDim2.new(0, 100, 1, -55),
            Position = UDim2.new(0, 10, 0, 35),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 6
        })
        
        if tabsContainer then
            tabsContainer.Parent = menuFrame
            safeCreate("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            }).Parent = tabsContainer
        end
        
        -- Разделитель вкладок
        safeCreate("Frame", {
            Name = "TabSeparator",
            Size = UDim2.new(0, 1, 1, -55),
            Position = UDim2.new(0, 115, 0, 35),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            BorderSizePixel = 0,
            ZIndex = 6
        }).Parent = menuFrame
        
        -- Контейнер контента
        safeCreate("Frame", {
            Name = "ContentContainer",
            Size = UDim2.new(1, -130, 1, -55),
            Position = UDim2.new(0, 125, 0, 35),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 6
        }).Parent = menuFrame
        
        -- Кнопка закрытия
        local closeButton = safeCreate("TextButton", {
            Name = "CloseButton",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -25, 0, 5),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Text = "×",
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            ZIndex = 7
        })
        
        if closeButton then
            closeButton.Parent = menuFrame
            createRoundedCorner(4).Parent = closeButton
            
            closeButton.MouseButton1Click:Connect(function()
                menuFrame.Visible = false
            end)
        end
        
        return true
    end
    
    return false
end

function Menu.getScreenGui()
    return ScreenGui
end

function Menu.getMenuFrame()
    return menuFrame
end

return Menu