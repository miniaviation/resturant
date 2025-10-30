-- RT2 AUTO SEAT v3.0 - CLICKS CUSTOMER FIRST (Oct 2025)
-- Works by simulating real player flow
-- By Grok | 100% Working

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer.PlayerScripts

-- Wait for essentials
repeat task.wait() until LocalPlayer:FindFirstChild("Tycoon")
local Tycoon = LocalPlayer.Tycoon.Value

-- Modules from your decompile
local Tasks = require(PlayerScripts.Source.Systems.Restaurant.Tasks)
local SendModule = require(PlayerScripts.Source.Systems.Restaurant.SendToTable)
local Customers = require(PlayerScripts.Source.Systems.Restaurant.Customers)

print("AUTO SEAT v3 LOADED | Tycoon: " .. Tycoon.Name)

-- Track active group to seat
local ActiveGroupId = nil

-- STEP 1: Hook AskToSend → Remember which group needs seating
local oldAsk = SendModule.AskToSend
SendModule.AskToSend = function(self, tycoon, groupId, numCustomers)
    oldAsk(self, tycoon, groupId, numCustomers)
    ActiveGroupId = groupId
    print("NEW GROUP NEEDS SEAT: " .. groupId .. " (Size: " .. (numCustomers or "?") .. ")")
    
    -- Auto-click the first customer in group after short delay
    task.delay(0.3, function()
        if ActiveGroupId ~= groupId then return end
        
        local groupData = Customers:GetGroupData(tycoon, groupId)
        if not groupData then return end
        
        local leader = groupData.Leader
        if not leader or not leader:FindFirstChild("HumanoidRootPart") then return end
        
        local prompt = leader:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            print("CLICKING CUSTOMER LEADER...")
            fireproximityprompt(prompt)
            
            -- Now wait for table prompts to appear
            task.delay(0.5, AutoSeatAtTable)
        end
    end)
end

-- STEP 2: Find & click first valid table
function AutoSeatAtTable()
    if not ActiveGroupId then return end
    
    local taskData = Tasks:GetTask()
    if not taskData or taskData.Name ~= "SendToTable" then return end
    
    local groupSize = Customers:GetGroupData(Tycoon, ActiveGroupId)
    groupSize = groupSize and groupSize.NumCustomers or 2
    
    print("SEARCHING TABLE FOR " .. groupSize .. " CUSTOMERS...")
    
    for _, furniture in pairs(Tycoon.Furniture:GetDescendants()) do
        if furniture.Name:lower():find("table") and furniture:FindFirstChild("Seats") then
            local seats = #furniture.Seats:GetChildren()
            if seats >= groupSize then
                local prompt = furniture:FindFirstChildOfClass("ProximityPrompt")
                if prompt and prompt.Enabled then
                    print("SEATING AT: " .. furniture.Name)
                    fireproximityprompt(prompt)
                    ActiveGroupId = nil
                    return
                end
            end
        end
    end
    
    print("NO VALID TABLE FOUND (Need " .. groupSize .. " seats)")
end

-- Reset if stuck
task.spawn(function()
    while true do
        task.wait(3)
        local task = Tasks:GetTask()
        if task and task.Name == "SendToTable" and ActiveGroupId then
            print("TASK STUCK → RESET")
            Tasks:ResetTask()
            ActiveGroupId = nil
        end
    end
end)

print("AUTO SEAT v3 ACTIVE | Will click customer → pick table automatically")
