-- Полная система меню
local MenuSystem = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Глобальные переменные для функций
local espEnabled = false
local espObjects = {}
local playerConnections = {}
local aimbotEnabled = false
local aimbotThroughWalls = false
local aimbotFOV = 100
local aimbotCircle
local noclipEnabled = false
local noclipConnection
local speedEnabled = false
local currentSpeed = 25
local originalWalkSpeed
local speedConnection
local highJumpEnabled = false
local originalJumpPower
local jumpMultiplier = 2.0
local jumpConnection
local autoPickupEnabled = false
local originalPosition = nil
local pickupConnection

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

-- Функция для создания переключателя
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

-- Функция для создания слайдера
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
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePosition = UserInputService:GetMouseLocation()
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

-- Функция для создания вкладки
local function createTab(menuFrame, name)
    if not menuFrame then return nil end
    
    local tabsContainer = menuFrame:FindFirstChild("TabsContainer")
    local contentContainer = menuFrame:FindFirstChild("ContentContainer")
    if not tabsContainer or not contentContainer then return nil end
    
    local tabButton = safeCreate("TextButton", {
        Name = name .. "TabButton",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Text = name,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        ZIndex = 7
    })
    
    local tabContent = safeCreate("ScrollingFrame", {
        Name = name .. "TabContent",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 7
    })
    
    local uiListLayout = safeCreate("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    if tabButton and tabContent and uiListLayout then
        tabButton.Parent = tabsContainer
        tabContent.Parent = contentContainer
        uiListLayout.Parent = tabContent
        
        createRoundedCorner(4).Parent = tabButton
        createStroke(1, Color3.fromRGB(60, 60, 60)).Parent = tabButton
        
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
            activate = activateTab
        }
    end
    
    return nil
end

-- ESP система
local function getMM2Role(playerChar)
    if playerChar and playerChar:FindFirstChild("Backpack") then
        local backpack = playerChar:FindFirstChild("Backpack")
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name == "Gun" then
                return "sheriff"
            elseif item.Name == "Knife" then
                return "murderer"
            end
        end
        
        for _, tool in ipairs(playerChar:GetChildren()) do
            if tool:IsA("Tool") then
                if tool.Name == "Gun" then
                    return "sheriff"
                elseif tool.Name == "Knife" then
                    return "murderer"
                end
            end
        end
    end
    return "innocent"
end

local function createESP(targetPlayer)
    if not targetPlayer or targetPlayer == Players.LocalPlayer or not targetPlayer.Character then return end
    
    if espObjects[targetPlayer] then
        if espObjects[targetPlayer].highlight then
            espObjects[targetPlayer].highlight:Destroy()
        end
        if espObjects[targetPlayer].billboard then
            espObjects[targetPlayer].billboard:Destroy()
        end
    end
    
    local role = getMM2Role(targetPlayer.Character)
    local fillColor = Color3.fromRGB(0, 255, 0)
    
    if role == "murderer" then
        fillColor = Color3.fromRGB(255, 0, 0)
    elseif role == "sheriff" then
        fillColor = Color3.fromRGB(0, 0, 255)
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = targetPlayer.Name .. "ESP"
    highlight.FillColor = fillColor
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = targetPlayer.Character
    
    local head = targetPlayer.Character:FindFirstChild("Head")
    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = targetPlayer.Name .. "NameTag"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.ExtentsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 1000
        billboard.Parent = head
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0, 25)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = targetPlayer.Name .. " (" .. role:upper() .. ")"
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.ZIndex = 10
        nameLabel.Parent = billboard
        
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "DistanceLabel"
        distanceLabel.Size = UDim2.new(1, 0, 0, 20)
        distanceLabel.Position = UDim2.new(0, 0, 0, 25)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = "0 studs"
        distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distanceLabel.TextSize = 12
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distanceLabel.TextStrokeTransparency = 0.3
        distanceLabel.ZIndex = 10
        distanceLabel.Parent = billboard
        
        local distanceConnection
        distanceConnection = RunService.Heartbeat:Connect(function()
            if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and 
               billboard and billboard.Parent then
                local rootPart = targetPlayer.Character.HumanoidRootPart
                local localChar = Players.LocalPlayer.Character
                if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                    local distance = (rootPart.Position - localChar.HumanoidRootPart.Position).Magnitude
                    distanceLabel.Text = string.format("%.0f studs", distance)
                end
            else
                if distanceConnection then
                    distanceConnection:Disconnect()
                end
            end
        end)
        
        espObjects[targetPlayer] = {
            highlight = highlight, 
            billboard = billboard, 
            distanceConnection = distanceConnection
        }
    else
        espObjects[targetPlayer] = {highlight = highlight}
    end
