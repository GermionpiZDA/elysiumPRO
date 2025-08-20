-- AimBot система
local AimBot = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local aimbotEnabled = false
local aimbotThroughWalls = false
local aimbotFOV = 100
local aimbotCircle = nil
local aimbotConnection = nil

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

function AimBot.toggle(state, screenGui)
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

function AimBot.setThroughWalls(state)
    aimbotThroughWalls = state
end

function AimBot.setFOV(value)
    aimbotFOV = value
    updateAimbotCircle()
end

function AimBot.getStatus()
    return aimbotEnabled
end

return AimBot