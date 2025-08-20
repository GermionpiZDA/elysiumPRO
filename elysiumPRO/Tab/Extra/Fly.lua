-- Fly функция
local Fly = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local flyEnabled = false
local flySpeed = 50
local flyConnection = nil
local bodyVelocity = nil

function Fly.toggle(state)
    flyEnabled = state
    
    if state then
        -- Создаем BodyVelocity для полета
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = player.Character.HumanoidRootPart
            
            flyConnection = RunService.Heartbeat:Connect(function()
                if flyEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = player.Character.HumanoidRootPart
                    
                    -- Управление полетом
                    local direction = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        direction = direction + rootPart.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        direction = direction - rootPart.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        direction = direction - rootPart.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        direction = direction + rootPart.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        direction = direction + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        direction = direction + Vector3.new(0, -1, 0)
                    end
                    
                    bodyVelocity.Velocity = direction.Unit * flySpeed
                    bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
                end
            end)
        end
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        
        -- Восстанавливаем гравитацию
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

function Fly.setSpeed(value)
    flySpeed = value
end

function Fly.getStatus()
    return flyEnabled
end

return Fly