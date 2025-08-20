-- Основной файл Elysium PROJECT
-- Автор: L

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

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
local AntiBan = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/BP/AntiBAN.lua")
local Menu = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/GUI/menu.lua")
local Button = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/GUI/Button.lua")

-- Загрузка функций
local AimBot = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Aim/AimBot.lua")
local PlayerESP = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Esp/PlayerESP.lua")
local HighJump = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Extra/HighJump.lua")
local NoClip = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Extra/NoClip.lua")
local SpeedHack = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Extra/Speedhack.lua")
local AutoPickup = loadModule("https://raw.githubusercontent.com/GermionpiZDA/elysiumPRO/refs/heads/main/elysiumPRO/Tab/Farm/AutoPickup.lua")

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

local function createToggle(name, defaultValue, callback)
    local toggleFrame = safeCreate("Frame", {
        Name = name .. "Toggle",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 7
    })
    
    local toggleLabel = safeCreate("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7
    })
    
    local toggleButton = safeCreate("TextButton", {
        Name = "ToggleButton",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = defaultValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 7
    })
    
    local toggleKnob = safeCreate("Frame", {
        Name = "Knob",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, defaultValue and 22 or 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 8
    })
    
    if toggleFrame and toggleLabel and toggleButton and toggleKnob then
        toggleLabel.Parent = toggleFrame
        toggleButton.Parent = toggleFrame
        toggleKnob.Parent = toggleButton
        
        createRoundedCorner(10).Parent = toggleButton
        createRoundedCorner(8).Parent = toggleKnob
        
        local isToggled = defaultValue
        
        toggleButton.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            
            local tween = TweenService:Create(
                toggleKnob,
                TweenInfo.new(0.2),
                {Position = UDim2.new(0, isToggled and 22 or 2, 0.5, -8)}
            )
            tween:Play()
            
            local colorTween = TweenService:Create(
                toggleButton,
                TweenInfo.new(0.2),
                {BackgroundColor3 = isToggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)}
            )
            colorTween:Play()
            
            if callback then
                callback(isToggled)
            end
        end)
        
        return toggleFrame
    end
    return nil
end

local function createSlider(name, minValue, maxValue, defaultValue, callback)
    local sliderFrame = safeCreate("Frame", {
        Name = name .. "Slider",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        ZIndex = 7
    })
    
    local sliderLabel = safeCreate("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = name .. ": " .. defaultValue,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7
    })
    
    local sliderTrack = safeCreate("Frame", {
        Name = "Track",
        Size = UDim2.new(1, -10, 0, 6),
        Position = UDim2.new(0, 5, 0, 25),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        ZIndex = 7
    })
    
    local sliderFill = safeCreate("Frame", {
        Name = "Fill",
        Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 170, 0),
        ZIndex = 8
    })
    
    local sliderButton = safeCreate("TextButton", {
        Name = "SliderButton",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -8, 0, -5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 9
    })
    
    if sliderFrame and sliderLabel and sliderTrack and sliderFill and sliderButton then
        sliderLabel.Parent = sliderFrame
        sliderTrack.Parent = sliderFrame
        sliderFill.Parent = sliderTrack
        sliderButton.Parent = sliderTrack
        
        createRoundedCorner(3).Parent = sliderTrack
        createRoundedCorner(3).Parent = sliderFill
        createRoundedCorner(8).Parent = sliderButton
        
        local isDragging = false
        
        local function updateSlider(value)
            local clampedValue = math.clamp(value, minValue, maxValue)
            local fillSize = (clampedValue - minValue) / (maxValue - minValue)
            
            sliderFill.Size = UDim2.new(fillSize, 0, 1, 0)
            sliderButton.Position = UDim2.new(fillSize, -8, 0, -5)
            sliderLabel.Text = name .. ": " .. math.floor(clampedValue)
            
            if callback then
                callback(clampedValue)
            end
        end
        
        sliderButton.MouseButton1Down:Connect(function()
            isDragging = true
        end)
        
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePosition = game:GetService("UserInputService"):GetMouseLocation()
                local trackAbsolutePosition = sliderTrack.AbsolutePosition
                local trackAbsoluteSize = sliderTrack.AbsoluteSize
                
                local relativeX = (mousePosition.X - trackAbsolutePosition.X) / trackAbsoluteSize.X
                local value = minValue + relativeX * (maxValue - minValue)
                
                updateSlider(value)
            end
        end)
        
        return sliderFrame
    end
    return nil
