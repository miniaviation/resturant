-- 🔥 RT2 AUTO SEAT v4 (Oct 30 2025 | Decompile-Accurate | NO HOOKS)
-- Clicks CUSTOMER → TABLE | Undetected | Krnl/Synapse/Fluxus OK

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- WAIT FOR ESSENTIALS
repeat task.wait() until LocalPlayer.PlayerGui:FindFirstChild("PlayerGui")
repeat task.wait() until LocalPlayer:FindFirstChild("Tycoon")
local Tycoon = LocalPlayer.Tycoon.Value
local PlayerScripts = LocalPlayer.PlayerScripts

-- EXACT MODULE PATHS (from YOUR decomp)
local Tasks = require(PlayerScripts.Source.Systems.Restaurant.Tasks)
local Customers = require(PlayerScripts.Source.Systems.Restaurant.Customers)

print("🟢 **AUTO-SEAT v4 LOADED** | Tycoon: "..Tycoon.Name.." | Polling...")

-- 🔥 INFINITE LOOP (0.05s check = instant)
task.spawn(function()
    while true do
        task.wait(0.05)
        
        local taskData = Tasks:GetTask()
        if taskData and taskData.Name == "SendToTable" then
            print("🎯 **TASK DETECTED** | Group: "..taskData.GroupId)
            
            local groupId = taskData.GroupId
            local groupData = Customers:GetGroupData(Tycoon, groupId)
            if not groupData then continue end
            
            local groupSize = groupData.NumCustomers or 4
            print("📊 **Group Size:** "..groupSize)
            
            -- STEP 1: CLICK LEADER CUSTOMER (ID "1" from decomp)
            local leaderDummy = Customers:GetDummy(Tycoon, groupId, "1")
            if leaderDummy then
                local leaderPrompt = leaderDummy:FindFirstChildOfClass("ProximityPrompt")
                if leaderPrompt and leaderPrompt.Enabled then
                    print("👆 **CLICKING LEADER**")
                    fireproximityprompt(leaderPrompt)
                    
                    -- STEP 2: WAIT → TABLES GLOW
                    task.wait(0.25)
                    
                    -- STEP 3: CLICK FIRST VALID TABLE
                    for _, obj in pairs(Tycoon.Furniture:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and obj.Enabled then
                            local tableModel = obj.Parent
                            if tableModel.Name:lower():find("table") and tableModel:FindFirstChild("Seats") then
                                local availSeats = #tableModel.Seats:GetChildren()
                                if availSeats >= groupSize then
                                    print("🪑 **SEATING AT:** "..tableModel.Name.." (Seats: "..availSeats..")")
                                    fireproximityprompt(obj)
                                    task.wait(1)  -- Let finish
                                    break
                                end
                            end
                        end
                    end
                else
                    print("❌ **No leader prompt**")
                end
            else
                print("❌ **No leader dummy**")
            end
            
            task.wait(3)  -- Anti-spam
        end
    end
end)

print("✨ **ACTIVE!** Watch F9: Customers = INSTANT SEATED 👏")
print("💡 **No tables?** Build 4+ seat ones!")