end

local function removeESP(targetPlayer)
    if espObjects[targetPlayer] then
        if espObjects[targetPlayer].highlight then
            espObjects[targetPlayer].highlight:Destroy()
        end
        if espObjects[targetPlayer].billboard then
            espObjects[targetPlayer].billboard:Destroy()
        end
        if espObjects[targetPlayer].distanceConnection then
            espObjects[targetPlayer].distanceConnection:Disconnect()
        end
        espObjects[targetPlayer] = nil
    end
end

local function setupPlayerESP(targetPlayer)
    if targetPlayer == Players.LocalPlayer then return end
    
    if targetPlayer.Character then
        createESP(targetPlayer)
    end
    
    playerConnections[targetPlayer] = targetPlayer.CharacterAdded:Connect(function(character)
        task.wait(1)
        if espEnabled then
            createESP(targetPlayer)
        end
    end)
end

local function toggleESP(state)
    espEnabled = state
    
    if state then
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= Players.LocalPlayer then
                setupPlayerESP(targetPlayer)
            end
        end
        
        Players.PlayerAdded:Connect(function(newPlayer)
            if newPlayer ~= Players.LocalPlayer then
                setupPlayerESP(newPlayer)
            end
        end)
    else
        for targetPlayer, _ in pairs(espObjects) do
            removeESP(targetPlayer)
        end
        espObjects = {}
        
        for targetPlayer, connection in pairs(playerConnections) do
            connection:Disconnect()
        end
        playerConnections = {}
    end
end

-- AimBot система
local function createAimbotCircle(screenGui)
    if aimbotCircle then
        aimbotCircle:Destroy()
    end
    
    aimbotCircle = Instance.new("Frame")
    aimbotCircle.Name = "AimbotFOVCircle"
    aimbotCircle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
    aimbotCircle.Position = UDim2.new(0.5, -aimbotFOV, 0.5, -aimbotFOV)
    aimbotCircle.BackgroundTransparency = 1
    aimbotCircle.Parent = screenGui
    
    local circle = Instance.new("UICorner")
    circle.CornerRadius = UDim.new(1, 0)
    circle.Parent = aimbotCircle
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = aimbotCircle
end

local function updateAimbotCircle()
    if aimbotCircle then
        aimbotCircle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
        aimbotCircle.Position = UDim2.new(0.5, -aimbotFOV, 0.5, -aimbotFOV)
    end
end

local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = aimbotFOV
    
    local localChar = player.Character
    if not localChar then return nil end
    
    local localHead = localChar:FindFirstChild("Head")
    if not localHead then return nil end
    
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player and target.Character then
            local targetHead = target.Character:FindFirstChild("Head")
            if targetHead then
                local screenPoint, visible = Workspace.CurrentCamera:WorldToViewportPoint(targetHead.Position)
                
                if visible or aimbotThroughWalls then
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = target
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimAtPlayer(target)
    if not target or not target.Character then return end
    
    local targetHead = target.Character:FindFirstChild("Head")
    if not targetHead then return end
    
    local camera = Workspace.CurrentCamera
    local cameraCFrame = camera.CFrame
    local direction = (targetHead.Position - cameraCFrame.Position).Unit
    
    local newCFrame = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + direction)
    camera.CFrame = cameraCFrame:Lerp(newCFrame, 0.8)
end

local aimbotConnection
local function toggleAimbot(state, screenGui)
    aimbotEnabled = state
    
    if state then
        createAimbotCircle(screenGui)
        aimbotConnection = RunService.RenderStepped:Connect(function()
            if aimbotEnabled then
                local closest = getClosestPlayer()
                if closest then
                    aimAtPlayer(closest)
                end
            end
        end)
    else
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
        
        if aimbotCircle then
            aimbotCircle:Destroy()
            aimbotCircle = nil
        end
    end