end

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
        
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = name .. "TabContent"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = false
        tabContent.ZIndex = 7
        tabContent.Parent = contentContainer
        
        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        uiListLayout.Padding = UDim.new(0, 8)
        uiListLayout.Parent = tabContent
        
        uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
        end)
        
        local function activateTab()
            for _, child in ipairs(contentContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") and child.Name:find("TabContent") then
                    child.Visible = false
                end
            end
            
            for _, child in ipairs(tabsContainer:GetChildren()) do
                if child:IsA("TextButton") and child.Name:find("TabButton") then
                    local tween = TweenService:Create(
                        child,
                        TweenInfo.new(0.2),
                        {
                            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                            TextColor3 = Color3.fromRGB(180, 180, 180)
                        }
                    )
                    tween:Play()
                end
            end
            
            tabContent.Visible = true
            local tween = TweenService:Create(
                tabButton,
                TweenInfo.new(0.2),
                {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }
            )
            tween:Play()
        end
        
        tabButton.MouseButton1Click:Connect(activateTab)
        
        tabButton.MouseEnter:Connect(function()
            if not tabContent.Visible then
                local tween = TweenService:Create(
                    tabButton,
                    TweenInfo.new(0.2),
                    {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}
                )
                tween:Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if not tabContent.Visible then
                local tween = TweenService:Create(
                    tabButton,
                    TweenInfo.new(0.2),
                    {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}
                )
                tween:Play()
            end
        end)
        
        local function addElement(element)
            element.LayoutOrder = #tabContent:GetChildren()
            element.Parent = tabContent
        end
        
        return {
            addElement = addElement,
            activate = activateTab,
            content = tabContent
        }
    end
    
    -- Создаем вкладки
    local farmTab = createTab("Farm")
    local espTab = createTab("ESP")
    local aimTab = createTab("Aim")
    local extraTab = createTab("Extra")
    
    -- Добавляем элементы на вкладки
    if farmTab and AutoPickup then
        local farmLabel = safeCreate("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = "Farm Functions",
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            ZIndex = 7
        })
        farmTab.addElement(farmLabel)
        
        local autoPickupToggle = createToggle("Auto Pickup Gun", false, function(state)
            AutoPickup.toggle(state)
        end)
        if autoPickupToggle then farmTab.addElement(autoPickupToggle) end
    end
    
    if espTab and PlayerESP then
        local espLabel = safeCreate("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = "ESP Functions",
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            ZIndex = 7
        })
        espTab.addElement(espLabel)
        
        local espToggle = createToggle("Player ESP", false, function(state)
            PlayerESP.toggle(state)
        end)
        if espToggle then espTab.addElement(espToggle) end
        espTab.activate()
    end
    
    if aimTab and AimBot then
        local aimLabel = safeCreate("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = "Aim Functions",
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            ZIndex = 7
        })
        aimTab.addElement(aimLabel)
        
        local aimbotToggle = createToggle("Aimbot", false, function(state)
            AimBot.toggle(state, screenGui)
        end)
        if aimbotToggle then aimTab.addElement(aimbotToggle) end
        
        local wallhackToggle = createToggle("Through Walls", false, function(state)
            AimBot.setThroughWalls(state)
        end)
        if wallhackToggle then aimTab.addElement(wallhackToggle) end
        
        local fovSlider = createSlider("Aimbot FOV", 50, 300, 100, function(value)
            AimBot.setFOV(value)
        end)
        if fovSlider then aimTab.addElement(fovSlider) end
    end
    
    if extraTab and HighJump and NoClip and SpeedHack then
        local extraLabel = safeCreate("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = "Extra Functions",
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            ZIndex = 7
        })
        extraTab.addElement(extraLabel)
        
        local speedToggle = createToggle("Speed Hack", false, function(state)
            SpeedHack.toggle(state)
        end)
        if speedToggle then extraTab.addElement(speedToggle) end
        
        local speedSlider = createSlider("Speed Value", 16, 100, 25, function(value)
            SpeedHack.setSpeed(value)
        end)
        if speedSlider then extraTab.addElement(speedSlider) end
        
        local highJumpToggle = createToggle("High Jump", false, function(state)
            HighJump.toggle(state)
        end)
        if highJumpToggle then extraTab.addElement(highJumpToggle) end
        
        local jumpSlider = createSlider("Jump Power", 50, 200, 100, function(value)
            HighJump.setMultiplier(value)
        end)
        if jumpSlider then extraTab.addElement(jumpSlider) end
        
        local noclipToggle = createToggle("Noclip", false, function(state)
            NoClip.toggle(state)
        end)
        if noclipToggle then extraTab.addElement(noclipToggle) end
    end
end

-- Создаем UI элементы
createUIElements()

print("Elysium PROJECT успешно загружен! Нажмите на кнопку L в правой части экрана.")