-- High Jump функция
local HighJump = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local highJumpEnabled = false
local originalJumpPower = 50
local jumpMultiplier = 2.0
local jumpConnection = nil

function HighJump.toggle(state)
    highJumpEnabled = state
    
    if state then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            originalJumpPower = player.Character.Humanoid.JumpPower
            player.Character.Humanoid.JumpPower = originalJumpPower * jumpMultiplier
        end
        
        jumpConnection = player.CharacterAdded:Connect(function(character)
            task.wait(1)
            if highJumpEnabled and character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = originalJumpPower * jumpMultiplier
            end
        end)
    else
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
        
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = originalJumpPower
        end
    end
end

function HighJump.setMultiplier(value)
    jumpMultiplier = value / 50
    if highJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = originalJumpPower * jumpMultiplier
    end
end

function HighJump.getStatus()
    return highJumpEnabled
end

return HighJump