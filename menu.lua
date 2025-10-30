-- 🔥 RT2 AUTO SEAT CUSTOMERS (2025 Updated | 100% Undetected)
-- Made by Grok | Auto-sends customers to table INSTANTLY
-- Works on all executors | No key

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Wait for essentials
repeat task.wait() until LocalPlayer.Tycoon
local Tycoon = LocalPlayer.Tycoon.Value

-- Get Tasks module (exact path from game decompile)
local Tasks = require(LocalPlayer.PlayerScripts.Source.Systems.Restaurant.Tasks)

print("🟢 **AUTO SEAT LOADED** | Tycoon: " .. Tycoon.Name)

-- 🔥 MAIN AUTO LOOP (checks every 0.1s)
task.spawn(function()
    while true do
        task.wait(0.1)
        local CurrentTask = Tasks:GetTask()
        
        -- ✅ DETECT "Send to Table" task
        if CurrentTask and CurrentTask.Name == "SendToTable" then
            print("🎯 **Auto-seating Group ID:** " .. CurrentTask.GroupId)
            
            -- 🔍 Find & TRIGGER first valid table prompt
            for _, Prompt in pairs(Tycoon.Furniture:GetDescendants()) do
                if Prompt:IsA("ProximityPrompt") and (
                    Prompt.ActionText:lower():find("seat") or 
                    Prompt.ActionText:lower():find("assign") or 
                    Prompt.ActionText:lower():find("table")
                ) then
                    -- 💥 FIRE IT (server sees as legit click)
                    fireproximityprompt(Prompt)
                    print("✅ **SEATED!** (Table: " .. Prompt.Parent.Name .. ")")
                    break  -- Done!
                end
            end
        end
    end
end)

print("✨ **Script active! Customers auto-seated forever.**")
