-- Auto Pickup функция
local AutoPickup = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local autoPickupEnabled = false
local originalPosition = nil
local pickupConnection = nil

function AutoPickup.getPlayerRole()
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

function AutoPickup.findGunOnMap()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Gun" and obj:IsA("Tool") then
            return obj
        end
    end
    return nil
end

function AutoPickup.toggle(state)
    autoPickupEnabled = state
    
    if state then
        pickupConnection = RunService.Heartbeat:Connect(function()
            if autoPickupEnabled then
                local role = AutoPickup.getPlayerRole()
                
                if role == "innocent" then
                    local gun = AutoPickup.findGunOnMap()
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

function AutoPickup.getStatus()
    return autoPickupEnabled
end

return AutoPickup