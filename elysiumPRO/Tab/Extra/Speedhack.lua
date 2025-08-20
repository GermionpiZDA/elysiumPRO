-- Speed Hack функция
local SpeedHack = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local speedEnabled = false
local currentSpeed = 25
local originalWalkSpeed = 16
local speedConnection = nil

function SpeedHack.toggle(state)
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
            player.Character.Humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end

function SpeedHack.setSpeed(value)
    currentSpeed = value
    if speedEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = currentSpeed
    end
end

function SpeedHack.getStatus()
    return speedEnabled
end

return SpeedHack