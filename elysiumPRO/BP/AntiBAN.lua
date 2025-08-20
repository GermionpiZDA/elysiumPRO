-- Система анти-бана
local AntiBan = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

function AntiBan.init()
    -- Случайные задержки для обхода детекции
    local randomDelay = math.random(100, 500) / 1000
    wait(randomDelay)
    
    -- Скрытие следов в логах
    local function cleanLogs()
        pcall(function()
            for i = 1, 10 do
                print("\n\n\n\n\n\n\n\n\n\n")
            end
        end)
    end
    
    -- Рандомизация имен объектов
    local function randomizeNames()
        local randomString = function(length)
            local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            local result = ""
            for i = 1, length do
                result = result .. string.sub(chars, math.random(1, #chars), 1)
            end
            return result
        end
        
        pcall(function()
            if game:FindFirstChild("CoreGui") then
                for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Name:find("LMenu") then
                        gui.Name = randomString(12)
                    end
                end
            end
        end)
    end
    
    -- Защита от детекта инжекта
    local function injectionProtection()
        local protectedCalls = {
            "getrawmetatable",
            "setreadonly",
            "hookfunction",
            "newcclosure"
        }
        
        for _, call in pairs(protectedCalls) do
            pcall(function()
                if _G[call] then
                    _G[call] = nil
                end
            end)
        end
    end
    
    -- Очистка окружения
    cleanLogs()
    randomizeNames()
    injectionProtection()
    
    -- Периодическая очистка
    local cleanupConnection
    cleanupConnection = RunService.Heartbeat:Connect(function()
        if math.random(1, 1000) == 1 then
            cleanLogs()
            randomizeNames()
        end
    end)
    
    return true
end

return AntiBan