end

-- Noclip функция
local function toggleNoclip(state)
    noclipEnabled = state
    
    if state then
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        
        noclipConnection = RunService.Stepped:Connect(function()
            if noclipEnabled and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

-- Speed функция
local function toggleSpeed(state)
    speedEnabled = state
    
    if state then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            originalWalkSpeed = player.Character.Humanoid.WalkSpeed
            player.Character.Humanoid.WalkSpeed = currentSpeed
        end
        
        speedConnection = player.CharacterAdded:Connect(function(character)
            task.wait(1)
            if speedEnabled and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = currentSpeed
            end
        end)
    else
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = originalWalkSpeed or 16
        end
    end
end

local function setSpeed(value)
    currentSpeed = value
    if speedEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = currentSpeed
    end
end

-- High Jump функция
local function toggleHighJump(state)
    highJumpEnabled = state
    
    if state then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            originalJumpPower = player.Character.Humanoid.JumpPower
            player.Character.Humanoid.JumpPower = originalJumpPower * jumpMultiplier
        end
        
        jumpConnection = player.CharacterAdded:Connect(function(character)
            task.wait(1)
            if highJumpEnabled and character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = (originalJumpPower or 50) * jumpMultiplier
            end
        end)
    else
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
        
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = originalJumpPower or 50
        end
    end
end

local function setJumpPower(value)
    jumpMultiplier = value / 50
    if highJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = (originalJumpPower or 50) * jumpMultiplier
    end
end

-- Функция для автоматического подбора пистолета
local function getPlayerRole()
    if player.Character then
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item.Name == "Gun" then
                    return "sheriff"
                elseif item.Name == "Knife" then
                    return "murderer"
                end
            end
        end
        
        for _, tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                if tool.Name == "Gun" then
                    return "sheriff"
                elseif tool.Name == "Knife" then
                    return "murderer"
                end
            end
        end
    end
    return "innocent"
end

local function findGunOnMap()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Gun" and obj:IsA("Tool") then
            return obj
        end
    end
    return nil
end

local function toggleAutoPickup(state)
    autoPickupEnabled = state
    
    if state then
        pickupConnection = RunService.Heartbeat:Connect(function()
            if autoPickupEnabled then
                local role = getPlayerRole()
                
                if role == "innocent" then
                    local gun = findGunOnMap()
                    if gun then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            originalPosition = player.Character.HumanoidRootPart.Position
                            player.Character.HumanoidRootPart.CFrame = CFrame.new(gun.Handle.Position)
                            wait(0.5)
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                player.Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                            end
                        end
                    end
                end
            end
        end)
    else
        if pickupConnection then
            pickupConnection:Disconnect()
            pickupConnection = nil
        end
    end
end

function MenuSystem.init()
    -- Создание основного GUI
    local ScreenGui = safeCreate("ScreenGui", {
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
    
    -- Создание кнопки меню
    local menuButton = safeCreate("TextButton", {
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
        menuButton.Parent = ScreenGui
        createRoundedCorner(8).Parent = menuButton
        createStroke(1, Color3.fromRGB(255, 255, 255)).Parent = menuButton
        
        menuButton.MouseEnter:Connect(function()
            local tween = TweenService:Create(
                menuButton,
                TweenInfo.new(0.2),
                {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}
            )
            tween:Play()
        end)
        
        menuButton.MouseLeave:Connect(function()
            local tween = TweenService:Create(
                menuButton,
                TweenInfo.new(0.2),
                {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}
            )
            tween:Play()
        end)
    end
    
    -- Создание меню
    local menuFrame = safeCreate("Frame", {
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
                local startTime = os.time()
                local timeConnection
                timeConnection = RunService.Heartbeat:Connect(function()
                    if menuFrame and menuFrame.Parent then
                        local elapsed = os.time() - startTime
                        local hours = math.floor(elapsed / 3600)
                        local minutes = math.floor((elapsed % 3600) / 60)
                        local seconds = elapsed % 60
                        keyTime.Text = string.format("Key Time: %02d:%02d:%02d", hours, minutes, seconds)
                    else
                        timeConnection:Disconnect()
                    end
                end)
            end
        end
        
        local separator = safeCreate("Frame", {
            Name = "Separator",
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            BorderSizePixel = 0,
            ZIndex = 6
        })
        
        if separator then separator.Parent = menuFrame end
        
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
            
            local status = safeCreate("TextLabel", {
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
            })
            
            if status then status.Parent = bottomBar end
        end
        
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
        
        local tabSeparator = safeCreate("Frame", {
            Name = "TabSeparator",
            Size = UDim2.new(0, 1, 1, -55),
            Position = UDim2.new(0, 115, 0, 35),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            BorderSizePixel = 0,
            ZIndex = 6
        })
        
        if tabSeparator then tabSeparator.Parent = menuFrame end
        
        local contentContainer = safeCreate("Frame", {
            Name = "ContentContainer",
            Size = UDim2.new(1, -130, 1, -55),
            Position = UDim2.new(0, 125, 0, 35),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 6
        })
        
        if contentContainer then contentContainer.Parent = menuFrame end
        
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
            
            closeButton.MouseEnter:Connect(function()
                local tween = TweenService:Create(
                    closeButton,
                    TweenInfo.new(0.2),
                    {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}
                )
                tween:Play()
            end)
            
            closeButton.MouseLeave:Connect(function()
                local tween = TweenService:Create(
                    closeButton,
                    TweenInfo.new(0.2),
                    {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}
                )
                tween:Play()
            end)
        end
        
        -- Создаем вкладки
        local farmTab = createTab(menuFrame, "Farm")
        local espTab = createTab(menuFrame, "ESP")
        local aimTab = createTab(menuFrame, "Aim")
        local extraTab = createTab(menuFrame, "Extra")
        
        -- Добавляем элементы на вкладки
        if farmTab then
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
                toggleAutoPickup(state)
            end)
            if autoPickupToggle then farmTab.addElement(autoPickupToggle) end
        end
        
        if espTab then
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
                toggleESP(state)
            end)
            if espToggle then espTab.addElement(espToggle) end
            espTab.activate()
        end
        
        if aimTab then
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
                toggleAimbot(state, ScreenGui)
            end)
            if aimbotToggle then aimTab.addElement(aimbotToggle) end
            
            local wallhackToggle = createToggle("Through Walls", false, function(state)
                aimbotThroughWalls = state
            end)
            if wallhackToggle then aimTab.addElement(wallhackToggle) end
            
            local fovSlider = createSlider("Aimbot FOV", 50, 300, 100, function(value)
                aimbotFOV = value
                updateAimbotCircle()
            end)
            if fovSlider then aimTab.addElement(fovSlider) end
        end
        
        if extraTab then
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
                toggleSpeed(state)
            end)
            if speedToggle then extraTab.addElement(speedToggle) end
            
            local speedSlider = createSlider("Speed Value", 16, 100, 25, function(value)
                setSpeed(value)
            end)
            if speedSlider then extraTab.addElement(speedSlider) end
            
            local highJumpToggle = createToggle("High Jump", false, function(state)
                toggleHighJump(state)
            end)
            if highJumpToggle then extraTab.addElement(highJumpToggle) end
            
            local jumpSlider = createSlider("Jump Power", 50, 200, 100, function(value)
                setJumpPower(value)
            end)
            if jumpSlider then extraTab.addElement(jumpSlider) end
            
            local noclipToggle = createToggle("Noclip", false, function(state)
                toggleNoclip(state)
            end)
            if noclipToggle then extraTab.addElement(noclipToggle) end
        end
        
        -- Открытие/закрытие меню
        if menuButton then
            menuButton.MouseButton1Click:Connect(function()
                menuFrame.Visible = not menuFrame.Visible
            end)
        end
        
        -- Автоматически настраиваем ESP для всех игроков при запуске
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= Players.LocalPlayer then
                setupPlayerESP(targetPlayer)
            end
        end
        
        -- Обработка новых игроков
        Players.PlayerAdded:Connect(function(newPlayer)
            if newPlayer ~= Players.LocalPlayer then
                setupPlayerESP(newPlayer)
            end
        end)
        
        return true
    end
    
    return false
end

return MenuSystem