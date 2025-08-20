-- Player ESP система
local PlayerESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local espEnabled = false
local espObjects = {}
local playerConnections = {}

local function getMM2Role(playerChar)
    if not playerChar then return "innocent" end
    
    local backpack = playerChar.Parent:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name == "Gun" then
                return "sheriff"
            elseif item.Name == "Knife" then
                return "murderer"
            end
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
    
    return "innocent"
end

local function createESP(targetPlayer)
    if not targetPlayer or targetPlayer == player or not targetPlayer.Character then return end
    
    if espObjects[targetPlayer] then
        if espObjects[targetPlayer].highlight then
            espObjects[targetPlayer].highlight:Destroy()
        end
        if espObjects[targetPlayer].billboard then
            espObjects[targetPlayer].billboard:Destroy()
        end
    end
    
    local role = getMM2Role(targetPlayer.Character)
    local fillColor = Color3.fromRGB(0, 255, 0) -- зеленый
    
    if role == "murderer" then
        fillColor = Color3.fromRGB(255, 0, 0) -- красный
    elseif role == "sheriff" then
        fillColor = Color3.fromRGB(0, 0, 255) -- синий
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
                local localChar = player.Character
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
    if targetPlayer == player then return end
    
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

function PlayerESP.toggle(state)
    espEnabled = state
    
    if state then
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
                setupPlayerESP(targetPlayer)
            end
        end
        
        Players.PlayerAdded:Connect(function(newPlayer)
            if newPlayer ~= player then
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

function PlayerESP.getStatus()
    return espEnabled
end

return PlayerESP