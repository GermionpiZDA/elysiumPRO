-- Кнопка меню
local Button = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local menuButton = nil

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

function Button.init(screenGui)
    if not screenGui then return false end
    
    -- Создание кнопки меню
    menuButton = safeCreate("TextButton", {
        Name = "LMenuButton",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -50, 0.5, -20),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Text = "L",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Active = true,
        Draggable = false,
        Selectable = true,
        ZIndex = 10
    })
    
    if menuButton then
        menuButton.Parent = screenGui
        createRoundedCorner(8).Parent = menuButton
        createStroke(1, Color3.fromRGB(255, 255, 255)).Parent = menuButton
        
        -- Анимации при наведении
        menuButton.MouseEnter:Connect(function()
            TweenService:Create(menuButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            }):Play()
        end)
        
        menuButton.MouseLeave:Connect(function()
            TweenService:Create(menuButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            }):Play()
        end)
        
        return true
    end
    
    return false
end

function Button.setClickCallback(callback)
    if menuButton and callback then
        menuButton.MouseButton1Click:Connect(callback)
    end
end

function Button.getButton()
    return menuButton
end

return Button